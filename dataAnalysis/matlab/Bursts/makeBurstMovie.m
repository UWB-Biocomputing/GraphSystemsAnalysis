%% Jewel Y. Lee (Documented. Last updated: Nov 29, 2017)
%  Usage: makeBurstMovie bursts/burst1
%  - read <burst#.mat> to get unique variable <frames> for each burst
%  - output burst video <burst#.avi>
function makeBurstMovie(burstfile)
% ------------------------------------------------------------------------
% Read from input data and open output file
% - spikesProbedNeurons = neurons and its firing times (column = neuron)
% - spikesHistory = spike count in each 10ms bins
% ------------------------------------------------------------------------
% burstfile = 'burst/burst2';
% load('burst/burst2.mat','frames');
load([burstfile, '.mat'], 'frames');
n_frames = length(frames(1,:));
% ------------------------------------------------------------------------
% Video settings
% ------------------------------------------------------------------------
videofile = strcat(burstfile, '.avi');             
v = VideoWriter(videofile, 'Uncompressed AVI');     
v.FrameRate = 10;                       % set frame rate (default 30)
min = 0; max = 20;                      % color bar limit
% ------------------------------------------------------------------------
% Saving each frame (column vector) and save as video
% - the size of frames equals number of pixels x number of frames
% - for example, 10000 x 56 means: 100 x 100 pixels and 56 frames 
% ------------------------------------------------------------------------
open(v);
for i = 1:n_frames                                     
    f = reshape(frames(:,i), 100, 100); % reshape flatten image vector
    imagesc(f);                         % create an image from this matrix
    title(['Frame: ' num2str(i)]);      % set title
    axis([0 100 0 100]); axis image;    % set axis 
    caxis([min max]);                   % set color scale
    % colorbar;                         % show colorbar
    m = getframe(gcf);                  % put all images in mov array
    writeVideo(v,m)                     % make video from images
end
close(v);
end
% impixelinfo % show pixel info
