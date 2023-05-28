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
%   <h5dir-starters.pdf>     - starter neuron threshold plot
%   <h5dir-starter-avg.pdf>  - starter neuron threshold plot (block
%                              averages)

function plotSpeedVsLoc(h5dir, chunks, layoutSize)

if nargin < 2
    layoutSize = 7;
end

% Burst origins
origins = readmatrix([h5dir '/allBurstOrigin.csv']);
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
startburst = analysisStart + numBurstsPerChunk * min(chunks);
endburst = min(startburst+(numBurstsPerChunk * numChunks)-1,analysisEnd);

% Convert the origin (x, y) locations to origin (tile_x, tile_y)
tileX = ceil((origins(:,1)+1) / 10);
tileY = ceil((origins(:,2)+1) / 10);

% Put each burst speeds in its tile. Remember that Y is rows and X is cols
for i = startburst:endburst
    tileSpeeds{tileY(i), tileX(i)} = [tileSpeeds{tileY(i), tileX(i)} speeds(i)];
end

% Compute mean and standard deviation of each tile
meanTileSpeeds = cellfun(@mean, tileSpeeds);
stdTileSpeeds = cellfun(@std, tileSpeeds);

% Scale color axis for only nonzero tiles
nonEmptyTiles = ~cellfun(@isempty, tileSpeeds);
cmap = parula;
cmap(1,:) = [1 1 1];

% Now plot two images
cmin = min(meanTileSpeeds(nonEmptyTiles));
cmax = max(meanTileSpeeds(nonEmptyTiles));
figure(1); clf;
imagesc(meanTileSpeeds, [cmin cmax]);
colormap(cmap);
axis ij;
xticklabels({});
yticklabels({});
colorbar;

cmin = min(stdTileSpeeds(nonEmptyTiles));
cmax = max(stdTileSpeeds(nonEmptyTiles));
figure(2); clf;
imagesc(stdTileSpeeds, [cmin cmax]);
colormap(cmap);
axis ij;
xticklabels({});
yticklabels({});
colorbar;

% exportgraphics(ax,[h5dir '-starter-avg.pdf']);


