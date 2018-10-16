function [f1_rbf, loss_rbf, trainT_rbf] = ML_rbfSVM(X1, X2)
% create labels, 1 for pre-burst; 0 for non-burst
x1_samples = size(X1,1); x2_samples = size(X2,1);
Y1 = ones(x1_samples,1); Y2 = zeros(x2_samples,1);
% concatenate data from two classes into one 
X = [X1;X2]; Y = [Y1;Y2];
% divide training data and test data
nSamples = size(X,1);           % get sample info
nTrain = ceil(nSamples*0.8);    % training data
%nTest = nSamples - nTrain;      % test data
% fprintf(1, 'Sample: %5d; Train: %5d; Test: %5d;\n', nSamples, nTrain, nTest); 
  
% perform random shuffling
rng(1);                       
rp = randperm(nSamples);        
trainRP = rp(1:nTrain);  
trainData = X(trainRP,:); 
trainLabel = Y(trainRP); 
testRP = rp(nTrain+1:end);
testData = X(testRP,:); 
testLabel = Y(testRP);

% ---------------------------------------------------------------------
% RBF SVM
% ---------------------------------------------------------------------
% time model training
SVM_rbf = @() fitcsvm(trainData, trainLabel, ...
                     'KernelFunction', 'rbf');
trainT_rbf = timeit(SVM_rbf);
% model training
SVM_rbf = fitcsvm(trainData, trainLabel, ...
                 'KernelFunction', 'rbf');
% perform cross validation (10 fold)
tic
CVMdl_rbf = crossval(SVM_rbf);  
toc
loss_rbf = kfoldLoss(CVMdl_rbf);
% get model performance - confusion matrix and accuracy
pred_rbf = predict(SVM_rbf, testData);
conM_rbf = confusionmat(testLabel, pred_rbf); 
eval_rbf = Evaluate(testLabel, pred_rbf);

    fprintf(1, '\n#########################\n');
    fprintf(1, 'RBF SVM results:');
    fprintf(1, '\n#########################\n');
    fprintf(1, 'confusion matrix:\n');
    disp(conM_rbf);
    f1_rbf = eval_rbf(6);
    fprintf(1, 'model accuracy:     %10.4f\n', eval_rbf(1));
    fprintf(1, 'model precision:    %10.4f\n', eval_rbf(4));
    fprintf(1, 'model recall:       %10.4f\n', eval_rbf(5));
    fprintf(1, 'model f1 score:     %10.4f\n', eval_rbf(6));
    fprintf(1, 'training time:      %10.4f\n', trainT_rbf); 
    fprintf(1, 'k-fold error:       %10.4f\n', loss_rbf);     
end
