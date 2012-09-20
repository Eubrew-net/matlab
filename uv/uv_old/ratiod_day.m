%function [x,r,ab,rp,data]=ratio_day(a,b,day,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%TODO input the minute
function [x,r,aa,bb,ab,rp,data]=ratiod_day(a,b,dia,name_a,name_b)
% calcula el ratio entre respuestas o lamparas

[aa,bb]=findm(a(:,1),b(:,1),dia);
c=a(aa,1);
if isempty(c) 
   error('no comon elemets to ratio')
end


n_col=size(b(:,2:end),2);
n_col_a=size(a(:,2:end),2);
% PORQUE NO RULA no busca todos !!!
% 3 minutos 1/( 3  *7E-4)
%aux_a(:,1)=fix(round(a(:,1)*MIN)/n_min);
%aux_b(:,1)=fix(round(b(:,1)*MIN)/n_min);
%[c,aa,bb]=intersect(aux_a(:,1),aux_b(:,1));

% seguramente halla duplicados, promediamos

data=[a(aa,1),a(aa,1)-b(bb,1),a(aa,2:end),b(bb,2:end)];
% seguramente halla duplicados, promediamos

try
 r=[c,(a(aa,2:end)./b(bb,2:end))];
 ab=[c,(a(aa,2:end)-b(bb,2:end))];
 rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];
catch
 r=[c,(a(aa,2)./b(bb,2))];
 ab=[c,(a(aa,2)-b(bb,2))];
 rp=[c,100*(a(aa,2)-b(bb,2))./b(bb,2)];

end


x=data;
if nargin>3
figure;
subplot(2,2,1);
ploty(data(:,[1,3:end]));grid;title('medidas');
datetick;
if nargin==2
    name_a=inputname(1);
    name_b=inputname(2);
end
legend(name_a,name_b,-1);


if size(b,2)~=size(a,2) & size(b,2)==2
    b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
end

subplot(2,2,2);
if n_col==n_col_a
 plot(data(:,3:3+n_col-1),data(:,3+n_col:end),'x');
else
  plot(data(:,3:3+n_col_a-1),data(:,3+n_col_a),'x');
end
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
