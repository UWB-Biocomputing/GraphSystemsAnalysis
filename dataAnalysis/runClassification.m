% 1. generate precursor sequences with different window and gap size
% 2. perform binary classification (DT, Linear SVM, Poly SVM)

h5file = 'tR_1.0--fE_0.90_10000';
prefile = 'tR_1.0--fE_0.90/preBurst1000_gap0_Seq.csv';
nonfile = 'tR_1.0--fE_0.90/nonBurst1000_gap2000_Seq.csv';
% window = [500];
window = [50;100;500];
% window = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
% gapPre = [0; 10; 20; 30; 40; 50; 60; 70; 80; 90; 100];
gapPre = 0;
gapNon = 1000;                  % fixed

preData = csvread(prefile); preData = preData(:,1:end-1);
nonData = csvread(nonfile); nonData = nonData(:,1:end-1);
outfile = 'tR_1.0--fE_0.90/classification.csv';
fid = fopen(outfile, 'w') ;
fprintf(fid,'method,window,gapPre,accuracy,loss,trainT\n');

% n = (510 - window)/10;
% gapPre = zeros(n,1);
% for k = 1:n
%     gapPre(k) = window*k;
% end

for i = 1:size(window,1)
    sub_nonData = getPartialSeq(nonData,window(i),0);
%     fprintf(1,'Classification (Decision Tree)\n');
%     sub_nonfile = ['data/nonBurst', int2str(window(i)), ...
%                    '_gap', int2str(gapNon)]; 
%     csvwrite([sub_nonfile '.csv'], sub_nonData);
    for j = 1:size(gapPre,1)
        sub_preData = getPartialSeq(preData,window(i),gapPre(j));
        [accuracy, loss, trainT] = DT(sub_preData,sub_nonData);
        [accuracy2, loss2, trainT2] = linearSVM(sub_preData,sub_nonData);
        [accuracy3, loss3, trainT3] = polySVM(sub_preData,sub_nonData);
        fprintf(fid,'DT, %d,%d,%6.4f,%6.4f,%6.4f\n', ...
                window(i),gapPre(j),accuracy,loss,trainT);  
        fprintf(fid,'lSVM, %d,%d,%6.4f,%6.4f,%6.4f\n', ...
                window(i),gapPre(j),accuracy2,loss2,trainT2); 
        fprintf(fid,'pSVM, %d,%d,%6.4f,%6.4f,%6.4f\n', ...
                window(i),gapPre(j),accuracy3,loss3,trainT3); 
%         sub_prefile = ['data/preBurst', int2str(window(i)), ...
%                         '_gap', int2str(gapPre(j))];
%         csvwrite([sub_prefile '.csv'], sub_preData);
    end 
end
% fclose(fid);

