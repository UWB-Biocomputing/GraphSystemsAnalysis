%MAKEIMGARRAY create one aggregated flatten image for target event
%Read spikeTime info for the target event (nonBurst, preBurst or Burst) and
%return one aggregated flatten image where each pixel represents a neuron 
%and pixel value is the spike count. 
% 
%   Syntax: imgArray = makeImgArray(spikeTime, n_neurons)
%   
%   Input:
%   spikeTime - matrix contains spikeTime info for target event
%
%   Output:
%   imgArray - flatten image. size = 1 x n_neurons

%Author: Jewel Y. Lee (jewel87@uw.edu)
function imgArray = makeImgArray(spikeTime)
load('config.mat','n_neurons')
n = size(spikeTime, 1);         % number of rows in spikeTime
%% one image per event
    imgArray = zeros(1,n_neurons);
    for row = 1:n
        col = 2;
        while spikeTime(row,col) ~= 0
            imgArray(1,spikeTime(row,col)) = imgArray(1,spikeTime(row,col))+1;
            col = col + 1;
        end
    end

end