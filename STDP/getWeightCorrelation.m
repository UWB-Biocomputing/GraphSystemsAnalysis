%  GETWEIGHTCORRELATION Calculate the Spearman correlation between neuron types
%  and whether the edge experiences LTD, LTP, or no change
%
%   Syntax: getWeightCorrelation(weightEvolution, edgeMap, neuronTypes)
%
%   Input:  
%   weightEvolution  -  csv file where x is the number of synapses
%                       and y is number of seconds in the simulation.
%                       Each row shows the synapse weight at y second.
%   edgeMap          -  csv file where each row correlates to the edge
%                       row in weightEvolution. The first column is the
%                       source neuron and the second column is the
%                       destination neuron
%   neuronTypes      -  Each neuron and their type, indicated by a boolean
%                       array in the format: [endogenously active,
%                       excitatory, inhibitory]
%
%   Output:
%   Correlation values are output to console
%   
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function getWeightCorrelation(weightEvolution, edgeMap, neuronTypes)

%% Load Files
w = readmatrix(weightEvolution, 'Range', [2 1]);
e = readmatrix(edgeMap);
n = readmatrix(neuronTypes, 'Range', [2,2]); % skip col names and index

sim_len = size(w,2);

%% Get Presynaptic Neuron Types
types = zeros(size(w,1), 3);
for i = 1:size(w,1)
    src = int32(e(i, 1)) + 1; % array indices start at 1
    types(i,:) = n(src,:);
end

%% Get weight changes
% No change
w_diff = w(:,sim_len) - w(:,1);
w_zero_col = w_diff == 0;

% LTD
w_neg_col = w_diff < 0;

% LTP
w_pos_col = w_diff > 0;

%% Calculate correlation
% LTP vs active
fprintf("Long Term Potentiation\n")
[r, p] = corr(w_pos_col, types(:,1), 'Type', 'Spearman'); % endogenously active
fprintf("LTP vs endogenously active: rho: %0.4f, pval: %d\n", r, p);

[r, p] = corr(w_pos_col, types(:,2), 'Type', 'Spearman'); % excitatory
fprintf("LTP vs excitatory: rho: %0.4f, pval: %d\n", r, p);

[r, p] = corr(w_pos_col, types(:,3), 'Type', 'Spearman'); % inhibitory
fprintf("LTP vs inhibitory: rho: %0.4f, pval: %d\n", r, p);

% LTd vs active
fprintf("Long Term Depression\n")

[r, p] = corr(w_neg_col, types(:,1), 'Type', 'Spearman'); % endogenously active
fprintf("LTD vs endogenously active: rho: %0.4f, pval: %d\n", r, p);

[r, p] = corr(w_neg_col, types(:,2), 'Type', 'Spearman'); % excitatory
fprintf("LTD vs excitatory: rho: %0.4f, pval: %d\n", r, p);

[r, p] = corr(w_neg_col, types(:,3), 'Type', 'Spearman'); % inhibitory
fprintf("LTD vs inhibitory: rho: %0.4f, pval: %d\n", r, p);

% No change
fprintf("No weight change\n")

[r, p] = corr(w_zero_col, types(:,1), 'Type', 'Spearman'); % endogenously active
fprintf("No change vs endogenously active: rho: %0.4f, pval: %d\n", r, p);

[r, p] = corr(w_zero_col, types(:,2), 'Type', 'Spearman'); % excitatory
fprintf("No change vs excitatory: rho: %0.4f, pval: %d\n", r, p);

[r, p] = corr(w_zero_col, types(:,3), 'Type', 'Spearman'); % inhibitory
fprintf("No change vs inhibitory: rho: %0.4f, pval: %d\n", r, p);