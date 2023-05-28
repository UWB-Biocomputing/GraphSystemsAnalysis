% VERIFYORIGINS Manual check of origin location computation
%
% The goal of this is to facilitate checking origin locations. Plot bin 10
% from each burst and overlay the computed burst origin. Present bursts in
% random order, so the user can get to see bursts from throughout the
% simulation quickly.
%
%   Syntax: verifyOrigins(h5dir, id)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'

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
    % A frame has one row per neuron and one column per time bin. Grab the
    % column for the desired time bin and then make it a 100x100 array, to
    % match the network "viewed from above", with neuron (x, y) = (0, 0) at
    % the top left. Note that, within Graphitti, neurons are numbered in
    % row-major order (starting at top left, across each row before moving
    % on to the next row; i.e., the column -- x coordinates -- increments
    % faster). I write this in such painstaking detail because not only
    % does Matlab use one-based, rather than zero-based, indexing, but it
    % generally does things in column-major order. An example of this is
    % "reshape" below, and so we need to transpose its result to get the
    % right display of each frame.
    f = reshape(frame(:, bin), 100, 100)';
    maxVal = max(f, [], 'All');
    numMax = length(find(f == maxVal));
    imagesc(f);
    colormap(parula);
    set(gca, 'Box', 'on', 'LineWidth', 1.0);
    title([num2str(burstsDone/numBursts*100) '%: Burst ' num2str(burst) ...
        ' at (' num2str(burstOrigins(burst,1)) ', '...
        num2str(burstOrigins(burst,2)) '); bin ' num2str(bin) ...
        ' of ' num2str(size(frame,2)) ' with max value of ' num2str(maxVal) ...
        ' for ' num2str(numMax) ' neurons']);
    hold on;

    % According to the Matlab documentation for imagesc(), "The row and
    % column indices of the elements determine the centers of the
    % corresponding pixels." Therefore, that means that (1, 1) is the
    % center of the top-left pixel. Burst origins, on the other hand, are
    % computed by getBurstOriginXYN(), which computes the origins based on
    % Graphitti neuron (x, y) locations (zero-based). Therefore, we need to
    % add one to the x and y coordinates to place the origin markers in the
    % right locations.
    %
    % We have already transposed the array, and imagesc() uses ij
    % coordinates (origin at top left).
    plot(burstOrigins(burst,1)+1, burstOrigins(burst,2)+1, 'Marker','pentagram',...
        'MarkerFaceColor','red', 'MarkerEdgeColor', 'red', 'MarkerSize', 15);
    s = input('Press return for next burst', 's');
    clf;
    burstsDone = burstsDone +1;
end


end
