DT = csvread('runDT.csv',1,0);
accuracy = reshape(DT(:,3),11,10);
imagesc(accuracy);
xlabel('window size')
xticklabels = 10:10:100;
yticklabels = 0:10:100;
set(gca,'XTickLabel', xticklabels, 'YTickLabel', yticklabels);
xlabel('window size'); ylabel('gap');
caxis([0.5 1])
colorbar;

LR = dlmread('runRegression.csv');
R2score = reshape(LR(:,1),11,10);
imagesc(R2score);
xlabel('window size')
xticklabels = 10:10:100;
yticklabels = 0:10:100;
set(gca,'XTickLabel', xticklabels, 'YTickLabel', yticklabels);
xlabel('window size'); ylabel('gap');
caxis([0 1])
colorbar;