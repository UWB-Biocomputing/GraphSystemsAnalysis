%GETALLBINNEDBURSTFRAMES make burst movies frames using binned burst info 
%  - need BrainGrid result (.h5), <binnedBurstInfo.csv> 
%  - save spike info for every 10 ms (100 time step) into one frame
%  - output <burst#.csv> file for each burst
function getAllBinnedBurstFrames(h5file)
% h5file = 'tR_1.0--fE_0.90_10000';
head = 5;                       % number of bins before burst start bin
tail = 5;                       % number of bins after burst end bin
binSize = 100;                  % number of timesteps per bin
bbInfo = csvread([h5file '/binnedBurstInfo.csv'],1,1);    % burst metadata
n_burst = length(bbInfo);                       % total number of bursts
maxSpike = getH5datasetSize(h5file, 'spikesProbedNeurons');
% ------------------------------------------------------------------------
% Get spike info from spikesProbedNeurons for each burst
% - every column in "frames" is a flatten image vector 
% - which represents a 100x100 image (Matlab is column-major) 
% - pixel value represent spike count of the same neuron within a frame
% - (NOTE: bin size = 10 ms, time step size = 0.1 ms)
% ------------------------------------------------------------------------
for i = 1:n_burst
    s_bin = (bbInfo(i,1)-head);          % start bin# -> timestep
    e_bin = (bbInfo(i,2)+tail);          % end bin# -> timestep  
    frames = getBinnedBurstFrames(h5file, s_bin, e_bin, binSize, maxSpike); 
    csvwrite(['Binned/burst', num2str(i) '.csv'], frames);
    fprintf('done with burst %d\n', i);       % for debugging 
end
