% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file in same folder, includes disclaimer

% this script is used to train a new classifier. The resulting classifier
% will be saved with a random unique ID

%% HEADER
format compact, clear all, close all; clc
addpath([pwd,'/subroutines'],'-end'); % my own subroutines

% set constants
cnst.crossVal = 10;             % number of cross validations, default 10
cnst.noOverheat = false;  % default false; true = will pause in between runs
cnst.pie = 0;                   % show pie chart of class distributions? deafult 0
cnst.scale = false;                 % scale all variables again? default false
cnst.showResults = false;           % show confusion matrix etc? default true
cnst.crossbar = '---';          % decoration for status report
cnst.allClassifiers = {'1NN','linSVM','rbfSVM','polySVM','rusbtree', 'adabtree', 'subspacetree', 'bagtree', 'naivebayes', 'optnn' }; %'1NN', 'ensembleTree', 'linSVM', 'rbfSVM'}; %{'1NN', 'linSVM','rbfSVM','rusbtree', 'adabtree', 'subspacetree', 'bagtree', 'naivebayes', 'optnn'}; 
cnst.allFSets = {'gaborrotinv', 'best2', 'best_all'}; %{'histogram_lower','histogram_higher','gaborrotinv','f-lbp','glcmrotinv', 'textureenergy', 'colorHist', 'allColorHist','IOCLBP','UGM', 'best5'};  
cnst.FeatureDataSource = 'HISTO2'; % default 'PRIMARY'
cnst.ReducedFeatures=false; % true if already ran feature selection, false if no feature selection
    cnst.reduceFeatSet = false; % experimental, works for combined_ALL only

% internal variables
rng('shuffle');         % reset random number generator for random ID
% randID = ['UID_',num2str(round(rand()*100000))]; % create random ID
randID='UID_58520';
cnst.saveDir = ['./output/',randID,'/']; % create directory name
% mkdir(cnst.saveDir);    % create directory for current experiment
rng('default');         % reset random number generator for reproducibility
shownPie = 0;           % internal variable, do not change
countr = 1198;             % do not change. Table indices for summary.

%% BODY
% iterate through all methods and classifiers, perform all experiments
for ClassifCount = cnst.allClassifiers; 

featureID = 1; % for summary grid

for FSetCount = cnst.allFSets;
    
% prepare variables for display and show status
currFSet = char(FSetCount); currClassifier = char(ClassifCount);
disp([cnst.crossbar,10,'starting iteration with ',currFSet]); countdown(5);

if cnst.ReducedFeatures==true
    [CatNames, source_and_target, myData, myLabels, myLabelCats] = ...
    load_feature_dataset_FS(currFSet, cnst.FeatureDataSource); %
else
%load and preprocess data
[CatNames, source_and_target, myData, myLabels, myLabelCats] = ...
    load_feature_dataset_EE(currFSet, cnst.FeatureDataSource); % ***CHANGE THIS LINE SO IT LOADS YOUR DATA**
end

% - this block is obsolete - 
% if cnst.reduceFeatSet && strcmp(currFSet,'combined_ALL')
%     warning('reducing feature set...');
%     load('./datasets/PRIMARY/featSetOut_combined_ALL_reduced_2016_01_24.mat');
%     source_and_target = source_and_target(:,[featSet,true]);
%     myData = myData(featSet,:);
% end
    
maxClasses = 2:max(unique(source_and_target(:,end)));

% optional: force scaling of variables (again)
if cnst.scale, source_and_target = enforceScale(source_and_target); end
% optional: show pie chart of class distribution and save to file
if cnst.pie && ~shownPie, 
    showMyPie(myLabelCats,CatNames,[cnst.saveDir,randID,'_Dataset.png']); shownPie = 1; end

% iterate through maxClass: perform experiments with 2,3,4,... classes
for currNumClass = [numel(maxClasses)] % first and last element [1,numel(maxClasses)]
    rng(currNumClass);  % reset random number generator for reproducibility
    maxClass = maxClasses(currNumClass); % extract max. class
    source_target_limit_classes = ...
      source_and_target(1:find(source_and_target(:,end)==(maxClass), 1, 'last' ),:);
  
    currClassifierName = [randID, '-row_',num2str(countr),...
      '-MaxClass_',num2str(maxClass), '-Feat_',currFSet,...
       '-Data_',cnst.FeatureDataSource, '-Classif_',currClassifier];
    
    % train and cross-validate classifier
    tic,   [trainedClassifier, validationAccuracy1, validationAccuracy2 ConfMat, ROCraw] = ...
           trainMyClassifier_EE(source_target_limit_classes,...
               1:maxClass,cnst.crossVal,currClassifier); elapsedTime = toc;
           
    % save classifier (only for the highest number of different classes)
     if currNumClass == numel(maxClasses)
         save([cnst.saveDir,currClassifierName,'-CLASSIFIER.mat'],'trainedClassifier');
    end
%     
	% display status
    disp([currClassifierName ' -> accuracy ', num2str(validationAccuracy1)]); 
    disp([cnst.crossbar,10,10]);
    
    % save result to summary table
    summaryTable(countr).experiment =   countr;
    summaryTable(countr).classes =      maxClass;
    summaryTable(countr).samples =      size(source_target_limit_classes,1);
    summaryTable(countr).method =       currFSet;
    summaryTable(countr).features =     size(source_target_limit_classes,2)-1;
    summaryTable(countr).classifier =   currClassifier; 
    summaryTable(countr).crossVal =     cnst.crossVal;
    summaryTable(countr).enforceScale = cnst.scale;
    summaryTable(countr).time =         round(elapsedTime);
    summaryTable(countr).ClassifErr =   round(validationAccuracy1,3);
    summaryTable(countr).MCC =          round(validationAccuracy2,3);
    countr = countr + 1;
    
    % write result to summary grid
                                        % (strrep(char(currFSet),'-','_')).
     summaryGrid.(['numcl_',num2str(maxClass)]).(['cl_',char(currClassifier)])(featureID) = ...
        round(validationAccuracy1,3);
    
    % optional: pause to avoid core overheat
    if cnst.noOverheat && (currNumClass<numel(maxClasses)), waitFor(elapsedTime,15); end

end

featureID = featureID + 1;

if cnst.showResults
    % create and save confusion matrix for last experiment
    showMyConfusionMatrix_lmb(ConfMat, currClassifierName, CatNames, cnst.saveDir);
    % create and save ROC plot for last experiment
    AUC = showMyROC(ROCraw, currClassifierName, CatNames, cnst.saveDir);   
    meanAUC = mean(cell2mat(AUC));
    stdAUC = std(cell2mat(AUC));
    %https://www.mathworks.com/matlabcentral/answers/60294-create-an-roc-curve-from-binary-classification-data
    close all
end 

end % end iteration through methods (feature sets)
end % end iteration through classifier (classifier methods)

%% SAVE RESULTS
% display all results as a table and play notification sound 
disp(cnst.crossbar);   struct2table(summaryTable);  sound(sin(1:0.3:800));
writetable(struct2table(summaryTable),[cnst.saveDir,randID,'_summary72220_2','.csv']);
 save([cnst.saveDir,randID,'_summary_grid_nonred','.mat'],'summaryGrid');

summaryGrid

% play notification sound 
sound(sin(1:0.3:800)); disp('done all.');
