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


function plotBurstSpeed(h5dir)

% Plot the mean speed information
clf;
meanSpeeds = readmatrix([h5dir '/allBurstSpeedMean.csv']);
numbursts = length(meanSpeeds);
plot(1:numbursts, meanSpeeds, 'k.', 'MarkerSize', 3);
hold on;
% We'll also plot a moving average
k = 100;
smoothed = movmean(meanSpeeds, k);
p = plot(1:numbursts, smoothed, 'b-');
ax = gca;
xlabel('Burst Number');
ylabel('Propagation Speed (ms^{-1})');
ax.FontSize = 12;
yl = ax.YLim;
ax.YLim = [0 0.7];
set(p, 'LineWidth', 4);
exportgraphics(ax, [h5dir '-burstspeed.pdf']);

% Next, let's look at the non-aggregated data. There are so many bursts
% that we can't plot the range of values for each, so we'll plot the max
% and min using different colors.
% speeds = csvread('allBurstSpeed.csv');
% numbursts = size(speeds,1);
% plot([1:numbursts], speeds, '.');
% xlabel('Burst Number');
% ylabel('Speed (ms^{-1})');
% set(gca, 'FontSize', 12);