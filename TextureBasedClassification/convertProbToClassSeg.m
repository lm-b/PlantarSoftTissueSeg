function fin=convertProbToClassSeg(initialPrediction, size_rows, size_cols)

% This function takes in the output of the deep neural network after
% pythonic stitching, and the size of the original image and outputs a
% cleaned segmentation



% scale values between 0 and 1 along channel dimension
initpred=normalize(initialPrediction,3, 'range');
initpred=initpred(1:size_rows, 1:size_cols,:);

%separate channels into class probability images
%blk=initpred(:,:,1);
bkg=initpred(:,:,2);
der=initpred(:,:,3);
ep=initpred(:,:,4);
fat=initpred(:,:,5);
musc=initpred(:,:,6);
sep=initpred(:,:,7);

% get binary class map by setting probaility threshold
B=bkg>.98;
D=der>.98;
E=ep>.98;
F=fat>.98;
M=musc>.98;
%S=sep>.98;

% epidermis processing
E2=imdilate(E, strel('disk', 3));

% dermis processing
D2=imclose(D, strel('disk', 50));
DD=bwconncomp(D2);
numPixels = cellfun(@numel,DD.PixelIdxList);
[biggest,idx] = max(numPixels);
D2(DD.PixelIdxList{idx})=0;
Dt=logical(D-D2);
%figure, imshow(Dt)

%septa procesing
thresh=multithresh(sep, 6);
quantC=imquantize(sep, thresh);
S=imclose(quantC==7, strel('disk', 2));
S2=S-E2;
S2=bwareaopen(S2>0, 300);



% compile  images; 
fin=NaN(size_rows,size_cols);
%fin(initpred(:,:,1)>.98)=0;
fin(B)=1;
fin(Dt)=2;
fin(E)=3;
fin(F)=4;

fin(S2)=6;
fin(M)=5;
%% Remove NaN's introduced by classwise cleaning
nanlocs=find(isnan(fin));
nonNanlocs = setdiff(1:numel(fin), nanlocs);
[xGood, yGood] = ind2sub(size(fin), nonNanlocs);
AA=zeros(size(fin));
AA(isnan(fin))=1;
s=regionprops(logical(AA), {'area','centroid', 'PixelIdxList'});
% tic
for index = 1: length(s);
  thisLinearIndex = nanlocs(index);
  % Get the x,y,z location
  %[x,y] = ind2sub(size(fin), thisLinearIndex);
  % Get distances of this location to all the other locations
   distances = sqrt((s(index).Centroid(2)-xGood).^2 + (s(index).Centroid(1) - yGood) .^ 2);
  [distance, indexofClosest] = sort(distances);
  % The closest non-nan value will be located at index sortedIndexes(1)
%   indexOfClosest = sortedIndexes(1);
%indexofClosest(1:6)
k=1;
while k<6
    goodvals(k)=fin(xGood(indexofClosest(k)), yGood(indexofClosest(k)));
    %disp([xGood(indexofClosest(k)), yGood(indexofClosest(k))])
      k=k+1;
end
%goodvals
  % Get the u value there
  goodValue = mode(goodvals);
  % Replace the bad nan value in u with the good value.
%   for Q=1:length(s(index).PixelIdxList)
    fin(s(index).PixelIdxList) = goodValue;
%   end

end 
% x=toc

%figure, imshowpair(fin, finalPrediction)

end

