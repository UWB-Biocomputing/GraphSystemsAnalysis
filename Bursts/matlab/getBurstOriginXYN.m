% GETBURSTORIGINXYN return burst origin  (X,Y) and neuron number N
% Read <binnedBurstInfo.csv> and retrieve burst x,y origin by calculating 
% the centroid location of neurons that spiked the most in the first 100 
% timesteps for each burst (brightest pixel in the starting frame)
%
%   Syntax: getBurstOriginXYN(h5dir)
%   
%   Input:  
%   frame   -   matrix of spike rates of a burst
%   xloc    -   array containing all x location of each burst
%   yloc    -   array containing all y location of each burst
%   
%   Return: 
%   X   - x location of origin neuron
%   Y   - y location of origin neuron
%   N   - neuron number of origin neuron
%
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 02/22/2022  added improvement on performance for file reads
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function [X, Y, N] = getBurstOriginXYN(frame, xloc, yloc)
% NOTE: assume square grid size
grid = sqrt(length(xloc));

% starts at 10 to leave room for start of movie before beginning of burst
originBin = 10;

% find brightest pixel (neuron that spikes the most in a time bin)
brightestPixel = max(frame(:,originBin));      % originBin starts at 10
% using 2 as the threshold for brightest pixel 
while (brightestPixel < 2)
    originBin = originBin + 1;
    % finds largest element in each column of a frame, starting at column 10
    brightestPixel = max(frame(:,originBin));
end

% The number of brightest pixel within a column is limited to 2 
% so the mean position do not deviate significantly for situations where there
% are multiple burst happening simutaneously.
% Therefore, we use find here to only get the first 2 index.
brightestPixelIndexes = find(frame(:,originBin)==brightestPixel, 2);           % finds and store the brightest pixel index with the bin it is in

points(1,iBrightestPixel) = xloc(brightestPixelIndexes(iBrightestPixel))+1;     % index starts at 0 in BG
points(2,iBrightestPixel) = yloc(brightestPixelIndexes(iBrightestPixel))+1;     % matlab start from 1, so +1

% get centroid of neurons with max value
X = ceil(mean(points(1,:)));          
Y = ceil(mean(points(2,:)));
N = (Y-1)*grid + X;

end
