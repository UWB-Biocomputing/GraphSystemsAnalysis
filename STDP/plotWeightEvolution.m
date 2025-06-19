% PLOTWEIGHTEVOLUTION Average weight change over time
%
%   Separate the edges by inhibitory and excitatory. Separate excitatory
%   synapses by whether their weight increases (LTP), decreases (LTD), or
%   has no change. Inhibitory synapse weights do not change as a result of
%   STDP. Graph the average weight of each synapse type over time.
%
%   Syntax: plotWeightEvolution(weightEvolution)
%
%   Input:  
%   weightEvolution  - csv file where x is the number of synapses
%                      and y is number of seconds in the simulation.
%                      Each row shows the synapse weight at y second. 
%
%   Output:
%   <weight_vs_time.png>  - plot of average weight over time, by
%                           synapse type
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotWeightEvolution(weightEvolution)

w = readmatrix(weightEvolution, 'Range', [2 1]);
[num_edges, sim_len] = size(w);
x = linspace(0,sim_len*10,sim_len);

%% Get Synapse Types
% Get inhibitory synapses
w_inh_idx = w(:,1) < 0;
w_inh = w(w_inh_idx,:);
inh_count = sum(w_inh_idx);
fprintf('Number of inhibitory synapses: %d, Percentage: %0.2f%%\n', inh_count, (inh_count/num_edges)*100);

% Get excitatory synapses
w_exc_idx = w(:,1) > 0;
w_exc = w(w_exc_idx,:);
exc_count = sum(w_exc_idx);
fprintf('Number of excitatory synapses: %d, Percentage: %0.2f%%\n', exc_count, (exc_count/num_edges)*100);

%% Separate excitatory into LTP and LTD
w_exc_diff = w_exc(:,sim_len) - w_exc(:,1);
w_exc_ltp_col = w_exc_diff > 0;
w_exc_ltp = w_exc(w_exc_ltp_col, :);

exc_ltp_count = sum(w_exc_ltp_col);
fprintf('Number of excitatory LTP synapses: %d, Percentage: %0.2f%%\n', exc_ltp_count, (exc_ltp_count/num_edges)*100);

w_exc_ltd_col = w_exc_diff < 0;
w_exc_ltd = w_exc(w_exc_ltd_col, :);
exc_ltd_count = sum(w_exc_ltd_col);
fprintf('Number of excitatory LTD synapses: %d, Percentage: %0.2f%%\n', exc_ltd_count, (exc_ltd_count/num_edges)*100);

w_exc_zero_col = w_exc_diff == 0;
w_exc_zero = w_exc(w_exc_zero_col, :);
exc_zero_count = sum(w_exc_zero_col);
fprintf('Number of excitatory synapses with no weight change: %d, Percentage: %0.2f%%\n', exc_zero_count, (exc_zero_count/num_edges)*100);

%% Plot the average weight change per synapse type
mu_w_inh = mean(w_inh);

mu_w_exc_ltp = mean(w_exc_ltp);
mu_w_exc_ltd = mean(w_exc_ltd);
mu_w_exc_zero = mean(w_exc_zero);

figure;
plot(x, mu_w_inh, 'Color', '#0072BD');

hold on;

plot(x, mu_w_exc_ltp, 'color', '#77AC30');
plot(x, mu_w_exc_ltd, 'color', '#D95319');
plot(x, mu_w_exc_zero, 'color', '#7E2F8E');

title('Average Synaptic Weight vs Time');
xlabel('Time (sec)');
ylabel('Synaptic Weight');
legend('Inhibitory Synapses', 'Excitatory Synapses - LTP', 'Excitatory Synapses - LTD', 'Excitatory Synapses - No Change', 'Location', 'northwest')

exportgraphics(gcf, 'weight_vs_time.png')
hold off;

