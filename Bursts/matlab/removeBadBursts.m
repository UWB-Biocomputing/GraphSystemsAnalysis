%Author: Jewel Y. Lee (jewel87@uw.edu)
%Last updated: 5/20/2018

function removeBadBursts()
datadir = '/Users/jewellee/Desktop/thesis-work/BrainGrid/tR_1.0--fE_0.90';
window = 500; gapPre = 0; gapNon = 2000;
preName = ['/preBurst', int2str(window), '_gap', int2str(gapPre)];
preFile = [datadir, preName];
nonName = ['/nonBurst', int2str(window), '_gap', int2str(gapNon)];  
nonFile = [datadir, nonName];
originFile = [datadir, '/allBurstOriginXY'];

preBurst = csvread([preFile, '.csv'],1,1); 
nonBurst = csvread([nonFile, '.csv'],1,1);
preEndTime = preBurst(:,4);
nonEndTime = nonBurst(:,4);

gapWidth = preEndTime - nonEndTime;
preWidth = preBurst(:,4)-preBurst(:,3);
nonWidth = nonBurst(:,4)-nonBurst(:,3);
% find bad bursts
badNon = find(nonWidth<window);
badGap = find(gapWidth<gapNon);
badPre = find(preWidth<window);
badData = union(badNon,badGap);
badData = union(badData,badPre);

% data
preBurstData = csvread([preFile, '_Seq.csv']);
nonBurstData = csvread([nonFile, '_Seq.csv']);
preBurstData = preBurstData(:,1:end-1);
nonBurstData = nonBurstData(:,1:end-1);
originData = csvread([originFile, '.csv']);

% remove bad data backwards so array index in badData still holds true
for i = size(badData,1):-1:1
    preBurstData(badData(i),:) = []; 
    nonBurstData(badData(i),:) = [];
    originData(badData(i),:) = [];
end

csvwrite([preFile, '_ML.csv'], preBurstData);
csvwrite([nonFile, '_ML.csv'], nonBurstData);
csvwrite([originFile, '_ML.csv'], originData);
