function y = quantile(x,p)
%  calculate quantiles of the data x
%  at fractions 0<=p<=1
%  y = quantile(x,p)

% Copyright (c) 1998 by Datatool
% $Revision: 1.00 $

if size(x,1)==1
   x = x(:);
end

x = sort(x);
x(isnan(x))=[];

n = size(x,1);

%  standard fractions for this number of points
f = ((1:n)-0.5)/n;

index = p<min(f);
p(index) = min(f);
index = p>max(f);
p(index) = max(f);

%  use nearest neighbor interpolation
index = interp1(f,1:n,p,'nearest');
y = x(index,:);

