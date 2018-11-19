%% Jewel Y. Lee (Documented. Last updated: Jan 23, 2018)
%  - read <allBurst.csv> and BrainGrid h5 file
%  - output burst origin (neuron index) to <allBurstOrigin.csv>
function getBurstOrigin
% #########################################################################
% # USER_DEFINED VARIABLES ---------------------------------------------- #
% #########################################################################
grid = 100;                 % grid size (i.e. 100 means 100 x 100)
initial = 10;               % the starting time bin of the burst
h5file = '1102_full_tR_1.0--fE_0.90_10000';
% #########################################################################
xloc = double((hdf5read([h5file '.h5'], 'xloc'))');     % x location
yloc = double((hdf5read([h5file '.h5'], 'yloc'))');     % y location
data = csvread('allBurstInfo.csv',1,1);             % read window info
n_burst = length(data);                         % number of burst
% ------------------------------------------------------------------------
% Output files
% ------------------------------------------------------------------------
fid = fopen('allBurstOrigin.csv', 'w') ;        % output file for ML 
fid2 = fopen('allBurstOrigin2.csv', 'w') ; 
% videofile = strcat('exBurstOrigin.avi');             
% v = VideoWriter(videofile, 'Uncompressed AVI');  
% v.FrameRate = 1;                           
% open(v);
for i = 1:n_burst
    burstfile = ['bursts/burst', num2str(i)];   
    load([burstfile, '.mat'], 'frames');      
    % find max values (neuron that spikes the most in a time bin)
    largest = max(frames(:,initial));           
    indexes = find(frames(:,initial)==largest, 2);
    n = length(indexes);
    % write locations in a matrix  x1 x2 .. xn
    %                              y1 y2 .. yn
    points = zeros(n);
    for j = 1:n
        k = 1;
        points(k,j) = xloc(indexes(j))+1;   % index starts at 0 in BG
        points(k+1,j) = yloc(indexes(j))+1; % matlab start from 1, so +1
    end
    % get centroid of points with max value
    centerX = ceil(mean(points(1,:)));          
    centerY = ceil(mean(points(2,:)));
    centerIndex = (centerY-1)*grid + centerX;
    fprintf(fid, '%d\n', centerIndex);  
    fprintf(fid2, '%d, %d\n', centerX, centerY);  
%% visualize 
%     f = reshape(frames(:,initial), grid, grid);
%     imagesc(f');
%     hold on;
%     plot(centerX, centerY, 'p','LineWidth',1,'MarkerSize',15, ...
%         'MarkerEdgeColor','w','MarkerFaceColor','red');
%     pause(1);
%     m = getframe(gcf);                  % put all images in mov array
%     writeVideo(v,m)                     % make video from images
end
fclose(fid);
fclose(fid2);
% close(v);
end
