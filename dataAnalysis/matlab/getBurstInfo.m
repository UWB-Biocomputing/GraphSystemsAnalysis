%GETBURSTINFO Identify bursts from spikesHistory and save burst metadata
%Read BrainGrid result in HDF5 format and get spikesHistory (spike 
%count in each 10ms bin). Identify burst using burst threshold 0.5 
%and get burst metadata (start/end time, count, width, size, etc)
% 
%   Syntax: getBurstInfo(h5file)
%   
%   Input:  h5file  - BrainGrid simulation result (.h5)
%
%   Output: <allBurstInfo.csv>      - burst metadata
function getBurstInfo(h5file)
% ------------------------------------------------------------------------
% Read from input data and open output file
% - spikesProbedNeurons = neurons and its firing times (column = neuron)
% - spikesHistory = spike count in each 10ms bins
% ------------------------------------------------------------------------
% h5file = '1011_half_tR_1.0--fE_0.90_10000';   % half simulation
h5file = 'tR_1.0--fE_0.90_10000';   % full simulation
SH = uint32((hdf5read([h5file '.h5'], 'spikesHistory'))'); 
N = uint32((hdf5read([h5file '.h5'], 'probedNeurons'))'); 
n_neurons = length(N);                          % number of neurons  

SH10ms = SH/n_neurons;                          % spikes/neuron in 10 ms
fid = fopen('allBurstInfo.csv', 'w') ;          % output file name
fprintf(fid, 'burstID,startBin#,endBin#,width,totalSpikeCount,meanSpikeRate,peakBin,peakHeight,BurstInterval\n');
% ------------------------------------------------------------------------
% Identify Bursts: find the number of bursts and burst boundaries
% ------------------------------------------------------------------------
% In Kawasaki, F., & Stiber, M. (2014): 
%   - 0.5 spikes/sec/neuron as a threshold for burst detection
%   - for 10ms (0.01s) bin, burst threshold = 0.5x0.01 = 0.005
b_threash = 0.005;                              % burst threashold
b_bins = find(SH10ms >= b_threash);             % find bins > threshold                             
b_boundary = find(diff(b_bins) > 1);            % find burst boundaries
n_bursts = length(b_boundary);                  % how many bursts are there
% ------------------------------------------------------------------------ 
% Extract burst info and output burst metadata to csv file
% ------------------------------------------------------------------------
b(1,n_bursts) = Burst();                        % allocate
last = 1;
for i = 1:n_bursts
    b(i).id = i;                                % burst ID
    b(i).start = b_bins(last);                  % start bin number
    b(i).ended = b_bins(b_boundary(i));         % end bin number
    b(i).width = (b(i).ended-b(i).start);       % burst width (unit = 10ms) 
    b(i).count = sum(SH(b(i).start:b(i).ended));            % total spike count
    b(i).mean = mean(SH10ms(b(i).start:b(i).ended));        % mean spike rate
    [b(i).height, temp] = max(SH(b(i).start:b(i).ended));   % height of the peak
    b(i).peak = b(i).start+temp-1;              % peak position (bin with highest spike count)
    if i > 1                                    % burst interval (peak - peak)
        b(i).interval = b(i).peak-b(i-1).peak;  
    else 
        b(i).interval = b(i).peak;
    end
    % 1.burstID, 2.startBin#, 3.EndBin#, 4.width, 5.totalSpikeCount, 
    % 6.meanSpikeRate, 7,peakBin, 8.peakHeight, 9.burstInterval
    fprintf(fid, '%d,%d,%d,%d,%d,%.4f,%d,%d,%d\n', ...
            i,b(i).start,b(i).ended,b(i).width,b(i).count, ...
            b(i).mean,b(i).peak,b(i).height,b(i).interval);   
    last = b_boundary(i) + 1;  
end
clear b;                                        % deallocate
fclose(fid);
