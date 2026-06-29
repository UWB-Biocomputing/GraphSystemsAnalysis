% generate burst evolution figure (image sequence)
% SHOWBURSTEVOLUTION Generate plot showing sequence of burst images
%
%   Syntax: showBurstEvolution(h5dir, id)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   id      -    Which burst from that result to plot
%   bins    -    Which bins from that burst to display
%
%   Output:
%   <h5dir-evolution.pdf>  - Image sequence
%
%   Note that this currently has which bins to plot hard-coded

function makeEvolution(h5dir, id, bins)

if nargin < 1
    h5dir = '/Users/stiber/My Drive/Public/data/tR_1.0--fE_0.90';
end
if nargin < 2
    id = 926;
end
if nargin < 3
    bins = [10 13 16 19 22];
end

fprintf('Loading data files... ');
% Get binned neuron spike counts
load([h5dir '/allFrames.mat'], 'allFrames');
fprintf('done.\n')

frame = allFrames{id};     % Get the data for indicated burst
numBins = size(bins,2);

figure(1);
clf;
t = tiledlayout(1,numBins);
t.Padding = 'tight';
t.TileSpacing = 'compact';

for i = 1:numBins
    % A frame has one row per neuron and one column per time bin. Grab the
    % column for the current time bin and then make it a 100x100 array, to
    % match the network "viewed from above", with neuron (x, y) = (0, 0) at
    % the top left. Note that, within Graphitti, neurons are numbered in
    % row-major order (starting at top left, across each row before moving
    % on to the next row; i.e., the column -- x coordinates -- increments
    % faster). I write this in such painstaking detail because not only
    % does Matlab use one-based, rather than zero-based, indexing, but it
    % generally does things in column-major order. An example of this is
    % "reshape" below, and so we need to transpose its result to get the
    % right display of each frame.
    f = reshape(frame(:,bins(i)), 100, 100)';
    ax = nexttile;
    imagesc(f);
    colormap(ax, parula);
    pbaspect([1 1 1]);
    set(ax, 'Box', 'on', 'LineWidth', 1.0, 'XTick', [], 'YTick', []);
    
    % Add timing title (each bin is 10 ms)
    title(ax, sprintf('%d-%d ms', (bins(i)-1)*10, bins(i)*10), 'FontSize', 14, 'FontWeight', 'normal');
end

exportgraphics(t, 'burst-wavefront.pdf');

end
