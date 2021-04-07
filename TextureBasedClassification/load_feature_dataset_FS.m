% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [CatNames, myFullData, myData, myLabels, myLabelCats, setStats] = ...
    load_feature_dataset_FS(setName, setVersion, varargin)

% arguments:
% setName can be 'moments' or 'f-lbp' or 'tamura'
% varargin{1} can be 'merge' to merge low grade and high grade tumor
% varargin{2} selects the highest class to use (>2)
% varargin{3} selects the proportion of the dataset to use, 0<=x<=1

%% load data
% load previously saved feature matrix and label vector
switch lower(setName) % check which set was requested
    
% --------------------------------------------------------------------
 case {'fourier-lbp','f-lbp'},  switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_57-Feat_f-lbp-NumFeat_18-select_relieffClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end      

% --------------------------------------------------------------------
 case 'perceptual',             switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/Desktop/perceptual_numFeatures5_last_output_rand_1252.mat';
   case 'MET', 
     setFile = 'MET/';          end     
                                             
% --------------------------------------------------------------------
 case 'histogram_higher',       switch upper(setVersion)
  case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_17-Feat_histogram_higher-NumFeat_10-select_stepregressClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end       
                                             
% --------------------------------------------------------------------   
 case 'histogram_lower',        switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_9-Feat_histogram_lower-NumFeat_2-select_relieffClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end          
                                             

% --------------------------------------------------------------------    
 case {'glcm','glcmrotinv'},    switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_73-Feat_glcmrotinv-NumFeat_19-select_relieffClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end               

% --------------------------------------------------------------------    
 case {'gabor','gaborrotinv'},  switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_41-Feat_gaborrotinv-NumFeat_9-select_relieffClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end    
                                             
% --------------------------------------------------------------------  

 case {'textureenergy'},    switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_89-Feat_textureenergy-NumFeat_15-select_relieffClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end    



 % --------------------------------------------------------------------  

 case {'ugm'},    switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_145-Feat_UGM-NumFeat_4-select_stepregressClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end    
 
 
 % --------------------------------------------------------------------  

 case {'allcolorhist'},    switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_71888/UID_95215-row_121-Feat_allColorHist-NumFeat_30-select_relieffClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end    
 
  % --------------------------------------------------------------------  

 case {'colorhist'},    switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_70312/UID_70312-row_17-Feat_colorHist-NumFeat_10-select_sbsClassifierrbfSVM.mat';
   case 'MET', 
     setFile = 'MET/';          end    
 
 % --------------------------------------------------------------------  

 case {'ioclbp'},    switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_70312/UID_95215-row_129-Feat_IOCLBP-NumFeat_50-select_stepregressClassifier1NN.mat';
   case 'MET', 
     setFile = 'MET/';          end    
 
 
 
% --------------------------------------------------------------------
 case 'best2',                  switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/UID_70312/best2_numFeatures60_last_output_rand_90579.mat';
   case 'MET', 
     setFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best3',                  switch upper(setVersion)
  case 'HISTO1'
     setFile = 'HISTO1/best3_numFeatures63_last_output_rand_80535.mat';
   case 'MET', 
     setFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best4',                  switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/best4_numFeatures69_last_output_rand_83753.mat';
   case 'MET', 
     setFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best5',                  switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/best5_numFeatures75_last_output_rand_18259.mat';
   case 'MET', 
     setFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'all6',                  switch upper(setVersion)
   case 'HISTO1'
     setFile = 'HISTO1/all6_numFeatures80_last_output_rand_49154.mat';
   case 'MET', 
     setFile = 'MET/';          end     

 
% --------------------------------------------------------------------  
 otherwise
      error('invalid set name');
end


load(['./datasets/',setFile]);                   % load selected dataset
% source_and_target=currfeat.source_and_target;
% source_array=currfeat.source_arry;
% target_array=currfeat.target_array;
% infostring=currfeat.infostring;
% TisCatsName=currfeat.TisCatsName;
setStats.means = mean(source_array');  % calculate mean of dataset
setStats.stds  =  std(source_array');  % calculate standard deviation

disp('------------------------------------------');
disp('successfully loaded dataset, description:');
disp(infostring);

%% merge categories
% merge categories for simple and complex stroma? optional.
if nargin>2 && strcmp(varargin{1},'merge')
    disp('- merging high grade tumor and low grade tumor');
    
    % merge category 2 (low grade tumor) with category 3 (high grade tumor)
    for j=2:9
        source_and_target(source_and_target(:,end)==j+1,end)=j;
    end
    
    % merge category 2 (low grade tumor) with category 3 (high grade tumor)
    target_array(2,target_array(3,:)==1) = 1;
    target_array(3,:) = [];

    % overwrite labels
    CatNames = {'Stroma', 'Tumor', 'Immune', 'Muscle', 'Liver', ...
        'Mucosa', 'Debris', 'Adipose', 'Background'};
else
    % prepare labels
    disp('merge: off');
    CatNames = strrep(TisCatsName,'_',' ');
end

%% restrict classes
% use only a subset of all classes
if nargin>3
    disp(['- restricting dataset to classes up to ', char(CatNames(varargin{2}))]);
    maxClass = varargin{2};
    source_and_target_restrict_classes = ...
        source_and_target(1:find(source_and_target(:,end)==(maxClass), 1, 'last' ),:);
    target_array(maxClass+1:end,:) = [];
else
    source_and_target_restrict_classes = source_and_target;
end

%% reduce dataset size
% choose a proportion of data (subsetSize), points are randomly picked
if nargin>4
    disp(['- reducing dataset size to ',num2str(varargin{3}*100),'%']);
    rng('default');
    subsetSize = varargin{3};
    subsetIdx = (rand(size(source_and_target_restrict_classes,1),1)<subsetSize);

    myFullData = ...
        source_and_target_restrict_classes(subsetIdx,:);
    myLabelCats = target_array(:,subsetIdx);
else
    myFullData = source_and_target_restrict_classes;
    myLabelCats = target_array;
end

%% return myData, myLabels, myLabelCats
myData = myFullData(:,1:end-1)';
myLabels = myFullData(:,end);

disp('------------------------------------------');

end