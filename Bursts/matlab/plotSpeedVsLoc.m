% Plot of starter neuron thresholds and burst origins
% PLOTSPEEDVSLOC plot burst propagation speed as image within network space
%
%   Syntax: plotSpeedVsLoc(h5dir, chunks, layoutSize)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   chunks -     which of the burstOriginMovement subplots to use for
%                overlaying (counting from zero). Can be a scalar, in which
%                case just that subplot is used, or a vector, in which case
%                all subplots from the min through max value of that vector,
%                inclusive, are used
%   layoutSize - Indicates the size of the burstOriginMovement subplots
%                (number of chunks is layoutSize x layoutSize)
%
%   Output:
%   <h5dir-meanspeedvsloc.pdf>    - starter neuron mean speed vs location
%   <h5dir-covspeedvsloc.pdf>     - starter neuron speed coefficient of
%                                   variation vs location


function plotSpeedVsLoc(h5dir, chunks, layoutSize)

% Default layout
if nargin < 2
    layoutSize = 5;
end

% Burst origins
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Get multi-bursts (Matlab numbering; starting with 1)
multiBurstIDs = readmatrix([h5dir '/multipleBursts.csv']);

% Generate list of non-multibursts
burstIDs = 1:size(origins, 1);
burstIDs = setdiff(burstIDs, multiBurstIDs);

% Excise the multi-burst data from origins
origins = origins(burstIDs,:);

% Burst speeds
speeds = readmatrix([h5dir '/allBurstSpeedMean.csv']);

% Create a cell array to hold a vector of burst speeds for each 10x10 tile
tileSpeeds = cell(10);

% Determine set of burst indices we will be working on
analysisStart = 1;
analysisEnd = size(origins,1);
totalGraphs = layoutSize*layoutSize;
numBurstsPerChunk = ceil((analysisEnd - analysisStart+1) / totalGraphs);
numChunks = max(chunks) - min(chunks) + 1;
startBurst = analysisStart + numBurstsPerChunk * min(chunks);
endBurst = min(startBurst+(numBurstsPerChunk * numChunks)-1,analysisEnd);

% Convert the origin Graphitti (x, y) locations to origin (tileX, tileY).
% Graphitti coordinates' range is [0, 99]; these will be zero-based.
tileX = floor(origins(:,1) / 10);
tileY = floor(origins(:,2) / 10);

% Put each burst speeds in its tile. Remember that Y is rows and X is cols
% and that we need to convert zero-based to one-based.
for i = startBurst:endBurst
    tileSpeeds{tileY(i)+1, tileX(i)+1} = [tileSpeeds{tileY(i)+1, tileX(i)+1} speeds(i)];
end

% Compute mean and standard deviation of each tile
meanTileSpeeds = cellfun(@mean, tileSpeeds);
stdTileSpeeds = cellfun(@std, tileSpeeds);
covTileSpeeds = stdTileSpeeds ./ meanTileSpeeds;

% Identify tiles with too few origins
tileSizes = cellfun(@length, tileSpeeds);
bigEnoughTiles = tileSizes > 10;

% Now plot two images
cmin = min(meanTileSpeeds(bigEnoughTiles));
cmax = max(meanTileSpeeds(bigEnoughTiles));
figure(1); clf;
meanIm = imagesc(meanTileSpeeds, [cmin cmax]);
colormap(parula);
set(meanIm, 'AlphaData', bigEnoughTiles)
axis ij;
% xticklabels({});
% yticklabels({});
colorbar;

% exportgraphics(ax,[h5dir '-meanspeedvsloc.pdf']);

cmin = min(covTileSpeeds(bigEnoughTiles));
cmax = max(covTileSpeeds(bigEnoughTiles));
figure(2); clf;
covIm = imagesc(covTileSpeeds, [cmin cmax]);
colormap(parula);
set(covIm, 'AlphaData', bigEnoughTiles)
axis ij;
% xticklabels({});
% yticklabels({});
colorbar;

% exportgraphics(ax,[h5dir '-covspeedvsloc.pdf']);

figure(3); clf;
plot3(origins(startBurst:endBurst, 1), origins(startBurst:endBurst, 2), ...
    speeds(startBurst:endBurst), '.');
set(gca, 'XLim', [0 100]);
set(gca, 'YLim', [0 100]);
view(15, -50);

