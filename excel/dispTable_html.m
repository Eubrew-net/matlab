function [ tabla ] = dispTable_html(M, T, rowNames, colHeaders, colors, strPrecision)
t=array2table(M);

try
    t.Properties.VariableNames=varname(colHeaders);
catch
    disp('varname error');
    t.Properties.VariableDescriptions=colHeaders;
end
try
     t.Properties.RowNames=varname(rowNames);
catch
     t.Row=rowNames;    
end
tabla=t;    
end

