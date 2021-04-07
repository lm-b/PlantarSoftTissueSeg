function [featVect]=IOCLBP(img)




% Improved opponent color local binary pattern
% code by Lynda Brady, methods from Bianconi et al 2017




% color image

% color channels
% imgR=img(:,:,1);
% imgG=img(:,:,2);
% imgB=img(:,:,3);


% % make 2i matrix
%  [dim1, dim2]=size(imgR);
%  mat1=dim1:-2:1; mat2=1:2:dim2;
%  totalvect=[mat1 mat2];
%  imat=reshape(totalvect, [dim1, dim2]);
%  i2mat=2.^imat;

for i=1:3
    for k=1:3
        img1=img(:,:,i); img2=img(:,:,k);
        mapping=getmaplbphf(8);            % constants from Ahonen et al.
        h=lbp_IOC(img1,img2,1,8);  % compute LBP
        h=h/sum(h);                        % normalize LBP
        histograms(1,:)=h;                 % create LBP histogram
        featureVector{i,k} =constructhf(histograms,mapping); % reduce dimensions - this is still a lot of features, can we reduce?
    end
end
featVect=cat(1, featureVector{:});
featVect=featVect(:);