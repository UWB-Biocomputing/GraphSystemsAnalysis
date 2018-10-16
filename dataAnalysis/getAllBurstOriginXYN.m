%GETALLBURSTORIGINXYN Get approximate (X,Y) and N of burst initiation 
%Read <binnedBurstInfo.csv> and get burst origin locations for all bursts
%by calling getBurstOriginXYN()
%
%   Syntax: getBurstOriginXY(h5file)
%   
%   Input:  
%   h5file  - BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%
%   Output: 
%   <allBurstOriginXY.csv> - burst origin (x,y) location for every burst
%   <allBurstOriginN.csv> - burst origin neuron number for every burst

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/18/2018
function getAllBurstOriginXYN(h5file)
bbInfoFile = [h5file '/binnedBurstInfo.csv'];
bbInfo = csvread(bbInfoFile,1,1);
n_burst = length(bbInfo);                
o_bin = 10;  
% Output files
file1 = [h5file '/allBurstOriginN.csv']; fid1 = fopen(file1, 'w');
file2 = [h5file '/allBurstOriginXY.csv']; fid2 = fopen(file2, 'w');
 
for i = 1:n_burst
    [X, Y, N] = getBurstOriginXYN(h5file, o_bin, i);
    fprintf(fid1, '%d\n', N);  
    fprintf(fid2, '%d, %d\n', X, Y);  
end
fclose(fid1);
fclose(fid2);
end