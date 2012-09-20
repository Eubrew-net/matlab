%function [x,r,ab,rp,data]=ratio_min_ozone(a,b,min,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%
% Special Version for ozone measurements
% input argument:  date, ozone,airm, sza,ms9,sms9, temperature, filter

function [r,ab,rp,data]=ratio_min(a,b,n_min)
% calcula el ratio entre respuestas o lamparas
MIN=60*24;

[aa,bb]=findm_min(a(:,1),b(:,1),n_min/MIN);
c=b(bb,1);
data=[a(aa,1),a(aa,1)-b(bb,1),a(aa,2:end),b(bb,2:end)]; data_l=size(a,2);

r=[c,(a(aa,2)./b(bb,2)),a(aa,2),b(bb,2),a(aa,2).*a(aa,3),a(aa,4)];
ab=[c,(a(aa,2:end)-b(bb,2:end))];
% date(ref), rel.dif., sza(ref), m(ref), ozono(inst), ozono(ref), temp(inst), filter(inst) 
% todo se refiere al instrumento, salvo fecha, m y sza, que se refieren a la referencia
rp=[b(bb,1),100*(a(aa,2)-b(bb,2))./b(bb,2),b(bb,4),b(bb,3),a(aa,2),b(bb,2),a(aa,7),a(aa,8)];


