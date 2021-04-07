% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function featureVector = computeFeatureVector_superpixel(imgIn, mask, method, gaborArray, idx, LawsFilters, numblock)
    
    % convert image. imgIn should be uint8 RGB (no alpha), range 0 ... 255
    imgInGray = double(rgb2gray(imgIn))/255;
    imgInGrayNaN=imgInGray;
    imgInGrayNaN(~mask)=NaN;
    
    % choose method
    switch lower(method)
        
        % pure feature sets
        case 'histogram_higher', % higher order central moments of the histogram
            featureVector = histogramHigher(imgInGrayNaN(mask));
            if idx
                featureVector=featureVector(idx);
            end
            
        case 'histogram_lower', % lower order central moments of the histogram
            featureVector = histogramLower(imgInGrayNaN(mask));
            if idx
                featureVector=featureVector(idx);
            end
        case 'perceptual' % five features that mimick human texture perception
            featureVector = perceptualFeatures(imgInGrayNaN);
            featureVector=featureVector(idx);
            
        case {'fourier-lbp','f-lbp'} % Local binary patterns, fourier variant
            featureVector = flbpFeatures(imgInGrayNaN, mask);
            featureVector=featureVector(idx);
            
        case 'ioclbp' % Improved oppoenent color local binary pattern
            featureVector=IOCLBP2(imgIn, idx,0,mask);
            
        case 'labioclbp' % Improved oppoenent color local binary pattern
            featureVector=IOCLBP2(rgb2lab(imgIn),idx,0,mask);
            
        case 'yiqioclbp' % Improved oppoenent color local binary pattern
            featureVector=IOCLBP2(rgb2ntsc(imgIn),idx,0,mask);
            
        case 'ycbcrioclbp' % Improved oppoenent color local binary pattern
            featureVector=IOCLBP2(rgb2ycbcr(imgIn),idx,0,mask);
            
        case 'glcmrotinv' % rotation invariant Gray-Level Co-Occurrence Matrix
            featureVector = glcmRotInvFeatures(imgInGrayNaN);
            featureVector=featureVector(idx);
            
        case 'gaborrotinv' % rotation invariant Gabor filter response
            featureVector = gaborRotInvFeaturesEE(imgInGray,gaborArray, ~mask);
            featureVector=featureVector(idx);
            
        case 'textureenergy' %texture energy features
            featureVector= lawsFeatures(imgInGray, LawsFilters, numblock, mask);
            featureVector=featureVector(idx);
            
        %case 'svd' % sigle value decomposition
            %featureVector = decompFeats(imgInGray);
            
        case 'ugm' %markov random field
            featureVector= UGMApprox(imgInGrayNaN, 3, 'loopy');
            
        case 'rgbhist' % color histogram Features
            featureVector=colorHist(imgIn, idx, mask);
            
        case 'allcolorhist' %compute vector for all colorspace transformations
            featureVector=TryColorSpace(imgIn);
            
        case 'labhist' % color histogram Features
%             imgIn=rgb2lab(imgIn);
            featureVector=colorHist(rgb2lab(imgIn), idx, mask);
            
        case 'hsvhist' % color histogram Features
%             imgIn=rgb2hsv(imgIn);
            imgIn=rgb2hsv(imgIn);
            featureVector=colorHist(imgIn, idx);
            
        case 'ycbcrhist' % color histogram Features
%             imgIn=rgb2ycbcr(imgIn);
            featureVector=colorHist(rgb2ycbcr(imgIn), idx, mask);
            
        case 'yiqhist' % color histogram Features
%             imgIn=rgb2ntsc(imgIn);
            featureVector=colorHist(rgb2ntsc(imgIn), idx, mask);
            
            
            
            % combinations of two or more methods
            % combinations of two or more methods
        case 'best2' % best 2 feature sets
            idx1=idx(idx<343); idx2=idx(idx>342)-342;
            featureVector = [IOCLBP2(rgb2ycbcr(imgIn), idx1, 0, mask)',...
                colorHist(rgb2ntsc(imgIn), idx2, mask)];
            
        case 'best3' % best 3 feature sets
            featureVector = [histogramLower(imgInGrayNaN),...
                flbpFeatures(imgInGrayNaN),...
                glcmRotInvFeatures(imgInGrayNaN)];
            
        case 'best4' % best 4 feature sets
            featureVector = [histogramJoint(imgInGrayNaN),...
                flbpFeatures(imgInGrayNaN),...
                glcmRotInvFeatures(imgInGrayNaN)];
            
        case 'best5' % best 5 feature sets
            featureVector = [histogramJoint(imgInGrayNaN),...
                flbpFeatures(imgInGrayNaN),...
                glcmRotInvFeatures(imgInGrayNaN),...
                gaborRotInvFeatures(imgInGrayNaN,gaborArray)];
            
        case 'best6' % all feature sets
            featureVector = [histogramJoint(imgInGrayNaN),...
                flbpFeatures(imgInGrayNaN),...
                glcmRotInvFeatures(imgInGrayNaN),...
                perceptualFeatures(imgInGrayNaN),...
                gaborRotInvFeatures(imgInGrayNaN,gaborArray)];
        case 'best7' % all feature sets
            featureVector = [histogramJoint(imgInGrayNaN),...
                flbpFeatures(imgInGrayNaN),...
                glcmRotInvFeatures(imgInGrayNaN),...
                perceptualFeatures(imgInGrayNaN),...
                gaborRotInvFeatures(imgInGrayNaN,gaborArray)];
        case 'best8' % all feature sets
            featureVector = [histogramJoint(imgInGrayNaN),...
                flbpFeatures(imgInGrayNaN),...
                glcmRotInvFeatures(imgInGrayNaN),...
                perceptualFeatures(imgInGrayNaN),...
                gaborRotInvFeatures(imgInGrayNaN,gaborArray)];
        case 'best_all'
            featureVector=best_all(imgIn, mask);
            featureVector=featureVector(idx);
            
            
        otherwise
            error('this method is not available');
    end
    
end