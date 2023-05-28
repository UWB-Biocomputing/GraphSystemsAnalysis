% Burst origin movement analysis
% BURSTORIGINMARKOV plot Markov model of burst origins
%
%   Syntax: burstOriginMarkov(h5dir)
%
%   Input:
%   h5dir   -   Graphitti result filename (e.g. tR_1.0--fE_0.90)
%               the entire path may be required, for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   layoutSize - Will generate a set of layoutSize x layoutSize graphs
%
%   Output:
%   <h5dir-markov.pdf>     - burst origin plot

function burstOriginMarkov(h5dir, layoutSize)

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

% Let's save all of the graphs so it's possible to plot them using a common
% color axis at the end, if desired.
MMcube = cell(1, numgraphs);

theGraph = 0;
for startburst = analysisStart:numbursts:analysisEnd
    endburst = min(startburst+numbursts-1,analysisEnd);

    MM = zeros(100);
    % Compute the counts of origin_i, origin_{i+1}. Remember that tileID is
    % zero based, so we add 1 to make Matlab indices in range [1, 100]
    for i = startburst:endburst-1
        MM(tileID(i)+1,tileID(i+1)+1) = MM(tileID(i)+1,tileID(i+1)+1) + 1;
    end

    theGraph = theGraph + 1;
    MMcube{theGraph} = MM;
end

% There are too many categories; reduce by deleting zero rows/columns in
% all of the graphs. In other words, all of the graphs start out as 100 x
% 100 (Matlab tile IDs in the range [1, 100] indexing rows and columns).
% Scan each image for any rows that have all zeros and deleting both the
% row and the column for that index. One drawback to this is that,
% afterwards, we can't tell which tile ID is which, other than that their
% order is preserved.
for i = 1:theGraph
    MM = MMcube{i};
    j = 1;
    numCategories = 100;
    while j <= numCategories
        if isempty(find((MM(j,:) ~= 0), 1))
            MM(j,:) = [];
            MM(:,j) = [];
            numCategories = numCategories - 1;
        else
            j = j + 1;
        end
    end

    % Replace the element of the cell array
    MMcube{i} = MM;
end

% Get the color axis limits by finding min and max values over all of the
% elements of all of the graphs
for i = 1:length(MMcube)
    if i == 1
       cmin = min(MMcube{i}, [], 'all');
       cmax = max(MMcube{i}, [], 'all');
    else
        cmin = min(cmin, min(MMcube{i}, [], 'all'));
        cmax = max(cmax, max(MMcube{i}, [], 'all'));
    end
end

% Now plot the graphs (with that common color axis, if comments changed)
for i = 1:theGraph
    tiles(i) = nexttile(t);
    % imagesc(MMcube{i}, [cmin cmax]);
    imagesc(MMcube{i});
    colormap(parula);
    axis xy;
    xticklabels({})
    yticklabels({})
end

% cb = colorbar(tiles(end));
% cb.Layout.Tile = 'east';
% cb.Ticks = [];

exportgraphics(t,[h5dir '-markov.pdf']);


