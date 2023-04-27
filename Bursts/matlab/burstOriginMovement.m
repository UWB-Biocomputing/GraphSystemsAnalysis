% Burst origin movement analysis
origins = csvread('tR_1.9--fE_0.98/allBurstOriginXY.csv');
%numbursts = size(origins,1);

% Only analyze bursts in this area of interest
analysisStart = 1;
% analysisEnd = 500;
%analysisStart = round(size(origins,1)*0.75);
analysisEnd = size(origins,1);

% Basic plots
figure(1)
clf
%  plot(origins(analysisStart:analysisEnd,1), ...
%      origins(analysisStart:analysisEnd,2), '*-');
 
layoutsize = 7;
 t = tiledlayout(layoutsize,layoutsize);
 t.Padding = 'tight';
 t.TileSpacing = 'tight';
 numgraphs = layoutsize*layoutsize;
 numbursts = ceil((analysisEnd - analysisStart+1) / numgraphs);

for startburst = analysisStart:numbursts:analysisEnd
     endburst = min(startburst+numbursts-1,analysisEnd);
     nexttile
     plot(origins(startburst:endburst,1), ...
         origins(startburst:endburst,2), '*-','MarkerEdgeColor','k','MarkerFaceColor','k');
     xticklabels({})
     yticklabels({})
end

 exportgraphics(t,'../tmp/tR1.9--fE0.98-origins.pdf')

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
