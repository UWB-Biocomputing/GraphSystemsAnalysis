% Burst origin movement analysis
% BURSTORIGINHISTOGRAM plot sequences of burst origins
%
%   Syntax: burstOriginHistogram(h5dir)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   layoutSize - Will generate a set of layoutSize x layoutSize graphs
%
%   Output:
%   <h5dir-histogram.pdf>     - burst histogram plot

function burstOriginHistogram(h5dir, layoutSize)

% Default layout
if nargin < 2
    layoutSize = 5;
end

% burst origin (x, y), neuron ID, and origin bin # for every burst. (This
% is Graphitti neuron ID, i.e., zero-based, and (x, y) are also zero-based,
% ij coordinates))
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Only analyze bursts in this area of interest
analysisStart = 1;
analysisEnd = size(origins,1);

% We want to divide the network into 10x10 tiles. Convert the (x, y) burst
% origin location into (xt, yt) tile location. These will be zero-based
% (i.e., their range is [0, 9].
xt = floor(origins(:,1)/10);
yt = floor(origins(:,2)/10);
% Then convert the (xt, yt) tile location to a linear tile ID (we'll use
% row major order). Their range will be [0, 99].
tileID = yt * 10 + xt;

figure(1);
clf;

% Set up a tiled layout with no space in between plots
t = tiledlayout(layoutSize,layoutSize);
t.Padding = 'tight';
t.TileSpacing = 'tight';

numgraphs = layoutSize*layoutSize;
numbursts = ceil((analysisEnd - analysisStart+1) / numgraphs);
fprintf('%d bursts per graph (%d total bursts)\n', numbursts, ...
    analysisEnd - analysisStart+1);

for startburst = analysisStart:numbursts:analysisEnd
    endburst = min(startburst+numbursts-1,analysisEnd);
    nexttile;

    % Create histogram for the burst origin tileIDs with 100 bins
    [N, edges] = histcounts(tileID(startburst:endburst), 100);

    % Get rid of the bins with zero entries. We just want to see how bursts
    % are distributed among the tiles that actually have burst origins.
    N = N(N ~= 0);

    % Compute chi-squared statistics for this to check if we can reject the
    % hypothesis that this is uniform
    nbins = length(N);
    E = ones(1,length(N)) * mean(N);
    [~ ,p, ~] = chi2gof(0:nbins-1, 'Frequency', N,...
        'Expected', E, 'NBins', nbins, 'Emin', 1);
    fprintf('p-value for bursts [%d, %d] = %f\n', startburst, endburst, p);

    % Add plot for this histogram to figure
    h = bar(N);
    h.BarWidth = 1;
    h.EdgeColor = h.FaceColor;
    xticklabels({});
    yticklabels({});
end

exportgraphics(t,[h5dir '-histogram.pdf']);
