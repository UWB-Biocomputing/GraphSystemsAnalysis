%GETH5DATASETSIZE retrieve the size from HDF5 dataset
% 
%   Syntax: getH5datasetSize(h5dir, dataset)
%   
%   Input:  h5dir       - BrainGrid simulation file (.h5)
%           dataset     - name of the dataset of interest
%
%   Output: size        - dataset size (column size for matrix)
%
%   Example: getH5datasetSize('tR_1.0--fE_0.90', 'neuronTypes')

% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Last updated: 11/06/2018
function size = getH5datasetSize(h5dir, dataset)
outfile = [dataset '.tmp'];
if exist(outfile, 'file') == 2
  delete(outfile);
end
diary(outfile)
h5disp([h5dir '.h5'], ['/' dataset]);
diary off

command = ['grep " Size" ' outfile ' | awk ''{print $2}'' | sed ''s/\(.*x\)//g'''];
[status, size] = system(command);
size = str2double(size);
delete(outfile);
end