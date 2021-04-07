% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function featureVector = gaborRotInvFeaturesEE(imgInGray,gaborArray, mask)
    gaborMag = imgaborfilt(imgInGray,gaborArray); 
    gabmask=repmat(mask, [1,1,size(gaborMag,3)]);
    gaborMag(gabmask)=NaN;
    featureVector_long = nanmean(reshape(gaborMag,[], size(gaborMag,3)));
    featureVector = reduceGabor(featureVector_long,11); %  11 offsets (# wavelengths)
end
