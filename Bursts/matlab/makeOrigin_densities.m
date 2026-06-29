function makeOrigin_densities()
% MAKEORIGIN_DENSITIES Assemble the origin densities plot into a 2x2 grid

fig = figure('Name', 'Origin Densities', 'Position', [100, 100, 800, 800]);
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
    originDistHist(dirs{i,1}, 5, ax);
    title(ax, dirs{i,2}, 'FontWeight', 'bold', 'FontSize', 14);
end

% Shared labels
xlabel(t, 'Distance to Nearest Edge', 'FontSize', 16);
ylabel(t, 'Density', 'FontSize', 16);

exportgraphics(t, 'origin-densities.pdf');

end
