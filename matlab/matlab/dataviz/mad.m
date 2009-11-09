function y = mad(x,dim)
%MAD    Median absolute deviation.
%  y = mad(x,dim)
%   For vectors, MAD(X) returns the median absolute deviation. For matrices,
%   MAD(X) is a row vector containing the median absolute deviation of each
%   column.  For N-D arrays, MAD(X) is the median absolute deviation of the
%   elements along the first non-singleton dimension of X.
%
%   MAD(X,DIM) takes the median absolute deviation along the dimension
%   DIM of X. 
%  
%   See also STD, MEDIAN.

% Copyright (c) 1998 by Datatool
% $Revision: 1.00 $

if nargin<2, 
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end

% Avoid divide by zero.
if size(x,dim)==1, y = zeros(size(x)); return, end

tile = ones(1,max(ndims(x),dim));
tile(dim) = size(x,dim);

xc = x - repmat(median(x,dim),tile);  % Remove median
y = median(abs(xc),dim);
