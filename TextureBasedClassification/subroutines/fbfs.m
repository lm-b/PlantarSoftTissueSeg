function newfeatures = fbfs (origFeat, method, opt)

% Filter-based feature reduction
%   origFeat is a structure structure containing the feature file
%   info (eg from dir('*.mat'))
%   type is a string denoting which type of filter method should be applied
%    opt 

numtypes=length(featvects);


switch method
    
    
    case 'corr'
        
        corrs=zeros(342,10);
        for k=1:numtypes
            load (featvects(k).name)
            featvs=source_and_target;
            labels=featvs(:,end);
            for r=1:(length(featvs(1,:))-1)
                corrs(r,k)=min(min(abs(corrcoef(featvs(:,r), labels'))));
            end
        end
        
        include=corrs>0.5;
        alldims=sum(include);
        maxdim=max(alldims);
        newcorrs=zeros(maxdim, 10);
        for j=1:numtypes
            % make new feature comparision visualization
            indiv=AA(:,j);
            newFeatv=featVects(:,individ);
            indiv(indiv==0)=[];
            % make and save new feature vectors
            newcorrs(1:length(indiv),j)=indiv;
            save (['New' featvects(j).name(1:end-40) '_numFeatures' num2str(sum(individ)) 'ID' featvects(j).name(end-9:end-4)  '.mat'], 'newfeat')
        end
        
        if fig==1
            figure, imagesc(newcorrs), colorbar
            xticks(1:10)
            xticklabels({'IOCLBP', 'UGM', 'AllCol', 'RGB', 'FLBP', 'GAB', 'GLCM', 'HH', 'HL', 'Laws'})
            title('Correlation Features (corr>0.5)')
        end
        
        
        
end