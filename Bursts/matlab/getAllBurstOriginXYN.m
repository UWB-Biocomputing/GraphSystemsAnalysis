% GETALLBURSTORIGINXYN Get approximate (X,Y) and N of burst initiation 
% Read <burstInfo.csv> and get burst origin locations for all bursts
% by calling getBurstOriginXYN()
%
%   Syntax: getBurstOriginXY(h5dir)
%   
%   Input:  
%   h5dir   -   BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%               the entire path is required for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Output: 
%   <allBurstOriginXY.csv>  - burst origin (x,y) location for every burst
%   <allBurstOriginN.csv>   - burst origin neuron number for every burst
%   
%
%
%   
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 02/22/2022 added improvement on performance for file reads
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function getAllBurstOriginXYN(h5dir)
% Input file paths
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];
framesFilePath = [h5dir 'allFrames.mat'];

% Input file data
burstInfo = csvread(binnedBurstInfoFilePath,1,1);
frames = load(framesFilePath);

% Number of bursts
nBursts = size(burstInfo,1);             

% Output files
outputFile1 = [h5dir '/allBurstOriginN.csv']; fid1 = fopen(outputFile1, 'w');
outputFile2 = [h5dir '/allBurstOriginXY.csv']; fid2 = fopen(outputFile2, 'w');

% Get x and y location of neurons
xloc = h5read([h5dir '.h5'], '/xloc');
yloc = h5read([h5dir '.h5'], '/yloc');

% Calculate burst origin based on spikerates at each x and y location     
for iBurst = 1:nBursts
    frame = frames.allFrames{[iBurst]};                 % spikerates
    % Gets centroid of neurons with the brightest pixel (highest spikerate)
    % by calculating the mean of neurons that produced the most spikes within 10ms.
    % What returns are the X and Y location and Neuron number
    [X, Y, N] = getBurstOriginXYN(frame, xloc, yloc);
    fprintf(fid1, '%d\n', N);  
    fprintf(fid2, '%d, %d\n', X, Y);  
end
fclose(fid1);
fclose(fid2);
end
