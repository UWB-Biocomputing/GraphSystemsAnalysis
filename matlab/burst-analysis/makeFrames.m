%MAKEFRAMES create one frame per timestep for target event
%Read spikeTime info for the target event (nonBurst, preBurst or Burst) and
%return a matrix with every row is a flatten image for each timestep. 
%In each image, pixel represents a neuron and if it spiked(=1) or not (=0)
% 
%   Syntax: frames = makeFrames(spikeTime, n_neurons)
%   
%   Input:
%   spikeTime - matrix contains spikeTime info for target event
%
%   Output:
%   frames - matrix of flatten images. size = timesteps x n_neurons

%Author: Jewel Y. Lee (jewel87@uw.edu)
function frames = makeFrames(spikeTime)
load('config.mat','n_neurons')
n = size(spikeTime, 1);         % number of rows in spikeTime
start = spikeTime(1,1);         % start time step
ended = spikeTime(n,1);         % ended time step
%% one image(frame) per timestep
length = ended - start + 1;     % total timestep span
frames = zeros(length,n_neurons);
for row = 1:n
    col = 2;                    
    while spikeTime(row,col) ~= 0
        % each column vector contains activities in each time step
        frames(spikeTime(row,1)-start+1, spikeTime(row,col)) = 1;
        col = col + 1;
    end
end
end