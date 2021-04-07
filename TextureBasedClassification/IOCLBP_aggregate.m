function [featVect]=IOCLBP_aggregate(img, channels, idxs)
% Improved opponent color local binary pattern for subset of channels and
% fourier histograms
% code by Lynda Brady, methods from Bianconi et al 2017


% color image

% color channels
% channels is a nx2 matrix of color channels to use


% % make 2i matrix
%  [dim1, dim2]=size(imgR);
%  mat1=dim1:-2:1; mat2=1:2:dim2;
%  totalvect=[mat1 mat2];
%  imat=reshape(totalvect, [dim1, dim2]);
%  i2mat=2.^imat;

for i=1:length(channels)
        img1=img(:,:,channels(i,1)); img2=img(:,:,channels(i,2));
        mapping=getmaplbphf(8);            % constants from Ahonen et al.
        h=lbp_IOC(img1,img2,1,8);  % compute LBP
        h=h/sum(h);                        % normalize LBP
        histograms(1,:)=h;                 % create LBP histogram
        featureVector{i} =constructhf_partial(histograms,mapping, idxs); % reduce dimensions - this is still a lot of features, can we reduce?
end
featVect=cat(1, featureVector{:});
featVect=featVect(:);