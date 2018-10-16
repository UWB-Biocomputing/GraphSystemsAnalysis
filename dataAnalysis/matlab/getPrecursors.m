%GETPRECURSORS get precursor metadata (startTime, endTime, size)
%Given the spikeTime info and specified window size, gap size, generate
%metadata for precursor windows (preBurst and nonBurst window)
%  
%   Syntax: [prefile, nonfile] = getPrecursors(h5dir, window, gapPre, gapNon)
%   
%   Input:
%   h5dir  - BrainGrid simulation directory (file name of .h5)
%   window - number of spikes in precursor windows
%   gapPre - number of spikes between burst and preburst
%   gapNon - number of spikes between burst and nonburst
%
%   Return:
%   preName - preBurst precursor metadata filename
%   nonName - nonBurst precursor metadata filename
%
%   Output:
%   <preBurst_WINDOW_gap_gapPre.csv> - preBurst metadata
%   <nonBurst_WINDOW_gap_gapNon.csv> - nonBurst metadata

% Author: Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 5/20/2018
function [preName, nonName] = getPrecursors(h5dir, window, gapPre, gapNon)
% window = 500; gapPre = 0; gapNon = 2000;
% dir = '/Users/jewellee/Desktop/thesis-work/BrainGrid/tR_1.0--fE_0.90';
if (window + gapPre) > gapNon
    error(['preBurst window overlaps with nonBurst window\n', ...
           'window + gapPre have to be smaller than gapNon\n']);
end
% Read data
stepCount = csvread([h5dir '/allSpikeTimeCount.csv']);
burstInfo = csvread([h5dir '/allBurst.csv'],1,1);
n_bursts = length(burstInfo);

% Output files
preName = ['/preBurst', int2str(window), '_gap', int2str(gapPre)];
preFile = [h5dir, preName];
fid_pre = fopen([preFile '.csv'], 'w') ;
fprintf(fid_pre, 'ID,StartRow,EndRow,StartT,EndT,TotalSpikes\n');

nonName = ['/nonBurst', int2str(window), '_gap', int2str(gapNon)];  
nonFile = [h5dir, nonName];
fid_non = fopen([nonFile '.csv'], 'w') ;
fprintf(fid_non, 'ID,StartRow,EndRow,StartT,EndT,TotalSpikes\n');     

for i = 1:n_bursts
   spikes = 0;
   row = burstInfo(i,1);        % find burst start boundary
   while spikes < gapPre        % read backwards and count gapPre spikes
       row = row - 1;
       spikes = spikes + stepCount(row,2);       
   end
   % Identify preBurst data
   pre_spikes = 0; 
   preEnd = row - 1;            % mark preburst end boundary           
   while pre_spikes < window    % read backwards and count window spikes
       row = row - 1;
       pre_spikes = pre_spikes + stepCount(row,2);
   end
   preStart = row;              % mark preburst start boundary 
   fprintf(fid_pre,'%d,%d,%d,%d,%d,%d\n',i,preStart,preEnd, ...
           stepCount(preStart,1),stepCount(preEnd,1), ...
           sum(stepCount(preStart:preEnd,2))); 
   spikes = spikes + pre_spikes;
   while spikes < gapNon        % read backwards until gapNon spikes
       row = row - 1;
       spikes = spikes + stepCount(row,2);     
   end
   % Identify nonBurst data
   non_spikes = 0;
   nonEnd = row - 1;            % mark nonburst end boundary 
   while non_spikes < window    % read backwards and count window spikes
       row = row - 1;
       non_spikes = non_spikes + stepCount(row,2);     
   end
   nonStart = row;              % mark nonburst start boundary 
   fprintf(fid_non,'%d,%d,%d,%d,%d,%d\n',i,nonStart,nonEnd, ...
           stepCount(nonStart,1),stepCount(nonEnd,1), ... 
           sum(stepCount(nonStart:nonEnd,2)));  
end
fclose(fid_pre);    
fclose(fid_non);
% Prompt user the output filenames and directory
fprintf('Precursor filenames: <%s> & <%s> ', preName, nonName); 
fprintf('under the directorty: <%s>\n', h5dir); 
fprintf('(window: %d, gapPre: %d, gapNon: %d\n)',window,gapPre,gapNon); 
end