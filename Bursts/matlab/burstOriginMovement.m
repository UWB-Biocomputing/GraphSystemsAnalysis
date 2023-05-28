% Burst origin movement analysis
% BURSTORIGINMOVEMENT plot sequences of burst origins
%
%   Syntax: burstOriginMovement(h5dir, layoutSize)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%   layoutSize - Will generate a set of layoutSize x layoutSize graphs
%
%   Output:
%   <h5dir-origins.pdf>     - burst origin plot

function burstOriginMovement(h5dir, layoutSize)

% Default layout
if nargin < 2
    layoutSize = 5;
end

% burst origin (x, y), neuron ID, and origin bin # for every burst. (This
% is Graphitti neuron ID, i.e., zero-based, and (x, y) are also zero-based,
% ij coordinates))
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Only analyze bursts in this area of interest
analysisStart = 1;
analysisEnd = size(origins,1);

figure(1);
clf;

% Set up a tiled layout with no space in between plots
t = tiledlayout(layoutSize,layoutSize);
t.Padding = 'tight';
t.TileSpacing = 'tight';

numgraphs = layoutSize*layoutSize;
numbursts = ceil((analysisEnd - analysisStart + 1) / numgraphs);
fprintf('%d bursts per graph (%d total bursts)\n', numbursts, ...
    analysisEnd - analysisStart+1);

for startburst = analysisStart:numbursts:analysisEnd
    endburst = min(startburst+numbursts-1,analysisEnd);
    nexttile
    plot(origins(startburst:endburst,1), ...
        origins(startburst:endburst,2), '*-', ...
        'MarkerEdgeColor','k','MarkerFaceColor','k');
    % Remember, the origins are in Graphitti coordinates
    axis ij;
    ax = gca;
    ax.XLim = [0 100];
    ax.YLim = [0 100];

    % No room for tick marks
    ax.XTick = [];
    ax.YTick = [];

end

exportgraphics(t,[h5dir '-origins.pdf']);

%xlabel('Burst x location')
%ylabel('Burst y location')

% figure(2);
% clf
% subplot(2,1,1);
% plot([analysisStart:analysisEnd],origins([analysisStart:analysisEnd],1), '.');
% px = gca;
% ylabel('Burst x location');
% subplot(2,1,2);
% plot([analysisStart:analysisEnd],origins([analysisStart:analysisEnd],2), '.');
% py = gca;
% xlabel('Burst number');
% ylabel('Burst y location');
% set(px, 'FontSize', 12);
% set(py, 'FontSize', 12);
% %print('originEvolution', '-deps2');
%
% % histograms
% figure(3)
% clf
% subplot(2,1,1)
% histogram(origins([analysisStart:analysisEnd],1), 20)
% xlabel('Burst x location')
% subplot(2,1,2)
% histogram(origins([analysisStart:analysisEnd],2), 20)
% xlabel('Burst y location')
% %
% % % Bivariate histogram
% figure(7)
% clf
% histogram2(origins([analysisStart:analysisEnd],1), ...
%     origins([analysisStart:analysisEnd],2),10);
% xlabel('Burst x location');
% ylabel('Burst y location');
% view(39, 48);
% %
% % 3D
% figure(4)
% clf
% plot3([analysisStart:analysisEnd], ...
%     origins([analysisStart:analysisEnd],1), ...
%     origins([analysisStart:analysisEnd],2), '.')
% box on
% ax = gca;
% ax.BoxStyle = 'full';
% ylabel('Burst x location')
% zlabel('Burst y location')
% xlabel('Burst number')
% %
% % Univariate return maps
% mapOrder = 1;
% figure(5)
% clf
% plot(origins([analysisStart:analysisEnd-mapOrder],1), ...
%     origins([analysisStart+mapOrder:analysisEnd],1), '*');
% xlabel('Burst x location i');
% ylabel(['Burst x location i+', num2str(mapOrder)]);
% figure(6)
% clf
% plot(origins([analysisStart:analysisEnd-mapOrder],2), ...
%     origins([analysisStart+mapOrder:analysisEnd],2), '*');
% xlabel('Burst y location i');
% ylabel(['Burst y location i+', num2str(mapOrder)]);
% %
% % Convert burst origin locations to polar coordinates, relative to (50, 50)
% % and then do some more plots
% originR = sqrt((origins(:,1)-50).^2 + (origins(:,2)-50).^2);
% originTheta = atan2(origins(:,2)-50, origins(:,1)-50);
% %
% % Basic plots
% figure(8)
% clf
% plot(originR(analysisStart:analysisEnd), ...
%     originTheta(analysisStart:analysisEnd), '*-');
% xlabel('Burst Radius');
% ylabel('Burst Angle');
% %
% % Bivariate histogram
% figure(9)
% clf
% histogram2(originR(analysisStart:analysisEnd), ...
%     originTheta(analysisStart:analysisEnd),10);
% xlabel('Burst Radius');
% ylabel('Burst Angle');
% view(39, 48);
% %
% % Look at power spectra
% figure(10)
% clf
% subplot(2,1,1)
% X = fft(origins([analysisStart:analysisEnd],1));
% X2 = abs(X/analysisEnd);
% X1 = X2(1:round((analysisEnd-analysisStart)/2)+1);
% X1(2:end-1) = 2*X1(2:end-1);
% plot([1:length(X1)-1], X1(2:end));
% ylabel('|X1(f)|');
% subplot(2,1,2)
% Y = fft(origins([analysisStart:analysisEnd],2));
% Y2 = abs(Y/analysisEnd);
% Y1 = Y2(1:round((analysisEnd-analysisStart)/2)+1);
% Y1(2:end-1) = 2*Y1(2:end-1);
% plot([1:length(Y1)-1], Y1(2:end));
% ylabel('|Y1(f)|');
% xlabel('f (cycles/150 bursts)');
% %
