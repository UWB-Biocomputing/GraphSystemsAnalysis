% PLOTBURSTSPEED Bust speed plotting
%
%   Syntax: plotBurstSpeed(h5dir)
%
%   Input:  
%   h5dir   -   BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%               the entire path is required for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Output:
%   <h5dir-byrstspeed.pdf>  - burst speed plot


function plotBurstSpeed(h5dir, parent)

if nargin < 2
    figure(1);
    clf;
    parent = gca;
    doExport = true;
else
    doExport = false;
end

% Plot the mean speed information
meanSpeeds = readmatrix([h5dir '/allBurstSpeedMean.csv']);
numbursts = length(meanSpeeds);
plot(parent, 1:numbursts, meanSpeeds, 'k.', 'MarkerSize', 3);
hold(parent, 'on');
% We'll also plot a moving average
k = 100;
smoothed = movmean(meanSpeeds, k);
p = plot(parent, 1:numbursts, smoothed, 'b-');
ax = parent;

if doExport
    xlabel(ax, 'Burst Number');
    ylabel(ax, 'Propagation Speed (ms^{-1})');
end

ax.FontSize = 12;
ax.YLim = [0 1.4];
set(p, 'LineWidth', 4);

if doExport
    exportgraphics(ax, [h5dir '-burstspeed.pdf']);
end

% Next, let's look at the non-aggregated data. There are so many bursts
% that we can't plot the range of values for each, so we'll plot the max
% and min using different colors.
% speeds = csvread('allBurstSpeed.csv');
% numbursts = size(speeds,1);
% plot([1:numbursts], speeds, '.');
% xlabel('Burst Number');
% ylabel('Speed (ms^{-1})');
% set(gca, 'FontSize', 12);