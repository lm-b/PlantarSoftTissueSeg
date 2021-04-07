function randomaugmentation=getRandAug(L1, L2, L3, L4, L5)
% returns a vector of indices for random augmentation that reduces number
% of repeats. 
% L1= length of rotations vector
% L2= length of resize vector
% L3= number of color/intensity/deformation options
% L4= number of augmentations to process
% L5= # of offsets
randomaugmentation=zeros(L4,4);
iter=1;
for p=[L1,L2,L3,L5]
    ini=1;
    for k=1:floor(L4/p)
        q=randperm(p,p);
        randomaugmentation(ini:ini+p-1,iter)=q;
        ini=ini+p;
    end
    if rem(L4,p)
        q=randperm(p,rem(L4,p));
        randomaugmentation(ini:ini+rem(L4,p)-1,iter)=q;
    end
    iter=iter+1;
end







end
