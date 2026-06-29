function makeOrigin_histogram()
% MAKEORIGIN_HISTOGRAM Assemble the burst origin histogram plot into a 2x2 grid

fig = figure('Name', 'Burst Origin Histogram', 'Position', [100, 100, 1000, 1000]);
clf(fig);
t = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

dirs = {
    'data/tR_1.0--fE_0.90', '\epsilon = 1.0, f = 0.90';
    'data/tR_1.0--fE_0.98', '\epsilon = 1.0, f = 0.98';
    'data/tR_1.9--fE_0.90', '\epsilon = 1.9, f = 0.90';
    'data/tR_1.9--fE_0.98', '\epsilon = 1.9, f = 0.98'
};

for i = 1:4
    t_inner = tiledlayout(t, 5, 5, 'TileSpacing', 'tight', 'Padding', 'tight');
    t_inner.Layout.Tile = i;
    burstOriginHistogram(dirs{i,1}, 5, t_inner);
    title(t_inner, dirs{i,2}, 'FontWeight', 'bold', 'FontSize', 14);
end

exportgraphics(t, 'origin-histogram.pdf');

end
