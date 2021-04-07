function bestfeatures=FeatureSelection (source, target, selectmethod, classifmethod)

% featVect is "source" from main_create_feature_dataset, and ClassNames is
% "target" from main_create_feature_dataset


switch lower(selectmethod)
    
    
        
    case 'sfs' % needs classifier
        % Search Forward Selection - works best when optimal feature subset  set is small
        
        % Current function: calculate classification error when using
        % quadratic discriminant function (Fits multivariate normal
        % densities with covariance estimates stratified by group)
        %         switch lower(classifmethod)
%             % fun must return scalar, should not average feature set; sfs does
%             % this automatically
%             case {'linsvm', 'rbfsvm'}
%                 fun= @(XT,yT,Xt,yt) (loss(getSFSclassifier(Xt,XT,yT,classifmethod),yt, 'LossFun', 'quadratic'));
%             case {'1nn','rusbtree', 'adabtree', 'subspacetree', 'bagtree', 'naivebayes', 'optnn'}
%                 fun= @(XT,yT,Xt,yt) (loss(getSFSclassifier(Xt,XT,yT,classifmethod),yt, 'LossFun', 'quadratic'));
%         end
        fun= @(XT,YT,xt,yt) (CohKapp(getSFSclassifier(XT,YT,xt,classifmethod),yt));
        optionstruc=statset('TolFun', 1e-3, 'Display', 'iter', 'UseParallel', true, 'UseSubstreams', true, 'Streams', RandStream('mrg32k3a', 'Seed', 2)) ;
        inmodel=sequentialfs(fun, source, target, 'cv', cvpartition(target,'KFold',10), 'Options',optionstruc);
        bestfeatures=inmodel;
        
    case 'sbs' % need classifier
        % Search Backward Selection - works best when optimal feature subset is large
        
        % Current function: calculate classification error when using
        % quadratic discriminant function (Fits multivariate normal
        % densities with covariance estimates stratified by group)
%         switch lower(classifmethod)
%             % fun must return scalar, should not average feature set; sfs does
%             % this automatically
%             case {'linsvm', 'rbfsvm'}
%                 fun= @(XT,yT,Xt,yt) (loss(getSFSclassifier(Xt,XT,yT,classifmethod),yt, 'LossFun', 'quadratic'));
%             case {'1nn','rusbtree', 'adabtree', 'subspacetree', 'bagtree', 'naivebayes', 'optnn'}
%                 fun= @(XT,yT,Xt,yt) (loss(getSFSclassifier(Xt,XT,yT,classifmethod),yt, 'LossFun', 'quadratic'));
%         end
        fun= @(XT,YT,xt,yt) (CohKapp(getSFSclassifier(XT,YT,xt,classifmethod),yt));
        optionstruc=statset('TolFun', 1e-3, 'Display', 'iter', 'UseParallel', true, 'UseSubstreams', true, 'Streams', RandStream('mrg32k3a', 'Seed', 2)) ;
        inmodel=sequentialfs(fun, source, target, 'direction', 'backward', 'cv', cvpartition(target,'KFold',10), 'Options', optionstruc);
        bestfeatures=inmodel;
        
    case 'corr'
        % use feature correlation to labels to identify best features
        bestfeatures=FeatCorrSelect(source, target, 0.5);
        
    case 'stepregress'
        % use stepwise regression to identify best features
        [b, se, pval,inmodel ]=stepwisefit(source, target, 'maxIter', 50);
        bestfeatures=inmodel;
        
        
    case 'relieff'
        %
        [ranks, weights]=relieff(source, target, 8, 'method', 'classification'); 
        % ranks gives indices of ranked features, weights are wights for features (from -1 to 1)
        bestfeatures=zeros(1,size(source, 2));
        bestfeatures(ranks(weights>0.05))=1;
        bestfeatures=logical(bestfeatures);
        
        
    case 'mi'
        % mutual information
        

        
end 




end
