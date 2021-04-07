% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [CatNames, myFullData, myData, myLabels, myLabelCats, setStats] = ...
    load_feature_dataset_EE(setName, setVersion, varargin)

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
   case 'HISTO2'
     featFile = 'HISTO2/f-lbp_numFeatures38_last_output_rand_99049.mat';
   case 'PRIMARY'
     featFile='PRIMARY/f-lbp_numFeatures38_last_output_rand_22315.mat'
   case 'MET', 
     featFile = 'MET/';          end      

% --------------------------------------------------------------------
 case 'perceptual',             switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/perceptual_numFeatures5_last_output_rand_64113.mat';
   case 'PRIMARY'
     featFile='PRIMARY/perceptual_numFeatures5_last_output_rand_74187.mat';
   case 'MET', 
     featFile = 'MET/';          end     
                                             
% --------------------------------------------------------------------
 case 'histogram_higher',       switch upper(setVersion)
  case 'HISTO1'
  case 'HISTO2'
     featFile = 'HISTO2/histogram_higher_numFeatures10_last_output_rand_34947.mat';
  case 'PRIMARY'
     featFile='PRIMARY/histogram_higher_numFeatures10_last_output_rand_83743.mat';
   case 'MET', 
     featFile = 'MET/';          end       
                                             
% --------------------------------------------------------------------   
 case 'histogram_lower',        switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/histogram_lower_numFeatures5_last_output_rand_47812.mat';
     case 'PRIMARY'
     featFile='PRIMARY/histogram_lower_numFeatures5_last_output_rand_71702.mat';
   case 'MET', 
     featFile = 'MET/';          end          
                                             

% --------------------------------------------------------------------    
 case {'glcm','glcmrotinv'},    switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/glcmrotinv_numFeatures20_last_output_rand_68830.mat';
     case 'PRIMARY'
     featFile='PRIMARY/glcmRotInv_numFeatures20_last_output_rand_91525.mat';
   case 'MET', 
     featFile = 'MET/';          end               

% --------------------------------------------------------------------    
 case {'gabor','gaborrotinv'},  switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/gaborrotinv_numFeatures9_last_output_rand_70537.mat';
     case 'PRIMARY'
     featFile='PRIMARY/gaborRotInv_numFeatures11_last_output_rand_16378.mat';
   case 'MET', 
     featFile = 'MET/';          end    
                                             
% --------------------------------------------------------------------  

 case {'textureenergy'},    switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/textureenergy_numFeatures15_last_output_rand_20489.mat';
     case 'PRIMARY'
     featFile='PRIMARY/textureenergy_numFeatures15_last_output_rand_69238.mat';
   case 'MET', 
     featFile = 'MET/';          end    



 % --------------------------------------------------------------------  

 case {'ugm'},    switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/UGM_numFeatures5_last_output_rand_45976.mat';
     case 'PRIMARY'
     featFile='PRIMARY/ugm_numFeatures5_last_output_rand_82275.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
 
 % --------------------------------------------------------------------  

 case {'allcolorhist'},    switch upper(setVersion)
   case 'HISTO1'
     featFile = 'HISTO1/allColorHists_numFeatures75_last_output_rand_93367.mat';

   case 'MET', 
     featFile = 'MET/';          end    
 
  % --------------------------------------------------------------------  

 case {'colorhist'},    switch upper(setVersion)
   case 'HISTO1'
     featFile = 'HISTO1/colorHist_numFeatures15_last_output_rand_42427.mat';

   case 'MET', 
     featFile = 'MET/';          end    
 
 % --------------------------------------------------------------------  

 case {'ioclbp'},    switch upper(setVersion)
   case 'HISTO1'
   case 'HISTO2'
     featFile = 'HISTO2/IOCLBP_numFeatures342_last_output_rand_84474.mat';
     case 'PRIMARY'
     featFile='PRIMARY/IOCLBP_numFeatures342_last_output_rand_92293.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
  % --------------------------------------------------------------------  
 
  case {'rgbhist'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/rgbhist_numFeatures15_last_output_rand_18240.mat';
     case 'PRIMARY'
     featFile='PRIMARY/rgbhist_numFeatures15_last_output_rand_86476.mat';
   case 'MET', 
     featFile = 'MET/';          end    
  % --------------------------------------------------------------------  

  case {'labhist'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/labhist_numFeatures15_last_output_rand_12711.mat';
     case 'PRIMARY'
     featFile='PRIMARY/labhist_numFeatures15_last_output_rand_50293.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
  % --------------------------------------------------------------------  

  case {'hsvhist'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/hsvhist_numFeatures15_last_output_rand_38439.mat';
     case 'PRIMARY'
     featFile='PRIMARY/hsvhist_numFeatures15_last_output_rand_4307.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
  % --------------------------------------------------------------------  

  case {'ycbcrhist'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/ycbcrhist_numFeatures15_last_output_rand_29413.mat';
     case 'PRIMARY'
     featFile='PRIMARY/ycbcrhist_numFeatures15_last_output_rand_49998.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
  % --------------------------------------------------------------------  

  case {'yiqhist'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/yiqhist_numFeatures15_last_output_rand_49786.mat';
     case 'PRIMARY'
     featFile='PRIMARY/yiqhist_numFeatures15_last_output_rand_10715.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
 % --------------------------------------------------------------------  

  case {'yiqioclbp'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/yiqIOCLBP_numFeatures342_last_output_rand_26911.mat';
     case 'PRIMARY'
     featFile='PRIMARY/yiqIOCLBP_numFeatures342_last_output_rand_97206.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
 
 % --------------------------------------------------------------------  

  case {'labioclbp'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/labIOCLBP_numFeatures342_last_output_rand_61327.mat';
     case 'PRIMARY'
     featFile='PRIMARY/labIOCLBP_numFeatures342_last_output_rand_65637.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
 
 % --------------------------------------------------------------------  

  case {'ycbcrioclbp'},    switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/ycbcrIOCLBP_numFeatures342_last_output_rand_48885.mat';
     case 'PRIMARY'
     featFile='PRIMARY/ycbcrIOCLBP_numFeatures342_last_output_rand_86464.mat';
   case 'MET', 
     featFile = 'MET/';          end    
 
 
 
% --------------------------------------------------------------------
 case 'best2',                  switch upper(setVersion)
   case 'HISTO1'
     featFile = 'HISTO1/Desktop/best2_numFeatures25_last_output_rand_82381.mat';
     case 'HISTO2'
     featFile = 'HISTO2/best2_numFeatures357_last_output_rand_95259.mat';
   case 'MET', 
     featFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best3',                  switch upper(setVersion)
  case 'HISTO1'
     featFile = 'HISTO1/best3_numFeatures63_last_output_rand_80535.mat';
   case 'MET', 
     featFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best4',                  switch upper(setVersion)
   case 'HISTO1'
     featFile = 'HISTO1/best4_numFeatures69_last_output_rand_83753.mat';
   case 'MET', 
     featFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best5',                  switch upper(setVersion)
   case 'HISTO1'
     featFile = 'HISTO1/best5_numFeatures75_last_output_rand_18259.mat';
   case 'MET', 
     featFile = 'MET/';          end     
% --------------------------------------------------------------------   
 case 'best_all',                  switch upper(setVersion)
   case 'HISTO2'
     featFile = 'HISTO2/best_all_numFeatures482_last_output_rand_9024.mat';
   case 'MET', 
     featFile = 'MET/';          end     

 
% --------------------------------------------------------------------  
 otherwise
      error('invalid set name');
end


load(['./datasets/',featFile]);                   % load selected dataset
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