%GETBINNEDBURSTINFO Identify bursts using binned data and save burst info
%Read BrainGrid result (.h5) and get spikesHistory (spike count for every 
%10ms bin). Identify burst using burst threshold of 0.5 spikes/sec/neuron,
%extract burst information (start/end time, count, width, size, etc)
% 
%   Syntax: getBinnedBurstInfo(h5file)
%   
%   Input:  
%   h5file  - BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%
%   Output: 
%   <binnedBurstInfo.csv> - burst metadata

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/17/2018
function getBinnedBurstInfo(h5file)

n_neurons = length(hdf5read([h5file '.h5'], 'neuronTypes')); 
SH = double(hdf5read([h5file '.h5'], 'spikesHistory'));
SH10ms = SH/n_neurons;                          % spikes/neuron per bin                        
% In Kawasaki, F. & Stiber, M. (2014): 
%   - 0.5 spikes/sec/neuron as a threshold for burst detection
%   - for 10ms (0.01s) bin, burst threshold = 0.5x0.01 = 0.005
b_threash = 0.005;                              % burst threashold
b_bins = find(SH10ms >= b_threash);             % find bins > threshold
b_boundary = find(diff(b_bins) > 1);            % find burst boundaries
n_bursts = length(b_boundary)+1;                % total bursts
b_boundary = [0; b_boundary];                   % boundary condition
b_boundary = [b_boundary; length(b_bins)];      % boundary condition
prev_peak = 0;
% Output file
fid = fopen([h5file '/binnedBurstInfo.csv'], 'w') ;         
fprintf(fid, ['ID,startBin#,endBin#,width(bins),totalSpikeCount,'... 
              'peakBin,peakHeight(spikes),Interval(bins)\n']);
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
