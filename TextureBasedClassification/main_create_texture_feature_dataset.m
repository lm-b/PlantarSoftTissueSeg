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
addpath(genpath([pwd,'/UGM']),'-end'); %code for undirected graphical model

% define some constants (paths, filenames and the like)

cnst.inputDir = 'E:\classifierims\';  % Path of a directory that contains 
% ONE FOLDER PER TISSUE CATEGORY with multiple small images per folder, 
% e.g. 625 images with 150 * 150 px each. Path must end with /

cnst.effectiveImageSize = 200*200; % default 150*150
cnst.noOverheat =  false; % pause program after each iteration to prevent overheat, default true
cnst.limitedMode = true; % use only the first N images per class, default false
    cnst.limit = 800;      % if limitedMode==true, how many images?, default 625
cnst.featureType = { 'ioclbp','textureenergy','allColorHists', 'colorHist', 'gaborRotInvFeaturesEE', 'ugm' }; %'best2','best3','best4','best5','all6'}; % one or more of {'histogram_lower','histogram_higher','gaborRotInvFeaturesEE','perceptual','f-lbp','glcmRotInv', 'allColorHists', 'colorHist','best2','best3'};  
cnst.lawFilts={'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'}; %'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'
cnst.windowSize=[5,5];
cnst.gabwav=2:12; cnst.gabang=[10:20:90, 120:20:180];
cnst.gaborArray = gabor(cnst.gabwav, cnst.gabang); % create gabor filter bank, requires Matlab R2015b

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
       currFeatureVector = computeFeatureVector_EE(currImg, currFeat, cnst.gaborArray, cnst.lawFilts, cnst.windowSize);
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
