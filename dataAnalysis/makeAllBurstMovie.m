%% Jewel Y. Lee (Documented. Last updated: Nov 29, 2017)
%  Usage: makeAllBurstMovie
%  - read <allBurstInfo.csv> and <burst#.mat>
%  - output video <burst#.avi> for every bursts
b = csvread('allBurstInfo.csv',1,1);    % read burst metadata
n_burst = size(b(:,1));                 % get number of bursts

for i = 1:n_burst
    burst_file = strcat('bursts/burst', num2str(i));
    makeBurstMovie(burst_file);         
    fprintf('done with moive %s\n', burst_file);
end