%function [x,r,ab,rp,data]=ratiol(a,b)
% calcula el ratio entre respuestas o lamparas
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual

function [x,r,ab,rp,data]=ratiol(a,b,namea,nameb)
% calcula el ratio entre respuestas o lamparas
if nargin==2
 namea=inputname(1);
 nameb=inputname(2);
end
if isempty(namea)
    namea='serie 1';
end
if isempty(nameb)
    nameb='serie 2';
end

    
[c,aa,bb]=intersect(a(:,1),b(:,1));
data=[c,a(aa,2:end),b(bb,2:end)];
%figure;

%r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
%r=[c,log(a(aa,2)./b(bb,2))];
if isempty(c) 
   error('no comon elemets to ratio')
end
if size(b,2)~=size(a,2) & size(b,2)==2
    b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
end
r=[c,(a(aa,2:end)./b(bb,2:end))];
ab=[c,(a(aa,2:end)-b(bb,2:end))];
rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];

subplot(2,2,1);
ploty(data);grid;title('');
legend(namea,nameb,2);

subplot(2,2,2)
ploty(ab);
ylabel([namea,' - ',nameb]);

subplot(2,1,2);
[h,y1,y2]=plotyy(c,r(:,2:end),c,rp(:,2:end));grid;
title('Ratios %');
ylabel(h(1),'ratio');
ylabel(h(2),'ratio %');
x=r;