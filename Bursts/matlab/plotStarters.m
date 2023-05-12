% Plot of starter neuron thresholds
% PLOTSTARTERS plot starter neuron thresholds as image
%
%   Syntax: plotStarters(h5dir, plotnum)
%
%   Input:
%   h5dir   -   Graphitti result filename (e.g. tR_1.0--fE_0.90)
%               the entire path may be required, for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   plotnum -   which of the burstOriginMovement subplots to use for
%               overlaying
%
%   Output:
%   <h5dir-starters.pdf>     - starter neuron threshold plot
%   <h5dir-starter-avg.pdf>  - starter neuron threshold plot (block
%                              averages)

function plotStarters(h5dir, plotnum)

% Endogenously active neurons
starterNeurons = h5read([h5dir '.h5'], '/starterNeurons');
% Neuron thresholds
neuronThresh = h5read('tR_1.0--fE_0.90.h5', '/neuronThresh');

% Burst origins for overlay
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Let's make an image where we show how far lowered the endogenously active
% neuron thresholds are.

lowered = max(neuronThresh) - neuronThresh;
loweredIm = reshape(lowered, [100 100]);

alpha = zeros(size(loweredIm));
alpha(starterNeurons + 1) = 1.0;

cmin = min(lowered(lowered > 0));
cmax = max(lowered);

% figure(1);
clf;

% origin overlay
analysisStart = 1;
analysisEnd = size(origins,1);
layoutsize = 7;
numgraphs = layoutsize*layoutsize;
numbursts = ceil((analysisEnd - analysisStart+1) / numgraphs);
startburst = analysisStart + numbursts * plotnum;
endburst = min(startburst+numbursts-1,analysisEnd);
% plot(origins(startburst:endburst,1), ...
%     origins(startburst:endburst,2), ...
%     '*-','MarkerEdgeColor','k','MarkerFaceColor','k', ...
%     'Color', 'black');
% hold on;

% im = imagesc(loweredIm, [cmin cmax]);
% im.AlphaData = alpha;
% ax = gca;
% ax.XLim = [0 100];
% ax.YLim = [0 100];
% colormap('parula');
% colorbar;
% 
% exportgraphics(ax,[h5dir '-starters.pdf']);

% figure(2);
% clf;

% Do basically the same thing, but average the starter threshold reduction
% over a 10x10 neuron block and plot the origins on top of that. To make
% plotting easy, we replicate the averages into a 100x100 image
blockAvgs = zeros(100);
for row = 1:10
    for col = 1:10
        blockStartrow = (row-1)*10 + 1;
        blockStartcol = (col-1)*10 + 1;
        % Multiply by 10 since only 10% of neurons have nonzero values
        blockAvgs(blockStartrow:blockStartrow+9, blockStartcol:blockStartcol+9) = ...
            mean(loweredIm(blockStartrow:blockStartrow+9, blockStartcol:blockStartcol+9), "all") * 10;
    end
end

im = imagesc(blockAvgs, [cmin cmax]);
ax = gca;
ax.XLim = [0 100];
ax.YLim = [0 100];
colormap('parula');
colorbar;

hold on;

% origin overlay
plot(origins(startburst:endburst,1), ...
    origins(startburst:endburst,2), ...
    '*-','MarkerEdgeColor','k','MarkerFaceColor','k', ...
    'Color', 'black');
axis xy;

exportgraphics(ax,[h5dir '-starter-avg.pdf']);


