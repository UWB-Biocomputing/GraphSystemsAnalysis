function ringTimeHist(data, bins, outFile)
% ringTimeHistogram.m Creates a histogram from a vector of ring (wait)
% times.
%
% Syntax: ringTimeHist(data, 10, outFile)
%
% Inputs:
%   data : Vector of ring (wait) times
%   bins : Number of bins in the histogram
%   outFile : Path to the file where histogram will be saved
%
% Outputs:
%   None
    h = histogram(data, 'NumBins', bins);

    % Get the values of the edges of the bins for centering labels
    edges = h.BinEdges;
    % Get bin values and total to estimate percentages for label
    values = h.Values;
    totVal = sum(h.Values);
    % Percentage of total for each bin
    s = compose('%.1f%%', values/totVal * 100);
    % Calculate X and Y positioning of the labels
    centers = edges(1:end-1)+diff(edges)/2;
    yPos = values + 0.2 * mean(values);
    
    % Place percentage labels centered on top of each bin
    text(centers, yPos, s, 'HorizontalAlignment', 'center')
    % Add x and y labels
    xlabel("Wait Time (s)")
    ylabel("Frequency (tens of thousands of observations)")
    
    exportgraphics(gcf, outFile)
    
end