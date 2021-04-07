startx=0;
starty=0;
endx=500; endy=500;
iter=0;
while starty<size(x28_161_03_X2,1)-500
    while startx<size(x28_161_03_X2,2)-500
        AA=imcrop(x28_161_03_X2, [startx starty 500 500]);
%         BB=imcrop(groundtruth, [startx starty 500 500]);
%         figure(1), imshow(AA, myCmap)
%         figure(2), imshow(BB)
%         pause(4)
        iter=iter+1;
        imwrite(AA, ['DeepLearnTrain/28_161_03_X2_'  sprintf( '%03d', iter ) '.tif'])
        startx=startx+500;

    end
    starty=starty+500;
    startx=0;
end
 