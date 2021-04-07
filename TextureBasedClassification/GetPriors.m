
GTz=dir('D:\EE577Project\test_cases\DL_Val_cases\*.mat');
priors={};
for k=1:length(GTz)
    priors(k,1)={GTz(k).name};
    load([GTz(k).folder '\' GTz(k).name])
    if exist('newlab')
        groundtruth=newlab;
    elseif exist('groundtruth2')
        groundtruth=groundtruth2;
    end
    totalpx=numel(groundtruth);
    priors(k,2)={sum(sum(groundtruth==1))/totalpx};
    priors(k,3)={sum(sum(groundtruth==2))/totalpx};
    priors(k,4)={sum(sum(groundtruth==3))/totalpx};
    priors(k,5)={sum(sum(groundtruth==4))/totalpx};
    priors(k,6)={sum(sum(groundtruth==5))/totalpx};
    priors(k,7)={sum(sum(groundtruth==6))/totalpx};
    clear newlab groundtruth2
end
        
    
    