function [q,N] = quantile2(X,p,dim,method)
% QUANTILE2 Quantiles of a sample via various methods.
% 
%   q = quantile2(x,p)
%   q = quantile2(x,p,dim)
%   q = quantile2(x,p,dim,method)
%   q = quantile2(x,p,[],method)
%   [q,N] = quantile2(...)
% 
%   Q = QUANTILE2(X,P) returns quantiles of the values in X.
%   P is a scalar or a vector of cumulative probability
%   values.  When X is a vector, Q is the same size as P,
%   and Q(i) contains the P(i)-th quantile.  When X is a
%   matrix, the i-th row of Q contains the P(i)-th quantiles
%   of each column of X.  For N-D arrays, QUANTILE2 operates
%   along the first non-singleton dimension.
% 
%   Q = QUANTILE2(X,P,DIM) calculates quantiles along
%   dimension DIM.  The DIM'th dimension of Q has length
%   LENGTH(P).
% 
%   Q = QUANTILE2(X,P,DIM,METHOD) calculates quantiles using
%   one of the methods described in
%   http://en.wikipedia.org/wiki/Quantile. The method are
%   designated 'R-1'...'R-9'; the default is R-8 as
%   described in http://bit.ly/1kX4NcT, whereas Matlab uses
%   'R-5'.
%   
%   Q = QUANTILE2(X,P,DIM,METHOD) calculates quantiles using
%   one of the methods described in
%   http://en.wikipedia.org/wiki/Quantile. The method are
%   designated 'R-1'...'R-9'; the default is 'R-8' as
%   described in http://bit.ly/1kX4NcT, whereas Matlab uses
%   'R-5'.
%   
%   Q = QUANTILE2(X,P,[],METHOD) uses the specified METHOD,
%   but calculates quantiles along the first non-singleton
%   dimension.
% 
%   Further reading
%   
%   Hyndman, R.J.; Fan, Y. (November 1996). "Sample 
%     Quantiles in Statistical Packages". The American
%     Statistician 50 (4): 361-365.
%   Frigge, Michael; Hoaglin, David C.; Iglewicz, Boris
%     (February 1989). "Some Implementations of the
%     Boxplot". The American Statistician 43 (1): 50-54.
%   
%   See also QUANTILE.

% !---
% ==========================================================
% Last changed:     $Date: 2014-05-29 10:32:09 +0100 (Thu, 29 May 2014) $
% Last committed:   $Revision: 300 $
% Last changed by:  $Author: ch0022 $
% ==========================================================
% !---

% Check input and make default assignments

assert(isnumeric(X),'X must be a numeric');
assert(isvector(p) & isnumeric(p),'P must be a numeric vector');
assert(p>=0 & p<=1,'P must be in the interval [0,1].')

if nargin<2
    error('Not enough input arguments.')
end

dims = size(X);
if nargin<3 || isempty(dim)
    dim = find(dims>1,1,'first'); % default dim
else % validate input
    assert(isnumeric(dim) | isempty(dim),'DIM must be an integer or empty');
    assert(isint(dim) | isempty(dim),'DIM must be an integer or empty');
    assert(dim>0,'DIM must be greater than 0')
end

if nargin<4
    method = 'r-8'; % default method
else % validate input
    assert(ischar(method),'METHOD must be a character array')
end

%% choose method

% See http://en.wikipedia.org/wiki/Quantile#Estimating_the_quantiles_of_a_population

switch lower(method)
    case 'r-1'
        min_con = @(N,p)(p==0);
        max_con = @(N,p)(false);
        h = @(N,p)((N*p)+.5);
        Qp = @(x,h)(x(ceil(h-.5)));
    case 'r-2'
        min_con = @(N,p)(p==0);
        max_con = @(N,p)(p==1);
        h = @(N,p)((N*p)+.5);
        Qp = @(x,h)((x(ceil(h-.5))+x(floor(h+.5)))/2);
    case 'r-3'
        min_con = @(N,p)(p<=(.5/N));
        max_con = @(N,p)(false);
        h = @(N,p)(N*p);
        Qp = @(x,h)(x(round(h)));
    case 'r-4'
        min_con = @(N,p)(p<(1/N));
        max_con = @(N,p)(p==1);
        h = @(N,p)(N*p);
        Qp = @(x,h)(x(floor(h)) + ((h-floor(h))*(x(floor(h)+1)-x(floor(h)))));
    case 'r-5'
        min_con = @(N,p)(p<(.5/N));
        max_con = @(N,p)(p>=((N-.5)/N));
        h = @(N,p)((N*p)+.5);
        Qp = @(x,h)(x(floor(h)) + ((h-floor(h))*(x(floor(h)+1)-x(floor(h)))));
    case 'r-6'
        min_con = @(N,p)(p<(1/(N+1)));
        max_con = @(N,p)(p>=(N/(N+1)));
        h = @(N,p)((N+1)*p);
        Qp = @(x,h)(x(floor(h)) + ((h-floor(h))*(x(floor(h)+1)-x(floor(h)))));
    case 'r-7'
        min_con = @(N,p)(false);
        max_con = @(N,p)(p==1);
        h = @(N,p)(((N-1)*p)+1);
        Qp = @(x,h)(x(floor(h)) + ((h-floor(h))*(x(floor(h)+1)-x(floor(h)))));
    case 'r-8'
        min_con = @(N,p)(p<((2/3)/(N+(1/3))));
        max_con = @(N,p)(p>=((N-(1/3))/(N+(1/3))));
        h = @(N,p)(((N+(1/3))*p)+(1/3));
        Qp = @(x,h)(x(floor(h)) + ((h-floor(h))*(x(floor(h)+1)-x(floor(h)))));
    case 'r-9'
        min_con = @(N,p)(p<((5/8)/(N+.25)));
        max_con = @(N,p)(p>=((N-(3/8))/(N+.25)));
        h = @(N,p)(((N+.25)*p)+(3/8));
        Qp = @(x,h)(x(floor(h)) + ((h-floor(h))*(x(floor(h)+1)-x(floor(h)))));
    otherwise
        error(['Method ''' method ''' does not exist'])
end

%% calculate quartiles

% reshape data so function works down columns
order = mod(dim-1:dim+length(dims)-2,length(dims))+1;
x = permute(X,order);
dims_shift = dims(order);
x = reshape(x,dims_shift(1),numel(x)/dims_shift(1));

% pre-allocate q
q = zeros([length(p) dims_shift(2:end)]);
q = reshape(q,length(p),numel(q)/length(p));
N = zeros([length(p) dims_shift(2:end)]);
N = reshape(N,length(p),numel(N)/length(p));
for m = 1:length(p)
    for n = 1:numel(q)/length(p)
        x2 = sort(x(~isnan(x(:,n)),n)); % sort
        N(m,n) = length(x2); % sample size
        if min_con(N(m,n),p(m)) % at lower limit
            q(m,n) = x2(1);
        elseif max_con(N(m,n),p(m)) % at upper limit
            q(m,n) = x2(N(m,n));
        else % everything else
            q(m,n) = Qp(x2,h(N(m,n),p(m)));
        end
    end
end

% restore dims of q to equate to those of input
q = reshape(q,[length(p) dims_shift(2:end)]);
q = ipermute(q,order);
N = reshape(N,[length(p) dims_shift(2:end)]);
N = ipermute(N,order);

% if q is a vector, make same shape as p
if numel(p)==numel(q)
    q=reshape(q,size(p));
    N=reshape(N,size(p));
end

% end of quantile2()

% ----------------------------------------------------------
% Local functions:
% ----------------------------------------------------------

% ----------------------------------------------------------
% isint: Test whether x is integer value (not type)
% ----------------------------------------------------------
function y = isint(x)

y = x==round(x);

% [EOF]
