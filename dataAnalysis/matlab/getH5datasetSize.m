%GETH5DATASETSIZE retrieve the size from H5 dataset
% 
%   Syntax: getH5datasetSize(h5file, dataset)
%   
%   Input:  h5file - BrainGrid simulation result (.h5)
%           dataset - name of the dataset of interest
%
%   Output: size - dataset size (column size for matrix)
%
%                                   by Jewel Y. Lee (last updated: 2/27/18)
function size = getH5datasetSize(h5file, dataset)
%h5file = 'tR_1.0--fE_0.90_10000';
%dataset = 'spikesProbedNeurons';

outfile = [dataset '.txt'];
if exist(outfile, 'file')==2
  delete(outfile);
end
diary(outfile)
h5disp([h5file '.h5'], ['/' dataset]);
diary off

command = ['grep " Size" ' outfile ' | awk ''{print $2}'' | sed ''s/\(.*x\)//g'''];
[status, size] = system(command);
size = str2num(size);
end
