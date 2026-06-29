function makeBurstspeed()
% MAKEBURSTSPEED Assemble the burst speed plot into a 2x2 grid

fig = figure('Name', 'Burst Speed', 'Position', [100, 100, 800, 600]);
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
    plotBurstSpeed(dirs{i,1}, ax);
    title(ax, dirs{i,2}, 'FontWeight', 'normal', 'FontSize', 12);
end

% Shared labels
xlabel(t, 'Burst Number', 'FontSize', 14);
ylabel(t, 'Propagation Speed (ms^{-1})', 'FontSize', 14);

exportgraphics(t, 'burstSpeed.pdf');

end
