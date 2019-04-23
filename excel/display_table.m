function [ tabla ] = display_table(data, colheadings, wid, fms, rowheadings, fid, colsep, rowending)
%displaytable([config_orig(1:52),config_def(1:52),config_ref],[Cal.brw_config_files(Cal.n_inst,1),Cal.brw_config_files(Cal.n_inst,2),fref],20,'',cellstr(leg))
t=array2table(data);
colHeaders=cellstr(colheadings);

try
    t.Properties.VariableNames=varname(colHeaders);
catch
    disp('varname error');
    t.Properties.VariableDescriptions=colHeaders;
end

if nargin>4
 rowNames=cellstr(rowheadings);   
 try
     t.Properties.RowNames=varname(rowNames);
 catch
     t.Row=rowNames;    
 end
end
tabla=t;    
end

