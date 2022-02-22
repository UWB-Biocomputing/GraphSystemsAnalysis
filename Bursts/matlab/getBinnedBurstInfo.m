% GETBINNEDBURSTINFO Identify bursts using binned data and save burst info
%
% This function reads the BrainGrid result (.h5 file), specifically
%   spikesHistory (contains spike Count for every 10ms bin; it is also the name of the dataset being read), 
%   identify burst using burst threshold of 0.5 spikes/sec/neuron,
%   calculate burst information from those bins above the threshold,
%   and store them in allBinnedBurstInfo.csv.
%
% List below are those burst information and how they are calculated:
%   ID                  - the burst ID
%   startBin#           - The starting bin number is the bin that is above the threshold.
%   endBin#             - The ending bin number is the next bin that is above the threshold.
%   width(bins)         - With the starting/ending bin number, the difference is calculated as the width 
%                         representing the number of bins in between each burst above the threshold.
%   totalSpikeCount     - the sum of all the spikesPerBin between the starting and ending bin number
%   peakBin             - startBin# + peakHeightIndex(index of the bin with the peakHeight) + 1
%   peakHeight(spikes)  - calculated by finding the bin with the highest spike count between each burst
%   Interval(bins)      - difference between current peakHeight and previous peakHeight
%                       - previous peakHeight is initialized as 0
% 
% 
%   Syntax: getBinnedBurstInfo(h5dir)
%   
%   Input:  
%   h5dir   -   BrainGrid simulation file (e.g. tR_1.0--fE_0.90_10000)
%               the entire path is required for example
%               '/CSSDIV/research/biocomputing/data/tR_1.9--fE_0.98'
%
%   Output:  
%   <allbinnedBurstInfo.csv> - burst metadata
%   the columns of the csv are named in the order of this list
%   ID, startBin#, endBin#, width(bins), totalSpikeCount, peakBin, peakHeight(spikes), Interval(bins)
%
% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Last updated: 02/10/2022 added Documentation, cleaned redundant code
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function getBinnedBurstInfo(h5dir)
% line below is used for testing
% h5dir = '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'        

% The h5info call below for neuronTypesFileInformation will get file information like:
%   Filename    - contains the filepath; it would be the same as h5dir
%   Name        - in this case is neuronTypes, the name of the field you want
%   Datatype    - array of structures describing datatypes stored in neuronTypes
%               - this struct has Name, Class, Type, Size, Attributes as its fields
%   Dataspace   - array of structures describing the size of the dataset
%               - this struct has Size, MaxSize, Type as its fields
neuronTypesFileInformation = h5info([h5dir '.h5'],'/neuronTypes');

nNeurons = neuronTypesFileInformation.Dataspace.Size;               % gets size of the array neuronTypes
% Assume each bin is 10ms
spikesPerBin = double(h5read([h5dir '.h5'], '/spikesHistory'));
spikesPerNeuronPerBin = spikesPerBin/nNeurons;                      % spikes/neuron per bin 

% In Kawasaki, F. & Stiber, M. (2014): 
%   - 0.5 spikes/sec/neuron as a threshold for burst detection
%   - for 10ms (0.01s) bin, burst threshold = 0.5x0.01 = 0.005
adjustedBurstThreshold = 0.005;                                                % burst threashold adjusted for 10ms Bin
binsAboveThreshold = find(spikesPerNeuronPerBin >= adjustedBurstThreshold);    % find index of bins above threshold
% find burst boundaries, if the bins above the threshold is not next to each other 
% then get their indexes
burstBoundaries = find(diff(binsAboveThreshold) > 1);               % contain indexes of bins above the threshold
nBursts = length(burstBoundaries)+1;                                % number of bursts detected
burstBoundaries = [0; burstBoundaries];                             % boundary condition
burstBoundaries = [burstBoundaries; length(binsAboveThreshold)];    % boundary condition
previousPeak = 0;

% Output file
fid = fopen([h5dir '/allBinnedBurstInfo.csv'], 'w') ;         
fprintf(fid, ['ID,startBin#,endBin#,width(bins),totalSpikeCount,'... 
              'peakBin,peakHeight(spikes),Interval(bins)\n']);
for iBurst = 1:nBursts
    startBinNum = binsAboveThreshold(burstBoundaries(iBurst)+1);        % start bin number
    endBinNum = binsAboveThreshold(burstBoundaries(iBurst+1));          % end bin number
    width = (endBinNum - startBinNum)+1;                                % burst width in bins 
    totalSpikeCount = sum(spikesPerBin(startBinNum:endBinNum));         % total spike count
    [peakHeight, peakHeightIndex] = max(spikesPerBin(startBinNum:endBinNum));      % height of the peak
    peakBin = startBinNum+peakHeightIndex-1;                                       % peak bin (highest spike Count)                
    burstPeakInterval = peakBin-previousPeak;                           % burst interval in bins
    fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d\n', ...
            iBurst,startBinNum,endBinNum,width,totalSpikeCount,peakBin,peakHeight,burstPeakInterval);   
    previousPeak = peakBin;
end
fclose(fid);
