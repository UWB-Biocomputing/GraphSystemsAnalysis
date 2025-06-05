% PLOTWEIGHTEVOLUTIONSAMPLE Sample weight change over time
%
%   Separate the edges by inhibitory and excitatory. Separate excitatory
%   synapses by whether their weight increases (LTP), decreases (LTD), or
%   has no change. Graph a random sample of synapse weights over time for
%   each synapse type.
%
%   Syntax: plotWeightEvolutionSample(weightEvolution)
%
%   Input:  
%   weightEvolution  - csv file where x is the number of synapses
%                      and y is number of seconds in the simulation.
%                      Each row shows the synapse weight at y second. 
%
%   Output:
%   figure1 - Random sample of 50 LTP synapse weights over time
%   figure2 - Random sample of 50 LTD synapse weights over time
%   
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotWeightEvolutionSample(weightEvolution)

w = readmatrix(weightEvolution, 'Range', [2 1]);
sim_len = size(w, 2);
x = linspace(0,sim_len*10,sim_len);

% Get excitatory synapses
w_exc_idx = w(:,1) > 0;
w_exc = w(w_exc_idx,:);

% Separate excitatory into LTP and LTD
w_exc_diff = w_exc(:,sim_len) - w_exc(:,1);

w_exc_ltp_col = w_exc_diff > 0;
w_exc_ltp = w_exc(w_exc_ltp_col, :);

w_exc_ltd_col = w_exc_diff < 0;
w_exc_ltd = w_exc(w_exc_ltd_col, :);

% get 50 random LTP synapses
r = randi([1 size(w_exc_ltp,1)], 1, 50);

figure;
hold on;
for i = 1:50
    y = w_exc_ltp(r(i),:);
    plot(x, y);
end

title('LTP Synaptic Weight vs Time');
xlabel('Time (sec)');
ylabel('Synaptic Weight');
hold off;

% get 50 random LTD synapses
r2 = randi([1 size(w_exc_ltd,1)], 1, 50);

figure;
hold on;

for r = 1:50
    y = w_exc_ltd(r2,:);
    plot(x, y);
end

title('LTD Synaptic Weight vs Time');
xlabel('Time (sec)');
ylabel('Synaptic Weight');
hold off;