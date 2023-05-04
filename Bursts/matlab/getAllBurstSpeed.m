% GETALLBURSTSPEED get propagation speed for all bursts (unit: neurons/ms)
% Read burst burstOrigins (allBurstOriginN.csv) and call getBurstSpeed 
% 
%   Syntax: [speed, m_speed] = getBurstSpeed(h5dir, id, origin)
%   
%   Input:  
%   h5dir   -   Graphitti result filename (e.g. tR_1.0--fE_0.90)
%               the entire path may be required, for example
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
% Updated: 2/22/2022   added documentation and removed unnecessary file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Updated: May 2023 minor tweaks
% Updated by: Michael Stiber

function getAllBurstSpeed(h5dir)

% Get origin neurons
burstOrigins = csvread([h5dir '/allBurstOriginN.csv']);
% Get binned neuron spike counts
frames = load([h5dir '/allFrames.mat']);
% Get x and y location of neurons
xlocs = h5read([h5dir '.h5'], '/xloc');
ylocs = h5read([h5dir '.h5'], '/yloc');

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
    frame = frames.allFrames{iBurst}; % per-neuron spike counts for this burst
    % NOTE: We already have the brightest pixel for each image/frame at this point,
    %       because that is what the burst origin is
    [S, M] = getBurstSpeed(frame, burstOrigins(iBurst), xlocs, ylocs);  
    fprintf(fid1, '%.4f\n', M);  
    % TO BE ADDED if [S, M] is nan , output nan for the mean but not the detail
    n = length(S);
    for j = 1:n            % to be remove
        fprintf(fid2, '%.4f,', S(j)); 
    end
     fprintf(fid2, '\n'); 
end
end
