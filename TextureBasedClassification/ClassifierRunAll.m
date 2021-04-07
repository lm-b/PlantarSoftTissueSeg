% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file in same folder, includes disclaimer

% this script reads all texture images (e.g. 5000 images) and computes a
% feature vector for each one of them. Default feature vector method is
% "best5"

%% header
format compact; clear all; close all; clc; % clean up session
rng('default'); % reset random number generator for reproducibility

addpath([pwd,'/subroutines'],'-end'); % my own functions, see license
addpath([pwd,'/lbp'],'-end'); % code for LBP, see license in subfolder
addpath([pwd,'/perceptual'],'-end'); % code for perceptual features, see license in subfolder

% define some constants (paths, filenames and the like)

cnst.inputDir = 'F:\LyndaB\NewSupDeep\classifierims\';  % Path of a directory that contains 
% ONE FOLDER PER TISSUE CATEGORY with multiple small images per folder, 
% e.g. 625 images with 150 * 150 px each. Path must end with /

cnst.effectiveImageSize = 200*200; % default 150*150
cnst.noOverheat =  true; % pause program after each iteration to prevent overheat, default true
cnst.limitedMode = true; % use only the first N images per class, default false
    cnst.limit = 800;      % if limitedMode==true, how many images?, default 625
cnst.featureType = {'histogram_lower','histogram_higher','gaborrotinv','perceptual','f-lbp','glcmRotInv','best2','best3', 'best4', 'best5','all6'}; %'best2','best3','best4','best5','all6'}; % one or more of {'histogram_lower','histogram_higher','gabor','perceptual','f-lbp','glcmRotInv','best2','best3'};  
cnst.gaborArray = gabor(2:2:12,0:30:150); % create gabor filter bank, requires Matlab R2015b

for currFeat = cnst.featureType % iterate through feature types
    
currFeat = char(currFeat);         % convert name of feature set to char
cnst.numFeatures = getNumFeat_lmb(currFeat); % request number of features

%% read source images of all classes, creates one class per folder
TisCats = dir(cnst.inputDir);               % read input folder contents
TisCats = TisCats([TisCats.isdir] & ~strncmpi('.', {TisCats.name}, 1));
TisCatsName = cellstr(char(TisCats.name))'; % create catory name array
TisCatImgCount = zeros(size(TisCats,1),1);  % preallocate summary array

for i = 1:size(TisCats,1) % iterate through each Tissue category (TisCat)
    CurrFiles = dir([cnst.inputDir,TisCats(i).name,'\']); % read file names ***CHANGED TO BACKSLASH, ADDED BACKSLASH BETWEEN inputDir and TisCat***
    % remove folders and dot files  
    CurrFiles = CurrFiles(~[CurrFiles.isdir] & ~strncmpi('.', {CurrFiles.name}, 1));
    % optional: crop currFiles vector to fewer elements per class
    if cnst.limitedMode && size(CurrFiles,1)>cnst.limit, CurrFiles = CurrFiles(1:cnst.limit); end
    % show status
    disp([num2str(size(CurrFiles,1)), ' items in class ',TisCats(i).name]);
    TisCatImgCount(i) = size(CurrFiles,1); % add file count to summary array
end
disp(['-> in total: ', num2str(sum(TisCatImgCount)), ' files.']); % show status

%% load all images and compute features
source_array = double(zeros(cnst.numFeatures,sum(TisCatImgCount))); % preallocate
target_array = uint8(zeros(size(TisCats,1),sum(TisCatImgCount)));   % preallocate

for i = 1:size(TisCats,1) % iterate through Tissue categories (TisCats)
    tImage = tic;  % start timer
    CurrFiles = dir([cnst.inputDir,TisCats(i).name,'/']); % read file names
    % remove folders and dot files
    CurrFiles = CurrFiles(~[CurrFiles.isdir] & ~strncmpi('.', {CurrFiles.name}, 1));
    % optional: crop currFiles vector to fewer elements per class
    if cnst.limitedMode && size(CurrFiles,1)>cnst.limit, CurrFiles = CurrFiles(1:cnst.limit); end
    % set up an index of first element of current class
    if i>1, firstEl = sum(TisCatImgCount(1:i-1))+1; else firstEl = 1; end
    
    tB = tic; tT = tic;
    % load each image, compute feature vector and add this vector to array
    for j = 1:size(CurrFiles,1)
       currImg = imread([cnst.inputDir,TisCats(i).name,...
           '/',CurrFiles(j).name]); % read image file  
       % compute the feature vector for the current image
       currFeatureVector = computeFeatureVector(currImg, currFeat, cnst.gaborArray);
       % add current feature vector to the source array
       source_array(:,firstEl-1+j) = currFeatureVector(:); 
       % show status of computation for every 25th element
       if ~mod(j,25), disp(['current class: completed ', num2str(j), ' of ', ...
           num2str(size(CurrFiles,1)), ' t= ',num2str(toc(tB))]); tB=tic; end
    end
    timeBlock(i) = toc(tT)/size(CurrFiles,1);
    disp(['time per image in this class: ', num2str(timeBlock(i)),' seconds']);
    
    % add target variable (tissue category ID) to target array
    target_array(i,firstEl:(firstEl+TisCatImgCount(i)-1)) = 1;
    disp(['Successfully added data from ', TisCats(i).name,' to array.']);

    % optional: avoid MacBook overheating by pausing the program
    if cnst.noOverheat && (i<size(TisCats,1)), waitFor(toc(tImage),60); end
end

disp('times per image per block:'); timeBlock 


%% save results and print status

% prepare data description
infostring = ['This dataset consists of Diabetic and Non-Diabetic Modified Harts stained plantar tissue blocks',...
   ', feature descriptor: ', currFeat, ', # ', num2str(cnst.numFeatures),...
   ', mean time per image: ', num2str(mean(timeBlock))];
%imageBlockSize = cnst.effectiveImageSize;

% reformat data for machine learning toolbox
target_reformatted = target_array;
for l=1:size(target_array,1), 
    target_reformatted(l,:) = target_array(l,:) * l; end
target_reformatted = sum(target_reformatted);
source_and_target = [source_array; target_reformatted]';

% save dataset for further use
rng('shuffle');
save(['./datasets/HISTO1/',currFeat,'_numFeatures',num2str(cnst.numFeatures),...
    '_last_output_rand_', num2str(round(rand()*100000)),'.mat'],...
    'source_array','target_array','source_and_target',...
    'infostring','TisCatsName');

end

% play notification sound 
sound(sin(1:0.3:800)); disp('done all.');



%%
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
cnst.showResults = true;           % show confusion matrix etc? default true
cnst.crossbar = '---';          % decoration for status report
cnst.allClassifiers = {'1NN','ensembleTree', 'linSVM','rbfSVM'}; %'1NN', 'ensembleTree', 'linSVM', 'rbfSVM'}; %{'1NN', 'ensembleTree', 'linSVM', 'rbfSVM'}; 
cnst.allFSets = {'histogram_lower','histogram_higher','gabor','perceptual','f-lbp','glcm','best2','best3','best4','best5','all6'}; %{'histogram_lower','histogram_higher','gabor','perceptual','f-lbp','glcm','best5'};  
cnst.FeatureDataSource = 'HISTO1'; % default 'PRIMARY'
    cnst.reduceFeatSet = false; % experimental, works for combined_ALL only

% internal variables
rng('shuffle');         % reset random number generator for random ID
randID = ['UID_',num2str(round(rand()*100000))]; % create random ID
cnst.saveDir = ['./output/',randID,'/']; % create directory name
mkdir(cnst.saveDir);    % create directory for current experiment
rng('default');         % reset random number generator for reproducibility
shownPie = 0;           % internal variable, do not change
countr = 1;             % do not change. Table indices for summary.

%% BODY
% iterate through all methods and classifiers, perform all experiments
for ClassifCount = cnst.allClassifiers; 

featureID = 1; % for summary grid

for FSetCount = cnst.allFSets;
    
% prepare variables for display and show status
currFSet = char(FSetCount); currClassifier = char(ClassifCount);
disp([cnst.crossbar,10,'starting iteration with ',currFSet]); countdown(5);

%load and preprocess data
[CatNames, source_and_target, myData, myLabels, myLabelCats] = ...
    load_feature_dataset_lmb1(currFSet, cnst.FeatureDataSource); % ***CHANGE THIS LINE SO IT LOADS YOUR DATA**

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
    tic,   [trainedClassifier, validationAccuracy, ConfMat, ROCraw] = ...
           trainMyClassifier(source_target_limit_classes,...
               1:maxClass,cnst.crossVal,currClassifier); elapsedTime = toc;
           
    % save classifier (only for the highest number of different classes)
    if currNumClass == numel(maxClasses)
        save([cnst.saveDir,currClassifierName,'-CLASSIFIER.mat'],'trainedClassifier');
    end
    
	% display status
    disp([currClassifierName ' -> accuracy ', num2str(validationAccuracy)]); 
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
    summaryTable(countr).accuracy =     round(validationAccuracy,3);
    countr = countr + 1;
    
    % write result to summary grid
                                        % (strrep(char(currFSet),'-','_')).
    summaryGrid.(['numcl_',num2str(maxClass)]).(['cl_',char(currClassifier)])(featureID) = ...
        round(validationAccuracy,3);
    
    % optional: pause to avoid core overheat
    if cnst.noOverheat && (currNumClass<numel(maxClasses)), waitFor(elapsedTime,15); end

end

featureID = featureID + 1;

if cnst.showResults
    % create and save confusion matrix for last experiment
    showMyConfusionMatrix_lmb(ConfMat, currClassifierName, CatNames, cnst.saveDir);
    % create and save ROC plot for last experiment
    AUC = showMyROC(ROCraw, currClassifierName, CatNames, cnst.saveDir);   
    meanAUC = mean(cell2mat(AUC))
    stdAUC = std(cell2mat(AUC))
end 

end % end iteration through methods (feature sets)
end % end iteration through classifier (classifier methods)

%% SAVE RESULTS
% display all results as a table and play notification sound 
disp(cnst.crossbar);   struct2table(summaryTable);  sound(sin(1:0.3:800));
writetable(struct2table(summaryTable),[cnst.saveDir,randID,'_summary','.csv']);
save([cnst.saveDir,randID,'_summary_grid','.mat'],'summaryGrid');

summaryGrid

% play notification sound 
sound(sin(1:0.3:800)); disp('done all.');


%% 
% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file in same folder, includes disclaimer

% this script is used to apply a given classifier to a large image in a
% tile-wise manner, e.g. 150 px square tiles with 50 px overlap. It
% contains an experimental feature (fractal classification) that is
% deactivated by default.

% HEADER
clear all, close all, clc

addpath([pwd,'/subroutines'],'-end'); % my own subroutines
addpath([pwd,'/lbp'],'-end');         % lbp subroutines
addpath([pwd,'/perceptual'],'-end');         % Bianconi et al. subroutines

% define some constants (paths, filenames and the like)
cnst.ApplicationInputDir = './test_cases/';  % specify folder for input images
cnst.parallel = false;              % parallel computing? 0 or 1. default 1
cnst.outputDir = './output/'; % where to save the results

% set block size for largest generation of blocks
cnst.CoreBlockSize = [14 18];     % default [50 50]
cnst.BorderSize =    [14 16];     % default [50 50]

% set feature set parameters
cnst.featureType = 'best4';
        
cnst.FeatureDataSource = 'HISTO1';
cnst.numFeatures = getNumFeat(cnst.featureType);
cnst.maxClass = 6;
setStats.doScale = false; % not needed default false

% offsets for GLCM, gabor data bank
cnst.offsets = getMyGLCMParams();
cnst.gaborArray = gabor(2:2:12,0:30:150); % create gabor filter bank, requires Matlab R2015b

% settings for fractal tiling (this feature is experimental and is in fact
% overridden by setting cnst.maxFractal to 1
cnst.confidenceThresh = [3,2]; % confidence threshold for each fractal level
cnst.maxFractal = 1;           % must be 1 at the moment, could be increased
cnst.subTileMask = createSubtileMask(cnst);
cnst.noOverheat = true;

% load dataset to have all meta-variables available
[CatNames, myFullData, X, labels, myLabelCats] =...
    load_feature_dataset_lmb1(cnst.featureType,cnst.FeatureDataSource);

% load classifier: manually change code if classifier is changed!
classifierFolder = 'UID_68362'; % classifier unique ID (UID) for "best5"
classifierName = 'UID_68362-row_31-MaxClass_6-Feat_best4-Data_HISTO1-Classif_linSVM-CLASSIFIER';
load(['./output/',classifierFolder,'/',classifierName,'.mat']);

cellofims=cellstr({'21_124_3_X1.tif';'21_124_4_X1.tif';'21_124_5_X1.tif';'21_124_6_X1.tif';'28_165_01_X1.tif';'28_165_02_X1.tif';'28_165_03_X1.tif';'28_165_04_X1.tif';'28_165_05_X1.tif';'28_165_06_X1.tif';'29_171_01_X1.tif';'29_171_02_X1.tif'});
% iterate through images and apply classifier tile-wise
for justaloopvar=1:size(cellofims, 1)
    % specify one or more larger image file names as a cell array of
    % strings
curr_imname=cellofims{justaloopvar};
curr_impath = [cnst.ApplicationInputDir, char(curr_imname)];

plotName = [char(curr_imname),' ',classifierName,' ',...
    num2str(cnst.CoreBlockSize(1)),'+',...
    num2str(cnst.BorderSize(1)),' ',cnst.featureType, ' scaling ',...
    num2str(setStats.doScale), ' ', cnst.FeatureDataSource];  % prepare title

% try to load existing image
try 
    load([cnst.outputDir,plotName,'.mat']);
    warning('Loaded existing dataset. Will not perform image analysis');
    countdown(10);
    elapsedTime = 0;
catch
    disp('Starting image analysis (block-wise) ...');
    tic
    %--- deploy classifier
    fun = @(blk) tileClassify_fractal(blk.data,trainedClassifier,...
        cnst.numFeatures,cnst.maxClass,cnst.featureType,cnst,setStats, cnst.gaborArray);
    imgResult = blockproc(curr_impath, cnst.CoreBlockSize, fun,...
                   'BorderSize',cnst.BorderSize, 'UseParallel',cnst.parallel,...
                   'PadPartialBlocks',true, 'PadMethod','symmetric',...
                   'TrimBorder',true);
    elapsedTime = toc;
end

showOriginalClassifiedConfidence_lmb(imgResult,cnst,plotName,curr_impath,CatNames); % show results

% save result
save([cnst.outputDir,plotName,'.mat'],'imgResult');

% optional: pause to avoid core overheat
if cnst.noOverheat, waitFor(elapsedTime,90); end

end

sound(sin(1:0.3:800));