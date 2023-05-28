% GETBURSTSPEED return burst propagation speed (unit: neurons/ms)
% Read burst frame (from getBurstSpikes) and calculate propagation speed by
% finding the distance between the most-spiked-neuron (brightest pixel in
% the frame) and origin-neuron, this distance divided by number of bins away
% from origin bin (default is 10) is the burst speed.
%
%   Syntax: [speed, mean] = getBurstSpeed(frame, origin, xlocs, ylocs)
%
%   Input:
%   frame   -   matrix of neuron spike counts in a burst. A frame has one row
%               per neuron and one column per time bin.
%   origin  -   burst origin location (neuron ID, zero-based)
%   xloc    -   array containing all neuron x locations
%   yloc    -   array containing all neuron y locations
%
%   Return:
%   speed     - propagation speed for every bin
%   meanSpeed - mean burst speed
%
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Updated: 2/22/2022   added documentation and removed unnecessary file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Updated: May 2023 minor tweaks
% Updated by: Michael Stiber

function [speed, meanSpeed] = getBurstSpeed(frame, origin, xlocs, ylocs)
originBin = 10;
startBin = originBin+2;       % avoid bins when burst just starts
edgeBin = size(frame,2)-2;    % avoid bins when burst propogates to edges

% to be added in future to replace while loop below
%{
 if edgeBin - startBin < 1
    speed = nan;
    m_speed = nan;
    return;
end 
%}

% to be remove this b/c the if statement covers it
% this slightly increases the span of bins we're working with
while (edgeBin - startBin) < 1 && edgeBin < size(frame,2) && startBin >= originBin
    edgeBin = edgeBin + 1;
    startBin = startBin - 1;
end

% convert unit to distance/ms; the following is really just the bin width
% in ms
unit = 10;

% Preallocate speed vector. We will calculate the speed for each bin
speed = zeros(edgeBin-startBin+1,1);

% calculate speed of burst using distance between most spiked neuron and origin neuron
for currentBin = startBin:edgeBin
    t = currentBin-originBin;            % bins since start of burst
    largest = max(frame(:,currentBin));  % Largest neuron spike count in this bin
    maxCountIndices = find(frame(:,currentBin)==largest);         % index of neuron(s) with the highest spike count
    originCopies = ones(size(maxCountIndices)) * (origin+1);      % make sure to convert origin neuron ID to index

    % Finds the distances between the highest spiking neurons and the origin.
    distances = getDistances(originCopies, maxCountIndices, xlocs, ylocs);

    speed(currentBin) = mean(distances)/t/unit;
end
meanSpeed = mean(speed);
end

