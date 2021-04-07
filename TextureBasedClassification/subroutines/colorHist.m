% Color histogram based features
function featureVector= colorHist(img, idx, mask)
if nargin<3
    mask=logical(ones(size(img,1), size(img,2)));
end
if nargin>1
    imR=double(img(:,:,1)); imG=double(img(:,:,2)); imB=double(img(:,:,3));
    featred=histogramLower(imR(mask)); featgreen=histogramLower(imG(mask)); featblue=histogramLower(imB(mask));
    featVector=[featred featgreen featblue];
    featureVector=featVector(idx);
else
    imR=double(img(:,:,1)); imG=double(img(:,:,2)); imB=double(img(:,:,3));
    featred=histogramLower(imR(mask)); featgreen=histogramLower(imG(mask)); featblue=histogramLower(imB(mask));
    featureVector=[featred featgreen featblue];
end

%histR=histogram(imR, 51); histG=histogram(imG, 51); histB=histogram(imB, 51);



end
