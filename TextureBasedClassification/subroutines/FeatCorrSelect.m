function bestfeatures= FeatCorrSelect (source, target, threshold)
% source is the matrix of features, each row is an instance of col features
% target is the label vector for each instance
% best features is a logical vector indicating features with correlation to
% labels above threshold. 
%Calculate new features based on correlation threshold


%compute correlation  between target and feature vector
for r=1:length(source(1,:))
    corrs(r)=min(min(abs(corrcoef(source(:,r), target')))); 
end
% include only features that have correlation with labels >thresh
includefeat=corrs>threshold;
bestfeatures=includefeat;
%bestfeatures=corrs(includefeat);
%bestfeatures=featvs(:, includefeat);

end





