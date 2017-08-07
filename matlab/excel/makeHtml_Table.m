function [ tabla ] = makeHtml_Table(M, T, rowNames, colHeaders, colors, strPrecision)
%function sOut = makeHtmlTable(M, T, rowNames, colHeaders, colors, strPrecision)
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

