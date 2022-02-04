%GETBINNEDBURSTSPIKES Get spikes within every burst and save as binnedBurstFrames
%Read BrainGrid result dataset "spikesProbedNeurons" to retrieve location 
%of each spike that happended within a burst, save as flatten image arrays
% 
%   Syntax: getBinnedBurstSpikes(h5dir)
%   
%   Input:  h5dir  - BrainGrid simulation file (.h5)
%   the entire path is required for example
%   '/CSSDIV/research/biocomputing/data/tR_1.90--fE_0.90'
%
%   Output: <Binned/burst_n.csv>  - flattened image arrays of a burst 
% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Last updated: 11/19/2018
function getBinnedBurstSpikes(h5dir)
% h5dir = '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'              this line is used for testing
if ~exist([h5dir '/Binned'], 'dir')
       mkdir([h5dir '/Binned'])
end
head = 10;                      % number of bins before burst start bin
tail = 0;                       % number of bins after burst end bin
binSize = 100;                  % one bin becomes one frame
spikesProbedNeurons = (h5read([h5dir '.h5'], '/spikesProbedNeurons'))';
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];
binnedBurstsData = csvread(binnedBurstInfoFilePath,1,1);
nBursts = length(binnedBurstsData);                         % number of bursts identified
nNeurons = length(spikesProbedNeurons(1,:));                % number of neurons in simulation (this line gets the number of columns)
ended = length(spikesProbedNeurons(:,1));                   % gets number of rows in spikesProbedNeurons
% ------------------------------------------------------------------------
% Get spike info from spikesProbedNeurons for each burst
% ------------------------------------------------------------------------
% every column in "binnedBurstFrames" is a flatten image vector represents 100x100 
% image (Matlab is column-major). To see what triggers a burst, save 10 
% extra bins before burst starts 
% (NOTE: bin size = 10ms, time step size = 0.1 ms)
% ------------------------------------------------------------------------
for iBurst = 1:nBursts
    % get burst info from 10 bins before burst
    binnedBurstFrames = zeros(nNeurons, binnedBurstsData(iBurst,3)+head+tail, 'uint16');
    % converting start bin and end bin to include time step size
    startingTimeStep = (binnedBurstsData(iBurst,1)-head+1)*100;         % start bin# -> start time step
    endingTimeStep = (binnedBurstsData(iBurst,2)+tail)*100;             % end bin# -> end time step  
    % search spike time for each neuron (column in spikesProbedNeurons)
    for jNeuron = 1:nNeurons 
        % first non-zero element in column iBurst that is >= startingTimeStep
        start = find(spikesProbedNeurons(:,jNeuron) >= startingTimeStep, 1); 
        if isempty(start) == 0
            for k = start:ended
                if ((spikesProbedNeurons(k,jNeuron) >= startingTimeStep) && (spikesProbedNeurons(k,jNeuron) <= endingTimeStep))
                    % 10 ms in one frame => 100 time step
                    col = fix(((spikesProbedNeurons(k,jNeuron)-startingTimeStep))/binSize)+1;
                    binnedBurstFrames(jNeuron,col) = binnedBurstFrames(jNeuron,col)+1;
                elseif ((spikesProbedNeurons(k,jNeuron) > endingTimeStep) || (spikesProbedNeurons(k,jNeuron) == 0))
                    break;
                end 
            end
        end
    end
    outputFile = [h5dir '/Binned/burst_', num2str(iBurst), '.csv'];
    csvwrite(outputFile, binnedBurstFrames);
    fprintf('done with burst:%d/%d\n', iBurst, nBursts);
end
