function [featVect, error]=IOCLBP2(img, idx, collectError, mask)




% Improved opponent color local binary pattern
% code by Lybda Brady, methods from Bianconi et al 2017

if nargin<2
    collectError=0;
    mask=true(size(img,1),size(img,2));
    idx=1:342;
%     perbin=discretize(idx, 1:38:343);
%     permus=[1,1;1,2;1,3;2,1;2,2;2,3;3,1;3,2;3,3];
%     permus=permus(unique(perbin),:);
%     FF=repmat(1:38, length(unique(perbin)),1)'+repmat(unique(perbin)*38-38,38,1);
%     FF=FF(:);
%     newidx=find(ismember(FF,idx)==1);
elseif nargin<3
    collectError=0;
    mask=true(size(img,1),size(img,2));
elseif nargin<4
    mask=true(size(img,1),size(img,2));
end

perbin=ones(9,38).*[1;4;7;2;5;8;3;6;9];
permus=[1,1;1,2;1,3;2,1;2,2;2,3;3,1;3,2;3,3];
permus=permus(unique(perbin(idx)),:);
featureVector=mat2cell(zeros(3,38*3),[1,1,1], [38,38,38]);
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
if collectError==0
%     permus=[1,1;1,2;1,3;2,2;2,3;3,3];
    for j=1:length(permus)
        i=permus(j,1); k=permus(j,2);
        img1=img(:,:,i); img2=img(:,:,k);
        mapping=getmaplbphf(8);            % constants from Ahonen et al.
        h=lbp_IOC(img1,img2,1,8,0,'h', mask);  % compute LBP
        h=h/sum(h);                        % normalize LBP
        histograms(1,:)=h;                 % create LBP histogram
        featureVector{i,k} =constructhf(histograms,mapping); % reduce dimensions - this is still a lot of features, can we reduce?
    end
elseif collectError==1
    for i=1:3
        for k=1:3
            img1=img(:,:,i); img2=img(:,:,k);
            mapping=getmaplbphf(8);            % constants from Ahonen et al.
            h=lbp_IOC(img1,img2,1,8);  % compute LBP
            h=h/sum(h);                        % normalize LBP
            histograms(1,:)=h;                 % create LBP histogram
            allhists(k+(i-1)* 3,:)=h;
            featureVector{i,k} =constructhf(histograms,mapping); % reduce dimensions - this is still a lot of features, can we reduce?
        end
    end
    error=[range(allhists(2,:)-fliplr(allhists(4,:))), range(allhists(3,:)-fliplr(allhists(7,:))), range(allhists(6,:)-fliplr(allhists(8,:)))];
end
%
featVect=cat(1, featureVector{:});
featVect=featVect(:);
featVect=featVect(idx);