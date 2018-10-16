%GETSPIKETIMES Get firing time steps and its firing neuron and spike count
%Read BrainGrid result in HDF5 format and convert spikesProbedNeurons to 
%easy-to-understand format for data analysis
% 
%   Syntax: getSpikeTimes(h5file)
%   
%   Input:  h5file  - BrainGrid simulation result (.h5)
%
%   Output: <allSpikeTime.csv>      - spike time step and neuron indexes 
%           <allSpikeTimeCount.csv> - spike time step and number of spikes

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 5/09/2018
function getSpikeTimes(h5dir)
if exist([h5dir '/allSpikeTime.csv'],'file') == 2 || ...
    exist([h5dir '/allSpikeTimeCount.csv'],'file') == 2
    error('spikeTime file already exsited.');
end
% ------------------------------------------------------------------------ 
% Read from input data and open output file
% - spikesProbedNeurons = neurons and its firing times (column = neuron)
% - spikesHistory = spike count in each 10ms bins
% ------------------------------------------------------------------------
dataset = 'spikesProbedNeurons';
P = hdf5read([h5dir '.h5'], dataset);
n_timesteps = getH5datasetSize(h5dir, 'spikesHistory')*100;            
n_neurons = size(P,1);                      % total number of neurons
maxCol = size(P,2);                         % maximum firing times/cols
P = [P zeros(n_neurons,1)];                 % for boundary condition
% -----------------------------------------------------------------
% Output files
% -----------------------------------------------------------------
fid1 = fopen([h5dir '/allSpikeTime.csv'], 'w');           
fid2 = fopen([h5dir '/allSpikeTimeCount.csv'], 'w');
% ------------------------------------------------------------------------ 
% Get spiking position(s) for every time step that has activities
% ------------------------------------------------------------------------
keeper = ones(n_neurons,1);     % keep track of columns, start with column 1
values = P(:,1);                % keep next unrecorded firing time
for i = 1:n_timesteps
     % no more unrecorded data
    if any(values) == 0  
        break;      
    end
    time = min(values(values>0,1));             % next spiking time step 
    idx = find(values == time);                 % neurons that fired at the same time
    fprintf(fid1,'%d', time);                   % record time step 
    fprintf(fid2,'%d,%d\n',time,length(idx));   % record time and count 
%     fprintf('time step: %d\n', time);         % for debugging 
    for j = 1:length(idx)   
        fprintf(fid1, ',%d', idx(j));           % record neuron number
        % keep track of next unrecorded column for each neuron 
        keeper(idx(j)) = keeper(idx(j)) + 1;     
        if keeper(idx(j)) <= maxCol
            % find the next unrecorded firing time (not -1s)
            values(idx(j)) = P(idx(j), keeper(idx(j)));
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