function [numeric txt raw]=read_checklists(filename,sheet)

brw=regexpi(sheet, '^B(\D*)(\d*)','match'); brwid=regexpi(cell2mat(brw), '\d*$','match');  
file_latex=fullfile('.','latex',cell2mat(brwid));

[a b c]=xlsread(filename,sheet,'A1:J90',@setNaNempty);
    

checklist=c(1:90,[1 2 3 4 5 6 8 9 10]);
% checklist=checklist(21,:);

for r=1:size(checklist,1)
    for c=1:size(checklist,2)
        if any(isnan(checklist{r,c}))
            checklist{r,c}=' ';
            continue
        end
        if isstr(checklist{r,c})
           checklist{r,c}=strrep(checklist{r,c},'#','\#');
           checklist{r,c}=strrep(checklist{r,c},'_',' ');
           checklist{r,c}=strrep(checklist{r,c},'%','\% ');
           checklist{r,c}=strrep(checklist{r,c},'&','\&');
           checklist{r,c}=strrep(checklist{r,c},'<','$<$');
           checklist{r,c}=strrep(checklist{r,c},'>','$>$');
        end
    if isfloat(checklist{r,c})
        checklist{r,c}=num2str(checklist{r,c});
    end
    end
end
matrix2latex_checklist(checklist(2:end,2:end),...
                     fullfile(file_latex,['checklist_',cell2mat(brwid),'.tex']),...
                     'columnlabels',checklist(1,2:end),'rowlabels',checklist(2:end,1),...
                                              'size','footnotesize','caption',sheet);
fclose all                                          