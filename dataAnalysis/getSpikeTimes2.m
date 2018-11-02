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
% Last updated: 10/19/2018
function getSpikeTimes2(h5file) 
if exist([h5file '/allSpikeTime2.csv'],'file') == 2 || ...
    exist([h5file '/allSpikeTimeCount2.csv'],'file') == 2
    error('spikeTime file already exsited.');
end
% h5file = 'tR_1.0--fE_0.90_10000';
dataset = 'spikesProbedNeurons';
n_timesteps = getH5datasetSize(h5file, 'spikesHistory')*100; 
n_neurons = length(hdf5read([h5file '.h5'], 'neuronTypes'));
maxCol = getH5datasetSize(h5file, dataset);
% -----------------------------------------------------------------
% Output files
% -----------------------------------------------------------------
fid1 = fopen([h5file '/allSpikeTime2.csv'], 'w');           
fid2 = fopen([h5file '/allSpikeTimeCount2.csv'], 'w');     
% ------------------------------------------------------------------------ 
% Get spiking position(s) for every time step that has activities
% ------------------------------------------------------------------------
keeper = ones(n_neurons,1);          % keep track of columns, start with column 1
values = h5read([h5file '.h5'], ...  % keep next unrecorded firing time
                ['/' dataset],[1,1],[n_neurons,1]);
for i = 1:n_timesteps  
    % no more unrecorded data
    if any(values) == 0   
        break;                                  
    end
    time = min(values(values>0,1));             % next spiking time step
    idx = find(values == time);                 % neurons that fired at the same time  
    fprintf(fid1,'%d', time);                   % record time step 
    fprintf(fid2,'%d,%d\n',time,length(idx));   % record time and count 
    %%fprintf('time step: %d\n', time);         % for debugging  
    for j = 1:length(idx)   
        fprintf(fid1, ',%d', idx(j));           % record neuron number
        % keep track of next unrecorded column for each neuron
        keeper(idx(j)) = keeper(idx(j)) + 1;
        if keeper(idx(j)) <= maxCol
            % find the next unrecorded firing time (not -1s)
            values(idx(j)) = h5read([h5file '.h5'], ['/' dataset], ... 
                                    [idx(j),keeper(idx(j))],[1,1]); 
        else
            % no more spikes for this neuron to be recorded
            values(idx(j)) = 0;
        end
    end
fprintf(fid1, '\n');                             % done with this time step
%%fprintf('\n');                                 % for debugging 
end
fprintf('Total time steps that has activities: %d,', i);
fclose(fid1);    
fclose(fid2);
