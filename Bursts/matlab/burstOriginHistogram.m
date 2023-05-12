% Burst origin movement analysis
% BURSTORIGINHISTOGRAM plot sequences of burst origins
%
%   Syntax: burstOriginHistogram(h5dir)
%
%   Input:
%   h5dir   -   Graphitti result filename (e.g. tR_1.0--fE_0.90)
%               the entire path may be required, for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Output:
%   <h5dir-histogram.pdf>     - burst histogram plot

function burstOriginHistogram(h5dir)

origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Only analyze bursts in this area of interest
analysisStart = 1;
% analysisEnd = 500;
%analysisStart = round(size(origins,1)*0.75);
analysisEnd = size(origins,1);

% We want to divide the grid into 10x10 blocks
% Convert the (x, y) neuron location into (xb, yb) block location
xb = floor(origins(:,1)/10);
yb = floor(origins(:,2)/10);
% Then convert the (xb, yb) block location to a linear block ID (we'll use
% row major order)
blockID = yb * 10 + xb;

figure(1)
clf
%  plot(origins(analysisStart:analysisEnd,1), ...
%      origins(analysisStart:analysisEnd,2), '*-');

layoutsize = 7;
t = tiledlayout(layoutsize,layoutsize);
t.Padding = 'tight';
t.TileSpacing = 'tight';
numgraphs = layoutsize*layoutsize;
numbursts = ceil((analysisEnd - analysisStart+1) / numgraphs);

for startburst = analysisStart:numbursts:analysisEnd
    endburst = min(startburst+numbursts-1,analysisEnd);
    nexttile;
    [N, edges] = histcounts(blockID(startburst:endburst), 100);
    N = N(N ~= 0);
    h = bar(N);
    h.BarWidth = 1;
    h.EdgeColor = h.FaceColor;
    xticklabels({});
    yticklabels({});
end

exportgraphics(t,[h5dir '-histogram.pdf']);
