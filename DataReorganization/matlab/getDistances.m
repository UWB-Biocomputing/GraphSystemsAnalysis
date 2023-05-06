% GETDISTANCES return distances between corresponding neurons in two sets
% passed in as Matlab indices (1 based)

function d = getDistances(n1s,n2s,xlocs,ylocs)
   x1s = xlocs(n1s);
   y1s = ylocs(n1s);
   x2s = xlocs(n2s);
   y2s = ylocs(n2s);

   d = sqrt((x1s - x2s).^2 + (y1s - y2s).^2);    % distance formula
end