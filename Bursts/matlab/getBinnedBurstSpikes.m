%GETBINNEDBURSTSPIKES Get spikes within every burst and save as frames
%Read BrainGrid result dataset "spikesProbedNeurons" to retrieve location 
%of each spike that happended within a burst, save as flatten image arrays
% 
%   Syntax: getBinnedBurstSpikes(h5dir)
%   
%   Input:  h5dir  - BrainGrid simulation file (.h5)
%
%   Output: <Binned/burst_n.csv>  - flattened image arrays of a burst 
% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Last updated: 11/19/2018
function getBinnedBurstSpikes(h5dir)
% h5dir = '/CSSDIV/research/biocomputing/data/tR_1.9--fE_0.98'
if ~exist([h5dir '/Binned'], 'dir')
       mkdir([h5dir '/Binned'])
end
head = 10;                      % number of bins before burst start bin
tail = 0;                       % number of bins after burst end bin
binSize = 100;                  % one bin becomes one frame
P = (hdf5read([h5dir '.h5'], 'spikesProbedNeurons'))';
bbInfoFile = [h5dir '/allBinnedBurstInfo.csv'];
b = csvread(bbInfoFile,1,1);
n_bursts = length(b);                   % number of bursts identified
n_neurons = length(P(1,:));             % number of neurons in simulation
ended = length(P(:,1));
% ------------------------------------------------------------------------
% Get spike info from spikesProbedNeurons for each burst
% ------------------------------------------------------------------------
% every column in "frames" is a flatten image vector represents 100x100 
% image (Matlab is column-major). To see what triggers a burst, save 10 
% extra bins before burst starts 
% (NOTE: bin size = 10ms, time step size = 0.1 ms)
% ------------------------------------------------------------------------
for i = 1:n_bursts
    % get burst info from 10 bins before burst
    frames = zeros(n_neurons, b(i,3)+head+tail, 'uint16');
    s_time = (b(i,1)-head+1)*100;       % start bin# -> start time step
    e_time = (b(i,2)+tail)*100;         % end bin# -> end time step  
    % search spike time for each neuron (column in P)
    for j = 1:n_neurons 
        % first non-zero element in column i that is >= s_time
        start = find(P(:,j) >= s_time, 1); 
        if isempty(start) == 0
            for k = start:ended
                if ((P(k,j) >= s_time) && (P(k,j) <= e_time))
                    % 10 ms in one frame => 100 time step
                    col = fix(((P(k,j)-s_time))/binSize)+1;
                    frames(j,col) = frames(j,col)+1;
                elseif ((P(k,j) > e_time) || (P(k,j) == 0))
                    break;
                end 
            end
        end
    end  
    outfile = [h5dir '/Binned/burst_', num2str(i), '.csv'];
    csvwrite(outfile, frames);
    fprintf('done with burst:%d/%d\n', i, n_bursts);
end
