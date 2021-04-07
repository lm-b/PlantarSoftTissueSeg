% Law's Texture energy Features
% Lynda Brady
function [filteredImage]= lawstexten_im(imInGray, filters)






for i=1:length(filters)
    filter=filters{i};
    imout=LawsFilt(imInGray, filter);
    



end