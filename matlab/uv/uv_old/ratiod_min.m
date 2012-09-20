%function [x,r,ab,rp,data]=ratiod(a,b,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%TODO input the minute
function [x,r,ab,rp,data]=ratiod_min(a,b,name_a,name_b)
% calcula el ratio entre respuestas o lamparas
MIN=60*24;
n_min=0.5;
[aa,bb]=findm(a(:,1),b(:,1),n_min/MIN);
c=a(aa,1);
% PORQUE NO RULA no busca todos !!!
% 3 minutos 1/( 3  *7E-4)
%aux_a(:,1)=fix(round(a(:,1)*MIN)/n_min);
%aux_b(:,1)=fix(round(b(:,1)*MIN)/n_min);
%[c,aa,bb]=intersect(aux_a(:,1),aux_b(:,1));

data=[a(aa,1),a(aa,1)-b(bb,1),a(aa,2:end),b(bb,2:end)];
r=[c,(a(aa,2:end)./b(bb,2:end))];
ab=[c,(a(aa,2:end)-b(bb,2:end))];
rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];
x=data;
if nargin>2
figure;
subplot(2,2,1);
ploty(data(:,[1,3:end]),'.');grid;title('medidas');
datetick;
if nargin==2
    name_a=inputname(1);
    name_b=inputname(2);
end
legend(name_a,name_b,-1);
%r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
%r=[c,log(a(aa,2)./b(bb,2))];
if isempty(c) 
   error('no comon elemets to ratio')
end
if size(b,2)~=size(a,2) & size(b,2)==2
    b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
end

subplot(2,2,2);
plot(data(:,3),data(:,4),'x');
rline;
grid;title([name_a,' vs ',name_b]);


subplot(2,3,4);
ploty(rp);grid;title(['ratio %',name_a,' vs ',name_b]);
datetick;
subplot(2,3,5);
ploty(ab);grid;title(['dif ',name_a,' - ',name_b]);
datetick;
subplot(2,3,6);
plot(data(:,2)*60*24,data(:,3)-data(:,4),'.');grid;
title('time difference (min) vs dif');
end
