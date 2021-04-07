function b = newcustfilt(a, nhood, fun)

%
%       C = FUN(X)
%
%   FUN must be a FUNCTION_HANDLE.
%
%   C is the output value for the center pixel in the M-by-N block X.
%   NLFILTER calls FUN for each pixel in A. NLFILTER zero pads the M-by-N
%   block at the edges, if necessary.
%
%   B = NLFILTER(A,'indexed',...) processes A as an indexed image, padding
%   with ones if A is of class single or double and zeros if A is of class
%   logical, uint8, or uint16.
%
%


%%%

% Validate 2D input image
validateattributes(a,{'logical','numeric'},{'2d'},mfilename,'A',1);

% Validate neighborhood
validateattributes(nhood,{'numeric'},{'integer','row','positive','nonnegative','nonzero'},mfilename,'[M N]',blockSizeParamNum);
if (numel(nhood) ~= 2)
    error(message('images:nlfilter:invalidBlockSize'))

% Expand A
[ma,na] = size(a);
aa = mkconstarray(class(a), padval, size(a)+nhood-1);
aa(floor((nhood(1)-1)/2)+(1:ma),floor((nhood(2)-1)/2)+(1:na)) = a;

% Find out what output type to make.
rows = 0:(nhood(1)-1);
cols = 0:(nhood(2)-1);
b = mkconstarray(class(feval(fun,aa(1+rows,1+cols),params{:})), 0, size(a));

% create a waitbar if we are able

% Apply fun to each neighborhood of a
for i=1:ma
    
    for j=1:na
        x = aa(i+rows,j+cols);
        b(i,j) = feval(fun,x,params{:});
    end

end

close(wait_bar);



end

fun = fcnchk(fun,length(params));
