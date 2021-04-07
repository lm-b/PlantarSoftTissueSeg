function featurevectors=constructhf_partial(inputvectors, map, iterdex)
%construct rotation invariant features from uniform LBP histogram
%inputvectors: NxD array, N histograms of D bins each
%map: mapping struct from getmaphf
%iterdex: a list of indices of histogram bins to calculate. 
%
%EXAMPLE:    
%I=imread('rice.png');
%I2=imrotate(I,90);
%mapping=getmaplbphf(8);
%h=lbp(I,1,8,mapping,'h');
%h=h/sum(h);
%histograms(1,:)=h;
%h=lbp(I2,1,8,mapping,'h');
%h=h/sum(h);
%histograms(2,:)=h;
%lbp_hf_features=constructhf(histograms,mapping);
%
%The two rows of lbp_hf_features now contain LBP 
%histogram Fourier feature vectors of rice.png and 
%its rotated version (with LBP radius 1 and 8 sampling 
%points)


    n=map.samples;
    FVLEN=(sum(iterdex<n))*(floor(n/2)+1)+sum(iterdex>n-1);
    featurevectors=zeros(size(inputvectors,1),FVLEN);
    
    k=1;
    for j=iterdex
        b=inputvectors(:,map.orbits{j}+1); % get *samples* elements from row order vector of histogram matrix
        if(size(b,2) > 1)
            b=fft(b')'; % compute dft
            b=abs(b);
            b=b(:,1:(floor(size(b,2)/2)+1));% take the most consistently performing fourier magnitude spectrum features (fvLBP-HF in paper, just above eq 10)
        end
        featurevectors(:,k:k+size(b,2)-1)=b;
        k=k+size(b,2);
    end
