% Law's Texture energy Features
% Lynda Brady
function featureVector= lawsFeatures(imInGray, filters, numblock, varargin)

% Description:
    % takes grayscale image and cell array of strings with Lws Texture
    % Energy measures (eg 'L5L5' or 'L5E5') and computes energy features.
    % numblock is the size of the filter you want to use for mean and
    % averaging (dep on size of image..)

    if nargin>0
        mask=varargin{1};
    else
        mask=ones(size(imInGray));
    end
    
%fun=@(x) x(floor((size(x,1)+1)/2), floor((size(x,2)+1)/2))-mean(x(:));
h=fspecial('average', numblock);
ImGraypreproc= imInGray-imfilter(imInGray, h);

for i=1:length(filters)
    filter=filters{i};
    imout=LawsFilt(ImGraypreproc, filter);
%     fun2=@(y) sum(y(:));
    imout2=imfilter(abs(imout), ones(numblock));
    %imout3=imout2/max(imout2(:));
    imout2(~mask)=NaN;
    featureVector(i)=nanmean(imout2(:));    
end


end