% Feature correlation analysis and feature reduction for Multi-class
% texture classification 11/21/17

% This code identifies uniqueness of the chosen features and overlapping of
% feature descriptors

% feature correlation analysis
% A is a Nx1 matrix, where N is # features used
feat_corrs=corrcoef(A,A); % pearson correlation coefficient
figure, imagesc(feat_corrs)
% B is a matrix NxM, where N is # sample images used, and N is # features
% used
samp_corrs=corrcoef(source_and_target);
figure, imagesc(samp_corrs)
title('Corcoeff for RGB')
colorbar


%feature reduction analysis
 % pseudocode
 
 %% reduce features by feature detection
 % featuresall=dir('*.mat');
 % featurenames={featureall.name};
 % for i=1:length(featurenames)
 %  features=[features]
 %  for 
 %  import feature matrix
 %  shortFeatMat=FeatureSelection(source_array, target_array, method, limit)
 %  numfeats=length(shortFeatMat);
 %  
 %  save( [
 % end
 
 %% reduce total feature vector
 
 
 
 
 
 
 
 %% reduce total reduced features
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 