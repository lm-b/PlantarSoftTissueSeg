function [w,yDecode]= UGMApprox(varargin)

% w = UGMApprox( img, nStates, alg)
% this funtion computes the approximate undirected graphical model
% parameters for the input image. Can take image only (default 2 stats
% (binary) and random vector mapping)

error(nargchk(2,4,nargin));

img=varargin{1};

if nargin==2
    nStates=varargin{2};
    alg='random';
end

if nargin==3
    nStates=varargin{2};
    alg=varargin{3};
end

if nargin>3
    nStates=varargin{2};
    alg=varargin{3};
    SGDvars=varargin{4};
end


% if nStates<1
%     nStates = 2;
% end
% if alg==[]
%     alg='random';
% end

% Compute the grayscale image, # nodes for the random field model
X=img;
%figure, imshow(X)
if size(varargin{1},3)>1
    Z=rgb2gray(X);
else 
    Z=X;
end
%y=int32(Z);
[nRows,nCols] = size(Z);
nNodes = nRows*nCols;

% compute the binary comparison on which the model is based. Takes user
% input for # partitions (default 2)
thresh=multithresh(Z, nStates-1);
y=int32(imquantize(Z, thresh)); % needs to have values smaller than edge potentials and >0 (values from 1:nStates)
%figure, imagesc(y);
% edgeStruct = UGM_makeEdgeStruct(adj,nStates);
% nEdges = edgeStruct.nEdges;


%nStates = 2;
y = reshape(y,[1 1 nNodes]);
Z = reshape(Z,1,1,nNodes);

%% Make edgeStruct
        
        adj = sparse(nNodes,nNodes);
        
        % Add Down Edges
        ind = 1:nNodes;
        exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
        ind = setdiff(ind,exclude);
        adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;
        
        % Add Right Edges
        ind = 1:nNodes;
        exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
        ind = setdiff(ind,exclude);
        adj(sub2ind([nNodes nNodes],ind,ind+nRows)) = 1;
        
        % Add Up/Left Edges
        adj = adj+adj';
        edgeStruct = UGM_makeEdgeStruct(adj,nStates);
        nEdges = edgeStruct.nEdges;
        
        %% Make Xnode, Xedge, nodeMap, edgeMap, initialize weights
        
        % Add bias and Standardize Columns
        tied = 1;
        Xnode = [ones(1,1,nNodes) double(Z)]; % no normalization for consistiency between samples
        nNodeFeatures = size(Xnode,2);
        
        % Make nodeMap
        nodeMap = zeros(nNodes,nStates,nNodeFeatures,'int32');
        for f = 1:nNodeFeatures
            nodeMap(:,1,f) = f;
        end
        
        % Make Xedge
        sharedFeatures = [1 0];
        Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,sharedFeatures);
        nEdgeFeatures = size(Xedge,2);
        

switch alg
    case 'random'
        
        % Make edgeMap
        f = max(nodeMap(:));
        edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
        for edgeFeat = 1:nEdgeFeatures
            edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
            edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
        end
        
        nParams = max([nodeMap(:);edgeMap(:)]);
        
        %% Evaluate with random parameters
        
        %figure;
        for i = 1:4
            %fprintf('ICM Decoding with random parameters (%d of 4)...\n',i);
            subplot(2,2,i);
            w = randn(nParams,1);
            [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
            yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
            imagesc(reshape(yDecode,nRows,nCols));
            colormap gray
        end
        %suptitle('ICM Decoding with random parameters');
        %fprintf('(paused)\n');
        pause
        
    case 'pseudo'
        % Make edgeMap
        f = max(nodeMap(:));
        edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
        for edgeFeat = 1:nEdgeFeatures
            edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
            edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
        end
        
        nParams = max([nodeMap(:);edgeMap(:)]);
       
        %% Train with Pseudo-likelihood
        %edgeStruct.useMex=0;
        w = zeros(nParams,1);
        funObj = @(w)UGM_CRF_PseudoNLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct);
        w = minFunc(funObj,w); % for debugging 
        %optst=struct('display', 'off');
        %w = minFunc(funObj,w, optst); % for final version to speed up processing time
        %% Evaluate with learned parameters
        
        %fprintf('ICM Decoding with estimated parameters...\n');
        figure;
        [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
        yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
        imagesc(reshape(yDecode,nRows,nCols));
        colormap gray
        title('ICM Decoding with pseudo-likelihood parameters');
        fprintf('(paused)\n');
        pause
        
    case 'NNE_SMR'
        %% Now try with non-negative edge features and sub-modular restriction
        
        sharedFeatures = [1 0];
        Xedge = UGM_makeEdgeFeaturesInvAbsDif(Xnode,edgeStruct.edgeEnds,sharedFeatures);
        nEdgeFeatures = size(Xedge,2);
        
        % Make different edgeMap
        f = max(nodeMap(:));
        edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
        for edgeFeat = 1:nEdgeFeatures
            edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
            edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
        end
        
        nParams = max([nodeMap(:);edgeMap(:)]);
        w = zeros(nParams,1);
        %% graph cuts only work with binary
        funObj = @(w)UGM_CRF_PseudoNLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct); % Make objective with new Xedge/edgeMap
        UB = [inf;inf;inf;inf]; % No upper bound on parameters
        LB = [-inf;-inf;0;0]; % No lower bound on node parameters, edge parameters must be non-negative
        w = minConf_TMP(funObj,w,LB,UB);
        
        % fprintf('Graph Cuts Decoding with estimated parameters...\n');
        % figure;
        % [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
        % yDecode = UGM_Decode_GraphCut(nodePot,edgePot,edgeStruct);
        % imagesc(reshape(yDecode,nRows,nCols));
        % colormap gray
        % title('GraphCut Decoding with constrained pseudo-likelihood parameters');
        % fprintf('(paused)\n');
        % pause
        
    case 'loopy'
        %% Now try with loopy belief propagation for approximate inference
        %VERY SLOW - either try a new fct (probably don't have time) or eliminate
        %all together
        % Make edgeMap
        f = max(nodeMap(:));
        edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
        for edgeFeat = 1:nEdgeFeatures
            edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
            edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
        end

%         w = zeros(nParams,1);
%         funObj = @(w)UGM_CRF_NLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
%         w = minConf_TMP(funObj,w,LB,UB);
        nParams = max([nodeMap(:);edgeMap(:)]);
        maxIter = 3; % Number of passes through the data set

        w = zeros(nParams,1);
        options.maxFunEvals = maxIter;
        options.display= 'off';
        funObj = @(w)UGM_CRF_NLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
        w = minFunc(funObj,w,options);

        
%         figure;
%         for i = 1:4
%             subplot(2,2,i);
%             [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct,i);
%             nodeBel = UGM_Infer_LBP(nodePot,edgePot,edgeStruct);
%             imagesc(reshape(nodeBel(:,2),nRows,nCols));
%             colormap gray
%         end
%         suptitle('Loopy BP node marginals with truncated minFunc parameters');
%         fprintf('(paused)\n');
%         pause
        % fprintf('Graph Cuts Decoding with estimated parameters...\n');
        % figure;
        % [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
        % yDecode = UGM_Decode_GraphCut(nodePot,edgePot,edgeStruct);
        % imagesc(reshape(yDecode,nRows,nCols));
        % colormap gray
        % title('GraphCut Decoding with constrained loopy BP parameters');
        % fprintf('(paused)\n');
        % pause
    case 'SGD'
        %% Train with Stochastic gradient descent for the same amount of time
        maxIter=SGDvars(1); nInstances=SGDvars(2);
        % Make edgeMap
        f = max(nodeMap(:));
        edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
        for edgeFeat = 1:nEdgeFeatures
            edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
            edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
        end

        nParams = max([nodeMap(:);edgeMap(:)]);
        stepSize = 1e-4;
        w = zeros(nParams,1);
        for iter = 1:maxIter*nInstances
            i = ceil(rand*nInstances);
            funObj = @(w)UGM_CRF_NLL(w,Xnode(i,:,:),Xedge(i,:,:),y(i,:),nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
            [f,g] = funObj(w);
            
            fprintf('Iter = %d of %d (fsub = %f)\n',iter,maxIter*nInstances,f);
            
            w = w - stepSize*g;
        end
        
        figure;
        for i = 1:4
            subplot(2,2,i);
            [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct,i);
            nodeBel = UGM_Infer_LBP(nodePot,edgePot,edgeStruct);
            imagesc(reshape(nodeBel(:,2),nRows,nCols));
            colormap gray
        end
        suptitle('Loopy BP node marginals with truncated  stochastic gradient parmaeters');
        fprintf('(paused)\n');
        pause
    otherwise
        disp('no algorithm selected')
end 
end