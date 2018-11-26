function ML_runClassification1(dir)
% 1. generate precursor sequences with different window and gap size
% 2. perform binary classification (DT, Linear SVM, Poly SVM)

% dir = '/Users/jewellee/Desktop/thesis-work/BrainGrid/tR_1.0--fE_0.90';
prefile = [dir '/MLdata/preBurst500_gap0_Seq.csv'];
nonfile = [dir '/MLdata/nonBurst500_gap2000_Seq.csv'];
outfile = [dir '/classification1.csv'];
% DT_outfile = [dir '/classification_DT.csv'];
% linearSVM_outfile = [dir '/classification_linearSVM.csv'];
% polySVM_outfile = [dir '/classification_polySVM.csv'];

preData = csvread(prefile); preData = preData(:,1:end-1);
nonData = csvread(nonfile); nonData = nonData(:,1:end-1);

% n = 5;
% n_windows = 50;
% windows = zeros(1,n_windows);
% n_gaps = 50;
% gaps = zeros(1,n_gaps);
% for k = 1:n_windows
%     windows(k) = k*n;
%     gaps(k) = k*n;
% end

windows = [10; 20; 50; 100; 200; 500];
gaps = [0];
gapNon = 2000;
% windows = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
% gaps = [0; 10; 20; 30; 40; 50; 60; 70; 80; 90; 100];


fid = fopen(outfile, 'w') ;
fprintf(fid,'method,window,gapPre,accuracy,loss,trainT\n');

for i = 1:size(windows,2)
    sub_nonData = getPartialSeq(nonData,windows(i),0);
    
%     fprintf(1,'Classification (Decision Tree)\n');
    sub_nonfile = [dir, '/MLdata/nonBurst', int2str(windows(i)), ...
                   '_gap', int2str(gapNon)]; 
    csvwrite([sub_nonfile '.csv'], sub_nonData);
    for j = 1:size(gaps,2)
        sub_preData = getPartialSeq(preData,windows(i),gaps(j));
        
        [accuracy, loss, trainT] = ML_DT(sub_preData,sub_nonData);
        fprintf(fid,'DT, %d,%d,%6.4f,%6.4f,%6.4f\n', ...
                windows(i),gaps(j),accuracy,loss,trainT);  
        
        [accuracy2, loss2, trainT2] = ML_linearSVM(sub_preData,sub_nonData);
        fprintf(fid,'lSVM, %d,%d,%6.4f,%6.4f,%6.4f\n', ...
                windows(i),gaps(j),accuracy2,loss2,trainT2); 
        
        [accuracy3, loss3, trainT3] = ML_polySVM(sub_preData,sub_nonData);
        fprintf(fid,'pSVM, %d,%d,%6.4f,%6.4f,%6.4f\n', ...
                windows(i),gaps(j),accuracy3,loss3,trainT3); 
          
        
        sub_prefile = [dir, '/MLdata/preBurst', int2str(windows(i)), ...
                        '_gap', int2str(gaps(j))];
        csvwrite([sub_prefile '.csv'], sub_preData);
    end 
end
fclose(fid);
end
