% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function numFeatures = getNumFeat_lmb(featureType)

    switch lower(featureType)
        case {'fourier-lbp','f-lbp'}, numFeatures = 38; % fourier local binary pattern? use regular binary pattern? uses radial
        case 'perceptual',            numFeatures = 5; 
        case 'histogram_higher',      numFeatures = 10;        
        case 'histogram_lower',       numFeatures = 5;     
        case 'glcmrotinv',            numFeatures = 20;   
        case 'gaborrotinv',           numFeatures = 11; % number of wavelengths used(?) ** how to determine this #?
        case 'textureenergy',         numFeatures = 15; % number of filters used! 
        case 'ugm',                   numFeatures = 5;
        case 'ioclbp',                numFeatures = 342;
        case 'ycbcrioclbp',                numFeatures = 342;
        case 'labioclbp',                numFeatures = 342;
        case 'rgbhist',               numFeatures= 15;
        case 'labhist',               numFeatures= 15;
        case 'hsvhist',               numFeatures= 15;
        case 'ycbcrhist',             numFeatures= 15;
        case 'yiqhist',               numFeatures= 15;
        

        case 'best2',        numFeatures = 15+342;
        case 'best3',        numFeatures = 5+38+20;
        case 'best4',        numFeatures = 5+38+6+20;
        case 'best5',        numFeatures = 5+38+6+20+6;
        case 'best6',        numFeatures = 5+38+6+20+5+6;
        case 'best7',        numFeatures = 0;
        case 'best8',        numFeatures = 0;
        case 'all9',         numFeatures = 0;
        case 'best_all',     numFeatures = 482;

    end
    
end
