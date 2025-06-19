% PLOTWEIGHTDIFFERENCE Plot percentage of LTD vs LTP over time
%
%   Syntax: plotWeightDifference(weightEvolution)
%
%   Input:  
%   weightEvolution  -  csv file where x is the number of synapses
%                       and y is number of seconds in the simulation.
%                       Each row shows the synapse weight at y second.
%
%   Output:
%   <weightDiff.png>  - weight difference progression
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotWeightDifference(weightEvolution)

% Load weight evolution matrix
w = readmatrix(weightEvolution, 'Range', [2 1]);
sim_len = size(w, 2);

% Remove weights with no change
w_diff = w(:,sim_len) - w(:,1);
w_nonzero_col = w_diff ~= 0;
w = w(w_nonzero_col,:);

w_change = diff(w,1,2);
[nonzero_count, diff_count] = size(w_change);

w_ltp = w_change > 0;
ltp_ratio = zeros(1, diff_count);

for i = 1:diff_count
    ltp_ratio(i) = sum(w_ltp(:,i))/nonzero_count;
end

ltd_ratio = 1 - ltp_ratio;
x = linspace(12, diff_count, diff_count-12+1);

figure;
bar(x, ltd_ratio(12:end));
hold on;

title('Percentage of LTD Synapses over Time');
xlabel('Time (sec)');
ylabel('Percentage (%)');

exportgraphics(gcf, 'weightDiff.png')

hold off;