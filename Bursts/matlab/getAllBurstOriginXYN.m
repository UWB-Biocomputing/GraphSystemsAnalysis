% GETALLBURSTORIGINXYN Get approximate (X,Y) and N of burst initiation 
% Read <burstInfo.csv> and get burst origin locations for all bursts
% by calling getBurstOriginXYN()
%
%   Syntax: getAllBurstOriginXYN(h5dir)
%   
%   Input:  
%   h5dir   -   BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%               the entire path is required for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Input for helper fuction getBurstOriginXYN
%   frame   -   matrix of spike rates of a burst
%   xloc    -   array containing all x location of each burst
%   yloc    -   array containing all y location of each burst
%
%   Output: 
%   <allBurstOriginXY.csv>  - burst origin (x,y) location for every burst
%   <allBurstOriginN.csv>   - burst origin neuron number for every burst
%   
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Updated: 02/22/2022 added improvement on performance for file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Updated: May 2023 minor tweaks
% Updated by: Michael Stiber

function getAllBurstOriginXYN(h5dir)
% Input file paths
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];    
framesFilePath = [h5dir '/allFrames.mat'];      % array of matrixes containing the spike rates

% Input file data
burstInfo = csvread(binnedBurstInfoFilePath,1,1);   % only used to get number of burst (could be removed if there's a way to do it without csvread)
% This is a cell array containing spike rate of each burst. The spike rates are stored in
% a matrix where the rows correspond to each neuron and columns corresponds to the time bin.
% NOTE: variable name for accessing the spike rates of specific burst is allFrames.
% example: allFrames{burst number}
load(framesFilePath, 'allFrames');

% Number of bursts
nBursts = size(burstInfo,1);             

% Output files
originFileName = [h5dir '/allBurstOrigin.csv'];
originFile = fopen(originFileName, 'w');

% Get x and y location of neurons
xlocs = h5read([h5dir '.h5'], '/xloc');
ylocs = h5read([h5dir '.h5'], '/yloc');

% Calculate burst origin based on spikerates at each x and y location     
for iBurst = 1:nBursts
    frame = allFrames{iBurst};  % Spike counts for each neuron and each bin in burst

    % Gets centroid of neurons with the highest spike count
    % What returns are the X and Y location and Neuron number
    [x, y, n] = getBurstOriginXYN(frame, xlocs, ylocs);
    fprintf(originFile, '%d, %d, %d\n', x, y, n);
end
fclose(originFile);
end
