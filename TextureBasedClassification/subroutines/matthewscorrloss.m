function  score= matthewscorrloss (confmat)
% score is Rk between -1 and +1, where +1 is perfect prediction. 
% confmat is the confusion matrix


% the confusion matrix at input is given by matrix confmat

[dim1, dim2]=size(confmat);

% calculate numerator
Ckk=repmat(diag(confmat),1, dim1*dim1)'; 
Clm=repmat(confmat(:), 1, dim1);
Ckl=repmat(confmat(:)', 6,1);
Ckl=reshape(Ckl(:),36,6);
Cmk=repmat(reshape(confmat',dim1*dim2,1), 1,dim1);
mcc_num=sum(sum(Ckk.*Clm-Ckl.*Cmk));


%Calculate first square root in denominator
denom1=0 ; 
for k=1:1:length(confmat)
    denom11=sum(confmat(:,k));
    newk=confmat; newk(:,k)=[];
    denom12=sum(newk(:));
    denom1=denom1+denom11*denom12;    
end
denom1=denom1^0.5;
    
% Calculate second square root in denominator
denom2=0 ; 
for k=1:1:length(confmat)
    denom21=sum(confmat(k,:));
    newk=confmat; newk(k,:)=[];
    denom22=sum(newk(:));
    denom2=denom2+denom21*denom22;    
end
denom2=denom2^0.5;

score =(mcc_num)/((denom1)*(denom2));


end
