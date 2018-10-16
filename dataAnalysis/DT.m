function [accuracy, loss, trainT] = DT(X1, X2)
%     X1 = csvread('csv/preBurst70_gap20_Seq.csv');
%     X2 = csvread('csv/nonBurst100Data.csv');
    
%     size_x1 = size(X1,2);
%     size_x2 = size(X2,2);
%     X2 = X2(:,1:end-(size_x2-size_x1));
%     
%     X2 = X2(:,1:end-1);
%     X1 = X1(:,1:end-1);
    
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

    % train and predict    
    tree_f = @() fitctree(trainData, trainLabel);
    trainT = timeit(tree_f);
    tree = fitctree(trainData, trainLabel); 
    pred = predict(tree, testData); 
%     tic
    cvmodel = crossval(tree);
%     toc
    loss = kfoldLoss(cvmodel);
    % see predictors
    imp = predictorImportance(tree);
    dlmwrite('DTimp.txt', imp);
    
    % get model performance - confusion matrix and accuracy
    % EVAL = (1)accuracy  (2)sensitivity (3)specificity 
    %        (4)precision (5)recall      (6)f_measure   (7)gmean];
    eval = Evaluate(testLabel, pred);
    conM = confusionmat(testLabel, pred);    
    accuracy = eval(1);
    
    fprintf(1, '\n#########################\n');
    fprintf(1, 'Decision Tree result:');
    fprintf(1, '\n#########################\n');
    fprintf(1, 'confusion matrix:\n');
    disp(conM);
    fprintf(1, 'model accuracy:     %10.4f\n', eval(1));
    fprintf(1, 'model precision:    %10.4f\n', eval(4));
    fprintf(1, 'model recall:       %10.4f\n', eval(5));
    fprintf(1, 'model f1 score:     %10.4f\n', eval(6));
    fprintf(1, 'training time:      %10.4f\n', trainT);
    fprintf(1, 'k-fold error:       %10.4f\n', loss);
%     
%     % Max split tree
%     tree_max = fitctree(trainData, trainLabel, 'MaxNumSplits', 300);
%     pred_max = predict(tree_max, testData);
%     confusionMatrix_max = confusionmat(testLabel, pred_max); 
%     accuracy_max = sum(diag(confusionMatrix_max))/sum(confusionMatrix_max(:));
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'Max split tree:');
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'confusion matrix:\n');
%     disp(confusionMatrix_max);
%     fprintf(1, 'model accuracy: %10.4f\n', accuracy_max);

%     % Min parent tree
%     tree_min = fitctree(trainData, trainLabel, 'MinParent', 300);
%     pred_min = predict(tree_min, testData);
%     confusionMatrix_min = confusionmat(testLabel, pred_min); 
%     accuracy_min = sum(diag(confusionMatrix_min))/sum(confusionMatrix_min(:));
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'Min parent tree:');
%     fprintf(1, '\n#########################\n');
%     fprintf(1, 'confusion matrix:\n');
%     disp(confusionMatrix_max);
%     fprintf(1, 'model accuracy: %10.4f\n', accuracy_min);
end
