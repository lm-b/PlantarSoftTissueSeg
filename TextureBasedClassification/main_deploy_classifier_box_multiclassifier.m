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

% path='K:/histology-multiclass-texture-v0.1/jnkather-histology-multiclass-texture-5638137';
% define some constants (paths, filenames and the like)
cnst.ApplicationInputDir = './test_cases/DL_Val_cases/';  % specify folder for input images
cnst.parallel = true;              % parallel computing? 0 or 1. default 1
cnst.outputDir ='./output/SDSegmentationtest/'; % where to save the results
mkdir(cnst.outputDir);

% set block size for largest generation of blocks
% cnst.CoreBlockSize = [4 4];     % default [50 50]
% cnst.BorderSize =    [30 30];     % default [50 50]
blocksizes=[ 2,3,4,2];
bordersizes=[30, 25, 20, 21];

% set feature set parameters
cnst.featureTypes = {'best2','best_all', 'yiqhist', 'ycbcrhist','textureenergy','rgbhist', 'perceptual', 'hsvhist', 'histogram_lower', 'histogram_higher', 'glcmrotinv', 'f-lbp', 'labhist'};
cnst.selectTypes = { 'sfs', 'stepregress', 'sbs', 'sbs', 'relieff', 'sfs', 'sfs','sbs',  'sbs', 'sbs', 'sbs', 'sbs', 'sfs'};
cnst.classifTypes = {'rbfSVM', 'polySVM', 'polySVM', 'polySVM', 'polySVM', 'polySVM', 'optnn', 'polySVM','rbfSVM', 'optnn', 'polySVM', 'polySVM', 'polySVM'};
cnst.filename={'UID_60007-row_869-Feat_best2-NumFeat_12-select_sfsClassifierrbfSVM.mat',
    'UID_60007-row_960-Feat_best_all-NumFeat_50-select_stepregressClassifierpolySVM.mat',
    'UID_60007-row_849-Feat_yiqhist-NumFeat_15-select_sbsClassifierpolySVM.mat',
    'UID_60007-row_834-Feat_ycbcrhist-NumFeat_13-select_sbsClassifierpolySVM.mat',
    'UID_60007-row_783-Feat_textureenergy-NumFeat_15-select_relieffClassifierpolySVM.mat',
    'UID_60007-row_807-Feat_rgbhist-NumFeat_8-select_sfsClassifierpolySVM.mat',
    'UID_60007-row_36-Feat_perceptual-NumFeat_5-select_sfsClassifieroptnn.mat',
    'UID_60007-row_819-Feat_hsvhist-NumFeat_13-select_sbsClassifierpolySVM.mat',
    'UID_60007-row_57-Feat_histogram_lower-NumFeat_4-select_sbsClassifierrbfSVM.mat',
    'UID_60007-row_98-Feat_histogram_higher-NumFeat_10-select_sbsClassifieroptnn.mat',
    'UID_60007-row_774-Feat_glcmrotinv-NumFeat_18-select_sbsClassifierpolySVM.mat',
    'UID_60007-row_698-Feat_f-lbp-NumFeat_36-select_sbsClassifierpolySVM.mat',
    'UID_60007-row_1018-Feat_labhist-NumFeat_12-select_sfsClassifierpolySVM.mat'};
cnst.classifiernames = { 'UID_58520-row_868-MaxClass_6-Data_HISTO2-Feat_best2_12-select_sfs-Classif_rbfSVM-CLASSIFIER.mat',
    'UID_58520-row_17-MaxClass_6-Data_HISTO2-Feat_best_all_50-select_stepregress-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_846-MaxClass_6-Data_HISTO2-Feat_yiqhist_15-select_sbs-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_830-MaxClass_6-Data_HISTO2-Feat_ycbcrhist_13-select_sbs-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_773-MaxClass_6-Data_HISTO2-Feat_textureenergy_15-select_relieff-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_800-MaxClass_6-Data_HISTO2-Feat_rgbhist_8-select_sfs-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_303-MaxClass_6-Data_HISTO2-Feat_perceptual_5-select_sfs-Classif_optnn-CLASSIFIER.mat',
    'UID_58520-row_813-MaxClass_6-Data_HISTO2-Feat_hsvhist_13-select_sbs-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_536-MaxClass_6-Data_HISTO2-Feat_histogram_lower_4-select_sbs-Classif_rbfSVM-CLASSIFIER.mat',
    'UID_58520-row_991-MaxClass_6-Data_HISTO2-Feat_histogram_higher_10-select_sbs-Classif_optnn-CLASSIFIER.mat',
    'UID_58520-row_763-MaxClass_6-Data_HISTO2-Feat_glcmrotinv_18-select_sbs-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_678-MaxClass_6-Data_HISTO2-Feat_f-lbp_36-select_sbs-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_1101-MaxClass_6-Data_HISTO2-Feat_labhist_12-select_sfs-Classif_polySVM-CLASSIFIER.mat'}; 
cnst.FeatureDataSource = ['./datasets/HISTO2/UID_60007/'];
cnst.DataFolder='HISTO2';

cnst.maxClass = 6;
setStats.doScale = false; % not needed default false


% offsets for GLCM, gabor data bank
cnst.offsets = getMyGLCMParams();
cnst.gaborArray = gabor(2:12,0:30:150); % create gabor filter bank, requires Matlab R2015b
cnst.lawFilts={'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'}; %'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'



for whichfeature=[13] %3
    cnst.featureType=char(cnst.featureTypes(whichfeature));
    cnst.numFeatures = getNumFeat_lmb(cnst.featureType);
    cnst.selectType=char(cnst.selectTypes(whichfeature));
    cnst.classifType=char(cnst.classifTypes(whichfeature));
% load dataset to have all meta-variables available
[CatNames, myFullData, X, labels, myLabelCats] =...
    load_dataset_Automatic(cnst.filename(whichfeature),cnst.FeatureDataSource);
[CatNames, allfeatST, allfeatures] =...
    load_feature_dataset_EE(cnst.featureType, cnst.DataFolder);
 if whichfeature~=8
    idxsel=sort(getSelectionIndices(X, allfeatures));
 else
     X(isnan(X))=0; allfeatures(isnan(allfeatures))=0
     idxsel=sort(getSelectionIndices(X,allfeatures));
     %idxsel=sort(getSelectionIndices(X, allfeatures);4]); % get indices of selected features to pass into feature detection
 end
clear allfeatST allfeatures

% load classifier: manually change code if classifier is changed!
classifierFolder = 'UID_58520'; % classifier unique ID (UID) for "best5"
classifierName = char(cnst.classifiernames(whichfeature));
load(['./output/',classifierFolder,'/',classifierName]);

cellofims=cellstr({ '27_160_8_X2crop.tif', '22_130_04_X2crop.tif','20_115_03_X2.tif','12_064_05_X2crop.tif', '18_101_02_X3.tif', '22_125_03_X1.tif', '28_162_03_X2.tif', '28_161_03_X2crop.tif', '28_166_1_X1.tif','19_112_03_X2.tif', '29_171_06_X2.tif','16_086_6_X2.tif',});%27_160_8_X2.tif','16_086_6_X2.tif', '12_064_05_X2.tif', '19_112_03_X2.tif'
% iterate through images and apply classifier tile-wise
for justaloopvar=[7,10]
    % specify one or more larger image file names as a cell array of
    % strings
curr_imname=cellofims{justaloopvar};
curr_impath = [cnst.ApplicationInputDir, char(curr_imname)];

for blkszevar=1:4
    cnst.CoreBlockSize=[1 1].*blocksizes(blkszevar);
    cnst.BorderSize=[1 1].* bordersizes(blkszevar);

    % settings for fractal tiling (this feature is experimental and is in fact
% overridden by setting cnst.maxFractal to 1
cnst.confidenceThresh = [3,2]; % confidence threshold for each fractal level
cnst.maxFractal = 1;           % must be 1 at the moment, could be increased
cnst.subTileMask = createSubtileMask(cnst);
cnst.noOverheat = true;
    
    
plotName = [char(curr_imname),' ',classifierName,' ',...
    num2str(cnst.CoreBlockSize(1)),'+',...
    num2str(cnst.BorderSize(1)),' ',cnst.featureType, ' scaling ',...
    num2str(setStats.doScale)];  % prepare title

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
    X=X';
    fun = @(blk) tileClassify_fractal_cluster(blk.data,trainedClassifier,...
        cnst.numFeatures,cnst.maxClass,cnst.featureType,cnst,setStats, cnst.gaborArray, idxsel, cnst.lawFilts, [5,5]);
    imgResult = blockproc(curr_impath, cnst.CoreBlockSize, fun,...
                   'BorderSize',cnst.BorderSize, 'UseParallel',cnst.parallel,...
                   'PadPartialBlocks',true, 'PadMethod','symmetric',...
                   'TrimBorder',true);
    elapsedTime = toc;
    save([cnst.outputDir,plotName,'.mat'],'imgResult', 'elapsedTime', '-v7.3');

if length(unique(imgResult(:,:,cnst.maxClass+2)))>2
showOriginalClassifiedConfidence_EE(imgResult,cnst,plotName,curr_impath,CatNames); % show results
end
end

% save result

close all

% optional: pause to avoid core overheat
if cnst.noOverheat, waitFor(elapsedTime,90); end
end
end
end
sound(sin(1:0.3:800));