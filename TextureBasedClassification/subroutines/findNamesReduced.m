function [FSet, Classifier, Selector, BlockSize ]=findNamesReduced(filename)
% Created by Lynda Brady 3/20/18
% Find the classifier, feature set, and reduction strategy from the
% filename

%str=lower(filename);
str=[filename];
fsetpattern=["histogram_lower","histogram_higher","f-lbp","glcmrotinv","gaborrotinv", "labhist","perceptual","textureenergy", "rgbhist", "labhist", "yiqhist", "hsvhist", "ycbcrhist","yiqIOCLBP","labIOCLBP","ycbcrIOCLBP","IOCLBP","ugm", "best2", "best_all"];
classifierpattern=["1NN", "linSVM","rbfSVM","polySVM","rusbtree", "adabtree", "subspacetree", "bagtree", "naivebayes","optnn"];
selectionpattern=["sbs","sfs", "stepregress", "relieff", "corr"];
blockpattern=["size300","size500","size1500","size2500","size3500","size4500", "2+30", "2+21", "3+25", "4+20", "6+18"];

k=1;
while k>0
    if contains(str, fsetpattern(k))>0
        FSet=char(fsetpattern(k));
        k=0;
    else
        k=k+1;
    end
end

m=1;
while m>0
    if contains(str, classifierpattern(m))>0
        Classifier=char(classifierpattern(m));
        m=0;
    else
        m=m+1;
    end
end


l=1;
while l>0
    if contains(str, selectionpattern(l))>0
        Selector=char(selectionpattern(l));
        l=0;
    else
        l=l+1;
    end
end

b=1;
while b>0
    if contains(str, blockpattern(b))>0
        BlockSize=char(blockpattern(b));
        b=0;
    else
        b=b+1;
    end
end

end
