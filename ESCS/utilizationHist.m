function [rate, avgWait, numAbandoned] = utilizationHist(filePath, outFile)
% utilizationHist.m Creates a utilization histogram from an XML ESCS
% simulation output file.
%
% The XML file format must conform to the one in the "test-data" directory.
% This is the format used in Graphitti's v0.9.2 release.
%
% Syntax: [rate, avgWait, nAbandoned] = utilizationHist(filePath, outFile)
%
% Inputs:
%   filePath : Path to the simulation output file
%   outFile  : Path of the file where the histogram is saved
%
% Outputs:
%   rate    : Simulation call rate (calls/hr)
%   avgWait : Simulation average wait time
%   numAbandoned : Number of abandoned calls during the simulation
    tic
    
    simOutput = readXmlFile(filePath);
    data = simOutput.utilizationHistory{1};
    
    % create histogram
    h = histogram(data, 'NumBins', 10);
    
    % Get the values of the edges of the bins for centering labels
    edges = h.BinEdges;
    % Get bin values and total to estimate percentages for label
    values = h.Values;
    totVal = sum(h.Values);
    % Percentage of total for each bin
    s = compose('%.1f%%', values/totVal * 100);
    % Calculate X and Y positioning of the labels
    centers = edges(1:end-1)+diff(edges)/2;
    yPos = values + 0.05 * mean(values);
    
    % Place percentage labels centered on top of each bin
    text(centers, yPos, s, 'HorizontalAlignment', 'center')
    % Add x and y labels
    xlabel("Utilization ratio")
    ylabel("Frequency (hundreds of thousands of observations)")
    
    exportgraphics(gcf, outFile)
    close

    % Calculate average waiting time
    beginT = simOutput.BeginTimeHistory{1};
    answerT = simOutput.AnswerTimeHistory{1};
    % Filter out dropped calls
    answeredIdx = answerT ~= 0;
    answerT = answerT(answeredIdx);
    beginT = beginT(answeredIdx);
    % Calculate wait time
    waitT = answerT - beginT;
    avgWait = mean(waitT);
    
    % Calculate number of calls per hour (call rate)
    simulationTime = simOutput.simulationEndTime/3600; % sim time in hours
    numCalls = simOutput.receivedCalls(1);
    rate = numCalls/simulationTime;

    % Calculate the number of abandoned calls
    numAbandoned = sum(simOutput.WasAbandonedHistory{1});

    toc
end