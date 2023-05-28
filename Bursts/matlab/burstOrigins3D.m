% Script to load burst data and plot burst origins in (x, y, burst) space

dataset = 'tR_1.9--fE_0.98';
datadir = ['data/' dataset];
origins = csvread([datadir '/allBurstOriginXY.csv']);
numbursts = size(origins,1);

% Only analyze bursts in this area of interest
analysisStart = 1;
% analysisEnd = 500;
%analysisStart = round(size(origins,1)*0.75);
analysisEnd = size(origins,1);

clf
scatter3([analysisStart:analysisEnd], ...
    origins([analysisStart:analysisEnd],1), ...
    origins([analysisStart:analysisEnd],2), ones(analysisEnd,1)*10, ...
    origins([analysisStart:analysisEnd],1), 'filled')
colormap(parula)
[az,el]=view();
view(41,16)
box on
ax = gca;
ax.BoxStyle = 'full';
ylabel('Burst x location')
zlabel('Burst y location')
xlabel('Burst number')
% 

exportgraphics(ax, ['tmp/' dataset '-3D.pdf']);
