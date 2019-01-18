% script to generate precursor sequences with different window and gap size
h5file = 'tR_1.0--fE_0.90_10000';
prefile = 'csv/preBurst1000_gap0_Seq.csv';
nonfile = 'csv/nonBurst1000_gap2000_Seq.csv';
% window = [5,10];
window = [10; 20; 30; 40; 50; 60; 70; 80; 90; 100];
gapPre = [0; 10; 20; 30; 40; 50; 60; 70; 80; 90; 100];
% gapPre = [0,10];
gapNon = 1000;                  % fixed

%preData = csvread(prefile); preData = preData(:,1:end-1);
nonData = csvread(nonfile); nonData = nonData(:,1:end-1); 

for i = 1:length(window)
    sub_nonData = getPartialSeq(nonData,window(i),0);
    csvwrite('data/nonBurstData.csv', sub_nonData);
    system('python regression.py >> runRegression.csv');  
%     for j = 1:length(gapPre)
%         sub_preData = getPartialSeq(preData,window(i),gapPre(j));
%         csvwrite('data/preBurstData.csv', sub_preData);
% %         fprintf(1,'preBurst: %d, %d\n', window(i),gapPre(j));
%         system('python regression.py >> runRegression.csv');  
%     end 
end
% fclose(fid);

