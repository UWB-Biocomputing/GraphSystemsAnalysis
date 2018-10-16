%% Jewel Y. Lee (last updated: Nov 27, 2017)
%  - need BrainGrid result (.h5), allBurstInfo.csv and Burst.m
%  - save spike places for every 10ms in frames
function getBurstSpikes(h5file)
% h5file = 'tR_1.0--fE_0.90_10000';
head = 10;                      % number of bins before burst start bin
tail = 0;                       % number of bins after burst end bin
binSize = 100;                  % one bin becomes one frame
P = (hdf5read([h5file '.h5'], 'spikesProbedNeurons'))';
bbInfoFile = [h5file '/binnedBurstInfo.csv'];
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
    frames = zeros(n_neurons, b(i,3)+10, 'uint16');
    s_time = (b(i,1)-head)*100;         % start bin# -> start time step
    e_time = (b(i,2)+tail)*100;         % end bin# -> end time step  
    % search spike time for each neuron (column in P)
    for j = 1:n_neurons 
        % first non-zero element in column i that is >= s_time
        start = find(P(:,j) >= s_time, 1); 
        if isempty(start) == 0
            for k = start:ended
                if ((P(k,j) >= s_time) && (P(k,j) <= e_time))
                    % 10 ms in one frame => 100 time step
                    col = fix(((P(k,j) - s_time - 1))/binSize)+1;
                    frames(j,col) = frames(j,col)+1;
                elseif ((P(k,j) > e_time) || (P(k,j) == 0))
                    break;
                end 
            end
        end
    end  
    outfile = [h5file '/Binned/burst_', num2str(i), '.csv'];
    csvwrite(outfile, frames);
    fprintf('done with burst:%d/%d\n', i, n_bursts);
end
