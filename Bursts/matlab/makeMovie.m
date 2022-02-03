%% Jewel Y. Lee (Documented. Last updated: Jan 19, 2018)
% Modifed 2/3/22 by Michael Stiber to change movie settings
%  Usage: makeBurstMovie bursts/burst1
%  - read <burst#.mat> to get unique variable <frames> for each burst
%  - output burst video <burst#.avi>
function makeMovie(infile, frate, cmin, cmax)
% ------------------------------------------------------------------------
% Read from input data and open output file
% - spikesProbedNeurons = neurons and its firing times (column = neuron)
% - spikesHistory = spike count in each 10ms bins
% ------------------------------------------------------------------------

frames = csvread(['Binned/' infile, '.csv']);
n_frames = size(frames,2);
% ------------------------------------------------------------------------
% Video settings
% ------------------------------------------------------------------------
videofile = ['Movies/' infile];             
v = VideoWriter(videofile);
v.FrameRate = frate;                   % set frame rate (default 30)
v.Quality = 100;
% ------------------------------------------------------------------------
% Saving each frame (column vector) and save as video
% - the size of frames equals number of pixels x number of frames
% - for example, 10000 x 56 means: 100 x 100 pixels and 56 frames 
% ------------------------------------------------------------------------
open(v);
for i = 1:n_frames                                     
    f = reshape(frames(:,i), 100, 100); % reshape flatten image vector
    imagesc(f);                         % create an image from this matrix
%    title(['Frame: ' num2str(i)]);      % set title
    axis([0 100 0 100]); axis image;    % set axis 
    caxis([cmin cmax]);                   % set color scale
    xticks([]);
    yticks([]);
    % colorbar;                         % show colorbar
    m = getframe(gcf);                  % put all images in mov array
    writeVideo(v,m)                     % make video from images
end
close(v);
end
% impixelinfo % show pixel info
