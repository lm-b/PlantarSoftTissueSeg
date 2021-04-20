% Calculate Accuracy fo Segmentations
% Lynda Brady 2021
segfolder='F:\Paper_DICE_Segs\Segmentations_16_WCE';
imgfolder='F:\From Finite\newsupdeep\DeepLearningData\RunSegs'; % F is 5TB external drive!
addpath(segfolder);
%allsegs=dir([segfolder '*mat']);
accs={};
ClassAcc=struct;
[Cmap1, names1]=tissueColorMap_digits(7);
imgnames=cellstr({'16_086_6_X2crop', '18_101_02_X3', '22_125_03_X1','28_166_1_X1','29_171_06_X2'});
for justaloopvar=1:length(imgnames) % for each image 
%%
 %for justaloopvar=[3,5]
    allsegs=dir([segfolder '\' imgnames{justaloopvar} '*mat']);
    img=imread([imgfolder '\' imgnames{justaloopvar} '.tif']);
    %load([segfolder '\' allsegs(1).name]) % imgResult
    for m=1:length(allsegs) % for each overlap
        %     imRes_all=imgResult(:,:,8); clear imgResult
        %     load([segfolder '\' allsegs(2).name]) % imgResult
        %     imRes_2=imgResult(:,:,8); clear imgResult
        %     load([segfolder '\' allsegs(3).name]) % imgResult
        %     imRes_lbp=imgResult(:,:,8); clear imgResult
        load([segfolder '\' allsegs(m).name], 'initialPrediction') %initialPredicition & finalPrediction
        
        try
            load([imgfolder '\YN' imgnames{justaloopvar} '_GroundTruth2.mat'], 'groundtruth2')
        catch
            load([imgfolder '\LB' imgnames{justaloopvar} '_GroundTruth2.mat'], 'groundtruth2')
        end
        
        %imResClean=cleanRegBounds(imRes, groundtruth2,Cmap1);
        fP2=convertProbToClassSeg(initialPrediction, size(img, 1), size(img, 2));
        clear initialPrediction
        
        load([segfolder '\' allsegs(m).name], 'finalPrediction') %initialPredicition & finalPrediction
        finalPrediction=finalPrediction(1:size(img,1), 1:size(img,2));
        
        % ---- accuracy ----
        % ~~~~~~~~~~DICE~~~~~~~~~~~
        acc1=dice(double(finalPrediction),groundtruth2);
        %classwiseAcc(justaloopvar,1:6)={acc1};
        acc2=dice(fP2,groundtruth2);
        %classwiseAcc(justaloopvar,7:12)={acc2};
        %     acc3=dice(imRes_lbp(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,13:18)={acc3};
        %     acc4=dice(imResClean_all(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,19:24)={acc4};
        %     acc5=dicee(imResClean_2(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,19:24)={acc5};
        %     acc6=dice(imResClean_lbp(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,19:24)={acc6};
        
        %disp(['Accuracy for' allsegs(k).name(1:12) ': ' num2str(acc1) ' ' num2str(acc2)])
        %accs(justaloopvar,8:13)={num2str(mean(acc1)), num2str(mean(acc2)),  num2str(mean(acc3)),  num2str(mean(acc4)), num2str(mean(acc5)), num2str(mean(acc6))};
        %accs(justaloopvar,8:9)={num2str(mean(acc1)), num2str(mean(acc2))};
        %by class accuracy
        
        %ClassAcc.classwiseAccDice{justaloopvar}= classwiseAcc;
        %ClassAcc.classmisclassifDice{justaloopvar}=classmisclassif;
        
        % ~~~~~~~~~~BF score~~~~~~~~~~~
        acc3=bfscore(double(finalPrediction),groundtruth2);
        %classwiseAcc(justaloopvar,1:6)={acc1};
        acc4=bfscore(fP2,groundtruth2);
        %classwiseAcc(justaloopvar,7:12)={acc2};
        %     acc3=bfscore(imRes_lbp(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,13:18)={acc3};
        %     acc4=bfscore(imResClean_all(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,19:24)={acc4};
        %     acc5=bfscore(imResClean_2(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,19:24)={acc5};
        %     acc6=bfscore(imResClean_lbp(1:size(img,1), 1:size(img,2)),groundtruth2, 20);
        %     classwiseAcc(justaloopvar,19:24)={acc6};
        
        %disp(['Accuracy for' allsegs(k).name(1:12) ': ' num2str(acc1) ' ' num2str(acc2)])
        %accs(justaloopvar,8:13)={num2str(mean(acc1)), num2str(mean(acc2)),  num2str(mean(acc3)),  num2str(mean(acc4)), num2str(mean(acc5)), num2str(mean(acc6))};
        accs(m,1:2)={num2str(mean(acc1)), num2str(mean(acc2))};
        accs(m,3:4)={num2str(mean(acc3)), num2str(mean(acc4))};
        %by class accuracy
        for p=1:6
            classwiseAcc{m, 4+p}=acc1(p);
            classwiseAcc{m, 4+length(acc1)+p}=acc2(p);
            classwiseAcc{m, 4+length(acc1)+length(acc2)+p}=acc3(p);
            classwiseAcc{m, 4+length(acc1)+length(acc2)+length(acc3)+p}=acc4(p);
        end
    end
        ClassAcc.classwiseAcc{justaloopvar}= classwiseAcc;
    %ClassAcc.classmisclassifBF{justaloopvar}=classmisclassif;
    
%     figure, subplot(3,2,1), imshow(img),title('originalImage'),
%     subplot(3,2,2), imshow(ind2rgb(groundtruth2+1,Cmap1)),title('Ground Truth')
%     subplot(3,2,3), imshow(ind2rgb(finalPrediction,Cmap1)), title('Unet Raw')
%     subplot(3,2,4), imshow(ind2rgb(imRes+1,Cmap1)),title('Texture Raw')
%     subplot(3,2,5), imshow(ind2rgb(fP2+1,Cmap1)),title('Unet Cleaned') 
%     subplot(3,2,6), imshow(ind2rgb(imResClean+1,Cmap1)),title('Texture Cleaned')
%     
%     saveas(gcf,[segfolder '\' imgnames{justaloopvar} 'Comp.png'])
%      save(['G:\BestSegsForCompare\clean' allsegs(1).name ], 'imResClean_all')
%      save(['G:\BestSegsForCompare\clean' allsegs(2).name], 'imResClean_2' )
%      save(['G:\BestSegsForCompare\clean' allsegs(3).name], 'imResClean_lbp')
%      save(['G:\BestSegsForCompare\clean' allsegs(4).name], 'fP2')
     
     clear fP2 groundtruth2 finalSeg imRes initialPrediction texseg img finalseg 
 end

 save('F:\Paper_DICE_Segs\CompareACCMisclassifs.mat', 'ClassAcc') 
