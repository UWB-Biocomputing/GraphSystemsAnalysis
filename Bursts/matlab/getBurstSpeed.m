% GETBURSTSPEED return burst propagation speed (unit: neurons/ms)
% Read burst frame (from getBurstSpikes) and calculate propagation speed by
% finding the distance between the most-spiked-neuron (brightest pixel in 
% the frame) and origin-neuron, this distance divided by number of bins away 
% from origin bin (default is 10) is the burst speed. 
% 
%   Syntax: [speed, m_speed] = getBurstSpeed(h5file, id, origin)
%   
%   Input:  
%   frame   -   matrix of spike rates of a burst
%   origin  -   burst origin location (neuron number)
%   xloc    -   array containing all neuron x locations
%   yloc    -   array containing all neuron y locations
%   
%   Return: 
%   speed   - propagation speed for every bin
%   m_speed - mean burst speed
%
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 2/22/2022   added documentation and removed unnecessary file reads
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function [speed, m_speed] = getBurstSpeed(frame, origin, xloc, yloc)
originBin = 10;
startBin = originBin+2;            % avoid bins when burst just start
edgeBin = size(frame,2)-2;    % avoid bins when burst propogate to edges

% to be added in future to replace while loop below
%{ 
 if edgeBin - startBin < 1
    speed = nan;
    m_speed = nan;
    return;
end 
%}

% to be remove this b/c the if statement covers it
% this simply increases the size of the bins we're working with
while (edgeBin - startBin) < 1 && edgeBin < size(frame,2)      
    edgeBin = edgeBin + 1;
    startBin = startBin - 1;
end

unit = 10;                              % convert unit to distance/ms
speed = zeros(edgeBin-startBin,1);

% calculate speed of burst using distance between most spiked neuron and origin neuron
for i = 1:edgeBin-startBin
    currentBin = i+startBin;     % current bin
    t = currentBin-originBin;    % bin since start of burst
    largest = max(frame(:,currentBin));
    brightestPixelIndexes = find(frame(:,currentBin)==largest, 2);         % index of neurons with the highest spikerate
    n = length(brightestPixelIndexes);
    distance = zeros(n,1);
    % Finds the distance between the brightest pixel for each image/frame and the origin.
    for j = 1:n
        distance(j) = getDistance(origin,brightestPixelIndexes(j),xloc,yloc);  
    end
    speed(i) = mean(distance)/t/unit; 
end
    m_speed = mean(speed);
end

