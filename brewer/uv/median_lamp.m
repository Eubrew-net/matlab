% [meanlamp,ratio_lamp]=mean_lamp(a,c_ref)
% retorna mediana y desviacion estandard
% a matrix : 1º colunma la longitud de onda, resto medidas a promediar
% [meanlamp]=[lamda,media,sigma,ndatos]
%  ratio_lamp
% calcula el ratio frente a la columna de referencia (c_ref) o respecto
% a la media si no se expecifica.
% see also: med_lamp
%
function [meanlamp,ratio_lamp]=mean_lamp(a,c_ref)



if size(a,2)>2
    meanlamp=[a(:,1),nanmedian(a(:,2:end)')',nanstd(a(:,2:end)')',sum(~isnan(a(:,2:end)'))'];
    if nargin<2
        ratio=repmat(meanlamp(:,2),1,size(a,2)-1);
    else    
        ratio=repmat(a(:,c_ref),1,size(a,2)-1);    
    end
    ratio_lamp=[a(:,1),(a(:,2:end)./ratio)];
else
   meanlamp=[a(:,1),a(:,2),a(:,2)*0,ones(size(a(:,2)))];
end
