
function showAllBurstOrigins(h5dir)
bbInfoFile = [h5dir '/binnedBurstInfo.csv'];
bbInfo = csvread(bbInfoFile,1,1); 
n_bursts = size(bbInfo,1); 
origins = csvread([h5dir '/allBurstOriginXY.csv']);                 
videofile = [h5dir, '/allBurstOrigins.avi'];  
v = VideoWriter(videofile,'Uncompressed AVI');     
v.FrameRate = 30;                           % set frame rate (default 30)
open(v);
for i = 1:n_bursts   
    burstfile = [h5dir, '/Binned/burst_', num2str(i)];
    frames = csvread([burstfile, '.csv']);
    cmin = 0; cmax = max(max(frames));      % color bar limit    
    bin = 11;                               % bin = size(frames,2)-5;
    f = reshape(frames(:,bin), 100, 100);   % reshape flatten image vector
    imagesc(f');                            % create an image from this matrix
    title(['Burst_' num2str(i) ' (bin: ' num2str(bin) ')']);
    axis([0 100 0 100]); axis image;        % set axis 
    caxis([cmin cmax]);                     % set color scale
    %colorbar;                              % show colorbar
    hold on;
    plot(origins(i,1), origins(i,2),'pentagram', ...
        'MarkerSize',20,...
        'MarkerEdgeColor','white',...
        'MarkerFaceColor','red')
    m = getframe(gcf);                      % put all images in mov array
    writeVideo(v,m)                         % make video from images
    fprintf('done with burst:%d/%d\n', i, n_bursts);
end
close(v);
end