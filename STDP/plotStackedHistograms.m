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

function plotStackedHistograms(weightEvolution)

w = readmatrix(weightEvolution, 'Range', [2 1]);
sim_len = size(w,2);

%% Plot Histograms
num_bins = 25; % Number of bins in the histogram
a = histogram(w(:,sim_len), num_bins);

times = [1,13,50,100];
for i = 1:4
    figure('Position', [10 10 600 300]);
    clf()
    
    s(1) = subplot(4,1,1:3);
    histogram(w(:,times(i)), num_bins);
    % yscale log
    ylabel('Total Synapses');
    xlim([-5.3813e-08, 5.0265e-07])

    s(2) = subplot(4,1,4);
    boxplot(w(:,times(i)), 'Symbol','|b', 'Orientation', 'horizontal')
    xlabel('Synaptic Weight');
    linkaxes(s, 'x')
end