%MAKESEQUENCE return sequence for every spike in target event
%retrieve t,x,y from spikeTime info for every spike in target event 
%as features, return an 1D array 
%  
%   Syntax:  sequence = makeSequence(h5file, spikeTime, n_spikes)
%   
%   Input:
%   h5file    - BrainGrid simulation result (.h5)
%   spikeTime - matrix contains spikeTime info for target event
%   n_spikes  - number of spikes in target event
%
%   Return:
%   sequence  - array of size 1 x (3*n_spikes)

%Author: Jewel Y. Lee (jewel87@uw.edu) 4/1/2018 last updated.
function sequence = makeSequence(h5file, spikeTime, window)
xloc = uint16((hdf5read([h5file '.h5'], 'xloc'))'); xloc=xloc+1;    % x location
yloc = uint16((hdf5read([h5file '.h5'], 'yloc'))'); yloc=yloc+1;    % y location
t_offset = spikeTime(1,1);          % relative time offset
features = 3*window;                % 3 features (t,x,y) for each spike
seq = zeros(3,window);
for row = size(spikeTime,1):-1:1    % for each timestep in this event
    t = spikeTime(row,1) - t_offset;     
    col = 2;                        % neuron idx starts at 2nd column
    % for all spikes in this timestep
    while spikeTime(row,col) > 0 && window > 0  
        seq(1,window) = t;
        seq(2,window) = xloc(spikeTime(row,col));
        seq(3,window) = yloc(spikeTime(row,col));
        col = col + 1;
        window = window - 1;
    end   
end
sequence = reshape(seq,[1,features]);
end