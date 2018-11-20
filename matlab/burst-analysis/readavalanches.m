function [ atimes, alengths, aspikes ] = readavalanches( filename )
%READAVALANCHES Reads CSV avalanche file
%   Reads contents of an avalanche CSV file, returning vectors containing
%   avalance start times, lengths (in ticks), and number of spikes.

aInfo = csvread(filename, 1, 3);
atimes = aInfo(:,1);
alengths = aInfo(:,3);
aspikes = aInfo(:,4);

end

