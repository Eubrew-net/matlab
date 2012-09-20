function [aux,t,label,label_pie]=group_var(dat,grp)
%updated
aux=NaN*ones(size(dat,1),size(dat,2)+1);
aux(:,1:end-1)=dat; osc_s=dat(:,end); % osc debe ser última columna en INPUT
label={};
for ii=1:length(grp)+1    
    if ii==1
        label{ii}=sprintf('<=%.1f',grp(ii));
        aux(osc_s<=grp(ii),end)=ii; 
    elseif ii==length(grp)+1
        label{ii}=sprintf('>%.1f',grp(ii-1));
        aux(osc_s>grp(ii-1),end)=ii;         
    else
        label{ii}=sprintf('(%.1f,%.1f]',[grp(ii-1),grp(ii)]);
        aux((osc_s>grp(ii-1) & osc_s<=grp(ii)),end)=ii;
    end
end

t=tabulate(aux(:,2));
tp=mmcellstr(sprintf('%4.1f %% |',t(:,3)));
try
 label_pie=cellfun(@(a,b) [a,', ',b],label',tp,'UniformOutput',false);
 pie(t(:,3),label_pie);
catch
 pie(t(:,3));
end
%[m,s,n]=grpstats(aux,aux(:,end),{'mean','std','numel'});         
