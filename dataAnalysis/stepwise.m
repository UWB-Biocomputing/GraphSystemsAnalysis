function stepwise
    X = csvread('preBurst100Data.csv'); X = X(1:200,1:end-1);
    Y = csvread('OriginLabel.csv'); Y = Y(1:200);
    nSamples = size(X,1);                     % get sample info
    nTrain = ceil(nSamples*0.7);              % training data
   
    % divide training data and test data
    rng(1);
    rp = randperm(nSamples);
    trainRP = rp(1:nTrain);
    trainData = X(trainRP, :); 
    trainLabel = Y(trainRP); 
    
    testRP = rp(nTrain+1:end);
    testData = X(testRP,:); 
    testLabel = Y(testRP);
    tic
    mdl = stepwiselm(trainData,trainLabel,'linear');
    toc
    pred = predict(mdl,testData);
    
    conM = confusionmat(testLabel, pred);    
    accuracy = sum(diag(conM))/sum(conM(:));
    fprintf(1, '\n#########################\n');
    fprintf(1, 'Stepwise regression (linear):');
    fprintf(1, '\n#########################\n');
    fprintf(1, 'confusion matrix:\n');
    disp(conM);
    fprintf(1, 'model accuracy: %10.4f\n', accuracy);
%     fprintf(1, 'training time:  %10.4f\n', trainT);

    

end