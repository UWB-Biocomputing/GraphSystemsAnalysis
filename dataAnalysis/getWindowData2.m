%% Jewel Y. Lee (Documented. Last updated: Jan 21, 2018)
%  - read <allSpikeTime.csv> and BrainGrid h5 file
%  - output t, x, y for each window to <pre/nonBurstData.csv>
%% TODO: make it output, and user input w on console
function getWindowData(infile)
% #########################################################################
% # USER_DEFINED VARIABLES ---------------------------------------------- #
% #########################################################################
% infile = 'preBurst'; 
% infile = 'nonBurst'; 
h5file = '1102_full_tR_1.0--fE_0.90_10000'; % simulation file
w = 500;                                    % window width
% #########################################################################
xloc = double((hdf5read([h5file '.h5'], 'xloc'))');     % x location
yloc = double((hdf5read([h5file '.h5'], 'yloc'))');     % y location
% -------------------------------------------------------------------------
% spikeTimeFile = 'allSpikeTime.csv';         
temp = csvread('allSpikeTime.csv');         % spikes in time step
data = csvread([infile '.csv'],1,1);        % read window info 
% 1. StartRow, 2.EndRow, 3.StartT, 4.EndT, 5.Width, 6.TotalSpikeCount
n = length(data);                           % n pre/non burst events 
fid = fopen([infile 'Data.csv'], 'w') ;     % output file for ML           
% ------------------------------------------------------------------------- 
% For each window, write out every spike in the following format:
% - t, x, y, t, x, y, ... (Note: t is relative time to the first spike)
% - so each line contains w spikes (window width)
% - and number of lines are number of examples
% -------------------------------------------------------------------------
for i = 1:n                                 % number of examples
    counter = 0;
    % --------------------------------------------------------------------- 
    % sed -n 'startRow,endRow p' allSpikeTime.csv > temp.csv
    % - reading allSpikeTime.csv is too slow and we don't need most of it
    % - so for each window, output only that window to temp.csv
    % ---------------------------------------------------------------------
    startRow = data(i,1)-1; % row numbers are off by 1 because header row
    endRow = data(i,2)-1;   % row numbers are off by 1 because header row
%     command = ['sed -n ''',num2str(data(i,1)),',',...
%         num2str(data(i,2)),' p'' ',spikeTimeFile,' > temp.csv'];
%     system(command);                
%     temp = csvread('temp.csv');
    % ---------------------------------------------------------------------
    % for each timestep in the window, convert all neuron index to x, y
    % ---------------------------------------------------------------------
    offset = data(i,3);                 % relative time offset
    for j = startRow:endRow             % each time step in the window
        time = temp(j,1) - offset;      % time step   
        k = 2;                          % neuron index
        % all neuron index in this timestep
        while temp(j,k) > 0 && counter < w  
            %fprintf('%d,%d,%d,\n', time,xloc(temp(j,k)),yloc(temp(j,k)));
            fprintf(fid,'%d,%d,%d,', time,xloc(temp(j,k)),yloc(temp(j,k)));
            k = k + 1;
            counter = counter + 1;
        end   
        %fprintf('ID: %d, time step: %d\n',i,j);
    end
    fprintf('%d ', i);                  % debugging
    fprintf(fid,'\n');                  % next example data
end
fclose(fid);