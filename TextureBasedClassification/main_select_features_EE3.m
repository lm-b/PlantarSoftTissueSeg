% Feature Selection for Multi-class Segmentation
% created by Lynda Brady 2017
%(based on codes by Jakob Nikolas Kather 2015 - 2016)
% license: see separate LICENSE file in same folder, includes disclaimer

% this script is used to select a subset of features for classification
% The resulting classifier will be saved with a random unique ID

addpath([pwd,'/subroutines'],'-end'); % my own subroutines
addpath([pwd,'/datasets/HISTO2/'],'-end'); % my own subroutines

% set constants
cnst.noOverheat = false;  % default false; true will pause in between runs
cnst.crossbar = '---';          % decoration for status report
cnst.allClassifiers = {'1NN', 'linSVM','rbfSVM','naivebayes','optnn','polySVM','rusbtree', 'adabtree', 'subspacetree', 'bagtree'}; %{'1NN', 'linSVM','rbfSVM','rusbtree', 'adabtree', 'subspacetree', 'bagtree', 'naivebayes', 'optnn'}; 
cnst.allFSets={'labhist'};
%cnst.allFSets = {'histogram_lower','histogram_higher','gaborrotinv','perceptual','f-lbp','glcmrotinv', 'textureenergy', 'ugm','rgbhist', 'hsvhist', 'ycbcrhist', 'yiqhist', 'IOCLBP'}; %{'histogram_lower','histogram_higher','gaborrotinv','f-lbp','glcmrotinv', 'textureenergy', 'colorHist', 'allColorHist','IOCLBP','UGM', 'best5'};  
cnst.allSelections= {'sfs', 'sbs', 'corr', 'relieff', 'stepregress'}; %{'sfs', 'sbs', 'corr', 'relieff', 'stepregress', };
cnst.FeatureDataSource = 'HISTO2'; % default 'PRIMARY'
cnst.crossbar = '******'; 

% internal variables
rng('shuffle');         % reset random number generator for random ID
%randID = ['UID_',num2str(round(rand()*100000))]; % create random ID
randID='UID_60007';
cnst.saveDir = ['./datasets/HISTO2/',randID,'/']; % create directory name
%mkdir(cnst.saveDir); 
countr = 1013; 

%% BODY
% iterate through all methods and classifiers, perform all experiments
for FSetCount = cnst.allFSets;

featureID = 983; % for summary grid

 for SelCount= cnst.allSelections 
     if ~strcmp( SelCount, {'sbs', 'sfs'})
         endafter1=0;
     else
         endafter1=1;
     end
  for ClassifCount = cnst.allClassifiers;

% prepare variables for display and show status
currFSet = char(FSetCount); currClassifier = char(ClassifCount); currSelecter=char(SelCount);
disp([cnst.crossbar,10,'starting iteration with ',currFSet]); countdown(3);

[CatNames, source_and_target, myData, myLabels, myLabelCats] = ...
    load_feature_dataset_EE(currFSet, cnst.FeatureDataSource); % ***CHANGE THIS LINE SO IT LOADS YOUR DATA**
%feature scaling
    %myData(myData>250)=myData(myData>250)-mean(myData(myData>250));
    myData=myData-mean(myData(:))./std(myData(:));

% - this block is obsolete - 
% if cnst.reduceFeatSet && strcmp(currFSet,'combined_ALL')
%     warning('reducing feature set...');
%     load('./datasets/PRIMARY/featSetOut_combined_ALL_reduced_2016_01_24.mat');
%     source_and_target = source_and_target(:,[featSet,true]);
%     myData = myData(featSet,:);
% end
    
maxClasses = 2:max(unique(source_and_target(:,end)));

% % optional: force scaling of variables (again)
% if cnst.scale, source_and_target = enforceScale(source_and_target); end
% % optional: show pie chart of class distribution and save to file
% if cnst.pie && ~shownPie, 
%     showMyPie(myLabelCats,CatNames,[cnst.saveDir,randID,'_Dataset.png']); shownPie = 1; end

% iterate through maxClass: perform experiments with 2,3,4,... classes
for currNumClass = [numel(maxClasses)] % first and last element [1,numel(maxClasses)]
    rng(currNumClass);  % reset random number generator for reproducibility
    maxClass = maxClasses(currNumClass); % extract max. class
%     source_target_limit_classes = ...
%       source_and_target(1:find(source_and_target(:,end)==(maxClass), 1, 'last' ),:);
  
    
    
    % select features;
    tic,   bestfeatures=FeatureSelection(myData',...
               myLabels, currSelecter, currClassifier); elapsedTime = toc;
    
    numfeat=sum(bestfeatures);
    
	% display status
    disp(numfeat); 
%     if endafter1==0
         featnameName = [randID, '-row_',num2str(countr),...
       '-Feat_',currFSet,'-NumFeat_',num2str(numfeat),...
        '-select_',currSelecter, 'Classifier' currClassifier];
%     else
%         featnameName = [randID, '-row_',num2str(countr),...
%        '-Feat_',currFSet,'-NumFeat_',num2str(numfeat),...
%         '-select_',currSelecter];
%     end
    if contains(currClassifier,'optnn') && contains(currSelecter, ['sfs', 'sbs'])
        save([cnst.saveDir 'OptNNFitParams' featnameName '.mat'], 'BayesoptResults');
    end
    
    % save result to summary table
    summaryTable(countr).experiment =   countr;
    summaryTable(countr).samples =      size(source_and_target,1);
    summaryTable(countr).method =       currFSet;
    summaryTable(countr).origFeatures = size(source_and_target,2)-1;
    summaryTable(countr).NewFeatures =  numfeat;
    summaryTable(countr).classifier =   currClassifier; 
    summaryTable(countr).Selection =    currSelecter;
    summaryTable(countr).time =         round(elapsedTime);
    summaryTable(countr).reduced =      'withscaling';
    countr = countr + 1;
    
    % write result to summary grid
                                        % (strrep(char(currFSet),'-','_')).
    summaryGrid.(['numcl_',num2str(maxClass)]).(['cl_',char(currClassifier)])(featureID) = ...
        numfeat;
    if numfeat>1
    bestfeatures(end+1)=1;
    newsource_target=source_and_target(:,bestfeatures);
    source_array=newsource_target(:, 1:end-1);
    target_array=newsource_target(:, end);
    source_and_target=newsource_target;
    
    infostring = ['This dataset consists of Diabetic and Non-Diabetic Modified Harts stained plantar tissue blocks',...
   ', feature descriptor: ', FSetCount, ', # ', num2str(numfeat)];
    
    TisCatsName=CatNames;
   
    save([cnst.saveDir,featnameName,'.mat'],...
    'source_array','target_array','source_and_target',...
    'infostring','TisCatsName');
    
    end
    % optional: pause to avoid core overheat
    if cnst.noOverheat && (currNumClass<numel(maxClasses)), waitFor(elapsedTime,15); end
    
    if endafter1>0
        break
    end
    
end

featureID = featureID + 1;

clear bestfeatures
close all
end % end iteration through classifier

end % end iteration through selection methods
end % end iteration through features

%% SAVE RESULTS
% display all results as a table and play notification sound 
disp(cnst.crossbar);   struct2table(summaryTable);  sound(sin(1:0.3:800));
writetable(struct2table(summaryTable),[cnst.saveDir,randID,'_summary_scale_2','.csv']);

summaryGrid 

% play notification sound 
sound(sin(1:0.3:800)); disp('done all.');
