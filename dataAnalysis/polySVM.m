function [accuracy, loss_poly, trainT_poly] = polySVM(X1, X2)
%     X1 = csvread('preBurst500Data.csv');
%     X2 = csvread('nonBurst500Data.csv');
%     X1 = X1(:,1:end-1);
%     X2 = X2(:,1:end-1);
    x1_samples = size(X1,1);
    x2_samples = size(X2,1);
    X = [X1;X2];
    Y1 = ones(x1_samples,1);
    Y2 = zeros(x2_samples,1);
    Y = [Y1;Y2];
      
    nSamples = size(X,1);                     % get sample info
    nTrain = ceil(nSamples*0.7);              % training data
    % nTest = nSamples - nTrain;              % test data
   
    % divide training data and test data
    rng(1);
    rp = randperm(nSamples);
    trainRP = rp(1:nTrain);
    trainData = X(trainRP, :); 
    trainLabel = Y(trainRP); 
    
    testRP = rp(nTrain+1:end);
    testData = X(testRP,:); 
    testLabel = Y(testRP);

    % ---------------------------------------------------------------------
    % Polynomial SVM
    % ---------------------------------------------------------------------
    SVM_poly = @() fitcsvm(trainData, trainLabel, ...
        'KernelFunction', 'polynomial', 'PolynomialOrder',2 );
    trainT_poly = timeit(SVM_poly);
    SVM_poly = fitcsvm(trainData, trainLabel, ...
        'KernelFunction', 'polynomial', 'PolynomialOrder',2 );
    tic
    CVMdl_poly = crossval(SVM_poly);  
    toc
    loss_poly = kfoldLoss(CVMdl_poly);
       
    % get model performance - confusion matrix and accuracy
    pred_poly = predict(SVM_poly, testData);
    conM_poly = confusionmat(testLabel, pred_poly); 
    eval_poly = Evaluate(testLabel, pred_poly);
    
    fprintf(1, '\n#########################\n');
    fprintf(1, 'Polynomial (q=2) SVM result:');
    fprintf(1, '\n#########################\n');
    fprintf(1, 'confusion matrix:\n');
    disp(conM_poly);
    accuracy = eval_poly(1);
    fprintf(1, 'model accuracy:     %10.4f\n', eval_poly(1));
    fprintf(1, 'model precision:    %10.4f\n', eval_poly(4));
    fprintf(1, 'model recall:       %10.4f\n', eval_poly(5));
    fprintf(1, 'model f1 score:     %10.4f\n', eval_poly(6));
    fprintf(1, 'training time:      %10.4f\n', trainT_poly); 
    fprintf(1, 'k-fold error:       %10.4f\n', loss_poly); 
    
end