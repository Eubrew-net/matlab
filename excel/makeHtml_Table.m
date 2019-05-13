function [ tabla ] = makeHtml_Table(M, T, rowNames, colHeaders, colors, strPrecision)
%matrix2latex_ctable(filter.ETC_FILTER_CORRECTION-filter.ETC_FILTER_CORRECTION(1,2),...
%                fullfile(Cal.file_latex,['table_etc_c',Cal.brw_str{Cal.n_inst},'.tex']),...
%                    'rowlabels',{'Mean','Median','CI ','CI'},...
%                    'columnlabels',mmcellstr(sprintf('Filter\\#%d|',[1:5])),...
%                                    'alignment','c','resize',0.9);


%function sOut = makeHtmlTable(M, T, rowNames, colHeaders, colors, strPrecision)
t=array2table(M);
if nargin>1
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
else
    tabla=t;
end
