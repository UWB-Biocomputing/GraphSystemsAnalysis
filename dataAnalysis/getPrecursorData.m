%GETPRECURSORDATA output (t, x, y) sequences for each  precursor window
%Read spikeTime and precursor metedata, for each precursor event, generate 
%data sequences by calling function "makeSequnece"
%  
%   Syntax:  sequence = makeSequence(h5dir, spikeTime, n_spikes)
%   
%   Input:
%   h5dir  - BrainGrid simulation directory (file name of .h5)
%   infile - precursor metadata filename (no extension)
%
%   Output:
%   <INFILE_Seq.csv>  - t,x,y sequence data for every sample

%Author: Jewel Y. Lee (jewel87@uw.edu)
%Last updated: 5/20/2018

function getPrecursorData(h5dir, infile) % takes 8-10 hours on raiju
outfile = [h5dir, '/', infile, '_Seq.csv'];
if exist(outfile,'file') == 2
    error('ERROR: outfile <%s> already exsited.',outfile);
end

% Read data
spikeTimeFile = [h5dir '/allSpikeTime.csv'];
tempfile = [h5dir, '/', infile, 'temp.csv'];
data = csvread([h5dir, '/', infile, '.csv'],1,1); 
window = min(data(:,5));	                % window width
n = size(data,1);                           % number of windows

% Output file
fid = fopen(outfile, 'w') ;     
for i = 1:n                                 
    % retrieve the range we need from allSpikeTime.csv
    command = ['sed -n ''', num2str(data(i,1)), ',', ...
    num2str(data(i,2)),' p'' ', spikeTimeFile, ' >', tempfile];
    system(command); 
    temp = csvread(tempfile);
    % for every spike in the event, convert them into t,x,y sequences
    sequence = makeSequence(h5dir, temp, window);
    for j = 1:window*3
        fprintf(fid, '%d,',sequence(j));
    end
    fprintf(fid,'\n'); 
    fprintf('Event: %d/%d\n', i, n);                  
end
fclose(fid);
end