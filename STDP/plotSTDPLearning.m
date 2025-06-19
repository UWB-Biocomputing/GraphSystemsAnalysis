% PLOTSTDPLEARNING Plot the STDP learning function
%
%   Plots the STDP learning function using the synapticWeightModification
%   function (copied from Graphitti). Shows the deltaW_{ij} value vs deltaT
%
%   Syntax: plotSTDPLearning()
%
%   Output:
%   Figure1  - STDP learning function
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotSTDPLearning()

x_len = 90;
x = linspace(-0.04, 0.04, x_len); % time interval (ms)
y = zeros(1, x_len);
STDPGap = 0.002;

for i = 1:x_len
    if abs(x(i)) > STDPGap
        y(i) = 1.0 + synapticWeightModification(x(i));
    end
end

ltd = find(y == 0, 1);
ltp = find(x > STDPGap, 1);

plot(x(1:ltd-1),y(1:ltd-1), '.', 'Color', '#0072BD');
hold on;
plot(x(ltp:end), y(ltp:end), '.', 'Color', '#0072BD');
xlabel('Time, \Delta t (seconds)')
ylabel('Synaptic Weight Change, \Delta w_{ij}')
hold off;