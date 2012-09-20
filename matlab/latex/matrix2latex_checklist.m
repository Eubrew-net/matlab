function matrix2latex_checklist(matrix, filename, varargin)

% Enjoy life!!!

    rowLabels = [];    colLabels = [];
    alignment = 'l';
    format = [];
    textsize = [];
    if (rem(nargin,2) == 1 || nargin < 2)
        error('matrix2latex: ', 'Incorrect number of arguments to %s.', mfilename);
    end

    okargs = {'rowlabels','columnlabels', 'alignment', 'format', 'size','caption'};
    for j=1:2:(nargin-2)
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(lower(pname), okargs);
        if isempty(k)
            error('matrix2latex: ', 'Unknown parameter name: %s.', pname);
        elseif length(k)>1
            error('matrix2latex: ', 'Ambiguous parameter name: %s.', pname);
        else
            switch(k)
                case 1  % rowlabels
                    rowLabels = pval;
                    if isnumeric(rowLabels)
                        rowLabels = cellstr(num2str(rowLabels(:)));
                    end
                case 2  % column labels
                    colLabels = pval;
                    if isnumeric(colLabels)
                        colLabels = cellstr(num2str(colLabels(:)));
                    end
                case 3  % alignment
                    alignment = lower(pval);
                    if alignment == 'right'
                        alignment = 'r';
                    end
                    if alignment == 'left'
                        alignment = 'l';
                    end
                    if alignment == 'center'
                        alignment = 'c';
                    end
                    if alignment ~= 'l' && alignment ~= 'c' && alignment ~= 'r'
                        alignment = 'l';
                        warning('matrix2latex: ', 'Unkown alignment. (Set it to \''left\''.)');
                    end
                case 4  % format
                    format = lower(pval);
                case 5  % format
                    textsize = pval;
                case 6  % caption
                    caption = pval;
                    caption=strrep(caption,'#','\\#');
            end
        end
    end

    fid = fopen(filename, 'w');
    
    fprintf(fid, '\\begin{landscape}\r\n\r\n');
    fprintf(fid, '\\section{Appendix: Calibration Checklist}\r\n\r\n');
    
    width = size(matrix, 2);
    height = size(matrix, 1);

    if(~isempty(textsize))
        fprintf(fid, '\\begin{%s}', textsize);
    end
    fprintf(fid, '\\begin{longtable}{@{}p{3cm}|p{4cm}|l|l|l|p{5cm}|c|c|c@{}}\r\n');     
    fprintf(fid, strcat('\\caption{',caption,' Checklist}\\\\ \r\n'));

        fprintf(fid, '&');
        for w=1:width-1
            fprintf(fid, '\\textbf{%s}&', colLabels{w});
        end
        fprintf(fid, '\\textbf{%s}\\\\\\hline\r\n', colLabels{width});
    
    fprintf(fid, '\\endfirsthead\r\n');
    fprintf(fid, strcat('\\caption{',caption,' Checklist}\\\\ \r\n'));
    
        fprintf(fid, '&');
        for w=1:width-1
            fprintf(fid, '\\textbf{%s}&', colLabels{w});
        end
        fprintf(fid, '\\textbf{%s}\\\\\\hline\r\n', colLabels{width});
    
    fprintf(fid, '\\endhead\r\n');
    fprintf(fid, '\\multicolumn{9}{c}{(Continuing in next page)} \\\\\r\n');
    fprintf(fid, '\\endfoot\r\n');
    fprintf(fid, '\\multicolumn{9}{c}{} \\\\\r\n');
    fprintf(fid, '\\endlastfoot\r\n');
   
    
    labels=[1,6,16,31,46,62];
    for h=1:height
        if(~isempty(rowLabels))
            if any(h==labels)
               fprintf(fid, '\\rowcolor{-red!75!green}\\textbf{%s}&', rowLabels{h});
            else
               fprintf(fid, '\\textbf{%s}&', rowLabels{h});                
            end
        end
        for w=1:width-1
            fprintf(fid, '%s&', matrix{h, w});
        end
           fprintf(fid, '%s\\\\\\hline\r\n', matrix{h, width});
    end
    fprintf(fid, '\\end{longtable}\r\n');
    
    if(~isempty(textsize))
        fprintf(fid, '\\end{%s}', textsize);
    end

    fprintf(fid, '\r\n\r\n\\end{landscape}');
    
    fclose(fid);