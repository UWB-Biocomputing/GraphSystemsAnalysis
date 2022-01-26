%GETBINNEDBURSTINFO Identify bursts using binned data and save burst info
%Read BrainGrid result (.h5) and get spikesHistory (spike count for every 
%10ms bin). Identify burst using burst threshold of 0.5 spikes/sec/neuron,
%extract burst information (start/end time, count, width, size, etc)
% 
%   Syntax: getBinnedBurstInfo(h5dir)
%   
%   Input:  
%   h5dir  - BrainGrid simulation file (e.g. tR_1.0--fE_0.90_10000)
%   the entire path is required for example
%   '/CSSDIV/research/biocomputing/data/tR_1.9--fE_0.98'
%
%   Output:  
%   <binnedBurstInfo.csv> - burst metadata

% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Last updated: 11/06/2018
function getBinnedBurstInfo(h5dir)
% h5dir = '/CSSDIV/research/biocomputing/data/tR_1.9--fE_0.98'
nNeurons = length(h5read([h5dir '.h5'], '/neuronTypes')); 
spikeHistory = double(h5read([h5dir '.h5'], '/spikesHistory'));
spikeHistory10msBin = spikeHistory/nNeurons;                        % spikes/neuron per bin                        
% In Kawasaki, F. & Stiber, M. (2014): 
%   - 0.5 spikes/sec/neuron as a threshold for burst detection
%   - for 10ms (0.01s) bin, burst threshold = 0.5x0.01 = 0.005
burstThreashold = 0.005;                                            % burst threashold
binsAboveThreshold = find(spikeHistory10msBin >= burstThreashold);  % find index of bins above threshold
% find burst boundaries, if the bins above the threshold is not next to each other 
% then get their indexes
burstBoundaries = find(diff(binsAboveThreshold) > 1);
nBursts = length(burstBoundaries)+1;                                % number of bursts detected
burstBoundaries = [0; burstBoundaries];                             % boundary condition
burstBoundaries = [burstBoundaries; length(binsAboveThreshold)];    % boundary condition
previousPeak = 0;
% Output file
fid = fopen([h5dir '/allBinnedBurstInfo.csv'], 'w') ;         
fprintf(fid, ['ID,startBin#,endBin#,width(bins),totalSpikeCount,'... 
              'peakBin,peakHeight(spikes),Interval(bins)\n']);
for iBurst = 1:nBursts
    Burst.start = binsAboveThreshold(burstBoundaries(iBurst)+1);    % start bin number
    Burst.ended = binsAboveThreshold(burstBoundaries(iBurst+1));    % end bin number
    Burst.width = (Burst.ended-Burst.start)+1;                      % burst width in bins 
    Burst.count = sum(spikeHistory(Burst.start:Burst.ended));       % total spike count
    [Burst.height, temp] = max(spikeHistory(Burst.start:Burst.ended));    % height of the peak
    Burst.peak = Burst.start+temp-1;            % peak bin (highest spike count)                
    Burst.interval = Burst.peak-previousPeak;      % burst interval in bins
    fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d\n', ...
            iBurst,Burst.start,Burst.ended,Burst.width,Burst.count,Burst.peak,Burst.height,Burst.interval);   
    previousPeak = Burst.peak;
end
fclose(fid);
