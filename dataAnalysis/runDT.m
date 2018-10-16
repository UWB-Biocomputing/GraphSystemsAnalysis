% script to generate precursor sequences with different window and gap size
h5file = 'tR_1.0--fE_0.90_10000';
prefile = 'csv/preBurst1000_gap0_Seq.csv';
nonfile = 'csv/nonBurst1000_gap2000_Seq.csv';
% window = [500];
window = [10; 20; 30; 40; 50; 60; 70; 80; 90; 100];
gapPre = [0; 10; 20; 30; 40; 50; 60; 70; 80; 90; 100];
% gapPre = [0,10];
gapNon = 1000;                  % fixed

preData = csvread(prefile); preData = preData(:,1:end-1);
nonData = csvread(nonfile); nonData = nonData(:,1:end-1);
outfile = 'runDT.csv';
fid = fopen(outfile, 'w') ;
fprintf(fid,'window,gapPre,accuracy,loss,trainT\n');

% n = (510 - window)/10;
% gapPre = zeros(n,1);
% for k = 1:n
%     gapPre(k) = window*k;
% end

for i = 1:length(window)
    sub_nonData = getPartialSeq(nonData,window(i),0);
%     fprintf(1,'Classification (Decision Tree)\n');
%     sub_nonfile = ['data/nonBurst', int2str(window(i)), ...
%                     '_gap', int2str(gapNon)]; 
%     csvwrite([sub_nonfile '.csv'], sub_nonData);
    for j = 1:length(gapPre)
        sub_preData = getPartialSeq(preData,window(i),gapPre(j));
        [accuracy, loss, trainT] = decisionTree(sub_preData,sub_nonData);
        fprintf(fid,'%d,%d,%6.4f,%6.4f,%6.4f\n', ...
                window(i),gapPre(j),accuracy,loss,trainT);        
%         sub_prefile = ['data/preBurst', int2str(window(i)), ...
%                         '_gap', int2str(gapPre(j))];
%         csvwrite([sub_prefile '.csv'], sub_preData);
    end 
end
fclose(fid);

