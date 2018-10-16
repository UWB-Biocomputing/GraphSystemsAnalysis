% pass in two neuron indexes, return the distance between two neurons

function d = getDistance(n1,n2)
h5file = 'tR_1.0--fE_0.90_10000';
xloc = double(hdf5read([h5file '.h5'], 'xloc')'); xloc=xloc+1;
yloc = double(hdf5read([h5file '.h5'], 'yloc')'); yloc=yloc+1;

x1 = xloc(n1); y1 = yloc(n1);
x2 = xloc(n2); y2 = yloc(n2);
d = sqrt((x1 - x2)^2 + (y1 - y2)^2); 
end