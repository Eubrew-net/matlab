function [hg,hgscan]=readb_hg_measures(l,jhgscan,jhg)

 
    

    %hg new is pfre
    %%
    jhg_old= ~(ismember(jhg,jhgscan+1) | ismember(jhg,jhgscan));
    jhg_new= (ismember(jhg,jhgscan+1));
    jhg_total=(ismember(jhg,jhgscan+1));
    hg=NaN*ones(length(jhg_total),9);
    %hg=hg(jhg_total,:)';
    if any(jhg_new)
      saux=strrep(l(jhg(jhg_new)),char(13),' ');
      haux_n=sscanf(char(saux)','hg %f:%f:%f %f %f %f %f %f %f\n ',[9,Inf]);
      hg(jhg_new,1:end)=haux_n';
    end 
    if any(jhg_old)
      saux=strrep(l(jhg(jhg_old)),char(13),' ');
      haux_o=sscanf(char(saux)','hg %f:%f:%f %f %f %f %f %f \n ',[8,Inf]);
      hg(jhg_old,1:end-1)=haux_o';
    end
    hg=hg(jhg_total,:);
    
   
    
    %not developed
    hg_scan=[];
end
    