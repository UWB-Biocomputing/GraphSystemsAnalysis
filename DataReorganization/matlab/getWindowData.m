%% Jewel Y. Lee (Documented. Last updated: Jan 23, 2018)
%  - read <allSpikeTime.csv> and BrainGrid h5 file
%  - output t, x, y for each window to <pre/nonBurstData.csv>
%% TODO: make it output, and user input w on console
function getWindowData(infile)
% #########################################################################
% # USER_DEFINED VARIABLES ---------------------------------------------- #
% #########################################################################
% infile = 'preBurst'; 
% infile = 'nonBurst'; 
% h5file = 'tR_1.0--fE_0.90_10000'; % simulation file
% infile = 'preBurst100';
% #########################################################################
% xloc = double((hdf5read([h5file '.h5'], 'xloc'))');     % x location
% yloc = double((hdf5read([h5file '.h5'], 'yloc'))');     % y location
spikeTimeFile = 'allSpikeTime.csv';         
data = csvread([infile '.csv'],1,1);        % read window info 
w = min(data(:,5));	                        % window width
n = size(data,1);                           % n pre/non burst events 
%fid1 = fopen([infile 'Seq.csv'], 'w') ;     % output file for ML
% fid2 = fopen([infile 'Img.csv'], 'w') ;
% ------------------------------------------------------------------------- 
% For each window, write out every spike in the following format:
% - t, x, y, t, x, y, ... (Note: t is relative time to the first spike)
% - so each line contains w spikes (window width)
% - and number of lines are number of examples
% -------------------------------------------------------------------------
% allImages = zeros(n,10000);
for i = 1:150                                 % number of examples
    % --------------------------------------------------------------------- 
    % sed -n 'startRow,endRow p' allSpikeTime.csv > temp.csv
    % - reading allSpikeTime.csv is too slow and we don't need most of it
    % - so for each window, output only that window to temp.csv
    % ---------------------------------------------------------------------
    command = ['sed -n ''',num2str(data(i,1)),',',...
        num2str(data(i,2)),' p'' ',spikeTimeFile,' > temp.csv'];
    system(command);                
    temp = csvread('temp.csv');
    % ---------------------------------------------------------------------
    % for each timestep in the window, convert all neuron index to x, y
    % ---------------------------------------------------------------------
%     sequence = makeSequences(temp, w);
%     fprintf(fid1,sequence); %%bug, need to fix
%     fprintf(fid1,'\n'); 

    % allImages(i,:) = makeImgArray(temp, w);
    frames = makeFrames(temp, 10000); 
    outfile = strcat(infile, '/frames_', int2str(i), '.csv');
    dlmwrite(outfile, frames);
    fprintf('Event: %d/%d\n', i, n);                  % debugging
end
% fclose(fid1);
% dlmwrite([infile 'Img.csv'], allImages);
end
