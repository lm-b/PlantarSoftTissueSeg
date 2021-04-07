% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [trainedClassifier, validationAccuracy1, validationAccuracy2, ConfMat, ROCraw] = ...
    trainMyClassifier_cluster(DataIn,classNames,NcrossVal,classifMethod)

switch lower(classifMethod)
    % --------------- NEURAL
    case 'neural'
    % NOTE: the dataset could also be classified by a neural network. When 
    % using the MATLAB GUI nprtool, a well-performing neural network can be
    % easily trained and classification accuracy is very high (comparable
    % to SVM). However, this has not yet been implemented here.
    
    [trainedClassifier, validationAccuracy,ConfMat, ROCraw] = ...
     trainMyNetwork(DataIn,NcrossVal);
        
    otherwise
    % --------------- OTHER THAN NEURAL 
    numFeat = size(DataIn,2) - 1; numResp = 1; % no. of features and response

    % Convert input to table
    DataIn = table(DataIn); DataIn.Properties.VariableNames = {'column'};

    % prepare column names
    nameMat = 'column_1#';
    for i=2:(numFeat+numResp), nameMat = [nameMat,['#column_',num2str(i)]]; end
    colnames = strsplit(nameMat,'#');

    % Split matrices in the input table into vectors
    DataIn = [DataIn(:,setdiff(DataIn.Properties.VariableNames, ...
        {'column'})), array2table(table2array(DataIn(:,{'column'})), ...
        'VariableNames', colnames)];

    % Extract predictors and response, convert to arrays
    predictorNames = colnames(1:(end-1));    responseName = colnames(end);
    predictr = DataIn(:,predictorNames);   response = DataIn(:,responseName);
        predictr = table2array(varfun(@double, predictr));
        response = table2array(varfun(@double, response));
        
    disp('start training...');
    switch lower(classifMethod)
        
        % --------------- support vector machine (SVM)
        case {'rbfsvm','linsvm'}
            switch lower(classifMethod)
                case 'rbfsvm' % radial basis function SVM
                    template = templateSVM('KernelFunction', 'rbf', 'PolynomialOrder', ...
                        [], 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', 1);
                case 'linsvm' % linear SVM
                    template = templateSVM('KernelFunction', 'linear', 'PolynomialOrder', ...
                        [], 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', 1);
            end % end svm subtypes, start svm common part
            trainedClassifier = fitcecoc(predictr, response, ...
                'Learners', template, 'Coding', 'onevsone',...
                'PredictorNames', predictorNames, 'ResponseName', ...
                char(responseName), 'ClassNames', classNames);
            % --------------- ensemble of decision trees
        case {'rusbtree', 'adabtree', 'subspacetree', 'bagtree', 'lsbtree'}
            switch lower(classifMethod)
                case 'rusbtree'
                    template = templateTree(...
                        'MaxNumSplits', 20);
                    trainedClassifier = fitensemble(...
                        predictr, ...
                        response, ...
                        'RUSBoost', ...
                        30, ...
                        template, ...
                        'Type', 'Classification', ...
                        'LearnRate', 0.1, ...
                        'ClassNames', classNames);
                case 'adabtree'
                    template = templateTree(...
                        'MaxNumSplits', 20);
                    trainedClassifier = fitensemble(...
                        predictr, ...
                        response, ...
                        'AdaBoostM2', ...
                        30, ...
                        template, ...
                        'Type', 'Classification', ...
                        'LearnRate', 0.1, ...
                        'ClassNames', classNames);
                case 'subspacetree'
                    template = templateDiscriminant(...
                        'DiscrimType', 'quadratic');
                    trainedClassifier = fitensemble(...
                        predictr, ...
                        response, ...
                        'Subspace', ...
                        30, ...
                        template, ...
                        'Type', 'Classification', ...
                        'ClassNames', classNames);
                case 'bagtree'
                    template = templateTree(...
                        'MaxNumSplits', 20);
                    trainedClassifier = fitensemble(...
                        predictr, ...
                        response, ...
                        'Bag', ...
                        30, ...
                        template, ...
                        'Type', 'Classification', ...
                        'ClassNames', classNames);
                case 'lsbtree'
                    template = templateTree(...
                        'MaxNumSplits', 20);
                    trainedClassifier = fitensemble(...
                        predictr, ...
                        response, ...
                        'LSBoost', ...
                        30, ...
                        template, ...
                        'Type', 'Classification', ...
                        'LearnRate', 0.1, ...
                        'ClassNames', classNames);
            end % end case of ensembletree
            
        % --------------- 1-nearest neighbor (1-NN)
        case '1nn'
            trainedClassifier = fitcknn(predictr, response, 'PredictorNames',...
                predictorNames, 'ResponseName', char(responseName), 'ClassNames', ...
                classNames, 'Distance', 'Euclidean', 'Exponent', '',...
                'NumNeighbors', 1, 'DistanceWeight', 'Equal', 'StandardizeData', 1);
        case 'optnn'
            trainedClassifier = fitcknn(predictr,response,'OptimizeHyperparameters','all',... 
                'HyperparameterOptimizationOptions',... 
                struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0, 'UseParallel', true, 'SaveIntermediateResults',true));
            
        % --------------- Naive Bayes 
        case 'naivebayes'
            distNames=repmat({'kernel'}, 1, length(predictorNames));
            trainedClassifier= fitcnb(predictr, response,'PredictorNames',...
                predictorNames, 'ResponseName', char(responseName),'Distribution',...
                distNames, 'ClassNames', classNames);
            
    end % end svm or not svm
    
    % ------ all non-neural methods continuing here
    % Perform cross-validation = re-train and test the classifier K times
    disp('start cross validation...');
%     optstruct=statset('UseParallel', true, 'UseSubstreams', true, 'Streams', RandStream('mrg32k3a', 'Seed', 2));
    partitionedModel = crossval(trainedClassifier, 'KFold', NcrossVal);
    disp('properties of partitioned set for cross validation'); partitionedModel.Partition
    % Compute validation accuracy on partitioned model
    disp('start validation...'); 
    validationAccuracy1 = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
        %accuracy is computed by "classiferror", which is weighted fraction
        %of misclassifications
    % Compute validation predictions and scores
    disp('computing validation predictions and scores...');
    [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
    ConfMat = confusionmat(response,validationPredictions);
    validationAccuracy2=matthewscorrloss(ConfMat);
    % Prepare data for ROC curves (reformat arrays)
    trues = zeros(numel(unique(response)),size(response,1));
    for i = 1:numel(unique(response)), trues(i,response==i) = 1; end
    ROCraw.true = trues; ROCraw.predicted = validationScores;
    
end % end neural or not neural
end % end function