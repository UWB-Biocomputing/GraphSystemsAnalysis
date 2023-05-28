% GETBINNEDBURSTSPIKES Get spikes within every burst and save as flattened images of arrays
%   of bursts. These are the results of "spike train binning", mentioned in lee-thesis18 Figure 4.1.
%   Spike train binning adds up the binary values for every. 
%   Read BrainGrid result dataset "spikesProbedNeurons" to retrieve location 
%   of each spike that happended within a burst, and save as flatten image arrays.
%
%   Example of flattened image arrays in a 5x5 matrix:
%       1 1 2 0 1                       
%       1 2 2 1 1
%       1 3 2 1 0
%       2 2 2 3 1
%       0 1 3 2 2
%   Each cell in a matrix this function output represents a pixel in which the number indicates how bright it is
%   with 5 being the highest value. The values in each cell is the result of "spike train binning" (this functions main algorithm)
%   This value can be understood as sum of all spike rate within 100 time step at that specific
%   x and y location.
%   
%   Syntax: getBinnedBurstSpikes(h5dir)
%   
%   Input:  
%   h5dir   -   BrainGrid dataset name (.h5)
%               the entire path can be used; for example
%               '/CSSDIV/research/biocomputing/data/tR_1.90--fE_0.90'
%
%   Output: 
%   <allFrames.mat>  - collection of flattened image arrays of a burst
%
% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Updated: 02/22/2022  added documentation and changed output filetype to a single .mat file
% Updated by: Vu T. Tieu (vttieu1995@gmail.com)
% Updated: May 2023 minor tweaks
% Updated by: Michael Stiber

function getBinnedBurstSpikes(h5dir)

head = 10;                      % number of bins before burst start bin to include
tail = 0;                       % number of bins after burst end bin to include

fprintf('Starting read of spikes from HDF5 file...');
spikesProbedNeurons = (h5read([h5dir '.h5'], '/spikesProbedNeurons'))';     % firing times & neuron IDs
fprintf(' done\n');
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];

% skipping the first column containing the burst ID, and the first row
% containing the names of the columns
burstInfo = readmatrix(binnedBurstInfoFilePath, 'Range', [2 2]);
nBursts = size(burstInfo,1);

% ended gets the number of row; nNeurons gets the number of columns/neurons
% (NOTE:    spikesProbedNeuron when read has columns as the number of neurons and rows 
%           as the number of time steps)
[ended, nNeurons] = size(spikesProbedNeurons);

% ------------------------------------------------------------------------
% Get spike info from spikesProbedNeurons for each burst
% ------------------------------------------------------------------------
% We build an "allFrames" cell array, in which each element corresponds to
% a burst. For each burst, we build a "frame" array, in which each row is a
% neuron and each column is a time bin (timeStepsPerBin is the computation
% of the number of simulation time steps in a bin, duh). For each frame,
% the value at (neuron, bin) is the number of spikes produced by that
% neuron in that bin.
% ------------------------------------------------------------------------
binSize = 10;                           % 10ms per bin
timeStepSize = 0.1;                     % 0.1ms per time step
timeStepsPerBin = binSize/timeStepSize; % 10/0.1 = 100 in the above case
allFrames = cell(1,nBursts);            % This stores all the frames produced by the loop below

% Get the analysis start time, to track how long this is taking
fprintf('Starting analysis...\n')
allStartTime = tic;
for iBurst = 1:nBursts
    % Get the current burst start time
    curBurstStartTime = tic;
    % Preallocate for a (number of neurons x number of bins) matrix used to store the output
    % The number of bins will differ depending on the burst ID (iburst)
    frame = zeros(nNeurons, burstInfo(iBurst,3) + head + tail, 'uint16');
    
    % get burst spikes from 10 bins before burst
    % converting start bin and end bin of each burst from allBinnedBurstInfo.csv
    % start and end bin is the bin that the burst starts and ends at
    burstStartBinNum = burstInfo(iBurst,1);     % starting bin
    burstEndBinNum   = burstInfo(iBurst,2);     % ending bin
    startingTimeStep = (burstStartBinNum - head + 1) * timeStepsPerBin;        % start bin# -> start time step
    endingTimeStep   = (burstEndBinNum + tail) * timeStepsPerBin;              % end bin# -> end time step  
    
    % search spike time for each neuron (a column in spikesProbedNeurons is one neuron)
    for jNeuron = 1:nNeurons 
        % find index of first non-zero element in column jNeuron that is >= startingTimeStep
        start = find(spikesProbedNeurons(:,jNeuron) >= startingTimeStep, 1);
        % if index exist, meaning start is not empty, then starting from that index 
        if ~isempty(start)
            for k = start:ended
                curSpikeTime = spikesProbedNeurons(k,jNeuron);
                if ((curSpikeTime >= startingTimeStep) && (curSpikeTime <= endingTimeStep))
                    % spike falls within burst; determine which bin
                    bin = fix(((curSpikeTime-startingTimeStep))/timeStepsPerBin)+1;
                    % we're just counting the number of spikes for this
                    % neuron and bin
                    frame(jNeuron,bin) = frame(jNeuron,bin)+1;              
                elseif ((curSpikeTime > endingTimeStep) || (curSpikeTime == 0))
                    break;
                end 
            end
        end
    end
    allFrames{iBurst} = frame;

    % Calculate statistics to give user feedback
    curBurstElapsedTime = toc(curBurstStartTime);
    curTotalElapsedTime = toc(allStartTime);
    fractionBurstsDone = iBurst/nBursts;
    averageTimePerBurst = curTotalElapsedTime/iBurst;
    totalEstimatedTime = averageTimePerBurst * nBursts;
    remainingEstimatedTime = totalEstimatedTime - curTotalElapsedTime;

    fprintf('\tdone with burst:%d/%d (%.1f%%) in %.1f sec (%.1f remaining)\n', ...
        iBurst, nBursts, fractionBurstsDone*100, curBurstElapsedTime, ...
        remainingEstimatedTime);
end

save([h5dir '/allFrames.mat'],'allFrames','-v7.3');
