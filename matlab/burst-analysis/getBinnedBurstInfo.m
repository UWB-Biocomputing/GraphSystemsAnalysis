%GETBINNEDBURSTINFO Identify bursts using binned data and save burst info
%Read BrainGrid result in HDF5 file format and get spikesHistory (spike 
%count in every 10ms bin). Identify burst using burst threshold of 0.5,
%and get burst information (start/end time, count, width, size, etc)
% 
%   Syntax: getBinnedBurstInfo(h5file)
%   
%   Input:  
%   h5file  - BrainGrid simulation result (.h5)
%
%   Output: 
%   <binnedBurstInfo.csv> - burst metadata

%Author: Jewel Y. Lee (jewel87@uw.edu) 3/25/2018 last updated.
function getBinnedBurstInfo(h5file)
% ------------------------------------------------------------------------
% Read from input data and open output file
% - spikesHistory = spike count in each 10ms bins
% - neuronTypes = neuron types for every neuron
% ------------------------------------------------------------------------
% h5file = 'tR_1.0--fE_0.90_10000';
SH = double(hdf5read([h5file '.h5'], 'spikesHistory')); 
N = uint8(hdf5read([h5file '.h5'], 'neuronTypes')); 
n_neurons = length(N);                          % number of neurons  
SH10ms = SH/n_neurons;                          % spikes/neuron in 10 ms
fid = fopen('binnedBurstInfo.csv', 'w') ;         
fprintf(fid, ['ID,startBin#,endBin#,width(bins),totalSpikeCount,'... 
              'peakBin,peakHeight(spikes),Interval(bins)\n']);
% ------------------------------------------------------------------------
% Identify Bursts: find the number of bursts and burst boundaries
% ------------------------------------------------------------------------
% In Kawasaki, F., & Stiber, M. (2014): 
%   - 0.5 spikes/sec/neuron as a threshold for burst detection
%   - for 10ms (0.01s) bin, burst threshold = 0.5x0.01 = 0.005
b_threash = 0.005;                              % burst threashold
b_bins = find(SH10ms >= b_threash);             % find bins > threshold
b_boundary = find(diff(b_bins) > 1);            % find burst boundaries
n_bursts = length(b_boundary)+1;                % total bursts
b_boundary = [0; b_boundary];                   % boundary condition
b_boundary = [b_boundary; length(b_bins)];      % boundary condition
prev_peak = 0;
for i = 1:n_bursts
    b.id = i;                                       % burst ID
    b.start = b_bins(b_boundary(i)+1);              % start bin number
    b.ended = b_bins(b_boundary(i+1));              % end bin number
    b.width = (b.ended-b.start)+1;                  % burst width in bins 
    b.count = sum(SH(b.start:b.ended));             % total spike count
    [b.height, temp] = max(SH(b.start:b.ended));    % height of the peak
    b.peak = b.start+temp-1;            % peak bin (highest spike count)                
    b.interval = b.peak-prev_peak;      % burst interval in bins
    fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d\n', ...
            i,b.start,b.ended,b.width,b.count,b.peak,b.height,b.interval);   
    prev_peak = b.peak;
end
fclose(fid);
