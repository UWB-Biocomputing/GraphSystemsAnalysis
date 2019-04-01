% Bust speed plotting

% Let's just look at the mean speeds first
clf;
meanSpeeds = csvread('allBurstSpeedMean.csv');
numbursts = size(meanSpeeds,1);
plot([1:numbursts], meanSpeeds, 'k.', 'MarkerSize', 3);
hold on;
% We'll also plot a moving average
k = 100;
smoothed = movmean(meanSpeeds, k);
h = plot([1:numbursts], smoothed, 'k-');
xlabel('Burst Number');
ylabel('Propagation Speed (ms^{-1})');
set(gca, 'FontSize', 12);
set(h, 'LineWidth', 4);
print('burstSpeed', '-deps2');

% Next, let's look at the non-aggregated data. There are so many bursts
% that we can't plot the range of values for each, so we'll plot the max
% and min using different colors.
% speeds = csvread('allBurstSpeed.csv');
% numbursts = size(speeds,1);
% plot([1:numbursts], speeds, '.');
% xlabel('Burst Number');
% ylabel('Speed (ms^{-1})');
% set(gca, 'FontSize', 12);