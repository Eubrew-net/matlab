%function [m,s,n]=osc_group(grp,dat)
% promeadia por rangos de osc osc es la ultima columna 
function [m,s,n,name]=nan_osc_group(grp,dat)

aux=NaN*ones(size(dat,1),size(dat,2)+1);
aux(:,1:end-1)=dat; 
osc_s=dat(:,end); % osc debe ser �ltima columna en INPUT
for ii=1:length(grp)+1 
    
    if ii==1
        aux(osc_s<grp(ii),end)=ii; 
    elseif ii==length(grp)+1
        aux(osc_s>grp(ii-1),end)=ii+2;         
    else
        aux((osc_s>=grp(ii-1) & osc_s<grp(ii)),end)=ii+1;
    end
end

[m,s,n,name]=grpstats(aux,aux(:,end),{'nanmean','nanstd','numel','gname'});         
