% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function featureVector = computeFeatureVector_EE(imgIn, method, gaborArray, LawsFilters, numblock)
    
    % convert image. imgIn should be uint8 RGB (no alpha), range 0 ... 255
    imgInGray = double(rgb2gray(imgIn))/255;
    
    % choose method
    switch lower(method)
        
        % pure feature sets
        case 'histogram_higher', % higher order central moments of the histogram
            featureVector = histogramHigher(imgInGray);
            
        case 'histogram_lower', % lower order central moments of the histogram
            featureVector = histogramLower(imgInGray);
            
        case 'perceptual' % five features that mimick human texture perception
            featureVector = perceptualFeatures(imgInGray);
            
        case {'fourier-lbp','f-lbp'} % Local binary patterns, fourier variant
            featureVector = flbpFeatures(imgInGray);
            
        case 'ioclbp' % Improved oppoenent color local binary pattern
            featureVector=IOCLBP(imgIn);
            
        case 'glcmrotinv' % rotation invariant Gray-Level Co-Occurrence Matrix
            featureVector = glcmRotInvFeatures(imgInGray);
            
        case 'gaborrotinv' % rotation invariant Gabor filter response
            featureVector = gaborRotInvFeaturesEE(imgInGray,gaborArray);
            
        case 'textureenergy' %texture energy features
            featureVector= lawsFeatures(imgInGray, LawsFilters, numblock);
            
        %case 'svd' % sigle value decomposition
            %featureVector = decompFeats(imgInGray);
            
        case 'ugm' %markov random field
            featureVector= UGMApprox(imgInGray, 3, 'loopy');
            
        case 'rgbhist' % color histogram Features
            featureVector=colorHist(imgIn);
            
        case 'allcolorhist' %compute vector for all colorspace transformations
            featureVector=TryColorSpace(imgIn);
            
        case 'labhist' % color histogram Features
            imgIn=rgb2lab(imgIn);
            featureVector=colorHist(imgIn);
            
        case 'hsvhist' % color histogram Features
            imgIn=rgb2hsv(imgIn);
            featureVector=colorHist(imgIn);
            
        case 'ycbcrhist' % color histogram Features
            imgIn=rgb2ycbcr(imgIn);
            featureVector=colorHist(imgIn);
            
        case 'yiqhist' % color histogram Features
            imgIn=rgb2ntsc(imgIn);
            featureVector=colorHist(imgIn);
            
            
            
            % combinations of two or more methods
        case 'best2' % best 2 feature sets
            featureVector = [histogramLower(imgInGray),...
                flbpFeatures(imgInGray)];
            
        case 'best3' % best 3 feature sets
            featureVector = [histogramLower(imgInGray),...
                flbpFeatures(imgInGray),...
                glcmRotInvFeatures(imgInGray)];
            
        case 'best4' % best 4 feature sets
            featureVector = [histogramJoint(imgInGray),...
                flbpFeatures(imgInGray),...
                glcmRotInvFeatures(imgInGray)];
            
        case 'best5' % best 5 feature sets
            featureVector = [histogramJoint(imgInGray),...
                flbpFeatures(imgInGray),...
                glcmRotInvFeatures(imgInGray),...
                gaborRotInvFeatures(imgInGray,gaborArray)];
            
        case 'best6' % all feature sets
            featureVector = [histogramJoint(imgInGray),...
                flbpFeatures(imgInGray),...
                glcmRotInvFeatures(imgInGray),...
                perceptualFeatures(imgInGray),...
                gaborRotInvFeatures(imgInGray,gaborArray)];
        case 'best7' % all feature sets
            featureVector = [histogramJoint(imgInGray),...
                flbpFeatures(imgInGray),...
                glcmRotInvFeatures(imgInGray),...
                perceptualFeatures(imgInGray),...
                gaborRotInvFeatures(imgInGray,gaborArray)];
        case 'best8' % all feature sets
            featureVector = [histogramJoint(imgInGray),...
                flbpFeatures(imgInGray),...
                glcmRotInvFeatures(imgInGray),...
                perceptualFeatures(imgInGray),...
                gaborRotInvFeatures(imgInGray,gaborArray)];
        case 'best_all'
            featureVector=best_all(imgIn);
            
        otherwise
            error('this method is not available');
    end
    
end