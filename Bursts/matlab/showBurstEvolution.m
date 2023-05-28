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
%
%   Output:
%   <h5dir-evolution.pdf>  - Image sequence
%
%   Note that this currently has which bins to plot hard-coded

function showBurstEvolution(h5dir, id)

fprintf('Loading data files... ');
% Get binned neuron spike counts
load([h5dir '/allFrames.mat'], 'allFrames');
fprintf('done.\n')

frame = allFrames{id};     % Get the data for indicated burst
bins = [10 13 16 19 22];   % bins to display
numBins = size(bins,2);

clf;
t = tiledlayout(1,numBins);
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
    nexttile
    imagesc(f);
    colormap(parula);
    pbaspect([2 2 2]);
    set(gca, 'Box', 'on', 'LineWidth', 1.0, 'XTick', [], 'YTick', []);
end

exportgraphics(t,[h5dir '-evolution.pdf']);

end
