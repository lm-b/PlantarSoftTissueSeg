function w= UGM_Approx(img, nStates, alg);
X=img
figure, imshow(X)
Z=rgb2gray(X);
%y=int32(Z);
[nRows,nCols] = size(Z);
nNodes = nRows*nCols;
nStates = 3;


thresh=multithresh(Z, nStates-1);
y=int32(imquantize(Z, thresh)); % needs to have values smaller than edge potentials and >0 (values from 1:nStates)
figure, imagesc(y);
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
Xnode = [ones(1,1,nNodes) UGM_standardizeCols(double(Z),tied)];
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

% Make edgeMap
f = max(nodeMap(:));
edgeMap = zeros(nStates,nStates,nEdges,nEdgeFeatures,'int32');
for edgeFeat = 1:nEdgeFeatures
   edgeMap(1,1,:,edgeFeat) = f+edgeFeat;
   edgeMap(2,2,:,edgeFeat) = f+edgeFeat;
end

nParams = max([nodeMap(:);edgeMap(:)]);

%% Evaluate with random parameters

figure;
for i = 1:4
    fprintf('ICM Decoding with random parameters (%d of 4)...\n',i);
    subplot(2,2,i);
    w = randn(nParams,1);
    [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
    yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
    imagesc(reshape(yDecode,nRows,nCols));
    colormap gray
end
suptitle('ICM Decoding with random parameters');
fprintf('(paused)\n');
pause

%% Train with Pseudo-likelihood
edgeStruct.useMex=0;
w = zeros(nParams,1);
funObj = @(w)UGM_CRF_PseudoNLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct);
w = minFunc(funObj,w);

%% Evaluate with learned parameters

fprintf('ICM Decoding with estimated parameters...\n');
figure;
[nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
imagesc(reshape(yDecode,nRows,nCols));
colormap gray
title('ICM Decoding with pseudo-likelihood parameters');
fprintf('(paused)\n');
pause

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

%% Now try with loopy belief propagation for approximate inference
%VERY SLOW - either try a new fct (probably don't have time) or eliminate
%all together

w = zeros(nParams,1);
funObj = @(w)UGM_CRF_NLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_LBP);
w = minConf_TMP(funObj,w,LB,UB);

% fprintf('Graph Cuts Decoding with estimated parameters...\n');
% figure;
% [nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct);
% yDecode = UGM_Decode_GraphCut(nodePot,edgePot,edgeStruct);
% imagesc(reshape(yDecode,nRows,nCols));
% colormap gray
% title('GraphCut Decoding with constrained loopy BP parameters');
% fprintf('(paused)\n');
% pause

