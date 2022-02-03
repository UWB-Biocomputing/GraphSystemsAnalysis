%% Jewel Y. Lee (Documented. Last updated: Nov 29, 2017)
%  Modified 2/3/22 Michael Stiber to use newer, makeMovie, code
%  Usage: makeAllBurstMovie
%  - read <allBurstInfo.csv> and <burst#.mat>
%  - output video <burst#.avi> for every bursts
function makeAllBurstMovie(dataDir)

% The following is not efficient; should be able to just read the
% last row of the CSV file to get the number of bursts from the
% final burst ID.
b = readmatrix([dataDir '/allBinnedBurstInfo.csv']);    % read burst metadata
n_burst = size(b(:,1));                 % get number of bursts

for i = 1:n_burst
    burst_file = strcat('burst_', num2str(i));
    makeMovie(burst_file, 10, 0, 20);         
    fprintf('done with movie %s\n', burst_file);
end
