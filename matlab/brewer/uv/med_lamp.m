% promedia datos de lamparas unidos (lamda,cuentas,lamda,cuentas..)
% function [med_lamp,ratio_lamp,ratio_P]=med_lamp(lamp)
% media, ratio respect a la media y ratio porcentual 100* (cuentas-media/media)
% TODO: si se especifica una referencia los ratios se refieren a esta
% 
function [med_lamp,ratio_lamp,data,ratio_P]=med_lamp(lamp)
% promedia datos de lamparas unidos (lamda,cuentas,lamda,cuentas..)

cuentas=lamp(:,2:2:end);
x=lamp(:,1);
data=[x,cuentas];
med_lamp=[x, nanmean(cuentas')',nanstd(cuentas')'];


ratio=repmat(med_lamp(:,2),1,size(cuentas,2));    

ratio_lamp=[x,(cuentas./ratio)];
ratio=repmat(med_lamp(:,2),1,size(cuentas,2));    
ratio_P=[x,100*(cuentas-ratio)./ratio];