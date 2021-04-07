% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [CatNames, myFullData, myData, myLabels, myLabelCats, numfeat, setStats] = ...
    load_dataset_Automatic(filename, folder)

% arguments:
% setName can be 'moments' or 'f-lbp' or 'tamura'
% varargin{1} can be 'merge' to merge low grade and high grade tumor
% varargin{2} selects the highest class to use (>2)
% varargin{3} selects the proportion of the dataset to use, 0<=x<=1

%% load data
% load previously saved feature matrix and label vector
load([folder, char(filename)]);                   % load selected dataset 
% source_and_target=currfeat.source_and_target;
% source_array=currfeat.source_arry;
% target_array=currfeat.target_array;
% infostring=currfeat.infostring;
% TisCatsName=currfeat.TisCatsName;
setStats.means = mean(source_array');  % calculate mean of dataset
setStats.stds  =  std(source_array');  % calculate standard deviation
numfeat=size(source_array,2);

% disp('------------------------------------------');
% disp('successfully loaded dataset, description:');
% disp(infostring);

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