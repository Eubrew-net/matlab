function matrix2latex_longtable(matrix, filename, varargin)

%% Function input
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

%% Formatting data    
    width = size(matrix, 2);    height = size(matrix, 1);    
    if isnumeric(matrix)
        matrix = num2cell(matrix);
    end
    for h=1:height
        for w=1:width            
            if(~isempty(format))
               if iscell(format)
                  if isfloat(matrix{h, w})
                     matrix{h,w} = num2str(matrix{h,w}, format{w});                        
                  end
               else
                  if isfloat(matrix{h, w})
                     matrix{h,w} = num2str(matrix{h,w}, format);                        
                  end
               end        
            end
        end
    end

%% Write file
    fid = fopen(filename, 'w');
    if(~isempty(textsize))
        fprintf(fid, '\\begin{%s}', textsize);
    end
    fprintf(fid, '\\begin{longtable}{%s}\r\n',strcat(repmat([alignment,'|'],1,size(matrix,2)-1),alignment));
    fprintf(fid, '\\caption{%s}\\\\\r\n',caption);

        if exist('rowlabels','var')
           fprintf(fid, '&');
        end
        for w=1:width-1
            fprintf(fid, '\\textbf{%s}&', colLabels{w});
        end
        fprintf(fid, '\\textbf{%s}\\\\\r\n', colLabels{width});
    
    fprintf(fid, '\\endfirsthead\r\n');
    fprintf(fid, '\\caption{%s}\\\\\r\n',caption);
    
        if exist('rowlabels','var')
           fprintf(fid, '&');
        end
        for w=1:width-1
            fprintf(fid, '\\textbf{%s}&', colLabels{w});
        end
        fprintf(fid, '\\textbf{%s}\\\\\r\n', colLabels{width});
                 
    fprintf(fid, '\\endhead\r\n');
    fprintf(fid, '\\multicolumn{3}{c}{(Continuing in next page)} \\\\\r\n');
    fprintf(fid, '\\endfoot\r\n');
    fprintf(fid, '\\multicolumn{3}{c}{} \\\\\r\n');
    fprintf(fid, '\\endlastfoot\r\n');
    fprintf(fid, '\\toprule\r\n');
    
    for h=1:height
        if(~isempty(rowLabels))
            fprintf(fid, '\\textbf{%s}&', rowLabels{h});
        end
        for w=1:width-1
            fprintf(fid, '%s&', matrix{h, w});
        end
        if h~=height
        fprintf(fid, '%s\\\\\\midrule\r\n', matrix{h, width});
        else
        fprintf(fid, '%s\\\\\r\n\\bottomrule\r\n', matrix{h, width});
        end
    end
    fprintf(fid, '\\end{longtable}\r\n');
    
    if(~isempty(textsize))
        fprintf(fid, '\\end{%s}', textsize);
    end
    fclose(fid);