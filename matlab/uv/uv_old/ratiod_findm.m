%function [x,r,ab,rp,data]=ratiol(a,b,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual

function [x,r,ab,rp,data]=ratiod(a,b,name_a,name_b)
% calcula el ratio entre respuestas o lamparas


[c,aa,bb]=intersect(a(:,1),b(:,1));
data=[c,a(aa,2:end),b(bb,2:end)];
%figure;
subplot(2,2,1);
ploty(data);grid;title('medidas');
%datetick;
datetick('x',12,'keepticks','keeplimits');
if nargin==2
    name_a=inputname(1);
    name_b=inputname(2);
end
legend(name_a,name_b);
%r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
%r=[c,log(a(aa,2)./b(bb,2))];
if isempty(c) 
   error('no comon elemets to ratio')
end
if size(b,2)~=size(a,2) & size(b,2)==2
    b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
end

subplot(2,2,2);
plot(data(:,2),data(:,3),'x');
rline;
grid;title([name_a,'vs',name_b]);


r=[c,(a(aa,2:end)./b(bb,2:end))];
ab=[c,(a(aa,2:end)-b(bb,2:end))];
rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];
subplot(2,3,4);
ploty(rp);grid;title(['ratio %',name_a,' vs ',name_b]);
datetick('x',12,'keepticks','keeplimits');
subplot(2,3,5);
ploty(ab);grid;title(['dif ',name_a,' - ',name_b]);
%datetick;
datetick('x',12,'keepticks','keeplimits');
subplot(2,3,6);
ploty(r);grid;title(['ratio',name_a,' vs ',name_b]);
%datetick;
datetick('x',12,'keepticks','keeplimits');
x=data;