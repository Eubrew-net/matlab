function fid=cfgtoicf(Cal,cual)

% Pasale la variable de definiciones Cal y cual quieres, 1 o 2. Escribe en el directorio de
% trabajo. 
% 
% 27 March 2014: 1ª aproximación. Puede ser muy potente debido a getcfgs

[a b c]=fileparts(Cal.brw_config_files{Cal.n_inst,cual});
if ~strcmpi(c,'.cfg')
    fprintf('\nBrewer %s: Operative Config. is ICF\n',Cal.brw_name{Cal.n_inst}); fid=0;
else
    events_cfg_chk=getcfgs(datenum(2014,7,18),Cal.brw_config_files{Cal.n_inst,cual});  
    cfg_str=sprintf('ICF%d%d.%d',diaj(events_cfg_chk.all_data(1)),year(events_cfg_chk.all_data(1))-2000,Cal.brw(Cal.n_inst));
    fprintf('\nBrewer %s: Write config to %s.\n',Cal.brw_name{Cal.n_inst},cfg_str);
    displaytable(events_cfg_chk.data(2:end,:),cellstr(datestr(events_cfg_chk.data(1,:),1))',12,'.5g',events_cfg_chk.legend(2:end));    

    fid = fopen(cfg_str,'wt'); % Open for writing
    for i=2:size(events_cfg_chk.all_data,1)
        fprintf(fid, '%f\n',  events_cfg_chk.all_data(i));
    end
    fprintf(fid, '%s\n', datestr(events_cfg_chk.all_data(1),2));

    fclose(fid);
    
end