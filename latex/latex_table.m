function s = latex_table(var,varargin)

% LATEX_TABLE v. 4.1
%
% latex_table(var,<varargin>)
%
% Export var as latex table
%
% Mandatory Parameters:
%   var is an array of floats or a cell array
%
% Optional Parameters:
%   dec is the number of decimals of the values of var
%       it may be an integer or an array of integer, in this case each
%       value of dec represents the number of decimals of each columns of
%       var. If the value of var is a char the value of dec is dicarded.
%
%   math_mode is use to choose to print or not $ $ as dec it may be a
%       boolean variable or an array of integer where 0 = false and 1 = true
%       default value is 0 = false
%
%   cols_title is used for the first row of the table, it must be a row cell 
%       array 
%
%   rows_title is used for the first column of the table, it must be a column cell 
%       array
%
%   width is the tabularx arguments, default value is \textwidth
%
%   file is the name of the file in which the resulting latex code will
%       be saved
%
%   h_line is an array to choose whether print or not the horizontal lines
%
%   vline is an array to choose whether print or not the vertical lines [TODO]
%
% EXAMPLE:
%   a = 1:5;
%   b = 5:-1:1;
%   c = 1.234*b; 
%   var = [a' b' c'];
%   dec = [0 2 3];
%   math_mode = false;
%   cols_title =  {'\bfseries a' '\bfseries b' '\bfseries c'};
%   rows_title =  {' '; '\textit A'; '\textit B'; '\textit C'; '\textit D'; '\textit E'};
%   width = '.5\textwidth';
%   str = latex_table([a' b' c'],'math_mode',math_mode,'dec',dec,'cols_title',cols_title,'width',width,'fontsize','\tiny','h_line',[1 0])
%
% Created by Andrea Vannuccini - 2008.05

% TO DO
% support selection of vertical and horizontal lines
% possible to modify algnment of columns
% improve preview
% create a GUI ??

% DEMO MODE
if nargin == 0
    var = 'demo';
end
if strcmpi(var,'demo')
    a = 1:5;
    b = 5:-1:1;
    c = 1.123*b;
    var = [a' b' c'];
    dec = [0 2 3];
    math_mode = false;
    cols_title =  {'\bfseries a' '\bfseries b' '\bfseries c'};
    rows_title =  {' ' '\textit A' '\textit B' '\textit C' '\textit D' '\textit E'};
    width = '.5\textwidth';
    str = latex_table([a' b' c'],'file','file.tex','math_mode',math_mode,'dec',dec,'cols_title',cols_title,'rows_title',rows_title,'width',width,'fontsize','\small','h_line',1,'preview','on')
    return
end


% Getting parameters
if (nargin < 1 || rem(nargin-1,2) == 1)
    error('MATLAB:ambiguousSyntax', 'Incorrect number of arguments to %s.', mfilename);
end

args = {'dec' 'math_mode' 'cols_title' 'rows_title' 'width' 'file' 'fontsize' 'h_line' 'vline' 'cols_format' 'preview'};
% generate empty variables
for i = 1:length(args) % assign value to cell variable
    eval([args{i} ' = '''';']);
end

for j=1:2:(nargin-2)
    param = varargin{j};
    pvalue = varargin{j+1};
    k = strmatch(lower(param), args);
    if isempty(k)
        error('MATLAB:ambiguousSyntax', 'Unknown parameter name: %s.', param);
    elseif length(k)>1
        error('MATLAB:ambiguousSyntax', 'Ambiguous parameter name: %s.', param);
    elseif iscell(pvalue)
        for i = 1:length(pvalue) % assign value to cell variable
            eval([args{k} '{' num2str(i) '} = ''' pvalue{i} ''' ;']);
        end
    else
        eval([args{k} ' = ' mat2str(pvalue) ';']) % assign value to numeric variable
    end
end


% Getting dimensions
[r c] = size(var);

% Convert to cell array
if ~iscell(var)
    var = num2cell(var);
end

% Setting dec
if isempty(dec)
    dec = zeros(1,c);
else
    if length(dec) < c
        if length(dec) ~= 1
            warning('MATLAB:ambiguousSyntax','Last value of dec used for remaining columns');
            dec = [dec dec(end)*ones(1,c-length(dec))];
        else
            dec = dec*ones(1,c);
        end
    end
end

% Setting math_mode
if isempty(math_mode) 
    math_mode = zeros(1,c);
else
    if length(math_mode) < c
        if length(math_mode) ~= 1
            warning('MATLAB:ambiguousSyntax','Last value of math_mode used for remaining columns');
            math_mode = [math_mode math_mode(end)*ones(1,c-length(math_mode))];
        else
            math_mode = math_mode*ones(1,c);
        end
    end
end

% Setting width
if isempty(width)
    width = '\textwidth';
    warning('MATLAB:ambiguousSyntax','Table width set to default value: "%s"',width);
end

% Adding cols_title
if ~isempty(cols_title)
    if length(cols_title) < c
        warning('MATLAB:ambiguousSyntax','cols_title didn''t have the same number of elements of the number of columns of var!\n\t Remaining columns title set to ""!');
        for i = (length(cols_title)+1):c
            cols_title = [cols_title ' '];
        end
    end
    var = [cols_title; var];
    r = r+1;
end

% Adding rows_title
if ~isempty(rows_title)
    if length(rows_title) < r
        warning('MATLAB:ambiguousSyntax','rows_title didn''t have the same number of elements of the number of rows of var!\n\t Remaining rows title set to ""!');
        for i = (length(rows_title)+1):r
            rows_title = [rows_title; ' ']
        end
    end
    var = [rows_title' var];
    dec = [0 dec];
    math_mode = [0 math_mode];
    c = c+1;
end


% Setting h_line
if isempty(h_line)
    h_line = zeros(1,r);
else
    if length(h_line) < r
        if length(h_line) ~= 1
            warning('MATLAB:ambiguousSyntax','Last value of h_line used for remaining rows');
            h_line = [h_line h_line(end)*ones(1,r-length(h_line))];
        else
            h_line = h_line*ones(1,r);
        end
    end
end


% Preparing to preview
Fig = figure('Visible','off');
hold on
axis off
pos = get(gcf,'Position');

% Columns width [pixels]
w = pos(3)/c;
% rows heigth [pixels]
h = pos(4)/r;

s = '';

% Creating table
for i = 1:r
    s = [s sprintf('\t')];
%     plot([-.5 -.5],[h*(r-i) h*(r-i-1)],'k','LineWidth',1.5)
    for k = 1:c
        if math_mode(k)
            math = '$';
        else
            math = '';
        end
        if ~ischar(var{i,k})
            data = ['%.' num2str(dec(k)) 'f' ];
        else
            data = '%s';
        end
        x_coord = [w*(k-1) w*(k-1) w*k w*k];
        y_coord = [h*(r-i-1) h*(r-i) h*(r-i) h*(r-i-1)];
        fill(x_coord,y_coord,'w','edgecolor','w');
        X = (x_coord(1)+x_coord(3))/2;
        Y = (y_coord(1)+y_coord(2))/2;
        data = sprintf([math data math],var{i,k});
        s = [s data];
        text(X,Y,data,'Interpreter','Latex','HorizontalAlignment','Center','VerticalAlignment','Middle');
%         plot([x_coord(3) x_coord(3)],[y_coord(3)+1 y_coord(4)+1],'k','LineWidth',1.5)
        if k == c
            s = [s  sprintf(' \\\\ ')];
            if h_line(i)
                s = [s sprintf('\\h_line ')];
                plot([0 x_coord(3)],[y_coord(1)+1 y_coord(1)+1],'k','LineWidth',1.5)
            end
            s = [s sprintf('\n')];
        else
            s = [s  sprintf(' & ')];
        end
    end
end

% top line
plot([0 w*c],[h*(r-1) h*(r-1)],'k','LineWidth',3)

s = [sprintf('\\h_line \n') s];
s = [sprintf('|*{%d}{U|}}\n',c) s];
s = [sprintf('\\begin{tabularx}{%s}{',width) s];
s = [sprintf('\\newcolumntype{U}{>{\\centering\\arraybackslash}X}\n') s];

% setting fontsize
if ~isempty(fontsize)
    s = [sprintf('%s \n',fontsize) s];
end

s = [sprintf('\n%%\n%%\t --- LATEX TABLE OUTPUT BEGIN --- \n\n') s];
s = [sprintf('\n%%\t WARNING: remember to add to latex document \n%%\t\t\\usepackage{tabularx}') s];

s = [s sprintf('\\end{tabularx}\n')];
s = [s sprintf('\n%%\t --- LATEX TABLE OUTPUT END ---\n\n\n')];

if ~isempty(file)
    fid = fopen(file,'w');
    fprintf(fid,'%s',s);
	fclose(fid);
end

if ~isempty(preview)
    set(Fig,'Visible','on')
else
    close(Fig)
end

end