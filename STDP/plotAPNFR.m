% PLOTAPNFR Average Per Neuron Firing Rate (APNFR) over time
%
%   Plot the progression of APNFR over time (seconds). APNFR is in
%   spikes/bin/neuron, so the burst threshold from Kawasaki and Stiber
%   is 0.5 * 0.01 = 0.005 spikes/bin/neuron. startBin and endBin
%   can be taken from allBinnedBurstInfo.csv to graph one burst at a time.
%
%   Syntax: plotAPNFR(dataset, nNeurons, startBin, endBin)
%
%   Input:  
%   dataset  -  Graphitti simulation output. This function requires the
%                 /spikesHistory dataset.
%   nNeurons   -  Number of neurons used in the simulation run
%   startBin   -  Bin number to start plotting
%   endBin     -  Bin number to finish plotting
%
%   Output:
%   <apnfr_vs_time.png>  - plot of APNFR over time
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function plotAPNFR(dataset, nNeurons, startBin, endBin)

spikesPerBin = double(h5read(dataset,'/spikesHistory'));
spikesPerNeuronPerBin = (spikesPerBin/nNeurons) * 0.01;

nBins = endBin - startBin;
simLength = (endBin - startBin) * 0.01; % simulation length in seconds

x = linspace(0,simLength,nBins);
y = spikesPerNeuronPerBin(startBin:endBin-1);

figure;
plot(x,y);
hold on;

title('APNFR vs Time');
xlabel('Time (sec)');
ylabel('APNFR (Hz per neuron)');

exportgraphics(gcf, 'apnfr_vs_time.png')
hold off;