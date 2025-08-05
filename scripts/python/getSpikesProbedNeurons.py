'''
GETSPIKESPROBEDNEURONS Generate a matrix of numNeurons * maxSpikesPerNeuron

This function reads the Graphitti simulation h5 output. Each column index 
corresponds to that neuron number. The zero-padded column contains all 
times when the neuron spiked. 

Input:
datasetName - Graphitti dataset the entire path can be used; for example
              '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

Output:
  - The spikesProbedNeurons dataset is added to the input h5 file

Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)
Last updated: 05/03/2025
'''

import h5py
import numpy as np
import sys
import time


def getSpikesProbedNeurons(h5dir): 
    maxSpikes = 0
    totalNeurons = 10000
        
    with h5py.File(h5dir + '.h5', 'r+') as f:
        # get the max spikes per array
        for n in f.keys():
            if n.startswith("Neuron_") and n in f:
                n_len = len(f[n])
                maxSpikes = n_len if n_len > maxSpikes else maxSpikes

        print('Max Spikes: ' + str(maxSpikes))

        spikes = np.zeros((maxSpikes, totalNeurons))
        # concatenate neuron arrays with zero padding
        for n in range(totalNeurons):
            key = "Neuron_" + str(n)
            if key in f:
                n_arr = np.array(f[key])
                n_t = n_arr[:, np.newaxis]
                n_len = len(n_t)
                spikes[0:n_len, n] = n_t[:,0]

        sPN = f.create_dataset("spikesProbedNeurons", data=spikes)
    
    
if __name__ == "__main__": 
    # example execution: python ./getSpikesHistory.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000
    h5dir = sys.argv[1]
    
    start = time.time()
    getSpikesProbedNeurons(h5dir) 
    end = time.time()

    elapsed_time = end - start
    print('Elapsed time: ' + str(elapsed_time) + ' seconds')