% PLOTWEIGHTBOXPLOTS Distribution of synaptic weights over time
%
%   Plot the boxplot weight distribution at important times in the
%   simulation. The below code uses the distribution at the start (1
%   second), after the first burst (13 seconds), halfway through the
%   simulation (50 seconds), and at the end of the simulation.
%
%   Syntax: plotWeightBoxplots(weightEvolution)
%
%   Input:  
%   weightEvolution  -  csv file where x is the number of synapses
%                       and y is number of seconds in the simulation.
%                       Each row shows the synapse weight at y second.
%
%   Output:
%   <weightBoxPlots.png>  - weight distribution boxplots
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotWeightBoxPlots(weightEvolution)

w = readmatrix(weightEvolution, 'Range', [2 1]);
sim_len = size(w,2);

w_subset = [w(:,1), w(:,13), w(:,50), w(:,sim_len)];

figure;
boxplot(w_subset, 'Symbol','_b', 'Labels', {1,13,50,sim_len});
hold on;
title('Synaptic Weight Distribution')
xlabel('Time (seconds)')

exportgraphics(gcf, 'weightBoxPlots.png')

hold off;

% Calculate summary statistics
% summary(w_subset,1)
% quantile(w_subset,[0.25,0.75],1)