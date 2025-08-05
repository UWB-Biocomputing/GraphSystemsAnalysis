% PLOTWEIGHTDISTRIBUTION Histogram distribution of synaptic weights over time
%
%   1. Plot the histogram distribution of synaptic weights over time
%   2. Plot the boxplot weight distribution at important times in the
%   simulation. The below code uses the distribution at the start (1
%   second), after the first burst (13 seconds), halfway through the
%   simulation (50 seconds), and at the end of the simulation.
%
%   Syntax: plotWeightDistribution(weightEvolution)
%
%   Input:  
%   weightEvolution  -  csv file where x is the number of synapses
%                       and y is number of seconds in the simulation.
%                       Each row shows the synapse weight at y second.
%
%   Output:
%   <weightHistogram.png>  - weight distribution histogram
%   <weightBoxPlots.png>   - weight distribution boxplots
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotWeightDistribution(weightEvolution)

w = readmatrix(weightEvolution, 'Range', [2 1]);
sim_len = size(w,2);

%% Plot Histograms
num_bins = 25; % Number of bins in the histogram
bins = zeros(sim_len, num_bins);

% Get bin edges at the end of the simulation to use for all timesteps
a = histogram(w(:,sim_len), num_bins);

figure;
for i=1:sim_len
   h = histogram(w(:,i)', a.BinEdges);
   bins(i,:) = h.Values;
end

% Get bin labels for the x-axis
E = [h.BinEdges(5), h.BinEdges(10), h.BinEdges(15), h.BinEdges(20), h.BinEdges(25)];
bar3(bins)

hold on;

title('Synaptic Weight Histogram')
xlabel('Synaptic Weight')
set(gca,'XTickLabel', E)
ylabel('Time (sec)')

exportgraphics(gcf, 'weightHistogram.png')

hold off;

%% Plot Boxplots
w_subset = [w(:,1), w(:,13), w(:,50), w(:,sim_len)];

figure;
boxplot(w_subset, 'Symbol','_b', 'Labels', {1,13,50,sim_len});
hold on;
title('Synaptic Weight Distribution')
xlabel('Time (seconds)')

exportgraphics(gcf, 'weightBoxPlots.png')

hold off;