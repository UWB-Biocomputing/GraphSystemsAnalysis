%GETPRECURSORS get start/end time steps for precursors 
%Given the spikeTime info and specified windown and gap size, generate
%metadata for precursors (startTime, endTime, size, etc)
%  
%   Syntax:  [prefile, nonfile] = getPrecursors(window, gapPre, gapNon)
%   
%   Input:
%   window - number of spikes in precursor windows
%   gapPre - number of spikes between burst and preburst
%   gapNon - number of spikes between burst and nonburst
%
%   Return:s
%   prefile - preBurst precursor metadata filename
%   nonfile - nonBurst precursor metadata filename
%
%   Output:
%   <csv/preBurst_WINDOW_gap_gapPre.csv> - preBurst metadata
%   <csv/nonBurst_WINDOW_gap_gapNon.csv> - nonBurst metadata

%Author: Jewel Y. Lee (jewel87@uw.edu) 4/5/2018 last updated.
function [prefile, nonfile] = getPrecursors(window, gapPre, gapNon)
% window = 100; gapPre = 10; gapNon = 1000;
stepCount = csvread('csv/allSpikeTimeCount.csv');
burstInfo = csvread('csv/allBurst.csv',1,1);
n_burst = length(burstInfo);

% output files
prefile = ['csv/preBurst', int2str(window), ...
            '_gap', int2str(gapPre)];
fid_pre = fopen([prefile '.csv'], 'w') ;
fprintf(fid_pre, 'ID,StartRow,EndRow,StartT,EndT,TotalSpikes\n');
nonfile = ['csv/nonBurst', int2str(window), ...
            '_gap', int2str(gapNon)];     
fid_non = fopen([nonfile '.csv'], 'w') ;
fprintf(fid_non, 'ID,StartRow,EndRow,StartT,EndT,TotalSpikes\n');     

for i = 1:n_burst
   spikes = 0;
   row = burstInfo(i,1);
   while spikes < gapPre
       row = row - 1;
       spikes = spikes + stepCount(row,2);       
   end
   preEnd = row - 1;         % mark preburst boundary
   pre_spikes = 0;
   while pre_spikes < window
       row = row - 1;
       pre_spikes = pre_spikes + stepCount(row,2);
   end
   preStart = row;           % mark preburst boundary
   fprintf(fid_pre,'%d,%d,%d,%d,%d,%d\n',i,preStart,preEnd, ...
           stepCount(preStart,1),stepCount(preEnd,1), ...
           sum(stepCount(preStart:preEnd,2))); 
   spikes = spikes + pre_spikes;
   while spikes < gapNon
       row = row - 1;
       spikes = spikes + stepCount(row,2);     
   end
   nonEnd = row - 1;         % mark nonburst boundary
   non_spikes = 0;
   while non_spikes < window
       row = row - 1;
       non_spikes = non_spikes + stepCount(row,2);     
   end
   nonStart = row;           % mark nonburst boundary
   fprintf(fid_non,'%d,%d,%d,%d,%d,%d\n',i,nonStart,nonEnd, ...
           stepCount(nonStart,1),stepCount(nonEnd,1), ... 
           sum(stepCount(nonStart:nonEnd,2)));  
%    fprintf('done with burst %d/%d\n', i, n_burst); 
end
fprintf('window: %d, gapPre: %d, gapNon: %d\n',window,gapPre,gapNon); 
fclose(fid_pre);
fclose(fid_non);
end