% GETBURSTATISTICS Outputs burst summary statistics
%
%   Calculate summary statistics for bursts, including
%   average width, average interval, average spikes per burst, and burst
%   percentage.
%
%   Syntax: getBurstStatistics(burstFile)
%
%   Input:  
%   burstFile  -  allBinnedBurstInfo.csv file output from the
%                 ../Bursts/matlab/getBinnedBurstInfo.m function
%
%   Output:
%   Burst summary statistics are printed to console
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function getBurstStatistics(burstFile)

burstMatrix = readmatrix(burstFile);    % read burst metadata

% Column indexes
width_col = 4;
total_spikes_col = 5;
interval_col = 8;

sim_length = 6000000; % bins

% Calculate Results
mean_width = mean(burstMatrix(:,width_col));
mean_spikes = mean(burstMatrix(:,total_spikes_col));
mean_interval = mean(burstMatrix(:,interval_col));
burst_percentage = (sum(burstMatrix(:,width_col)))/sim_length;

% Print Results
fprintf("====== Burst Statistics =====\n")
fprintf("Average Width: %.2f\n", mean_width)
fprintf("Average Spikes: %.2f\n", mean_spikes)
fprintf("Average Interval: %.2f\n", mean_interval)
fprintf("Burst Percentage: %.2f%%\n", burst_percentage * 100)