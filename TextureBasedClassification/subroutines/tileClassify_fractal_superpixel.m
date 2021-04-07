% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [committeeVotes, featureVector] = tileClassify_fractal_superpixel(imgIn,mask,myClassifier,...
    numFeats,numClasses,featType,cnst,setStats, GaborArray, idx, lawFilts, windowsz)

    % compute features, then apply classifier to features
    featureVector = computeFeatureVector_superpixel(imgIn,mask,featType,GaborArray, idx, lawFilts, windowsz);
    
% %     
    [label,committeeVotes] = predict(myClassifier,featureVector(:)');
    
%     % save the vote for each class to the respective channel in "out"
%     out = double(zeros(size(imgIn,1),size(imgIn,2),numClasses+2));
%     for i=1:numClasses, out(:,:,i) = committeeVotes(i); end
    
    % check confidence and compute decision and write to separate channels
    [decision, confidence] = computeConfidence(normalizeVector(committeeVotes));
    try
        committeeVotes(numClasses+1) = confidence;
        committeeVotes(numClasses+2) = decision;
    catch % in case of error, occurs when feature vector contains NaNs
        committeeVotes(numClasses+1) = 0;  % set confidence to zero
        committeeVotes(numClasses+2) = 9;  % set decision to background
        warning('set confidence to zero and decision to background (9)');
    end

end
