%GETALLBURSTSPEED get propagation speed for all bursts (unit: neurons/ms)
%Read burst origins (allBurstOriginN.csv) and call getBurstSpeed 
% 
%   Syntax: [speed, m_speed] = getBurstSpeed(h5file, id, origin)
%   
%   Input:  
%   h5file  - BrainGrid result filename (e.g. tR_1.0--fE_0.90_10000)
%   id      - burst ID
%   origin  - burst origin location (neuron number)
%
%   Output: 
%   <allBurstSpeedMean.csv>     - mean speed for each burst
%   <allBurstSpeed.csv>         - all speeds between bins 

% Author:   Jewel Y. Lee (jewel87@uw.edu)
% Last updated: 4/19/2018
function getAllBurstSpeed(h5file)
origins = csvread([h5file '/allBurstOriginN.csv']);
n_bursts = size(origins,1);

% Output files
file1 = [h5file '/allBurstSpeedMean.csv']; fid1 = fopen(file1, 'w');
file2 = [h5file '/allBurstSpeed.csv']; fid2 = fopen(file2, 'w');

for i = 1:n_bursts
    [S, M] = getBurstSpeed(h5file, i, origins(i));  
    fprintf(fid1, '%.4f\n', M);  
    n = length(S);
    for j = 1:n
        fprintf(fid2, '%.4f,', S(j)); 
    end
     fprintf(fid2, '\n'); 
end
end