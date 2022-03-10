% GETBINNEDBURSTSPIKES Get spikes within every burst and save as flattened images of arrays
%   of bursts. These are the results of "spike train binning", mentioned in lee-thesis18 Figure 4.1.
%   Spike train binning adds up the binary values for every. 
%   Read BrainGrid result dataset "spikesProbedNeurons" to retrieve location 
%   of each spike that happended within a burst, and save as flatten image arrays.
%
%   Example of flatten image arrays in a 5x5 matrix:
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
%   h5dir   -   BrainGrid simulation file (.h5)
%               the entire path is required for example
%               '/CSSDIV/research/biocomputing/data/tR_1.90--fE_0.90'
%
%   Output: 
%   <allFrames.mat>  - collection of flattened image arrays of a burst
%
% Author:   Jewel Y. Lee (jewel.yh.lee@gmail.com)
% Last updated: 02/22/2022  added documentation and changed output filetype to a single .mat file
% Last updated by: Vu T. Tieu (vttieu1995@gmail.com)

function getBinnedBurstSpikes(h5dir)
% h5dir = '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90';             
if ~exist([h5dir '/Binned'], 'dir')
       mkdir([h5dir '/Binned'])
end
head = 10;                      % number of bins before burst start bin,     start video before beginning of burst
tail = 0;                       % number of bins after burst end bin,        end video at last bin of burst
frameDuration = 100;            % one frame = 100 bin
spikesProbedNeurons = (h5read([h5dir '.h5'], '/spikesProbedNeurons'))';     % firing times & neuron IDs
binnedBurstInfoFilePath = [h5dir '/allBinnedBurstInfo.csv'];

% skipping the first column containing the burst ID, and the first row containing the names of the columns
burstInfo = csvread(binnedBurstInfoFilePath,1,1);    % read file with row offset by 1 and column offset by 1
nBursts = size(burstInfo,1);                         % number of bursts identified

% ended gets the number of row; nNeurons gets the number of columns/neurons
% (NOTE:    spikesProbedNeuron when read has columns as the number of neurons and rows 
%           as the time step)
[ended, nNeurons] = size(spikesProbedNeurons);

% ------------------------------------------------------------------------
% Get spike info from spikesProbedNeurons for each burst
% ------------------------------------------------------------------------
% Every column in "frame" is a flatten image vector represents 100x100 
% image (Matlab is column-major). A cell within a "frame" represents the spikerate
% at that x and y location. A "frame" could be understood as a collection of spikerates.
% To see what triggers a burst, save 10 extra bins before burst starts.
% The spikerate is produced using the method called spike train binning where the spike count
% at each x and y location is concatenated(summed) and compressed from 100 time steps.
% Each frame is then saved in one single .mat file for better performance.
% (NOTE:    bin size = 10ms, time step size = 0.1 ms)
% ------------------------------------------------------------------------
binSize = 10;                           % 10ms per bin
timeStepSize = .1;                      % 0.1ms per time step
binPerTimeStep = binSize/timeStepSize;  % 10/.1 = 100
allFrames = cell(1,nBursts);            % This stores all the frames produced by the loop below

for iBurst = 1:nBursts
    % Preallocate for a (number of neurons x width of bin) matrix used to store the output
    % The width of bin will differ depending on the burst ID (iburst)
    % A width is the number of bins in between each burst
    frame = zeros(nNeurons, burstInfo(iBurst,3) + head + tail, 'uint16');
    
    % get burst info from 10 bins before burst
    % converting start bin and end bin of each burst from allBinnedBurstInfo.csv
    % start and end bin is the bin that the burst starts and ends at
    burstStartBinNum = burstInfo(iBurst,1);     % the bin that this burst start, detected by
    burstEndBinNum   = burstInfo(iBurst,2);     % the bin that this burst ends
    startingTimeStep = (burstStartBinNum - head + 1) * binPerTimeStep;        % start bin# -> start time step
    endingTimeStep   = (burstEndBinNum + tail) * binPerTimeStep;              % end bin# -> end time step  
    
    % search spike time for each neuron (a column in spikesProbedNeurons is one neuron)
    for jNeuron = 1:nNeurons 
        % find index of first non-zero element in column jNeuron that is >= startingTimeStep
        start = find(spikesProbedNeurons(:,jNeuron) >= startingTimeStep, 1); 
        % if index exist, meaning start is not empty, then starting from that index 
        if isempty(start) == 0              
            for k = start:ended
                if ((spikesProbedNeurons(k,jNeuron) >= startingTimeStep) && (spikesProbedNeurons(k,jNeuron) <= endingTimeStep))
                    % 10 ms in one frame -> 100 time step
                    col = fix(((spikesProbedNeurons(k,jNeuron)-startingTimeStep))/frameDuration)+1;
                    frame(jNeuron,col) = frame(jNeuron,col)+1;              
                elseif ((spikesProbedNeurons(k,jNeuron) > endingTimeStep) || (spikesProbedNeurons(k,jNeuron) == 0))
                    break;
                end 
            end
        end
    end
    allFrames{iBurst} = frame;
% OLD CODE (writes to a csv file for each burst)
    %outfile = [h5dir 'Binned/burst_', num2str(i), '.csv'];
    %csvwrite(outfile, frame);
    fprintf('done with burst:%d/%d\n', iBurst, nBursts);
end

save([h5dir '/allFrames.mat'],'allFrames')