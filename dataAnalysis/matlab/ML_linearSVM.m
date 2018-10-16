function [f1_score, loss_linear, trainT_linear] = ML_linearSVM(X1, X2)
% create labels, 1 for pre-burst; 0 for non-burst
x1_samples = size(X1,1); x2_samples = size(X2,1);
Y1 = ones(x1_samples,1); Y2 = zeros(x2_samples,1);
% concatenate data from two classes into one 
X = [X1;X2]; Y = [Y1;Y2];

% divide training data and test data
nSamples = size(X,1);           % get sample info
nTrain = ceil(nSamples*0.8);    % training data
nTest = nSamples - nTrain;      % test data
fprintf(1, 'Sample: %5d; Train: %5d; Test: %5d;\n', nSamples, nTrain, nTest); 
  
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
% Linear SVM
% ---------------------------------------------------------------------
SVM_linear = @() fitcsvm(trainData, trainLabel, ...
                        'KernelFunction', 'linear');
trainT_linear = timeit(SVM_linear);
SVM_linear = fitcsvm(trainData, trainLabel, ...
                    'KernelFunction', 'linear');
% perform cross validation (10 fold)
tic
CVMdl_linear = crossval(SVM_linear);  
toc
loss_linear = kfoldLoss(CVMdl_linear);
    
% get model performance - confusion matrix and accuracy
pred_linear = predict(SVM_linear, testData);
conM_linear = confusionmat(testLabel, pred_linear); 
eval_linear = Evaluate(testLabel, pred_linear);
    
    fprintf(1, '\n#########################\n');
    fprintf(1, 'Linear SVM results:');
    fprintf(1, '\n#########################\n');
    fprintf(1, 'confusion matrix:\n');
    disp(conM_linear);
    f1_score = eval_linear(6);
    fprintf(1, 'model accuracy:     %10.4f\n', eval_linear(1));
    fprintf(1, 'model precision:    %10.4f\n', eval_linear(4));
    fprintf(1, 'model recall:       %10.4f\n', eval_linear(5));
    fprintf(1, 'model f1 score:     %10.4f\n', eval_linear(6));
    fprintf(1, 'training time:      %10.4f\n', trainT_linear); 
    fprintf(1, 'k-fold error:       %10.4f\n', loss_linear);

    % ---------------------------------------------------------------------
    % Polynomial SVM
    % ---------------------------------------------------------------------
%     SVM_poly = @() fitcsvm(trainData, trainLabel, ...
%         'KernelFunction', 'polynomial', 'PolynomialOrder',2 );
%     trainT_poly = timeit(SVM_poly);
%     SVM_poly = fitcsvm(trainData, trainLabel, ...
%         'KernelFunction', 'polynomial', 'PolynomialOrder',2 );
%     tic
%     CVMdl_poly = crossval(SVM_poly);  
%     toc
%     loss_poly = kfoldLoss(CVMdl_poly);
%        
%     % get model performance - confusion matrix and accuracy
%     pred_poly = predict(SVM_poly, testData);
%     conM_poly = confusionmat(testLabel, pred_poly); 
%     eval_poly = Evaluate(testLabel, pred_poly);
%     
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'Polynomial (q=2) SVM result:');
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'confusion matrix:\n');
%     disp(conM_poly);
%     fprintf(1, 'model accuracy:     %10.4f\n', eval_poly(1));
%     fprintf(1, 'model precision:    %10.4f\n', eval_poly(4));
%     fprintf(1, 'model recall:       %10.4f\n', eval_poly(5));
%     fprintf(1, 'model f1 score:     %10.4f\n', eval_poly(6));
%     fprintf(1, 'training time:      %10.4f\n', trainT_poly); 
%     fprintf(1, 'k-fold error:       %10.4f\n', loss_poly);   
   
    
    % ---------------------------------------------------------------------
    % Gaussian SVM
    % ---------------------------------------------------------------------
%     SVM_gaussian = @() fitcsvm(trainData, trainLabel, ...
%         'KernelFunction', 'gaussian');
%     trainT_gaussian = timeit(SVM_gaussian);
%     SVM_gaussian = fitcsvm(trainData, trainLabel, ...
%         'KernelFunction', 'gaussian');
%     tic
%     CVMdl_gaussian = crossval(SVM_gaussian);  
%     toc
%     loss_gaussian = kfoldLoss(CVMdl_gaussian);
%     
%     % get model performance - confusion matrix and accuracy
%     pred_gaussian = predict(SVM_gaussian, testData);
%     conM_gaussian = confusionmat(testLabel, pred_gaussian); 
%     accuracy_gaussian = sum(diag(conM_gaussian))/sum(conM_gaussian(:));
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'Gaussian SVM result:');
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'confusion matrix:\n');
%     disp(conM_gaussian);
%     fprintf(1, 'model accuracy: %10.4f\n', accuracy_gaussian);
%     fprintf(1, 'training time:  %10.4f\n', trainT_gaussian); 
%     fprintf(1, 'k-fold error:   %10.4f\n', loss_gaussian);  
    
%     % ---------------------------------------------------------------------
%     % RBF SVM
%     % ---------------------------------------------------------------------
%     SVM_rbf = @() fitcsvm(trainData, trainLabel, ...
%         'KernelFunction', 'rbf');
%     trainT_rbf = timeit(SVM_rbf);
%     SVM_rbf = fitcsvm(trainData, trainLabel, ...
%         'KernelFunction', 'rbf');
%     tic
%     CVMdl_rbf = crossval(SVM_rbf);  
%     toc
%     loss_rbf = kfoldLoss(CVMdl_rbf);
%     
%     % get model performance - confusion matrix and accuracy
%     pred_rbf = predict(SVM_rbf, testData);
%     conM_rbf = confusionmat(testLabel, pred_rbf); 
%     accuracy_rbf = sum(diag(conM_rbf))/sum(conM_rbf(:));
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'rbf SVM result:');
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'confusion matrix:\n');
%     disp(conM_rbf);
%     fprintf(1, 'model accuracy: %10.4f\n', accuracy_rbf);
%     fprintf(1, 'training time:  %10.4f\n', trainT_rbf); 
%     fprintf(1, 'k-fold error:   %10.4f\n', loss_rbf);     
end
