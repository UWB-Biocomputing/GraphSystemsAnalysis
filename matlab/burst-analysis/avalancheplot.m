function [binEdges, probabilities] = avalancheplot( alengths, fitlimit )
%AVALANCHEPLOT Produce log-log and semilog plots of avalanche size distribution
%   Computes the probabilities of avalanche lengths and then produces a
%   log-log plot of probability vs. length and a semilog plot of the same.
%   Produces best fits of the data to power law and exponential functions
%   and plots lines of best fit on each graph.
%   alengths   vector of avalanche lengths
%   fitlimit   (optional) only fit power law function to data smaller than
%              this amount
%
% To plot only a subset of the avalanches, after reading the avalanche
% file, make a call like the following (example shows last 1/4 of
% avalanches).
% [binEdges, probabilities] = ...
%       avalancheplot(aspikes(min(find(atimes>atimes(round(numa*0.75)))):end));

% If limit for fitting data not provided, fit all data
if nargin < 2
    fitlimit = max(alengths);
end

% We will count the number of avalanches of each length that is represented
% in the data.
binEdges = unique(alengths);
if isrow(binEdges)
    binEdges = [binEdges binEdges(end)+1]; % handle rightmost bin issue
else
    binEdges = [binEdges' binEdges(end)+1];
end
[binCounts, binEdges] = histcounts(alengths, binEdges);
binEdges = binEdges(1:end-1);
probabilities = binCounts/length(alengths);

% Log-log plot will be linear if there is a power law relationship, Y=X^a
figure(1); clf;
loglog(binEdges, probabilities, 'o');
xlabel('Avalanche Size');
ylabel('Probability');

% Next, let's do a linear fit of the log-log data, for the non-burst data
nonbursts = find(binEdges<fitlimit);
logprobs = log10(probabilities(nonbursts));
logsizes = log10(binEdges(nonbursts));
% To get the Y intercept, we need to pad the X values with a column of 
% ones and use the \ operator to get Y intercept and slope of simple LMS
% linear fit
X = [ones(length(logsizes),1) logsizes'];
b = X\logprobs';

fprintf('Slope for the log-log plot: %f\n', b(2));

% Now overlay the best fit line on figure 1.
hold on
fitYvals = X * b;
loglog(binEdges(nonbursts), 10.^fitYvals, '-');
set(gca, 'FontSize', 12);
set(gca, 'FontSize', 12);
print('avalanche_loglog', '-deps2');

% Semi-log plot will be linear if there is an exponential relationship,
% Y=a^X
figure(2); clf;
semilogy(binEdges, probabilities, 'o');
xlabel('Avalanche Size');
ylabel('Probability');

% Next, let's do a linear fit of the semilog data
% To get the Y intercept, we need to pad this with a column of ones and use
% the \ operator to get Y intercept and slope of simple LMS linear fit
X = [ones(length(nonbursts),1) binEdges(nonbursts)'];
b = X\logprobs';

fprintf('Slope for the semilog plot: %f\n', b(2));

% Now overlay the best fit line on figure 2.
hold on
fitYvals = X * b;
semilogy(binEdges(nonbursts), 10.^fitYvals, '-');

end

