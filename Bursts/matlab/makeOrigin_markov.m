function makeOrigin_markov()
% MAKEORIGIN_MARKOV Assemble the burst origin markov plot into a 2x2 grid

fig = figure('Name', 'Burst Origin Markov', 'Position', [100, 100, 1000, 1000]);
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
    burstOriginMarkov(dirs{i,1}, 5, t_inner);
    title(t_inner, dirs{i,2}, 'FontWeight', 'bold', 'FontSize', 14);
end

% Wait, we want a single global colorbar for the markov plots.
% Since the counts can vary, we can just attach one to the last tile
% and label it appropriately.
% Create an invisible axes in the outer tiledlayout to anchor the colorbar
last_ax = gca;
ax_dummy = axes(t, 'Visible', 'off', 'Color', 'none');
ax_dummy.Layout.Tile = 1;
ax_dummy.Layout.TileSpan = [2 2];
ax_dummy.Colormap = last_ax.Colormap;
ax_dummy.CLim = last_ax.CLim;

cb = colorbar(ax_dummy);
cb.Layout.Tile = 'east';
cb.Label.String = 'Count';
cb.Label.FontSize = 14;

exportgraphics(t, 'origin-markov.pdf');

end
