function [idx]= getSelectionIndices(newSourceTarg, origSourceTarg);

% find which features were selected by the selection algorithms


A=newSourceTarg; B=origSourceTarg;
[C, ia, ib]=intersect(A,B, 'rows');

idx=ib;



end
