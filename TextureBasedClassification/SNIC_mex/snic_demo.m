%======================================================================
% Simple Non-Iterative Clustering (SNIC) demo
% Copyright (C) 2017 Ecole Polytechnique Federale de Lausanne
% File created by Radhakrishna Achanta (firstname.lastname@epfl.ch)
%
% If you use the code for your research, please cite:
%
% "Superpixels and Polygons using Simple Non-Iterative Clustering"
% Radhakrishna Achanta and Sabine Susstrunk
% CVPR 2017
%======================================================================
%Input parameters for snic_mex function are:
%
%[1] 8 bit images (color or grayscale)
%[2] The number of superpixels
% [3] Compactness factor [10, 40]
%
%Ouputs are:
% [1] The labels of the segmented image
% [2] The number of labels
%
%NOTES:
%[2] Before using this demo code you must compile the C++ file usingthe command:
% mex snic_mex.cpp
% ==========================================
% 
% close all;
filename = 'C:\Users\Admin\Desktop\jnkather-histology-multiclass-texture-5638137\test_cases\16_086_6_X2.tif';
img = imread(filename);
[height, width, colors] = size(img);
tic;
%-------------------------------------------------
numsuperpixels = 10000;
compactness = 30.0;
numSuperPx=(size(img,1)*size(img,2))/1000;
[labels2, numlabels2] = snic_mex(img,numSuperPx,compactness);
%-------------------------------------------------
timetaken = toc;
disp(num2str(timetaken));
BW2 = boundarymask(labels2);
figure, imshow(imoverlay(img,BW2, 'black'))
h2=histcounts(labels2, unique(labels2));
min(h2)