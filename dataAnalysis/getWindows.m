%GETWINDOWS 
% 
%   Syntax:  getWindows(h5dir)
%   
%   Input:
%   h5dir - BrainGrid simulation directory name (name of the h5 file)
%
%   Output:
%   <allAvalanche.csv> - spike time step and neuron indexes 
%   <allBurst.csv>     - spike time step and number of spikes

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 5/09/2018
function getWindows(h5dir)
spiketime = csvread([h5dir '/allSpikeTimeCount.csv']);
space = diff(spiketime(:,1));        % find interspike intervals (ISI)
totalCount = sum(spiketime(:,2));    % total spike counts in the simulaiton
% -----------------------------------------------------------------
% Simulation parameters              % time step: 0.1ms = 0.0001s
% -----------------------------------------------------------------
n_bins = getH5datasetSize(h5dir,'spikesHistory');
binSize = 100;                       % 10ms = 100 time steps
totalTimeSteps = n_bins*binSize;     % total number of time steps
meanISI = totalTimeSteps/totalCount; % mean interspike-interval (ts)

fprintf('Total time steps: %d\n', totalTimeSteps);
fprintf('Total spikes: %d\n', totalCount);
fprintf('meanISI: %.4f\n', meanISI);
% -----------------------------------------------------------------
% Output files
% -----------------------------------------------------------------
fid_aval = fopen([h5dir '/allAvalanche.csv'], 'w') ;
fprintf(fid_aval, 'ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes\n');
fid_burst = fopen([h5dir '/allBurst.csv'], 'w') ;
fprintf(fid_burst, 'ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes,IBI\n');
n_avals = 0;                        % number of avalanches 
n_bursts = 0;                       % number of bursts
last = 1;                           % keep track of last spike
i = 1;                              % incrementer 
while i < length(space)
    % --------------------------------------------------------------------- 
    % Identify avalanches
    % - if the interval of two spikes < meanISI or there are more than 2
    %   spikes in one timestep, it's an avalanche event
    % ---------------------------------------------------------------------
    if ((space(i) < meanISI) || (spiketime(i,2) > 1))
        n_avals = n_avals + 1;                        
        % see how many continuous timesteps are in this avalanche
        j = i + 1;                     
        while ((space(j) < meanISI) && (j < length(space)))
            j = j + 1;
        end     
        width = j - i + 1;                          % duration (ts)
        n_spikes = sum(spiketime(i:j, 2));          % avalanche size
        fprintf(fid_aval,'%d,%d,%d,%d,%d,%d,%d\n', ...
                n_avals,i,j,spiketime(i,1),spiketime(j,1), ...
                width,n_spikes);
        % --------------------------------------------------------------------- 
        % Identify bursts 
        % - if the avalanche is a burst (spikeRate > burstThreshold),
        %   output prebursta and nonburst window info to output file
        % ---------------------------------------------------------------------
        % width > 1e3? or n_spikes > 1e4 can be criteria to detect burst
        if n_spikes > 1e4
            n_bursts = n_bursts + 1;
            interval = spiketime(i,1) - spiketime(last,1);           
            fprintf(fid_burst,'%d,%d,%d,%d,%d,%d,%d,%d\n',...
                    n_bursts,i,j,spiketime(i,1),spiketime(j,1),...
                    width,n_spikes,interval);                
            last = j;                   % save the time of last burst
            fprintf('done with burst %d\n', n_bursts);    
        end  
        i = j + 1;
    end
    i = i + 1;                          % increment i
end
fprintf('Total number of avalanches: %d\n', n_avals);
fprintf('Total number of bursts: %d\n', n_bursts);
fclose(fid_aval);
fclose(fid_burst);

