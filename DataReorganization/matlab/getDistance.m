% GETDISTANCE return distance between two neurons by passing its indexes

function d = getDistance(n1,n2,xloc,yloc)
xloc=xloc+1;
yloc=yloc+1;

x1 = xloc(n1); y1 = yloc(n1);
x2 = xloc(n2); y2 = yloc(n2);
d = sqrt((x1 - x2)^2 + (y1 - y2)^2);    % distance formula
end