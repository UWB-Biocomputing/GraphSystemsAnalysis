% Plot of starter neuron thresholds and burst origins
% PLOTSTARTERS plot starter neuron thresholds as image, with origin overlay
%
%   Syntax: plotStarters(h5dir, chunks, layoutSize)
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
%   <h5dir-starter-avg.pdf>  - starter neuron threshold plot (block
%                              averages)

function plotStarters(h5dir, chunks, layoutSize)

% Default layout
if nargin < 2
    layoutSize = 5;
end

% Endogenously active neurons (Graphitti neuron IDs, [0, 9999])
starterNeurons = h5read([h5dir '.h5'], '/starterNeurons');
% Neuron thresholds (for all neurons)
neuronThresh = h5read('tR_1.0--fE_0.90.h5', '/neuronThresh');

% Burst origins for overlay
%
% burst origin (x, y), neuron ID, and origin bin # for every burst. (This
% is Graphitti neuron ID, i.e., zero-based, and (x, y) are also zero-based,
% ij coordinates))
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Let's make an image where we show how far lowered the endogenously active
% neuron thresholds are.
lowered = max(neuronThresh) - neuronThresh;
% The "lowered" vector, like the "neuronThresh" vector, is ordered by
% Graphitti neuron ID. Note that, within Graphitti, neurons are numbered in
% row-major order (starting at top left, across each row before moving on
% to the next row; i.e., the column -- x coordinates -- increments faster).
% I write this in such painstaking detail because not only does Matlab use
% one-based, rather than zero-based, indexing, but it generally does things
% in column-major order. An example of this is "reshape" below, and so we
% need to transpose its result to get the right display of each frame.
loweredIm = reshape(lowered, [100 100])';

cmin = min(lowered(lowered > 0));
cmax = max(lowered);

clf;

% Average the starter threshold reduction over a 10x10 neuron tile and plot
% the origins on top of that. To make plotting easy, we replicate the
% averages into a 100x100 image (but we will also keep a vector of the 100
% averages)
tileAvgs = zeros(100);
avgVec = zeros(100,1);
% Our loop variables below count tiles
for row = 1:10
    for col = 1:10
        % Convert tile (row, col) to Matlab (neuronRowIndex,
        % neuronColumnIndex) for the first neuron at the top left of the
        % current tile.
        tileStartRow = (row-1)*10 + 1;
        tileStartCol = (col-1)*10 + 1;
        % Multiply mean by 10 since only 10% of neurons have nonzero values
        theAvg = mean(loweredIm(tileStartRow:tileStartRow+9, tileStartCol:tileStartCol+9), "all") * 10;
        % replicate into image we're building
        tileAvgs(tileStartRow:tileStartRow+9, tileStartCol:tileStartCol+9) = theAvg;
        % Also save into vector of averages.
        avgVec(sub2ind([10 10], row, col)) = theAvg;
        % avgVec((row-1)*10 + col) = theAvg;
    end
end

% At this point, "tileAvgs" is an image that, in ij coordinates, matches
% the network layout
im = imagesc(tileAvgs, [cmin cmax]);
ax = gca;
ax.XLim = [0 100];
ax.YLim = [0 100];
colormap(parula);
colorbar;
% yticklabels({});

hold on;

% origin overlay
analysisStart = 1;
analysisEnd = size(origins,1);
totalGraphs = layoutSize*layoutSize;
numBurstsPerChunk = ceil((analysisEnd - analysisStart+1) / totalGraphs);
numChunks = max(chunks) - min(chunks) + 1;
startburst = analysisStart + numBurstsPerChunk * min(chunks);
endburst = min(startburst+(numBurstsPerChunk * numChunks)-1,analysisEnd);

% According to the Matlab documentation for imagesc(), "The row and
% column indices of the elements determine the centers of the
% corresponding pixels." Therefore, that means that (1, 1) is the
% center of the top-left pixel. Burst origins, on the other hand, are
% computed by getBurstOriginXYN(), which computes the origins based on
% Graphitti neuron (x, y) locations (zero-based). Therefore, we need to
% add one to the x and y coordinates to place the origin markers in the
% right locations.
%
% We have already transposed the array, and imagesc() uses ij
% coordinates (origin at top left).
plot(origins(startburst:endburst,1)+1, ...
    origins(startburst:endburst,2)+1, ...
    '*','MarkerEdgeColor','k','MarkerFaceColor','k', ...
    'Color', 'black');
axis ij;
xticklabels({});
yticklabels({});

exportgraphics(ax,[h5dir '-starter-avg.pdf']);

% We're also going to do a Spearman's rho test to see if there is any
% correlation between the average threshold reduction in a tile and the
% number of origins in that tile

% Convert the origin Graphitti (x, y) locations to origin (tileX, tileY).
% Graphitti coordinates' range is [0, 99]; these will be zero-based.
tileX = floor(origins(startburst:endburst,1) / 10);
tileY = floor(origins(startburst:endburst,2) / 10);

% And then convert these to linear tile indices, remembering that row = Y
% and col = X and that we need to convert zero-based to one-based. These
% should match the linear tile indices in "avgVec".
originTileInds = sub2ind([10 10], tileY+1, tileX+1);
% Get the count for each linear index
[countVec, edges] = histcounts(originTileInds, 0.5:1:100.5);
% Compute Spearman stats
[rho, pval] = corr(avgVec, countVec', 'Type', 'Spearman');
fprintf('Spearman rho=%f, pval=%f\n', rho, pval);
