'''
GETBINNEDBURSTINFO Python implementation of GETBINNEDBURSTINFO.m:
    GETBINNEDBURSTINFO Identify bursts using binned data and save burst info

    This function reads the BrainGrid result (.h5 file), specifically
    spikesHistory (contains spike Count for every 10ms bin; it is also the name of the dataset being read), 
    identify burst using burst threshold of 0.5 spikes/sec/neuron,
    calculate burst information from those bins above the threshold,
    and store them in allBinnedBurstInfo.csv.

    List below are those burst information and how they are calculated:
    ID                  - the burst ID
    startBin#           - The starting bin number is the bin that is above the threshold.
    endBin#             - The ending bin number is the next bin that is above the threshold.
    width(bins)         - With the starting/ending bin number, the difference is calculated as the width 
                            representing the number of bins in between each burst above the threshold.
    totalSpikeCount     - the sum of all the spikesPerBin between the starting and ending bin number
    peakBin             - startBin# + peakHeightIndex(index of the bin with the peakHeight) + 1
    peakHeight(spikes)  - calculated by finding the bin with the highest spike count between each burst
    Interval(bins)      - difference between current peakHeight and previous peakHeight
                        - previous peakHeight is initialized as 0


    Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
    Last updated: 02/10/2022 added Documentation, cleaned redundant code
    Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

Syntax: getBinnedBurstInfo(h5dir)
    
Input:
datasetName - Graphitti dataset the entire path can be used; for example
              '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

Output:
  - <allbinnedBurstInfo.csv> - burst metadata. The columns of the csv are:
                               burst ID, startBin#, endBin#, width(bins),
                               totalSpikeCount, peakBin,
                               peakHeight(spikes), Interval(bins)

Author: Marina Rosenwald (marinarosenwald@gmail.com)
Last updated: 12/16/2025    
'''


import h5py
import numpy as np
import csv
import os
import sys
import time

def getBinnedBurstInfo(datasetName, adjustedBurstThreshold=0.005):

    with h5py.File(f"{datasetName}.h5", "r") as f:
        if '/neuronTypes' in f:
            nNeurons = f['/neuronTypes'].shape[0]
        elif '/spikesProbedNeurons' in f:
            nNeurons = f['/spikesProbedNeurons'].shape[0]
        else:
            raise KeyError("No neuronTypes or spikesProbedNeurons dataset found")

        spikesPerBin = f['/spikesHistory'][:].astype(float)
    nNeurons=10000
    spikesPerNeuronPerBin = spikesPerBin / nNeurons
    binsAboveThreshold = np.where(spikesPerNeuronPerBin >= adjustedBurstThreshold)[0]

    if len(binsAboveThreshold) == 0:
        print("No bursts detected above threshold")
        return

    burstBoundaries = np.where(np.diff(binsAboveThreshold) > 1)[0]
    burstBoundaries = np.concatenate(([0], burstBoundaries, [len(binsAboveThreshold) - 1]))
    nBursts = len(burstBoundaries) - 1

    print(nBursts)

    previousPeak = 0
    out_path = os.path.join(datasetName, "allBinnedBurstInfo.csv")
    with open(out_path, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow([
            "ID", "startBin#", "endBin#", "width(bins)", "totalSpikeCount",
            "peakBin", "peakHeight(spikes)", "Interval(bins)"
        ])
        for iBurst in range(nBursts):
            startBinNum = binsAboveThreshold[burstBoundaries[iBurst]]
            endBinNum   = binsAboveThreshold[burstBoundaries[iBurst + 1]]
            burstSlice  = spikesPerBin[startBinNum:endBinNum+1]
            width = (endBinNum - startBinNum) + 1

            if burstSlice.size == 0:
                continue 
            totalSpikeCount = np.sum(burstSlice)
            peakHeightIndex = np.argmax(burstSlice)
            peakHeight = burstSlice[peakHeightIndex]
            peakBin = startBinNum + peakHeightIndex
            burstPeakInterval = peakBin - previousPeak
            writer.writerow([
                iBurst + 1, startBinNum, endBinNum, width,
                int(totalSpikeCount), peakBin, int(peakHeight), burstPeakInterval
            ])
            previousPeak = peakBin

    
    print(f"Saved burst info to {out_path}")

if __name__ == "__main__": 
    # example execution: python ./getBinnedBurstSpikes.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000
    h5dir = sys.argv[1]
    
    start = time.time()
    getBinnedBurstInfo(h5dir)
    end = time.time()

    elapsed_time = end - start
    
    
    print('Elapsed time: ' + str(elapsed_time) + ' seconds')
