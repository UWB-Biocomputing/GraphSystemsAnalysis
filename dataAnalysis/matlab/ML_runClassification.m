function ML_runClassification(datadir)
% 1. generate precursor sequences with different window and gap size
% 2. perform binary classification (DT, Linear SVM, Poly SVM)

mask = 0;
windows = [5;10;20;50;100;200;500];
% datadir = '/Users/jewellee/Desktop/thesis-work/BrainGrid/tR_1.0--fE_0.90';
prefile = [datadir, '/MLdata/preBurst500_gap0_ML.csv'];
nonfile = [datadir, '/MLdata/nonBurst500_gap2000_ML.csv'];
outfile = [datadir, '/MLdata/classification_', int2str(mask), '.csv'];

preData = csvread(prefile); %preData = preData(:,1:end-1);
nonData = csvread(nonfile); %nonData = nonData(:,1:end-1);

fid = fopen(outfile, 'w') ;
fprintf(fid,'method,window,gapPre,accy,loss,trainT\n');

for i = 1:size(windows,1)
     sub_nonData = getPartialSeq(nonData,windows(i),0);
%     sub_nonfile = [datadir, '/MLdata/nonBurst', int2str(windows(i)), ...
%                    '_mask', int2str(mask)]; 
%     csvwrite([sub_nonfile '.csv'], sub_nonData);
    for j = 1:size(mask,1)
        sub_preData = getPartialSeq(preData,windows(i),mask(j));
%        sub_prefile = [datadir, '/MLdata/preBurst', int2str(windows(i)), ...
%                       '_mask', int2str(mask(j))];
%        csvwrite([sub_prefile '.csv'], sub_preData);
        
%        [accuracy, loss, trainT] = ML_DT(sub_preData,sub_nonData);
%        fprintf(fid,'  DT,%5d,%5d,%10.4f,%10.4f,%10.4f\n', ...
%                windows(i),mask(j),accuracy,loss,trainT);  
        
%        [accuracy2, loss2, trainT2] = ML_linearSVM(sub_preData,sub_nonData);
%        fprintf(fid,'lSVM,%5d,%5d,%10.4f,%10.4f,%10.4f\n', ...
%                windows(i),mask(j),accuracy2,loss2,trainT2); 
        
        [accuracy3, loss3, trainT3] = ML_polySVM(sub_preData,sub_nonData);
        fprintf(fid,'pSVM,%5d,%5d,%10.4f,%10.4f,%10.4f\n', ...
                windows(i),mask(j),accuracy3,loss3,trainT3); 
    end 
end
fclose(fid);
end

