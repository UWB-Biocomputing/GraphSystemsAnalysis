%GETALLBURSTORIGINXYN Get approximate (X,Y) and N of burst initiation 
%Read <binnedBurstsData.csv> and get burst origin locations for all bursts
%by calling getBurstOriginXYN()
%
%   Syntax: getBurstOriginXY(h5dir)
%   
%   Input:  
%   h5dir  - BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%   the entire path is required for example
%   '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Output: 
%   <allBurstOriginXY.csv> - burst origin (x,y) location for every burst
%   <allBurstOriginN.csv> - burst origin neuron number for every burst

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/18/2018
function getAllBurstOriginXYN(h5dir)
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];
binnedBurstsData = csvread(binnedBurstInfoFilePath,1,1);
nBursts = length(binnedBurstsData);             % size of allBinnedBurstinfo.csv
originBin = 10;                                 % Origin bin

% Output files
outputFile1 = [h5dir '/allBurstOriginN.csv']; fid1 = fopen(outputFile1, 'w');
outputFile2 = [h5dir '/allBurstOriginXY.csv']; fid2 = fopen(outputFile2, 'w');

% get X Y N for each burst
for iBurst = 1:nBursts
    [X, Y, N] = getBurstOriginXYN(h5dir, originBin, iBurst);
    fprintf(fid1, '%d\n', N);  
    fprintf(fid2, '%d, %d\n', X, Y);  
end
fclose(fid1);
fclose(fid2);
end
