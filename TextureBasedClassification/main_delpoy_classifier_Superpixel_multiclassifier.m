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
addpath([pwd '/SNIC_mex'], '-end'); % SNIC superpixels

% path='K:/histology-multiclass-texture-v0.1/jnkather-histology-multiclass-texture-5638137';
% define some constants (paths, filenames and the like)
cnst.ApplicationInputDir = './test_cases/DL_Val_cases/';  % specify folder for input images
cnst.parallel = false;              % parallel computing? 0 or 1. default 1
cnst.outputDir = ['./output/newSuperpixel2/']; % where to save the results
mkdir(cnst.outputDir);

% set feature set parameters
cnst.featureTypes = {'best2','best_all', 'yiqhist', 'ycbcrhist','textureenergy','rgbhist', 'perceptual', 'hsvhist', 'histogram_lower', 'histogram_higher', 'glcmrotinv', 'f-lbp', 'gaborrotinv', 'IOCLBP', 'labhist'};
cnst.selectTypes = { 'sfs', 'stepregress', 'sbs', 'sbs', 'relieff', 'sfs', 'sfs','sbs',  'sbs', 'sbs', 'sbs', 'sbs', 'corr', 'sbs', 'sfs'};
cnst.classifTypes = {'rbfSVM', 'polySVM', 'polySVM', 'polySVM', 'polySVM', 'polySVM', 'optnn', 'polySVM','rbfSVM', 'optnn', 'polySVM', 'polySVM', 'polySVM', 'polySVM', 'polySVM' };
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
    'UID_60007-row_726-Feat_gaborrotinv-NumFeat_9-select_corrClassifierpolySVM.mat', 
    'UID_60007-row_879-Feat_IOCLBP-NumFeat_341-select_sbsClassifierpolySVM.mat', 
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
    'UID_58520-row_666-MaxClass_6-Data_HISTO2-Feat_gaborrotinv_9-select_corr-Classif_polySVM-CLASSIFIER.mat',
    'UID_58520-row_879-MaxClass_6-Data_HISTO2-Feat_IOCLBP_341-select_sbs-Classif_polySVM-CLASSIFIER.mat'
    'UID_58520-row_1101-MaxClass_6-Data_HISTO2-Feat_labhist_12-select_sfs-Classif_polySVM-CLASSIFIER.mat'}; 
cnst.FeatureDataSource = ['./datasets/HISTO2/UID_60007/'];
cnst.DataFolder='HISTO2';
%cnst.numFeatures = getNumFeat_cluster(cnst.featureType);
cnst.maxClass = 6;
cnst.compactness=20;
setStats.doScale = false; % not needed default false


% offsets for GLCM, gabor data bank
cnst.offsets = getMyGLCMParams();
cnst.gaborArray = gabor(2:12,0:30:150); % create gabor filter bank, requires Matlab R2015b
cnst.lawFilts={'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'}; %'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'

% settings for fractal tiling (this feature is experimental and is in fact
% overridden by setting cnst.maxFractal to 1
cnst.confidenceThresh = [3,2]; % confidence threshold for each fractal level



for whichfeature=[15] % failed on 5 and 8
    cnst.featureType=char(cnst.featureTypes(whichfeature));
    cnst.numFeatures = getNumFeat_lmb(cnst.featureType);
    cnst.selectType=char(cnst.selectTypes(whichfeature));
    cnst.classifType=char(cnst.classifTypes(whichfeature));
% load dataset to have all meta-variables available
[CatNames, myFullData, X, labels, myLabelCats] =...
    load_dataset_Automatic(cnst.filename(whichfeature),cnst.FeatureDataSource);
[CatNames, allfeatST, allfeatures] =...
    load_feature_dataset_EE(cnst.featureType, cnst.DataFolder, path);
 if sum(isnan(X(:)))~=0
     X(isnan(X))=0; allfeatures(isnan(allfeatures))=0;
    idxsel=sort(getSelectionIndices(X, allfeatures));
 else
     idxsel=sort(getSelectionIndices(X, allfeatures)); % get indices of selected features to pass into feature detection
 end
clear allfeatST allfeatures
% if cnst.featureType=='rgbhist'
% idxsel=sort([idxsel;4]); % add undetected selected feature
% end


% load classifier: manually change code if classifier is changed!
classifierFolder = 'UID_58520'; % classifier unique ID (UID) for "best5"
classifierName=char(cnst.classifiernames(whichfeature));

load(['./output/',classifierFolder,'/',classifierName]);

cellofims=cellstr({'27_160_8_X2crop.tif', '22_130_04_X2crop.tif','20_115_03_X2.tif','12_064_05_X2crop.tif', '18_101_02_X3.tif', '22_125_03_X1.tif', '28_162_03_X2.tif', '28_161_03_X2crop.tif', '28_166_1_X1.tif','19_112_03_X2.tif', '29_171_06_X2.tif','16_086_6_X2.tif',});%,'20_115_03_X2.tif', '28_162_03_X2.tif', '28_161_03_X2crop.tif', '28_166_1_X1.tif','19_112_03_X2.tif', '29_171_06_X2.tif' '12_064_05_X2.tif','19_112_03_X2.tif','16_086_6_X2.tif', '27_160_8_X2.tif', '22_130_04_X2.tif', '28_161_03_X2.tif', '28_166_1_X1.tif'});
% iterate through images and apply classifier tile-wise

for justaloopvar=5:length(cellofims);
    % specify one or more larger image file names as a cell array of
    % strings
curr_imname=cellofims{justaloopvar};
curr_impath = [cnst.ApplicationInputDir, char(curr_imname)];

% add super pixel here
for pxsize=[300,500:1000:5000]
    numSuperPx=(numel(imread(curr_impath)))./pxsize;
    clear imgResult L N regProps plotName
img=imread(curr_impath);
    % numSuperPx=(numel(img))/2000;
[L,N]=snic_mex(img, numSuperPx, cnst.compactness);
imgResult=zeros(size(img,1), size(img,2), cnst.maxClass+2);
clear img;

% figure out how to do processing without loading whole image into memory?
plotName = [char(curr_imname(1:end-4)),' ',classifierName(1:end-15),' SuperPixel_size'...
    num2str(pxsize),'_' num2str(N),'_total'];  % prepare title

% try to load existing analysis
try 
    load([cnst.outputDir,plotName,'.mat']);
    warning('Loaded existing dataset. Will not perform image analysis');
    countdown(4);
    elapsedTime = 0;
catch
    disp('Starting image analysis (block-wise) ...');
    tic
    regProps=regionprops(L, 'Area', 'BoundingBox', 'Image');
    %--- deploy classifier
    if cnst.parallel
        regProps(1).ClassifRes=[];
%     D = parallel.pool.DataQueue;
%     f = waitbar(0, 'Start Superpixel Classification')
%     afterEach(D, @updateWaitbar);
        parfor K=1:N-1
            regBox=ceil(regProps(K).BoundingBox);
            if min(regProps(K).BoundingBox(3:4))<45
                testid=find(regBox(3:4)<45);
                maxdim=fliplr(size(L))-regBox(1:2);
                regBox(2+testid)=45;
                if min(maxdim)<45
                    regBox([false, false, maxdim<40])=maxdim(maxdim<40)+1;
                end
%                 if [regBox(2)+regBox(4)-1, regBox(1)+regBox(3)-1] > size(L)
%                     newtestid=[regBox(2)+regBox(4)-1, regBox(1)+regBox(3)-1] > size(L);
%                     regBox(2+testid)=regBox(2+testid)-newtestid(testid);
%                 end
                regProps(K).Image=padarray(regProps(K).Image, ([ regBox(4),regBox(3)]- size(regProps(K).Image)), 0, 'post');
            end
            img=imread(curr_impath, 'PixelRegion', {[ regBox(2), regBox(2)+regBox(4)-1], [regBox(1), regBox(1)+regBox(3)-1]});
%             img(~)=NaN;
            [blockVotes, featVect]=tileClassify_fractal_superpixel(img,regProps(K).Image,...
                trainedClassifier, cnst.numFeatures,cnst.maxClass,cnst.featureType,cnst,...
                setStats, cnst.gaborArray, idxsel, cnst.lawFilts, [5,5]);
%             regProps(K).blockVotes=tileClassify_fractal_superpixel(img,regProps(K).Image,...
%                 trainedClassifier, cnst.numFeatures,cnst.maxClass,cnst.featureType,cnst,...
%                 setStats, cnst.gaborArray, idxsel);
            regProps(K).ClassifRes=repmat(regProps(K).Image, 1,1,cnst.maxClass+2).*reshape(blockVotes, [1,1,cnst.maxClass+2])
            regProps(K).class=blockVotes;
        end
        toc
        disp('making image')
        for k=1:N-1
            regBox=ceil(regProps(k).BoundingBox);
            if min(regProps(k).BoundingBox(3:4))<3
                regBox(3)=regBox(3)+3;
                regBox(4)=regBox(4)+3;
            end
            imgResult(regBox(2): regBox(2)+regBox(4)-1, regBox(1): regBox(1)+regBox(3)-1,:)=imgResult(regBox(2): regBox(2)+regBox(4)-1, regBox(1): regBox(1)+regBox(3)-1,:)+regProps(k).ClassifRes;
        end
%         disp('making image')
%         for k=1:cnst.maxClass+2
%             resMat=imgResult(:,:,l);
%             parfor m=1:N-1
%                 resmat=resMat;
%                 pxlist=regProps(m).PixelList;
%                 resmat(pxlist)=regProps(m).blockVotes(k);
%             end 
%             
%         end
 
        toc
    else
        f=waitbar(0, 'Start Superpixel Classification', 'Name', ['SuperPixel Classification' curr_imname]);
        for K=1:N-1
            regBox=ceil(regProps(K).BoundingBox);
            thresh=60;
            if min(regProps(K).BoundingBox(3:4))<thresh
                testid=find(regBox(3:4)<thresh);
                maxdim=fliplr(size(L))-regBox(1:2);
                regBox(2+testid)=thresh;
                if min(maxdim)<thresh
                    regBox([false, false, maxdim<thresh])=maxdim(maxdim<thresh)+1;
                end
%                 if [regBox(2)+regBox(4)-1, regBox(1)+regBox(3)-1] > size(L)
%                     newtestid=[regBox(2)+regBox(4)-1, regBox(1)+regBox(3)-1] > size(L);
%                     regBox(2+testid)=regBox(2+testid)-newtestid(testid);
%                 end
                regProps(K).Image=padarray(regProps(K).Image, ([ regBox(4),regBox(3)]- size(regProps(K).Image)), 0, 'post');
            end
            img=imread(curr_impath, 'PixelRegion', {[ regBox(2), regBox(2)+regBox(4)-1], [regBox(1), regBox(1)+regBox(3)-1]});
%             img(~regProps(K).Image)=NaN;
%             imshowpair(img, regProps(K).Image, 'blend')
            blockVotes=tileClassify_fractal_superpixel(img,regProps(K).Image,...
                trainedClassifier, cnst.numFeatures,cnst.maxClass,cnst.featureType,cnst,...
                setStats, cnst.gaborArray, idxsel, cnst.lawFilts, [5,5]);
%             FV2(K/50,:)=FV';
%             BV(K/50,:)=blockVotes;
            imgResult(regBox(2): regBox(2)+regBox(4)-1, regBox(1): regBox(1)+regBox(3)-1,:)=imgResult(regBox(2): regBox(2)+regBox(4)-1, regBox(1): regBox(1)+regBox(3)-1,:)+repmat(regProps(K).Image, 1,1,cnst.maxClass+2).*reshape(blockVotes, [1,1,cnst.maxClass+2]);
            if rem(K,50)==0
            waitbar(K/N,f,[num2str(K) ' of ' num2str(N) ' superpixels processed'])
            end
            
        end
        delete(f)
        disp('makingImage')
%      imgResult= reshape(cell2mat(struct2cell(imgRes)), [size(L,1), size(L,2), cnst.maxClass+2]);
   
    end
    elapsedTime = toc
    save([cnst.outputDir,plotName,'.mat'],'imgResult', 'elapsedTime', '-v7.3');
    if length(unique(imgResult(:,:,cnst.maxClass+2)))>2
       showOriginalClassifiedConfidence_EE(imgResult,cnst,plotName,curr_impath,CatNames); % show results
    end
    close all
    %figure, imagesc(imgResult(:,:,8)), title(cnst.featureType)
    % save result
    
end



% optional: pause to avoid core overheat
% if cnst.noOverheat, waitFor(elapsedTime,90); end

end
end
end
sound(sin(1:0.3:800));