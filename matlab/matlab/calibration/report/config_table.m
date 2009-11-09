% return from the config the O3abs ETC and table
% per brewer, is there are changes-> one per day
% 
function [A,ETC,icf_brw,cfg]=config_table(config)

A=[]; % ozone absortion
ETC=[]; %etc

for i=1:length(config)
    a=cell2mat(config{i}');
    %configuracon inicial (1)
    % end-1 en la ultima posicion esta la fecha
    
    % configuracion 2�
    cfg{i,1}=unique(a(1:end-1,1:2:end)','rows');
    cfg{i,2}=unique(a(1:end-1,2:2:end)','rows');
  for jj=1:2
    if size(cfg{i,jj},1)==1
        A(i,jj)= cfg{i,jj}(8);
        ETC(i,jj)= cfg{i,jj}(11);
        icf_brw{i,jj}=[a(end,jj:2:end);a(8,jj:2:end);a(11,jj:2:end)];
    else % several configurations
        A(i,jj)=NaN;
        ETC(i,jj)=NaN;
    
    if ~isempty(a)
        icf_brw{i,jj}=[a(end,jj:2:end);a(8,jj:2:end);a(11,jj:2:end)];
    end
    end
  end
end


