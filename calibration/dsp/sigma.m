function [f,N]=sigma(A,p)

% function [f,N]=sigma(A,p);
% 21 10 97 julian
% calculates sigma=sqrt(sum(A~=0)^2/(N-p)
% p is number of free variables.

ind=(A~=0 & ~isnan(A));
N=sum(ind(:));
f=sqrt( sum(A(ind).^2)/(N-p) );
