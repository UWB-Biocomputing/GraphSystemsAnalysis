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

function burstOriginHistogram(h5dir, layoutSize, parent)

% Default layout
if nargin < 2
    layoutSize = 5;
end
if nargin < 3
    doExport = true;
    figure(1);
    clf;
    t = tiledlayout(layoutSize,layoutSize);
else
    doExport = false;
    t = parent;
end

% burst origin (x, y), neuron ID, and origin bin # for every burst. (This
% is Graphitti neuron ID, i.e., zero-based, and (x, y) are also zero-based,
% ij coordinates))
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Get multi-bursts (Matlab numbering; starting with 1)
multiBurstIDs = readmatrix([h5dir '/multipleBursts.csv']);

% Generate list of non-multibursts
burstIDs = 1:size(origins, 1);
burstIDs = setdiff(burstIDs, multiBurstIDs);

% Excise the multi-burst data from origins
origins = origins(burstIDs,:);

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

t.Padding = 'tight';
t.TileSpacing = 'none';

numgraphs = layoutSize*layoutSize;
numbursts = ceil((analysisEnd - analysisStart+1) / numgraphs);
if doExport
    fprintf('%d bursts per graph (%d total bursts)\n', numbursts, ...
        analysisEnd - analysisStart+1);
end

for startburst = analysisStart:numbursts:analysisEnd
    endburst = min(startburst+numbursts-1,analysisEnd);
    nexttile(t);

    % Create histogram for the burst origin tileIDs with 100 bins
    % using 'probability' so the y-axes are directly comparable
    [N, edges] = histcounts(tileID(startburst:endburst), 100, 'Normalization', 'probability');

    % Get rid of the bins with zero entries for plotting
    % Actually, preserving bins is safer for bar plots so x-axis is correct,
    % but existing code removed zero entries. Let's keep it as is, but use probability.
    N_nonzero = N(N ~= 0);
    
    % Compute chi-squared statistics for this to check if we can reject the
    % hypothesis that this is uniform (using original counts for chi2)
    if doExport
        [N_counts, ~] = histcounts(tileID(startburst:endburst), 100);
        N_c_nonzero = N_counts(N_counts ~= 0);
        nbins = length(N_c_nonzero);
        if nbins > 0
            E = ones(1,nbins) * mean(N_c_nonzero);
            [~ ,p, ~] = chi2gof(0:nbins-1, 'Frequency', N_c_nonzero,...
                'Expected', E, 'NBins', nbins, 'Emin', 1);
            fprintf('p-value for bursts [%d, %d] = %f\n', startburst, endburst, p);
        end
    end

    % Add plot for this histogram to figure
    h = bar(N_nonzero);
    h.BarWidth = 1;
    h.EdgeColor = h.FaceColor;
    xticklabels({});
    yticklabels({});
    % Standardize y-limits if possible, probability is [0, 1]
    % Let's set it to [0, 1] so scales are truly identical
    % ax = gca;
    % ax.YLim = [0, 1];
end

if doExport
    exportgraphics(t,[h5dir '-histogram.pdf']);
end
