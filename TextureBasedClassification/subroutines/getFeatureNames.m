

function names=getFeatureNames(selectidx, featureSet)
% get selected feature names

switch lower(featureSet)
    case 'histogram_lower'
        histlowfeats={'mean', 'var', 'skew', 'kurt', 'moment'};
        names={histlowfeats{selectidx}}';
    case 'histogram_higher'
        histhighfeats={'moment2','moment3','moment4','moment5','moment6','moment7','moment8','moment9','moment10','moment11'};
        names={histhighfeats{selectidx}}';
    case 'perceptual'
        perceptfeats={'Coarseness', 'Contrast', 'Directionality', 'LineLikeliness', 'Roughness'};
        names={perceptfeats{selectidx}}';
    case 'f-lbp'
        flbpfeats=sprintfc('%d',[1:38]);
        names={flbpfeats{selectidx}}';
    case 'ioclbp'
        fioclbpfeats=[strcat(sprintfc('%d',[1:38]), 'RR'),strcat(sprintfc('%d',[1:38]), 'RG'),strcat(sprintfc('%d',[1:38]), 'RB'),strcat(sprintfc('%d',[1:38]), 'GR'),strcat(sprintfc('%d',[1:38]), 'GG'),strcat(sprintfc('%d',[1:38]), 'GB'),strcat(sprintfc('%d',[1:38]), 'BR'),strcat(sprintfc('%d',[1:38]), 'BG'),strcat(sprintfc('%d',[1:38]), 'BB')];
        names={fioclbpfeats{selectidx}}';
    case 'glcmrotinv'
        glcmfeats={'0_1','0_2','0_3','0_4','0_5','45_1','45_2','45_3','45_4','45_5','90_1','90_2','90_3','90_4','90_5','135_1','135_2','135_3','135_4','135_5'};
        names={glcmfeats{selectidx}};
    case 'gaborrotinv'
        gaborfeats=sprintfc('%d',[2:12]);
        names={gaborfeats{selectidx}}';
    case 'textureenergy'
        lawsfeats={'L5L5', 'L5E5', 'L5S5', 'L5R5', 'L5W5', 'E5E5', 'E5S5', 'E5R5', 'E5W5','S5S5', 'S5R5', 'S5W5','R5R5', 'R5W5','W5W5'};
        names={lawsfeats{selectidx}}';
    case 'ugm'
        ugmfeats=strcat(sprintfc('%d',[1:5]), 'w');
        names={ugmfeats{selectidx}}';
    case 'rgbhist'
        rgbfeats={'meanR','varR','skewR','kurtR','momentR','meanG','varG','skewG','kurtG','momentG','meanB','varB','skewB','kurtB','momentB'};
        names={rgbfeats{selectidx}}';
    case 'hsvhist'
        hsvfeats={'meanH','varH','skewH','kurtH','momentH','meanS','varS','skewS','kurtS','momentS','meanV','varV','skewV','kurtV','momentV'};
        names={hsvfeats{selectidx}}';
    case 'labhist'
        labfeats={'meanL','varL','skewL','kurtL','momentL','meanGR','varGR','skewGR','kurtGR','momentGR','meanBY','varBY','skewBY','kurtBY','momentBY'};
        names={labfeats{selectidx}}';
    case 'yiqhist'
        yiqfeats={'meanY','varY','skewY','kurtY','momentY','meanI','varI','skewI','kurtI','momentI','meanQ','varQ','skewQ','kurtQ','momentQ'};
        names={yiqfeats{selectidx}}';
    case 'ycbcrhist'
        ycbcrfeats={'meanY','varY','skewY','kurtY','momentY','meanB','varB','skewB','kurtB','momentB','meanR','varR','skewR','kurtR','momentR'};
        names={ycbcrfeats{selectidx}}';
end


end






