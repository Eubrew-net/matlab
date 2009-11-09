 function [fwl,fstps,pwl,pstps]=normaldsp(wl,A)
% function [fwl,fstps,pwl,pstps]=normaldsp(wl,A)
%22 1 98 julian
% 30 8 99 julian modify input variables


%wl=A(:,1);
fwl=zeros(length(wl),6);
fstps=fwl;
pwl=[];
pstps=[];

for i=1:6,%2:7,
   ind=A(:,i)~=0 & ~isnan(A(:,i));
   if sum(ind)>2,
    lastwarn('');   
    %p=polyfit(A(ind,i),wl(ind),2);
    %p2=polyfit(wl(ind),A(ind,i),2);
    
    
    p=polyfit2(A(ind,i),wl(ind));
    p2=polyfit2(wl(ind),A(ind,i));
    
    fwl(ind,i)=polyval(p,A(ind,i))-wl(ind);  % i-1 bei fwl
    fstps(ind,i)=polyval(p2,wl(ind))-A(ind,i);   % i-1 bei fstps
    pwl=[pwl;p];
    pstps=[pstps;p2];
    [msg,id]=lastwarn;
 else
    fwl(:,i)=nan;  % hier auch i-1
    fstps(:,i)=nan;  % i-1
    pwl=[pwl ;[nan nan nan]];
    pstps=[pstps ;[nan nan nan]];   
  end  
end

function [p,s,v]=polyfit2(x,y)
[p1,s,m]=polyfit(x,y,2);
%desacemos el cambio
p(1)=p1(1)/m(2)^2;
p(2)=p1(2)/m(2)-2*p1(1)*m(1)/m(2)^2;
p(3)=p1(1)*(m(1)/m(2))^2-p1(2)*(m(1)/m(2))+p1(3);
v=[round(-p(2)/2/p(1)),polyval(p,round(-p(2)/2/p(1)))];
