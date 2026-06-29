% VERIFYBURSTSPEED manual check of burst propagation speed (unit: neurons/ms)
% For the indicated burst number, output diagnostic information and display
% elements of the burst speed computation

% Read burst frame (from getBurstSpikes) and calculate propagation speed by
% finding the distance between the most-spiked-neuron (brightest pixel in
% the frame) and origin-neuron, this distance divided by number of bins away
% from origin bin (default is 10) is the burst speed.
%
%   Syntax: verifyBurstSpeed(h5dir, burstNum)
%
%   Input:
%   h5dir    - Graphitti result filename (e.g. tR_1.0--fE_0.90)
%              the entire path may be required, for example
%              '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   burstNum - burst ID
%
% Original author:   Jewel Y. Lee (jewel87@uw.edu)
% Updated: 2/22/2022   added documentation and removed unnecessary file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Rewritten: June 2023
% By: Michael Stiber

function verifyBurstSpeed(h5dir, burstNum)

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

frame = allFrames{burstNum};
originID = burstOrigins(burstNum,3);
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

fprintf('Analysis of burst %d speed for bins [%d, %d]:\n', burstNum, startBin, edgeBin);
clf;

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
    originCopies = ones(size(maxCountIndices)) * (originID+1);      % make sure to convert origin neuron ID to index

    % Finds the distances between the highest spiking neurons and the origin.
    distances = getDistances(originCopies, maxCountIndices, xlocs, ylocs);

    speed(currentBin-startBin+1) = mean(distances)/(t*unit);
    subplot(2, edgeBin - startBin + 1, currentBin - startBin + 1);
    f = reshape(frame(:, currentBin), 100, 100)';
    imagesc(f);
    colormap(parula);
    pbaspect([1 1 1]);
    set(gca, 'Box', 'on', 'LineWidth', 1.0);
    title(['t: ' num2str(t*unit) 'ms, speed: ' num2str(speed(currentBin-startBin+1))]);
    hold on;

    % According to the Matlab documentation for imagesc(), "The row and
    % column indices of the elements determine the centers of the
    % corresponding pixels." Therefore, that means that (1, 1) is the
    % center of the top-left pixel. Burst origins, on the other hand, are
    % computed by getBurstOriginXYN(), which computes the origins based on
    % Graphitti neuron (x, y) locations (zero-based). Therefore, we need to
    % add one to the x and y coordinates to place the origin markers in the
    % right locations.
    %
    % We have already transposed the array, and imagesc() uses ij
    % coordinates (origin at top left).
    plot(burstOrigins(burstNum,1)+1, burstOrigins(burstNum,2)+1, 'Marker','pentagram',...
        'MarkerFaceColor','red', 'MarkerEdgeColor', 'red', 'MarkerSize', 20);
    plot(xlocs(maxCountIndices)+1, ylocs(maxCountIndices)+1, 'Marker','pentagram',...
        'MarkerFaceColor','red', 'MarkerEdgeColor', 'red', 'MarkerSize', 12, ...
        'LineStyle', 'none');

    % Now let's look at the distances
    subplot(2, edgeBin - startBin + 1, (edgeBin - startBin + 1) +(currentBin - startBin + 1));
    histogram(distances);
    title(['std = ' num2str(std(distances))]);


end
meanSpeed = mean(speed);
fprintf('\tmean speed: %f\n', meanSpeed);
end

