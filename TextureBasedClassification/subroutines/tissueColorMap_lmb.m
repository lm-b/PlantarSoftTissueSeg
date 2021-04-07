% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [myCmap, CatNamesShort] = tissueColorMap_lmb(numCol)

myCmap =      [hex2rgb('777777');...  % background
              hex2rgb('DE4714');...  % Dermis
              hex2rgb('EDB409');...  % Epidermis
              hex2rgb('386CB0');...  % Adipose
              hex2rgb('7570B3');...  % Muscle
              hex2rgb('1B9E77');...  % Septae
              hex2rgb('F2D0C4');...  % not used
              hex2rgb('333333')];    % not used

CatNamesShort  = {'Bkg','Der','Epi','Adi','Mus','Sep','NA','NA'};

% restrict classes
myCmap((numCol+1):end,:) = [];
CatNamesShort((numCol+1):end) = [];

end