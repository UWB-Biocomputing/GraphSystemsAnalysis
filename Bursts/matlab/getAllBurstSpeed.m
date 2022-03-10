% GETALLBURSTSPEED get propagation speed for all bursts (unit: neurons/ms)
% Read burst burstOrigins (allBurstOriginN.csv) and call getBurstSpeed 
% 
%   Syntax: [speed, m_speed] = getBurstSpeed(h5dir, id, origin)
%   
%   Input:  
%   h5dir   -   BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%               the entire path is required for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   frame   -   matrix of spike rates of a burst
%   origin  -   burst origin location (neuron number)
%   xloc    -   array containing all x location of each burst
%   yloc    -   array containing all y location of each burst
%
%   Output: 
%   <allBurstSpeedMean.csv>     - mean speed for each burst
%   <allBurstSpeed.csv>         - all speeds between bins 

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 2/22/2022   added documentation and removed unnecessary file reads
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function getAllBurstSpeed(h5dir)
% Input file paths
framesFilePath = [h5dir '/allFrames.mat'];

% Input file data
burstOrigins = csvread([h5dir '/allBurstOriginN.csv']);
frames = load(framesFilePath);
% Get x and y location of neurons
xloc = h5read([h5dir '.h5'], '/xloc');
yloc = h5read([h5dir '.h5'], '/yloc');

% Number of Bursts
nBursts = size(burstOrigins,1);

% Output files
outputFile1 = [h5dir '/allBurstSpeedMean.csv']; fid1 = fopen(outputFile1, 'w');
outputFile2 = [h5dir '/allBurstSpeed.csv'];     fid2 = fopen(outputFile2, 'w');

% calculate the distance between the most spiked neuron and the origin neuron
for iBurst = 1:nBursts
% OLD CODE (reads csv file containing spikerate for each burst)
    % frameDir = [h5file, '/Binned/burst_', num2str(iBurst), '.csv'];
    % frame = csvread(frameDir);
    frame = frames.allFrames{[iBurst]};                     % spikerates of a burst
    % NOTE: We already have the brightest pixel for each image/frame at this point,
    %       because that is what the burst origins input entices
    [S, M] = getBurstSpeed(frame, burstOrigins(iBurst), xloc, yloc);  
    fprintf(fid1, '%.4f\n', M);  
    % TO BE ADDED if [S, M] is nan , output nan for the mean but not the detail
    n = length(S);
    for j = 1:n            % to be remove
        fprintf(fid2, '%.4f,', S(j)); 
    end
     fprintf(fid2, '\n'); 
end
end
