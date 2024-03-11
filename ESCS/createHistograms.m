
% waitData stores [rate, avgWait]
waitData = zeros(13, 3);
n = 1;

for d = [80 110 130 150]
    filePath = strcat(string(d), '/test-spd-911-out.xml');
    outFile = strcat(string(d), '/utilizationHist', string(d));
    [rate, avgWait, numAbandoned] = utilizationHist(filePath, outFile);
    waitData(n,:) = [rate, avgWait, numAbandoned];
    n = n+1;
end

save('waitData.mat', 'waitData');