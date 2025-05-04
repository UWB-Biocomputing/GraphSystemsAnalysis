'''
GETSPIKESHISTORY Generate a single array with the binned spike counts

This function reads the Graphitti simulation h5 output.

Input:
datasetName - Graphitti dataset the entire path can be used; for example
              '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

Output:
  - The spikesHistory dataset is added to the input h5 file

Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)
Last updated: 05/03/2025
'''

import h5py
import numpy as np
import sys
import time


def getSpikesHistory(h5dir): 
    # Set configuration parameters from the simulation
    numEpochs = 600
    epochDuration = 100 # seconds
    nNeurons = 10000

    # prepare the output
    nBins = numEpochs * epochDuration * 100 # 10ms timestep bins
    arr = np.zeros(nBins)
    raw_spikes = np.array([])
        
    # concatenate all neuron spike times into one array
    with h5py.File(h5dir + '.h5', 'r+') as f:
        print('Get raw spike usage in one array')
        for n in f.keys():
            if n.startswith("Neuron_") and n in f:
                n_arr = np.array(f[n])
                n_div = (n_arr / 100) # bins each spiketime by rounding the integer down

                raw_spikes = np.append(raw_spikes, n_div)

        # save the raw_spikes array in case of failure
        # np.save(h5dir + '/raw_spikes.npy', raw_spikes)
        # raw_spikes = np.load('raw_spikes.npy') # Load raw spikes array

        # Get count of spikes per timestep
        print('Get spike history count')
        unique, counts = np.unique(raw_spikes, return_counts=True)
        print('Number of unique values: ' + str(len(unique)))

        sH = f.create_dataset("spikesHistory", data=arr)

        # add counts to the spike history dataset
        print('Adding unique counts to spikesHistory')
        for i in range(len(unique)):
            u = int(unique[i])
            sH[u] = counts[i]


if __name__ == "__main__": 
    # example execution: python ./getSpikesHistory.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000
    h5dir = sys.argv[1]

    start = time.time()
    getSpikesHistory(h5dir) 
    end = time.time()

    elapsed_time = end - start
    print('Elapsed time: ' + str(elapsed_time) + ' seconds')