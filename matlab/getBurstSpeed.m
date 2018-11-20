%GETBURSTSPEED return burst propagation speed (unit: neurons/ms)
%Read burst frames (from getBurstSpikes) and calculate propagation speed by
%finding the distance between the most-spiked-neuron (brightest pixel in 
%the frame) and origin-neuron, this distance divided by number of bins away 
%from origin bin (default is 10) is the burst speed. 
% 
%   Syntax: [speed, m_speed] = getBurstSpeed(h5file, id, origin)
%   
%   Input:  
%   h5file  - BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%   id      - burst ID
%   origin  - burst origin location (neuron number)
%
%   Return: 
%   speed   - propagation speed for every bin
%   m_speed - mean burst speed

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/18/2018
function [speed, m_speed] = getBurstSpeed(h5file, id, origin)
burstfile = [h5file, '/Binned/burst_', num2str(id), '.csv'];
frames = csvread(burstfile);  
o_bin = 10;                 % origin bin
s_bin = o_bin+5;            % avoid bins when burst just start
e_bin = size(frames,2)-5;   % avoid bins when burst propogate to edges
unit = 10;                  % convert unit to distance/ms
speed = zeros(e_bin-s_bin,1);

for i = 1:e_bin-s_bin
    b = i+s_bin;  
    t = b-o_bin;
    largest = max(frames(:,b));
    idx = find(frames(:,b)==largest, 2);
    n = length(idx);
    d = zeros(n,1);
    for j = 1:n
        d(j) = getDistance(origin,idx(j));  
    end
    speed(i) = mean(d)/t/unit; 
end
    m_speed = mean(speed);
end

