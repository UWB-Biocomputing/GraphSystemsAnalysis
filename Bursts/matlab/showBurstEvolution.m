% generate burst evolution figure (image sequences)

function showBurstEvolution(h5dir, id)

fprintf('Loading data files... ');
% Get binned neuron spike counts
load([h5dir '/allFrames.mat'], 'allFrames');
fprintf('done.\n')

frame = allFrames{id};
bins = [10 13 16 19 22];
numBins = size(bins,2);
clf;
t = tiledlayout(1,numBins);
for i = 1:numBins
    f = reshape(frame(:,bins(i)), 100, 100);
    nexttile
    imagesc(f');
    colormap(parula);
    pbaspect([2 2 2]);
    set(gca, 'Box', 'on', 'LineWidth', 1.0, 'XTick', [], 'YTick', []);
end

exportgraphics(t,[h5dir '-evolution.pdf']);

end
