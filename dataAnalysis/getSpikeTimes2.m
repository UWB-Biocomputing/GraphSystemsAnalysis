%GETSPIKETIMES2 Get firing time steps and its firing neuron and spike count
%Read BrainGrid result in HDF5 format and convert spikesProbedNeurons to 
%easy-to-understand format for data analysis. NOTE: This script read HDF5 
%file a little at a time so won't be restricted by MATLAB RAM usage
% 
%   Syntax: getSpikeTimes(h5file)
%   
%   Input:  h5file  - BrainGrid simulation result (.h5)
%
%   Output: <allSpikeTime.csv>      - spike time step and neuron indexes 
%           <allSpikeTimeCount.csv> - spike time step and number of spikes

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/17/2018
function getSpikeTimes2(h5file) 
if exist([h5file '/allSpikeTime.csv'],'file') == 2 || ...
    exist([h5file '/allSpikeTimeCount.csv'],'file') == 2
    error('spikeTime file already exsited.');
end
% h5file = 'tR_1.0--fE_0.90_10000';
dataset = 'spikesProbedNeurons';
size = getH5datasetSize(h5file, dataset);
n_timesteps = getH5datasetSize(h5file, 'spikesHistory')*100; 
n_neurons = length(hdf5read([h5file '.h5'], 'neuronTypes'));   
% output file name
fid1 = fopen([h5file '/allSpikeTime.csv'], 'w');           
fid2 = fopen([h5file '/allSpikeTimeCount.csv'], 'w');     
% ------------------------------------------------------------------------ 
% Get spiking position(s) for every time step that has activities
% ------------------------------------------------------------------------
keeper = ones(n_neurons,1);
P = h5read([h5file '.h5'], ['/' dataset], [1,1],[n_neurons,1]);
for i = 1:n_timesteps  
    % no more non-recorded data
    if any(P) == 0   
        break;                                  
    end
    time = min(P(P>0,1));                       % get spiking timestep 
    idx = find(P == time);                      % get all spiking neuron(s)    
    fprintf(fid1, '%d', time);                  % record time step 
    fprintf(fid2,'%d,%d\n',time,length(idx));   % record time and count 
    %%fprintf('time step: %d; neuron#:', time); % for debugging 
    for j = 1:length(idx)   
        %%fprintf('%d,', idx(j));               % for debugging 
        fprintf(fid1, ',%d', idx(j));           % record neuron number    
        keeper(idx(j)) = keeper(idx(j)) + 1;
        if keeper(idx(j)) <= size
            P(idx(j)) = h5read([h5file '.h5'], ['/' dataset], [idx(j),keeper(idx(j))],[1,1]); 
        else
            P(idx(j)) = 0;
        end
    end
fprintf(fid1, '\n');                             % done with this time step
%%fprintf('\n');                                 % for debugging 
end
fprintf('Total time steps that has activities: %d,', i);
fclose(fid1);    
fclose(fid2);
