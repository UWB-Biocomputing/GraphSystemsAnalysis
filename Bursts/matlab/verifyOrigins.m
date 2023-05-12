% VERIFYORIGINS Manual check of origin location computation
%
% The goal of this is to facilitate checking origin locations. Plot bin 10
% from each burst and overlay the computed burst origin. Present bursts in
% random order, so the user can get to see bursts from throughout the
% simulation quickly.


function verifyOrigins(h5dir)

fprintf('Loading data files... ');
% Get origins
burstOrigins = csvread([h5dir '/allBurstOrigin.csv']);
% Get binned neuron spike counts
load([h5dir '/allFrames.mat'], 'allFrames');
fprintf('done.\n')

numBursts = size(burstOrigins, 1);
allBurstNums = randperm(numBursts);
burstsDone = 1;

clf;
for burst = allBurstNums
    frame = allFrames{burst};
    bin = burstOrigins(burst,4);
    f = reshape(frame(:, bin), 100, 100);
    maxVal = max(frame(:,bin));
    numMax = length(find(frame(:,bin) == maxVal));
    imagesc(f');
    colormap(parula);
    set(gca, 'Box', 'on', 'LineWidth', 1.0, 'XTick', [], 'YTick', []);
    title([num2str(burstsDone/numBursts*100) '%: Burst ' num2str(burst) ...
        ' at (' num2str(burstOrigins(burst,1)) ', '...
        num2str(burstOrigins(burst,2)) '); bin ' num2str(bin) ...
        ' of ' num2str(size(frame,2)) ' with max value of ' num2str(maxVal) ...
        ' for ' num2str(numMax) ' neurons']);
    hold on;
    plot(burstOrigins(burst,1), burstOrigins(burst,2), 'Marker','pentagram',...
        'MarkerFaceColor','red', 'MarkerEdgeColor', 'red', 'MarkerSize', 15);
    s = input('Press return for next burst', 's');
    clf;
    burstsDone = burstsDone +1;
end


end
