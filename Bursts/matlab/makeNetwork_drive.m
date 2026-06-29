function makeNetwork_drive()
% MAKENETWORK_DRIVE Assemble the network drive / starters plot into a 2x2 grid

fig = figure('Name', 'Network Drive (Starters)', 'Position', [100, 100, 1000, 1000]);
clf(fig);
t = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

dirs = {
    'data/tR_1.0--fE_0.90', '\epsilon = 1.0, f = 0.90';
    'data/tR_1.0--fE_0.98', '\epsilon = 1.0, f = 0.98';
    'data/tR_1.9--fE_0.90', '\epsilon = 1.9, f = 0.90';
    'data/tR_1.9--fE_0.98', '\epsilon = 1.9, f = 0.98'
};

for i = 1:4
    ax = nexttile(t);
    plotStarters(dirs{i,1}, [20 24], 5, ax);
    title(ax, dirs{i,2}, 'FontWeight', 'bold', 'FontSize', 14);
end

% Wait, we want a single global colorbar for the network drive plot as well.
cb = colorbar(ax);
cb.Layout.Tile = 'east';
cb.Label.String = 'Threshold Reduction';
cb.Label.FontSize = 14;

exportgraphics(t, 'network-drive.pdf');

end
