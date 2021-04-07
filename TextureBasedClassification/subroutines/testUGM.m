 Imsall=dir('*.tif');
 numims=length(Imsall);
 mydata=cell(1,numims);
 for k=1:numims
 mydata{k}=imread(Imsall(k).name);
 end
 %numstates=[3,2,3,2,3,3];
allUGMfeats={};
%for nst=2:5
   % w=cell(1, numims);
    %%
    for k=1:numims
        w{k}=UGMApprox(mydata{k}, 3, 'pseudo');
        %w(k,:)=UGMApprox(mydata{k}, numstates(k),'pseudo')
        %saveas(gcf, ['UGM_states' num2str(nst) 'Class' num2str(k) '.jpg'])
    end
    for j=1:numims
        wj(j, :)=w{j};
    end
%    allfeats{nst}=wj;
%end