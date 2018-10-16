function ML_runDT_findGW(datadir)
% 1. generate precursor sequences with different window and gap size
% 2. perform binary classification (DT, Linear SVM, Poly SVM)

% datadir = '/Users/jewellee/Desktop/thesis-work/BrainGrid/tR_1.0--fE_0.90';
prefile = [datadir, '/MLdata/preBurst500_gap0_ML.csv'];
nonfile = [datadir, '/MLdata/nonBurst500_gap2000_ML.csv'];
outfile = [datadir, '/MLdata/findGW_classification_DT_2.csv'];
% DT_outfile = [dir '/classification_DT.csv'];
% linearSVM_outfile = [dir '/classification_linearSVM.csv'];
% polySVM_outfile = [dir '/classification_polySVM.csv'];

preData = csvread(prefile);% preData = preData(:,1:end-1);
nonData = csvread(nonfile);% nonData = nonData(:,1:end-1);

n = 1;
n_windows = 100;
windows = zeros(n_windows,1);
for k = 1:n_windows
    windows(k) = k*n;
end
n_gaps = 100;
gaps = zeros(n_gaps,1);
for k = 1:n_gaps
    gaps(k) = k*n;
end

fid = fopen(outfile, 'w') ;
fprintf(fid,'method,window,gapPre,accuracy,loss,trainT\n');

for i = 1:size(windows,1)
    sub_nonData = getPartialSeq(nonData,windows(i),0);
%     sub_nonfile = [dir 'MLdata/nonBurst', int2str(window(i)), ...
%                    '_gap', int2str(gapNon)]; 
%     csvwrite([sub_nonfile '.csv'], sub_nonData);
    for j = 1:size(gaps,1)
        sub_preData = getPartialSeq(preData,windows(i),gaps(j));
%         sub_prefile = [dir, 'MLdata/preBurst', int2str(window(i)), ...
%                        '_gap', int2str(gapPre(j))];
%         csvwrite([sub_prefile '.csv'], sub_preData);
        
        [accuracy, loss, trainT] = ML_DT(sub_preData,sub_nonData);
        fprintf(fid,'  DT,%10d,%10d,%10.4f,%10.4f,%10.4f\n', ...
                windows(i),gaps(j),accuracy,loss,trainT);  
        

    end 
end
fclose(fid);
end

