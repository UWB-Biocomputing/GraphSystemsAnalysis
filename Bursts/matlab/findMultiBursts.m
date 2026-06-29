% FINDMULTIBURSTS Indentify which putative bursts are multiple
% The initial burst data can include more than one overlapping burst. This
% function identifies those cases.

% This function uses the distances from the identified burst origin to the
% burst wavefront to identify overlapping bursts. It reads the burst frame
% (from getBurstSpikes) and calculates the distance between the most-spiking-neurons
% and the origin. If there is a single bursts, these distance values will
% all be very similar, as the wavefront is roughly a circular arc (or set
% of circular arcs). If not, then there will be some distances that are
% much farther. The standard deviation of the set of distances is use to
% determine this, using the provided threshold as a decision parameter. A
% multiple burst will be diagnosed if this happens in _any_ 10ms bin.
%
%   Syntax: findMultiBursts(h5dir, threshold)
%
%   Input:
%   h5dir    - Graphitti result filename (e.g. tR_1.0--fE_0.90)
%              the entire path may be required, for example
%              '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   threshold - distance standard deviation threshold
%
%   Output:
%   <multipleBursts.csv> - File containing burst numbers for overlapping
%   bursts. Bursts in this are numbered starting with 1.
%
% Original author:   Jewel Y. Lee (jewel87@uw.edu)
% Updated: 2/22/2022   added documentation and removed unnecessary file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Rewritten: June 2023
% By: Michael Stiber

function findMultiBursts(h5dir, threshold)

fprintf('Reading data... ');

% burst origin (x, y), neuron ID, and origin bin # for every burst. (This
% is Graphitti neuron ID, i.e., zero-based, and (x, y) are also zero-based,
% ij coordinates))
burstOrigins = readmatrix([h5dir '/allBurstOrigin.csv']);
% Get binned neuron spike counts
load([h5dir '/allFrames.mat'], 'allFrames');
% Get x and y location of neurons (zero-based, ij coordinates)
xlocs = double(h5read([h5dir '.h5'], '/xloc'));
ylocs = double(h5read([h5dir '.h5'], '/yloc'));

fprintf('done\n');

% Number of Bursts
nBursts = size(burstOrigins,1);

% Output file
multiBurstFileName = [h5dir '/multipleBursts.csv'];
multiBurstFile = fopen(multiBurstFileName, 'w');

% Count how many were found
numMultiBursts = 0;

% For each burst
for iBurst = 1:nBursts
    frame = allFrames{iBurst}; % per-neuron spike counts for this burst
    % A frame has one row per neuron and one column per time bin.

    originID = burstOrigins(iBurst,3);
    originBin = 10;
    startBin = originBin+2;       % avoid bins when burst just starts
    edgeBin = size(frame,2)-2;    % avoid bins when burst propogates to edges

    % to be remove this b/c the if statement covers it
    % this slightly increases the span of bins we're working with
    while (edgeBin - startBin) < 1 && edgeBin < size(frame,2) && startBin >= originBin
        edgeBin = edgeBin + 1;
        startBin = startBin - 1;
    end

    % calculate the distance between the most spiking neurons and the
    % origin neuron for each bin
    for currentBin = startBin:edgeBin

        largest = max(frame(:,currentBin));  % Largest neuron spike count in this bin
        maxCountIndices = find(frame(:,currentBin)==largest);         % index of neuron(s) with the highest spike count
        originCopies = ones(size(maxCountIndices)) * (originID+1);      % make sure to convert origin neuron ID to index

        % Finds the distances between the highest spiking neurons and the origin.
        distances = getDistances(originCopies, maxCountIndices, xlocs, ylocs);

        if length(distances) > 3 && std(distances) > threshold
            fprintf('Found putative multiple burst: %d\n', iBurst);
            fprintf(multiBurstFile, '%d\n', iBurst);
            numMultiBursts = numMultiBursts + 1;
            break;
        end

    end
end

fprintf('Found %d multiple bursts\n', numMultiBursts);
end

