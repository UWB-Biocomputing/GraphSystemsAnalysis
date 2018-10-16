%% Jewel Y. Lee (last updated: Nov 27, 2017)
%  - need BrainGrid result (.h5), allBurstInfo.csv and Burst.m
%  - save spike places for every 10ms in frames
function getBurstSpikes(infile)
% infile = '1011_half_tR_1.0--fE_0.90_10000';
% infile = '1102_full_tR_1.0--fE_0.90_10000';
P = double((hdf5read([infile '.h5'], 'spikesProbedNeurons'))');
b = csvread('allBurstInfo.csv',1,1);
numBurst = length(b);                   % number of bursts identified
numNeurons = length(P(1,:));            % number of neurons in simulation
ended = length(P(:,1));
% ------------------------------------------------------------------------
% Get spike info from spikesProbedNeurons for each burst
% ------------------------------------------------------------------------
% every column in "frames" is a flatten image vector represents 100x100 
% image (Matlab is column-major). To see what triggers a burst, save 10 
% extra bins before burst starts 
% (NOTE: bin size = 10ms, time step size = 0.1 ms)
% ------------------------------------------------------------------------
for i = 1805:numBurst
    % get burst info from 10 bins before burst
    frames = zeros(numNeurons, b(i,3)+10, 'int8');
    s_time = (b(i,1)-10) * 100;         % start bin# -> start time step
    e_time = b(i,2) * 100;              % end bin# -> end time step  
    % search spike time for each neuron (column in P)
    for j = 1:numNeurons 
        % first non-zero element in column i that is >= s_time
        start = find(P(:,j) >= s_time, 1); 
        if isempty(start) == 0
            for k = start:ended
                if ((P(k,j) >= s_time) && (P(k,j) <= e_time))
                    % 10 ms in one frame => 100 time step
                    col = fix(((P(k,j) - s_time - 1)) / 100) + 1;
                    frames(j,col) = frames(j,col) + 1;
                elseif ((P(k,j) > e_time) || (P(k,j) == 0))
                    break;
                end 
            end
        end
    end
    filename=strcat('bursts/burst', num2str(i), '.mat');
    save(filename,'frames');
    clearvars frames;
    fprintf('done with burst%d\n', i);
end
