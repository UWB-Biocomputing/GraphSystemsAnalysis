%READSPIKEPROBEDNEURONSCHUNK read chunk of spikesProbedNeurons dataeset
%   Given BrainGrid simulation result in HDF5 format, read dataset 
%   "spikesProbedNeurons" chunk by chunk to avoid matlab memory issues 
%   when handling large dataset, return a matrix P.
%   
%   
%   Syntax: P = readSpikesProbedNeuronsChunk(h5file,begin,ended)
%   
%   Input:  begin - 1st column for the chunk
%           ended - last column for the chunk
%
%   Output: P - spikeProbedNeuron data chunk matrix where each row is a 
%           neuron, columns values are its spike timings (in time steps)
%
%                                   by Jewel Y. Lee (last updated: 2/27/18)                                    
function P = readSpikesProbedNeuronsChunk(h5file, begin, ended)

dataset = 'spikesProbedNeurons';
size = getH5datasetSize(h5file, dataset);
if ended > size || begin < 1
    error('Exceed matrix dimention')
elseif begin > ended
    error('Wrong dimention given')
end

Neurons = double((hdf5read([h5file '.h5'], 'probedNeurons'))'); 
n = length(Neurons); 
cols = ended-begin+1;
s = 1;
P = zeros(n,cols);
P(:,s:cols) = h5read([h5file '.h5'], ['/' dataset], [1,begin],[n,cols]);

end