function [featVect]=best_all(img, mask)

% Improved opponent color local binary pattern
% code by Lynda Brady, methods from Bianconi et al 2017

% color image

% IOCLBP features
    
% IOCLBP
    featVect=IOCLBP_aggregate(img, [1,3;2,1], [1,3,4,5,7]);
% YIQ IOCLBP
    featVect=[featVect;IOCLBP_aggregate(rgb2ntsc(img), [1,3;2,1;2,2;2,3;3,1;3,2;3,3], [1,3,4,5,6,7,9,10])];
% YCbCr IOCLBP
    featVect=[featVect;IOCLBP_aggregate(rgb2ycbcr(img), [1,3;2,1], [1,2,3,4,8])];
% Lab IOCLBP
    featVect=[featVect;IOCLBP_aggregate(rgb2lab(img), [1,3;3,1;3,2;3,3], [1,2,3,4,5,6,7])];
% perceptual
    imgGS=rgb2gray(img);
    featVect=[featVect;Contrast(imgGS, double(max(imgGS(:))))];
% grayscale f-lbp
    mapping=getmaplbphf(8);            % constants from Ahonen et al.
    h=lbp(imgGS,1,8,mapping,'h');  % compute LBP
    h=h/sum(h);                        % normalize LBP
    histograms(1,:)=h;                 % create LBP histogram
    featureVector =constructhf_partial(histograms,mapping, [1,3,4,5,9,10]); % reduce dimensions
    featVect=[featVect;featureVector'];
% textureenergy
    featVect=[featVect;lawsFeatures(imgGS, {'L5L5'}, [5,5], mask)];
% glcm
    offsets = getMyGLCMParams();   % get offset matrix
    glcms = graycomatrix(imgGS,'Offset',offsets,'Symmetric',true);
    glcms_red = reduceGLCM(glcms,5); % 5 offset values, 4 directions
    stats = graycoprops(glcms_red,{'Contrast'});
    featVect=[featVect;stats.Contrast(3:4)'];



end
