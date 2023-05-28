% GETBURSTORIGINXYN return burst origin  (X,Y) and neuron number N
% Read <binnedBurstInfo.csv> and retrieve burst x,y origin by calculating 
% the centroid location of neurons that spiked the most in early 
% in a burst (brightest pixel in the starting frame)
%
%   Syntax: [x, y, n, bin] = getBurstOriginXYN(frame, xloc, yloc)
%   
%   Input:  
%   frame   -   matrix of neuron spike counts in a burst. A frame has one row
%               per neuron and one column per time bin.
%   xlocs   -   array containing all x location of each burst (zero-based,
%               ij coordinates)
%   ylocs   -   array containing all y location of each burst (zero-based,
%               ij coordinates)
%   
%   Return: 
%   x   - x location of origin neuron (zero-based, ij coordinates)
%   y   - y location of origin neuron (zero-based, ij coordinates)
%   n   - neuron number of origin neuron (zero-based, Graphitti row major
%         order)
%   bin - bin used
%
% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Updated: 02/22/2022  added improvement on performance for file reads
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Updated: May 2023 minor tweaks
% Updated by: Michael Stiber

function [x, y, n, bin] = getBurstOriginXYN(frame, xlocs, ylocs)
% NOTE: assumes square grid size
grid = sqrt(length(xlocs));

% find the number of neurons producing more than one spike
bin = 1;
numMinimalSpikingNeurons = length(find(frame(:,bin) > 1));

% Search for the first bin that has as least three neurons producing
% more than one spikes.
while numMinimalSpikingNeurons < 3
    bin = bin + 1;
    % finds largest element in theBin
    if bin > size(frame, 2)
        errorStruct.message = 'No bin with three neurons producing multiple spikes';
        errorStruct.identifier = 'getBurstOrigin()';
        error(errorStruct);
    end
    numMinimalSpikingNeurons = length(find(frame(:,bin) > 1));
end

% Now get the most active spike counts, the indices for the neurons that
% produced that many spikes, and how many neurons produced that many
maxSpikes = max(frame(:,bin));
maxSpikingNeuronInds = find(frame(:,bin)==maxSpikes);
numMaxNeurons = length(maxSpikingNeuronInds);
originalNumMaxNeurons = numMaxNeurons;

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
while i <= numMaxNeurons
    diffNs = mod(abs(maxSpikingNeuronInds(i) - maxSpikingNeuronInds), grid);
    numClose = length(find(diffNs <= 10));
    % if there aren't enough close neurons, remove this one from the list
    if numClose < length(maxSpikingNeuronInds) - numClose
        maxSpikingNeuronInds(i) = [];
        numMaxNeurons = numMaxNeurons - 1;
    else
        i = i + 1;
    end
end

assert(~isempty(maxSpikingNeuronInds));

if originalNumMaxNeurons > 1 && numMaxNeurons == 1
    fprintf('Warning: number of neurons reduced to one.\n')
end

% get centroid of neurons with max value (zero-based, ij coordinates)
x = ceil(mean(xlocs(maxSpikingNeuronInds)));          
y = ceil(mean(ylocs(maxSpikingNeuronInds)));
% Compute neuron ID corresponding to (x, y) (zero based)
n = y*grid + x;

end
