% created by Jakob Nikolas Kather 2015 - 2016
% license: see separate LICENSE file, includes disclaimer

function [myCmap, CatNamesShort] = tissueColorMap_digits(numCol)

myCmap =      [hex2rgb('F2D0C4');...  % not used
              hex2rgb('919191');...  % background
              hex2rgb('d6592f');...  % Dermis
              hex2rgb('ffc414');...  % Epidermis
              hex2rgb('3558b7');...  % Adipose
              hex2rgb('886eb2');...  % Muscle
              hex2rgb('1a9b75');...  % Septae
              hex2rgb('7de8c6');... % Sup
              hex2rgb('ffa1fe')];    % Deep

CatNamesShort  = {'NA','Bkg','Der','Epi','Adi','Mus','Sep','Sup', 'Deep'};

% restrict classes
myCmap((numCol+1):end,:) = [];
CatNamesShort((numCol+1):end) = [];

end