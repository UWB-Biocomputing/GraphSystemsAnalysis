% GETBURSTORIGINXYN return burst origin  (X,Y) and neuron number N
% Read <binnedBurstInfo.csv> and retrieve burst x,y origin by calculating 
% the centroid location of neurons that spiked the most in early 
% in a burst (brightest pixel in the starting frame)
%
%   Syntax: [X, Y, N] = getBurstOriginXYN(frame, xloc, yloc)
%   
%   Input:  
%   frame   -   matrix of neuron spike counts in a burst
%   xlocs   -   array containing all x location of each burst
%   ylocs   -   array containing all y location of each burst
%   
%   Return: 
%   X   - x location of origin neuron
%   Y   - y location of origin neuron
%   N   - neuron number of origin neuron
%
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Updated: 02/22/2022  added improvement on performance for file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Updated: May 2023 minor tweaks
% Updated by: Michael Stiber

function [x, y, n] = getBurstOriginXYN(frame, xlocs, ylocs)
% NOTE: assumes square grid size
grid = sqrt(length(xlocs));

% starts at 10 to leave room for beginning of burst
theBin = 10;

% find the maximum number of spikes by any neuron in the bin
maxSpikes = max(frame(:,theBin));      % theBin starts at 10
% using 2 as the threshold for brightest pixel (wait until burst is big
% enough)
while (maxSpikes < 2)
    theBin = theBin + 1;
    % finds largest element in theBin
    maxSpikes = max(frame(:,theBin));
end

% Get the neurons that have the max number of spikes
maxSpikingNeurons = find(frame(:,theBin)==maxSpikes);

initialNeurons = length(maxSpikingNeurons);

% There could be multiple clusters. Let's find the largest one using a
% simple greedy algorithm. Iterate over the neurons; find the "distance"
% from it to all others (here, we are just going to use difference in
% neuron ID mod the grid). Given a threshold for "close", count the number
% of neurons that are close or far and only keep this neuron if the number
% of close neurons is greater than the number of far neurons.
%
% This will break if there are many clusters; it assumes that there is one
% cluster with more neurons than all other clusters combined. (Well,
% actually, if that is the case, the neuron with the highest index will end
% up as the origin.)
i = 1;
while i <= length(maxSpikingNeurons)
    diffNs = mod(abs(maxSpikingNeurons(i) - maxSpikingNeurons),grid);
    numClose = length(find(diffNs <= 10));
    % if there aren't enough close neurons, remove this one from the list
    if numClose < length(maxSpikingNeurons) - numClose
        maxSpikingNeurons(i) = [];
    else
        i = i + 1;
    end
end

assert(length(maxSpikingNeurons) > 0);

if initialNeurons > 1 & length(maxSpikingNeurons) == 1
    fprintf('Warning: number of neurons arbitrarily reduced to one.\n')
end

% get centroid of neurons with max value
x = ceil(mean(xlocs(maxSpikingNeurons)));          
y = ceil(mean(ylocs(maxSpikingNeurons)));
n = y*grid + x;

end
