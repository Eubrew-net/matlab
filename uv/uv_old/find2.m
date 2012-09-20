function [inda,indb]=find2(a,b,delta)
%function [inda,indb]=find2(a,b,delta)
%25 3 98 julian
% 26 8 98 julian add delta
% so dass a(inda)=b(indb)

if nargin<3,delta=0;end

a=a(:);
N=length(a);
b=b(:);
c=[a;b];
[y,i]=sort(c);
ind=find(abs(diff(y))<=delta);
ind=[ind;ind+1];
iind=i(ind);
inda=iind(iind<=N);
indb=iind(iind>N)-N;

[buf,indaa]=sort(a(inda));
[buf,indba]=sort(b(indb));

inda=inda(indaa);
indb=indb(indba);
