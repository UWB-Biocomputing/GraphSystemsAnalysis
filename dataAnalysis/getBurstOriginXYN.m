%GETBURSTORIGINXYN return burst origin  (X,Y) and neuron number N
%Read <binnedBurstInfo.csv> and retrieve burst x,y origin by calculating 
%the centroid location of neurons that spiked the most in the first 100 
%timesteps for each burst (brightest pixel in the starting frame)
%
%   Syntax: getBurstOriginXY(h5file)
%   
%   Input:  
%   h5file  - BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%
%   Output: 
%   <allBurstOriginXY.csv> - burst origin (x,y) location for every burst
%   <allBurstOriginN.csv> - burst origin neuron number for every burst

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/18/2018
function [X, Y, N] = getBurstOriginXYN(h5file, o_bin, id)
burstfile = [h5file, '/Binned/burst_', num2str(id), '.csv'];
frames = csvread(burstfile);    
xloc = hdf5read([h5file '.h5'], 'xloc');        % x location
yloc = hdf5read([h5file '.h5'], 'yloc');        % y location
grid = sqrt(length(xloc));                    	% grid size 
% find brightest pixel (neuron that spikes the most in a time bin)
largest = max(frames(:,o_bin)); 
while (largest < 2)  
    o_bin = o_bin + 1;
    largest = max(frames(:,o_bin)); 
end
indexes = find(frames(:,o_bin)==largest, 2);
n = length(indexes);
points = zeros(2,n);
for j = 1:n
    points(1,j) = xloc(indexes(j))+1;   % index starts at 0 in BG
    points(2,j) = yloc(indexes(j))+1;   % matlab start from 1, so +1
end
    % get centroid of neurons with max value
    X = ceil(mean(points(1,:)));          
    Y = ceil(mean(points(2,:)));
    N = (Y-1)*grid + X;
end
