%MAKEALLSEQUENCE output precursor sequence file
%Read spikeTime and precursor metedata, generate t,x,y sequence file  
%  
%   Syntax:  sequence = makeSequence(h5dir, spikeTime, n_spikes)
%   
%   Input:
%   h5dir - BrainGrid simulation result (.h5)
%   infile - precursor metadata filename
%   window - number of spikes in target event
%
%   Output:
%   <INFILE_Seq.csv>  - t,x,y sequence data for every sample

%Author: Jewel Y. Lee (jewel87@uw.edu) 4/2/2018 last updated.
%% takes about 8-10 hours on raiju
function makeAllSequence(h5dir, infile, window)
% infile = 'csv/nonBurst_100_gap_1000';
% infile = 'csv/preBurst_100_gap_10';
% h5dir = 'tR_1.0--fE_0.90_10000';
% infile = 'csv/nonBurst_100_gap_1000';
% window = 100;
% #########################################################################
spikeTimeFile = [h5dir '/allSpikeTime.csv'];    
data = csvread([infile '.csv'],1,1);        % read window info 
w = min(data(:,5));	                        % window width
if window > w
    error('ERROR: Wrong window size given');
end
n = size(data,1);     
fid = fopen([infile '_Seq.csv'], 'w') ;     % output file for ML
for i = 1:n                                 % number of examples
    command = ['sed -n ''',num2str(data(i,1)),',',...
        num2str(data(i,2)),' p'' ',spikeTimeFile,' > ', infile,'_temp.csv'];
    system(command);                
    temp = csvread([infile,'_temp.csv']);
    % for every spike in the event, convert them into t,x,y sequences
    sequence = makeSequence(h5dir, temp, window);
    for j = 1:window*3 
        fprintf(fid, '%d,',sequence(j));
    end
    fprintf(fid,'\n'); 
    % debugging
    fprintf('Event: %d/%d\n', i, n);                  
end
fclose(fid);
end
