% GETWINDOWS Determine avalanches and bursts from temporal information
% Read temporal spiking information (time steps and spike counts) and
% determine avalanches and bursts. Only uses temporal information, not
% spatial relationships among spikes.
% 
%   Syntax:  getWindows(directory)
%   
%   Input:
%   infile - time steps and # spikes (.csv)
%
%   Output:
%   <allAvalanche.csv> - avalanche information (1 row per avalanche)
%   <allBurst.csv> - burst information (1 row per burst)

function getWindows(directory)
% #########################################################################
spiketime = csvread([directory '/allSpikeTimeCount.csv']);
frame = spiketime(:,1);         % frames/timeStep that has activities
count = spiketime(:,2);         % spike counts for each frame
space = diff(frame);            % find interspike intervals (ISI)
totalCount = sum(count);        % total spike counts in the simulaiton
% -----------------------------------------------------------------
% Simulation parameters (yes, hard coded)
% -----------------------------------------------------------------
numSim = 600;                   % number of epochs
Tsim = 100;                     % seconds per epoch 
deltaT = 0.0001;                % time step size is 0.1 ms = 0.0001 sec
totalTimeSteps = numSim*Tsim*(1/deltaT);    % total number of time steps
meanISI = totalTimeSteps/totalCount;        % mean interspike interval (ts)
fprintf('Total time steps: %d\n', totalTimeSteps);
fprintf('Total spikes: %d\n', totalCount);
fprintf('meanISI: %.4f\n', meanISI);
% -----------------------------------------------------------------
% Output files
% -----------------------------------------------------------------
fid_aval = fopen('allAvalanche.csv', 'w') ;
fprintf(fid_aval, 'ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes\n');
fid_burst = fopen('allBurst.csv', 'w') ;
fprintf(fid_burst, 'ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes,IBI\n');

n_aval = 0;                     % number of avalanches 
n_bursts = 0;                   % number of bursts
last = 1;                       % keep track of last spike
i = 1;                          % incrementer 
while i < length(space)
    % --------------------------------------------------------------------- 
    % Identify avalanches and bursts
    % - if the interval of two spikes < meanISI, it's an avalanche event
    % - find where the avalanche ends and see if this avalanche is a burst
    % ---------------------------------------------------------------------
    if ((space(i) < meanISI) || (count(i) > 1))
        n_aval = n_aval + 1;
        j = i + 1;
        while ((j < length(space)) && (space(j) < meanISI))
            j = j + 1;
        end     
        width = j - i + 1;                          % duration (ts)
        totalSpikes = sum(count(i:j));              % total spike count  
        fprintf(fid_aval,'%d,%d,%d,%d,%d,%d,%d\n', ...
            n_aval,i,j,spiketime(i),spiketime(j),width,totalSpikes);
        % --------------------------------------------------------------------- 
        % Identify bursts 
        % - if the avalanche is a burst (spikeRate > burstThreshold)
        % - output prebursta and nonburst window information to output file
        % ---------------------------------------------------------------------
		% width > 1000 can also be a criteria to detect burst
        if totalSpikes > 10000 
            n_bursts = n_bursts + 1;
            interval = spiketime(i) - spiketime(last);           
            fprintf(fid_burst,'%d,%d,%d,%d,%d,%d,%d,%d\n',n_bursts,i,j, ...
                    spiketime(i),spiketime(j),width,totalSpikes,interval);                
            last = j;                   % save the time of last burst
            fprintf('done with burst %d\n', n_bursts);    
        end  
        i = j + 1;
    end
    i = i + 1;
end
fprintf('Total number of avalanches: %d\n', n_aval);
fprintf('Total number of bursts: %d\n', n_bursts);
fclose(fid_aval);
fclose(fid_burst);

