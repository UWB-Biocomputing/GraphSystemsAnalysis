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
% Last updated: 02/22/2022 added improvement on performance for file reads
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function getAllBurstOriginXYN(h5dir)
% Input file paths
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];    
framesFilePath = [h5dir '/allFrames.mat'];      % array of matrixes containing the spike rates

% Input file data
burstInfo = csvread(binnedBurstInfoFilePath,1,1);   % only used to get number of burst (could be removed if there's a way to do it without csvread)
% This is a cell array containing spike rate of each burst. The spike rates are stored in
% a matrix where the columns corresponds to each neuron and row corresponds to the timestep.
% NOTE: variable name for accessing the spike rates of specific burst is allFrames.
% example: frames.allFrames{burst number}
frames = load(framesFilePath);                      

% Number of bursts
nBursts = size(burstInfo,1);             

% Output files
outputFile1 = [h5dir '/allBurstOriginN.csv']; fid1 = fopen(outputFile1, 'w');       % array containing origin neuron
outputFile2 = [h5dir '/allBurstOriginXY.csv']; fid2 = fopen(outputFile2, 'w');      % array containing x and y location of origin neuron

% Get x and y location of neurons
xloc = h5read([h5dir '.h5'], '/xloc');
yloc = h5read([h5dir '.h5'], '/yloc');

% Calculate burst origin based on spikerates at each x and y location     
for iBurst = 1:nBursts
    frame = frames.allFrames{iBurst};                 % spikerates
    
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
