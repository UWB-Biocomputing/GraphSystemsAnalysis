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

% Get origins
burstOrigins = csvread([h5dir '/allBurstOrigin.csv']);
% Get binned neuron spike counts
load([h5dir '/allFrames.mat'], 'allFrames');
% Get x and y location of neurons
xlocs = double(h5read([h5dir '.h5'], '/xloc'));
ylocs = double(h5read([h5dir '.h5'], '/yloc'));

% Number of Bursts
nBursts = size(burstOrigins,1);

% Output files
outputFile1 = [h5dir '/allBurstSpeedMean.csv']; meanFile = fopen(outputFile1, 'w');
outputFile2 = [h5dir '/allBurstSpeed.csv'];     speedsFile = fopen(outputFile2, 'w');

% calculate the distance between the most spiked neuron and the origin neuron
for iBurst = 1:nBursts
    frame = allFrames{iBurst}; % per-neuron spike counts for this burst
    % NOTE: We already have the brightest pixel for each image/frame at this point,
    %       because that is what the burst origin is
    fprintf('Processing burst %d\n', iBurst);
    [S, m] = getBurstSpeed(frame, burstOrigins(iBurst,3), xlocs, ylocs);  
    fprintf(meanFile, '%.4f\n', m);  
    % TODO if [S, m] is nan , output nan for the mean but not the detail
    fprintf(speedsFile, '%.4f, ', S); 
    fprintf(speedsFile, '\n'); 
end
end
