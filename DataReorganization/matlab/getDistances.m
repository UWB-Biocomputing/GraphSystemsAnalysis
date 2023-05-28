% GETDISTANCES return distances between corresponding neurons in two sets
% passed in as Matlab indices (1 based)
%
%   Syntax: d = getDistances(n1s, n2s, xlocs, ylocs)
%
%   Input:
%   n1s, n2s - vectors of neuron indexes (Matlab one-based)
%   xloc    -   array containing all neuron x locations (zero-based,
%               ij coordinates)
%   yloc    -   array containing all neuron y locations (zero-based,
%               ij coordinates)
%
%   Return:
%   d     - vector of distances between each pair of corresponding n1s, n2s

function d = getDistances(n1s, n2s, xlocs, ylocs)
   x1s = xlocs(n1s);
   y1s = ylocs(n1s);
   x2s = xlocs(n2s);
   y2s = ylocs(n2s);

   d = sqrt((x1s - x2s).^2 + (y1s - y2s).^2);    % distance formula
end