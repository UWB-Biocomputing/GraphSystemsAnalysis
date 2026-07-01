'''
GETBINNEDBURSTSPIKES Python implementation of GETBINNEDBURSTSPIKES.m:
    GETBINNEDBURSTSPIKES Get spikes within every burst and save as flattened images of arrays
    of bursts. These are the results of "spike train binning", mentioned in lee-thesis18 Figure 4.1.
    Spike train binning adds up the binary values for every. 
    Read BrainGrid result dataset "spikesProbedNeurons" to retrieve location 
    of each spike that happended within a burst, and save as flatten image arrays.

    Example of flattened image arrays in a 5x5 matrix:
        1 1 2 0 1                       
        1 2 2 1 1
        1 3 2 1 0
        2 2 2 3 1
        0 1 3 2 2
    Each cell in a matrix this function output represents a pixel in which the number indicates how bright it is
    with 5 being the highest value. The values in each cell is the result of "spike train binning" (this functions main algorithm)
    This value can be understood as sum of all spike rate within 100 time step at that specific
    x and y location.  

    Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
    Updated: 02/22/2022  added documentation and changed output filetype to a single .mat file
    Updated by: Vu T. Tieu (vttieu1995@gmail.com)
    Updated: May 2023 minor tweaks
    Updated by: Michael Stiber

Syntax: getBinnedBurstSpikes(h5dir)

Input:
datasetName - Graphitti dataset the entire path can be used; for example
              '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

Output:
  - allFrames.npz - collection of flattened image arrays of a burst 

Author: Marina Rosenwald (marinarosenwald@gmail.com)
Last updated: 12/16/2025
'''

import h5py
import numpy as np
import os
import sys
import time

def getBinnedBurstSpikes(h5dir, n_neurons=10000, head=10, tail=0, binSize=10.0, timeStepSize=0.1):

    timeStepsPerBin = int(binSize / timeStepSize) 

    print("Starting read of spikes from HDF5 file...")
    with h5py.File(f"{h5dir}.h5", "r") as f:
        spikesProbedNeurons = f['/spikesProbedNeurons'][:]  
    print("done")

    burstInfoPath = os.path.join(h5dir, "allBinnedBurstInfo.csv")
    burstInfo = np.loadtxt(burstInfoPath, delimiter=",", skiprows=1, usecols=(1,2,3,4,5,6,7))
    nBursts = burstInfo.shape[0]

    allFrames = []

    print("Starting burst analysis...")
    for iBurst in range(nBursts):
        burstStartBinNum = int(burstInfo[iBurst,0])
        burstEndBinNum   = int(burstInfo[iBurst,1])
        width            = int(burstInfo[iBurst,2])

        startingTimeStep = (burstStartBinNum - head + 1) * timeStepsPerBin
        endingTimeStep   = (burstEndBinNum + tail) * timeStepsPerBin

        frame = np.zeros((n_neurons, width + head + tail), dtype=np.uint16)

        for jNeuron in range(n_neurons):
            neuronSpikes = spikesProbedNeurons[:, jNeuron]
            spike_mask = (neuronSpikes >= startingTimeStep) & (neuronSpikes <= endingTimeStep)
            spike_times = neuronSpikes[spike_mask]
            for curSpikeTime in spike_times:
                bin_idx = int((curSpikeTime - startingTimeStep) / timeStepsPerBin)
                if 0 <= bin_idx < frame.shape[1]:
                    frame[jNeuron, bin_idx] += 1

        allFrames.append(frame)
        print(f"\tdone with burst {iBurst+1}/{nBursts}")

    np.savez(os.path.join(h5dir, "allFrames.npz"), *allFrames)
    print(f"Saved allFrames.npz with {len(allFrames)} bursts and {n_neurons} neurons per frame.")

if __name__ == "__main__": 
    # example execution: python ./getBinnedBurstSpikes.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000
    h5dir = sys.argv[1]
    
    start = time.time()
    getBinnedBurstSpikes(h5dir)
    end = time.time()

    elapsed_time = end - start
    
    
    print('Elapsed time: ' + str(elapsed_time) + ' seconds')
