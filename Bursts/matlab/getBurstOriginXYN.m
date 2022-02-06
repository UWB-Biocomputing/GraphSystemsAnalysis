%GETBURSTORIGINXYN return burst origin  (X,Y) and neuron number N
%Read <binnedBurstInfo.csv> and retrieve burst x,y origin by calculating 
%the centroid location of neurons that spiked the most in the first 100 
%timesteps for each burst (brightest pixel in the starting frame)
%
%   Syntax: getBurstOriginXY(h5dir)
%   
%   Input:  
%   h5dir  - BrainGrid result filename
%   the entire path is required for example
%   '/CSSDIV/research/biocomputing/data/tR_1.90--fE_0.90'
%
%   Output: 
%   <allBurstOriginXY.csv> - burst origin (x,y) location for every burst
%   <allBurstOriginN.csv> - burst origin neuron number for every burst

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/18/2018
function [X, Y, N] = getBurstOriginXYN(h5dir, originBin, id)
binnedBurstFramesFilePath = [h5dir, '/Binned/burst_', num2str(id), '.csv'];
binnedBurstFrames = csvread(binnedBurstFramesFilePath);         % flattened image vectors         
xloc = h5read([h5dir '.h5'], '/xloc');          % x location
yloc = h5read([h5dir '.h5'], '/yloc');          % y location
grid = sqrt(length(xloc));                    	% grid size

% find brightest pixel (neuron that spikes the most in a time bin)
brightestPixel = max(binnedBurstFrames(:,originBin));      % originBin starts at 10
while (brightestPixel < 2)                                 
    originBin = originBin + 1;
    % finds largest element in each column starting at column 10
    brightestPixel = max(binnedBurstFrames(:,originBin));  
end

brightestPixelIndexes = find(binnedBurstFrames(:,originBin)==brightestPixel, 2);    % finds and store the brightest pixel index with the bin it is in
nBrightestPixels = length(brightestPixelIndexes);       % number of brightest pixel found
points = zeros(2,nBrightestPixels);                     % stores x and y location of brightest pixels
for iBrightestPixel = 1:nBrightestPixels
    points(1,iBrightestPixel) = xloc(brightestPixelIndexes(iBrightestPixel))+1;   % index starts at 0 in BG
    points(2,iBrightestPixel) = yloc(brightestPixelIndexes(iBrightestPixel))+1;   % matlab start from 1, so +1
end

    % get centroid of neurons with max value
    X = ceil(mean(points(1,:)));          
    Y = ceil(mean(points(2,:)));
    N = (Y-1)*grid + X;
end
