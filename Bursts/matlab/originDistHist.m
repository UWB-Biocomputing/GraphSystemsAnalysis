% Plot of starter neuron thresholds and burst origins
% ORIGINDISTHIST plot histogram of origin distances from nearest culture
% edge
%
%   Syntax: originHistDist(h5dir, numBins)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   numBins -    Number of histogram bins (if not provided; will default
%                based on Matlab defaults for histograms
%
%   Output:
%   <h5dir-origin-hist.pdf>        - histogram plot
%   <h5dir-origin-densities.pdf>  - density plot

function originDistHist(h5dir, numBins, parent)

if nargin < 2 || isempty(numBins)
    numBins = [];
end
if nargin < 3
    doExport = true;
    figure(1); clf;
    axHist = gca;
    figure(2); clf;
    axDens = gca;
else
    doExport = false;
    axDens = parent;
end

% Burst origins
%
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
origins = origins(burstIDs,1:2);

% Compute distance of each origin to nearest culture edge
minDist = min(min(origins, [], 2), 99-max(origins,[],2));

% Create histogram of minimum distances (if not exporting, don't plot it to screen, just calculate)
if doExport
    if isempty(numBins)
       h = histogram(axHist, minDist);
    else
       h = histogram(axHist, minDist, numBins);
    end
    axHist.FontSize = 28;
    xlabel(axHist, 'Distance to Nearest Edge');
    ylabel(axHist, 'Frequency');
    exportgraphics(axHist,[h5dir '-origin-hist.pdf']);
else
    % Just calculate the histogram counts without plotting to main axes
    if isempty(numBins)
        [N, edges] = histcounts(minDist);
    else
        [N, edges] = histcounts(minDist, numBins);
    end
    h.Values = N;
    h.BinEdges = edges;
    h.BinWidth = edges(2) - edges(1);
end

% Calculate the area of the culture that corresponds to each bin
binAreas = -diff((100 - 2*h.BinEdges).^2);

% Calculate the densities of origins for each bin
densities = h.Values ./ binAreas;

% Plot densities as a function of bin midpoint distance
binMidpoints = h.BinEdges(1:end-1) + h.BinWidth/2;

plot(axDens, binMidpoints, densities, '.', 'MarkerSize', 40);

if doExport
    axDens.FontSize = 28;
    xlabel(axDens, 'Distance to Nearest Edge');
    ylabel(axDens, 'Density');
    exportgraphics(axDens,[h5dir '-origin-densities.pdf']);
end
