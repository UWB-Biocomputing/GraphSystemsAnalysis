%READSPIKESPROBEDNEURONS read chunk of spikesProbedNeurons dataeset
%Given BrainGrid simulation result in HDF5 format, read neuron spiking 
%information by assigning chunk range. For example, to see the first 10 
%spiking for neuron 7~9: readSpikesProbedNeurons(h5file,7,9,1,10)
%   
%   Syntax: P = readSpikesProbedNeurons(h5file,s_idx,e_idx,s_col,e_col)
%   
%   Input:  s_idx   - start neuron number (> 1)
%           e_idx   - last neuron number (< number of neurons)
%           s_col   - start column (> 1)
%           e_col   - end column (< size of spikesProbedNeurons dataset)
%
%   Output: P       - spikeProbedNeuron data chunk matrix where each row is 
%                     a neuron, columns values are its spike timings (in 
%                     time steps)

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/17/2018
function P = readSpikesProbedNeurons(h5file, s_idx, e_idx, s_col, e_col)
% h5file = 'tR_1.0--fE_0.90_10000';
dataset = 'spikesProbedNeurons';
size = getH5datasetSize(h5file, dataset);
n_neurons = length(hdf5read([h5file '.h5'], 'neuronTypes')); 
 
if s_col < 1 || e_col > size
    error('Error: Firing time range: 1 ~ %d', size)
elseif s_col > e_col
    error('Wrong input value given')
end

if s_idx < 1 || e_idx > n_neurons
    error('Error: Neuron index range: 1 ~ %d', n_neurons)
elseif s_idx > e_idx
    error('Wrong input value given')
end
P = h5read([h5file '.h5'], ['/' dataset],...
           [s_idx,s_col],[e_idx-s_idx+1, e_col-s_col+1]);
end
