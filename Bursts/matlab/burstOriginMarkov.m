% Burst origin movement analysis
% BURSTORIGINMARKOV plot Markov model of burst origins
%
%   Syntax: burstOriginMarkov(h5dir)
%
%   Input:
%   h5dir   -   Graphitti result filename (e.g. tR_1.0--fE_0.90)
%               the entire path may be required, for example
%               '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Output:
%   <h5dir-markov.pdf>     - burst origin plot

function burstOriginMarkov(h5dir)

origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Only analyze bursts in this area of interest
analysisStart = 1;
% analysisEnd = 500;
% analysisStart = round(size(origins,1)*0.75);
analysisEnd = size(origins,1);

% We want to divide the grid into 10x10 blocks
% Convert the (x, y) neuron location into (xb, yb) block location
xb = floor(origins(:,1)/10);
yb = floor(origins(:,2)/10);
% Then convert the (xb, yb) block location to a linear block ID (we'll use
% row major order)
blockID = yb * 10 + xb;

% Basic plots
figure(1)
clf

layoutsize = 7;
t = tiledlayout(layoutsize,layoutsize);
t.Padding = 'tight';
t.TileSpacing = 'tight';
numgraphs = layoutsize*layoutsize;
numbursts = ceil((analysisEnd - analysisStart+1) / numgraphs);

% Let's save all of the tiles so it's possible to plot them using a common
% color axis at the end, if desired.
MMcube = cell(1, numgraphs);

theTile = 0;
for startburst = analysisStart:numbursts:analysisEnd
    endburst = min(startburst+numbursts-1,analysisEnd);

    MM = zeros(100);
    % Compute the counts of origin_i, origin_{i+1}
    for i = startburst:endburst-1
        MM(blockID(i),blockID(i+1)) = MM(blockID(i),blockID(i+1)) + 1;
    end

    theTile = theTile + 1;
    MMcube{theTile} = MM;
end

% Get the color axis limits
cmin = min(cell2mat(MMcube), [], 'all');
cmax = max(cell2mat(MMcube), [], 'all');

for i = 1:theTile
    % There are too many categories; reduce by deleting zero rows/columns
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

    tiles(i) = nexttile(t);
   % imagesc(MMcube{i}, [cmin cmax]);
   imagesc(MMcube{i});
    colormap(parula);
    axis ij;
    xticklabels({})
    yticklabels({})
end

% cb = colorbar(tiles(end));
% cb.Layout.Tile = 'east';
% cb.Ticks = [];

exportgraphics(t,[h5dir '-markov.pdf']);


