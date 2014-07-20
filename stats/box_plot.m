function [z,hl,hb] = box_plot(varargin)
% Draw a box plot with arbitrary box spacing
% 
%   box_plot(y)
%   box_plot(x,y)
%   box_plot(...,'parameter',value)
%   z = box_plot(...)
%   [z,hl,hb] = box_plot(...)
% 
%   BOX_PLOT(Y) produces a box plot of the data in Y. If Y
%   is a vector, there is just one box; if Y is a matrix,
%   there is one box per column; if Y is an N-by-P-by-G
%   array then G boxes are plotted for each column P. For
%   each box, the central mark is the median of the
%   data/column, the edges of the box are the 25th and 75th
%   percentiles, the whiskers extend to the most extreme
%   data points not considered outliers, and outliers are
%   plotted individually. NaNs are excluded from the data.
% 
%   BOX_PLOT(X,Y) specifies the x-axis values for each box.
%   X should be a vector, with as many elements as Y has
%   columns. The default is 1:SIZE(Y,2).
%   
%   BOX_PLOT(...,'PARAMETER',VALUE) allows the appearance of
%   the plot to be configured. See below for a full list of
%   parameters.
% 
%   Z = BOX_PLOT(...) returns a structure Z containing the
%   statistics used for the box plot. With the exception of
%   'outliers' and 'outliers_IX' noted below, each field
%   contains a 1-by-P-by-G numeric array of values
%   (identical to that returned by QUANTILE2). The fields
%   are:
%       'median'        : the median values
%       'N'             : the sample size
%       'Q1'            : the 25th percentiles
%       'Q3'            : the 75th percentiles
%       'IQR'           : the inter-quartile ranges
%       'min'           : the minimum values (excl.
%                         outliers)
%       'max'           : the maximum values (excl.
%                         outliers)
%       'notch_u'       : the upper notch values
%       'notch_l'       : the lower notch values
%       'outliers'      : a 1-by-P-by-G cell array of
%                         outlier values
%       'outliers_IX'   : a logical array, the same size as
%                         Y, with true values indicating
%                         outliers
% 
%   [Z,HL,HB] = BOX_PLOT(...) returns a 1-by-P-by-G array of
%   handles (one for each box) for median lines (HL) and
%   boxes (HB).
% 
%   The parameters BOX_PLOT accepts are:
% 
%   ({} indicates the default value)
% 
%   'boxColor'          : ColorSpec | 'auto' | {'none'}
%       Fill color of the box; 'auto' means that Matlab's
%       default colors are used.
%   'boxSpacing'        : scalar | {'auto'}
%       The spacing of boxes within a group. When set to a
%       scalar, the spacing is in x-axis units. When set to
%       'auto', the spacing is calculated automatically.
%   'boxWidth'          : scalar | {'auto'}
%       The width of the box. When set to a scalar, the box
%       width is in x-axis units. When set to 'auto', the
%       width is calculated automatically.
%   'limit'             : {'1.5IQR'} | '3IQR' |'none'
%       Mode indicating the limits that define outliers.
%       When set to '1.5IQR', the min and max values are
%       Q1-1.5*IQR and Q3+1.5*IQR respectively. When set to
%       'none', the min and max values are the min and max
%       of the data (in this case there will be no
%       outliers).
%   'lineColor'         : ColorSpec {'k'} | 'auto'
%       color of the box outline and whiskers.
%   'lineStyle'         : {-} | -- | : | -. | none
%       Style of the whisker line.
%   'lineWidth'         : Scalar {1}
%       Width, in points, of the box outline, whisker lines,
%       notch line, and outlier marker edges.
%   'medianColor'       : ColorSpec | {'auto'}
%       color of the median line.
%   'method'            : 'R-1' | 'R-2' | 'R-3' | 'R-4' | 
%                         'R-5' | 'R-6' | 'R-7' | {'R-8'} |
%                         'R-9'
%       The method used to calculate the quantiles, labelled
%       according to http://en.wikipedia.org/wiki/Quantile.
%       Although the default is 'R-8', the default for 
%       Matlab is 'R-5'.
%   'notch'             : true | {false}
%       Add a notch to the box. The notch is centred on the
%       median and extends to ±1.58*IQR/sqrt(N), where N is
%       the sample size (number of non-NaN rows in Y).
%       Generally if the notches of two boxes do not
%       overlap, this is evidence of a statistically
%       significant difference between the medians.
%   'notchDepth'        : Scalar {0.4}
%       Depth of the notch as a proportion of half the box
%       width.
%   'notchLine'         : true | {false}
%       Choose whether to draw a horizontal line in the box
%       at the extremes of the notch. (May be specified
%       indpendently of 'notch'.)
%   'notchLineColor'    : ColorSpec {'k'} | 'auto'
%       color of the notch line.
%   'notchLineStyle'    : - | -- | {:} | -. | none
%       Line style of the notch line.
%   'outlierSize'       : Scalar {36}
%       Size, in square points, of the outlier marker.
%   'symbolColor'       : ColorSpec | {'auto'}
%       Outlier marker color.
%   'symbolMarker'      : '+' | {'o'} | '*' | '.' | 'x' |
%                         'square' or 's' | 'diamond' or 'd'
%                         | '^' | 'v' | '>' | '<' |
%                         'pentagram' or 'p' | 'hexagram' or
%                         'h' | 'none'
%       Marker used to denote outliers.
% 
%   In addition to the above specifications, some options
%   can be specified for each group G. Parameters can be
%   specified as a cell array of length G for string or
%   numeric parameters, or a G-by-A numeric array for
%   numeric parameters where A=1 for scalars or A=3 for
%   colors. These options are: 'boxColor', 'lineColor',
%   'lineStyle', 'lineWidth', 'medianColor',
%   'notchLineColor', 'notchLineStyle', 'outlierSize',
%   'symbolColor', 'symbolMarker'.
% 
%   Example
% 
%   % Grouped box plots
%   
%   y = randn(100,6,3);
%   x = 1:size(y,2);
%   figure; hold on
%   [~,hl] = box_plot(x,y,'symbolMarker',{'o','+','s'},...
%       'notch',true);
%   box on
%   legend(squeeze(hl(:,1,:)),{'y1','y2','y3'})
% 
%   See also BOXPLOT, QUANTILE2.

% !---
% ==========================================================
% Last changed:     $Date: 2014-05-12 17:42:10 +0100 (Mon, 12 May 2014) $
% Last committed:   $Revision: 294 $
% Last changed by:  $Author: ch0022 $
% ==========================================================
% !---

%% Initial checks and styles

% check for input data
if nargin > 1
    if isnumeric(varargin{2})
        x = varargin{1};
        y = varargin{2};
        if isvector(y) % ensure y is column vector
            y = y(:);
        end
        start = 3;
    else
        y = varargin{1};
        if isvector(y) % ensure y is column vector
            y = y(:);
        end
        x = 1:size(y,2);
        start = 2;
    end
else
    y = varargin{1};
    if isvector(y) % ensure y is column vector
        y = y(:);
    end
    x = 1:size(y,2);
    start = 1;
end

if size(y,1)==1
    error('Boxes are plotted for each column. Each column in the input has only one data point.')
end

% size of input
nCols = size(y,2);
nGroups = size(y,3);

% default style options
options = struct(...
    'boxColor','none',...
    'boxSpacing','auto',...
    'boxWidth','auto',...
    'limit','1.5IQR',...
    'lineColor','k',...
    'lineStyle','-',...
    'lineWidth',1,...
    'medianColor','auto',...
    'method','R-8',...
    'notch',false,...
    'notchDepth',0.4,...
    'notchLine',false,...
    'notchLineStyle',':',...
    'notchLineColor','k',...
    'outlierSize',6^2,...
    'symbolColor','auto',...
    'symbolMarker','o');

% read parameter/value inputs
if start < nargin % if parameters are specified
    % read the acceptable names
    optionNames = fieldnames(options);
    % count arguments
    nArgs = length(varargin)-start+1;
    if round(nArgs/2)~=nArgs/2
       error('BOX_PLOT needs propertyName/propertyValue pairs')
    end
    % overwrite defults
    for pair = reshape(varargin(start:end),2,[]) % pair is {propName;propValue}
       IX = strcmpi(pair{1},optionNames); % find match parameter names
       if any(IX)
          % do the overwrite
          options.(optionNames{IX}) = pair{2};
       else
          error('%s is not a recognized parameter name',pair{1})
       end
    end
end

if isfield(options,'boxWidthMode')
    error('Sorry, ''boxWidthMode'' is no longer supported');
end

% check for auto color values and replace with true color
options.boxColor = checkAutoColor(options.boxColor,nGroups);
options.lineColor = checkAutoColor(options.lineColor,nGroups);
options.medianColor = checkAutoColor(options.medianColor,nGroups);
options.notchLineColor = checkAutoColor(options.notchLineColor,nGroups);
options.symbolColor = checkAutoColor(options.symbolColor,nGroups);

% transform parameters for each group
boxColor = groupOption(options.boxColor,nGroups,'boxColor');
lineColor = groupOption(options.lineColor,nGroups,'lineColor');
lineStyle = groupOption(options.lineStyle,nGroups,'lineStyle');
lineWidth = groupOption(options.lineWidth,nGroups,'lineWidth');
medianColor = groupOption(options.medianColor,nGroups,'medianColor');
notchLineColor = groupOption(options.notchLineColor,nGroups,'notchLineColor');
notchLineStyle = groupOption(options.notchLineStyle,nGroups,'notchLineStyle');
outlierSize = groupOption(options.outlierSize,nGroups,'outlierSize');
symbolColor = groupOption(options.symbolColor,nGroups,'symbolColor');
symbolMarker = groupOption(options.symbolMarker,nGroups,'symbolMarker');

%% Statistics

% check x/y data
assert(isnumeric(x),'x must be a vector');
assert(isnumeric(y),'y must be a numeric column vector or matrix');
assert(length(size(y))<=3,'y must be a numeric column vector, matrix, or 3-D array');
assert(numel(x)==size(y,2),'x must have the same number of elements as  has columns')

% calculate stats
z = struct;
z.median = quantile2(y,.5,[],options.method); % median
z.N = zeros(size(z.median)); % sample size
z.Q1 = zeros(size(z.median)); % lower quartile
z.Q3 = zeros(size(z.median)); % upper quartile
z.IQR = zeros(size(z.median)); % inter-quartile range
z.min = zeros(size(z.median)); % minimum (excluding outliers)
z.max = zeros(size(z.median)); % maximum (excluding outliers)
z.notch_u = zeros(size(z.median)); % high notch value
z.notch_l = zeros(size(z.median)); % low notch value
z.outliers = cell(size(z.median)); % outliers (defined as more than 1.5 IQRs above/below each quartile)
z.outliers_IX = false(size(y)); % outlier logical index
for g = 1:nGroups
    for n = 1:nCols
        [z.Q1(1,n,g),z.N(1,n,g)] = quantile2(y(:,n,g),0.25,[],options.method);
        z.Q3(1,n,g) = quantile2(y(:,n,g),0.75,[],options.method);
        z.IQR(1,n,g) = z.Q3(1,n,g)-z.Q1(1,n,g);
        z.notch_u(1,n,g) = z.median(1,n,g)+(1.58*z.IQR(1,n,g)/sqrt(z.N(1,n,g)));
        z.notch_l(1,n,g) = z.median(1,n,g)-(1.58*z.IQR(1,n,g)/sqrt(z.N(1,n,g)));
        switch lower(options.limit)
            case '1.5iqr'
                upper_limit = z.Q3(1,n,g)+1.5*z.IQR(1,n,g);
                lower_limit = z.Q1(1,n,g)-1.5*z.IQR(1,n,g);
            case '3iqr'
                upper_limit = z.Q3(1,n,g)+3*z.IQR(1,n,g);
                lower_limit = z.Q1(1,n,g)-3*z.IQR(1,n,g);
            case 'none'
                upper_limit = Inf;
                lower_limit = -Inf;
            otherwise
                error('Unknown ''limit'': ''%s''',options.limit)
        end
        z.outliers_IX(:,n,g) = y(:,n,g)>upper_limit | y(:,n,g)<lower_limit;
        z.min(1,n,g) = min(min(y(~z.outliers_IX(:,n,g),n,g)),z.Q1(1,n,g)); % min excl. outliers but not greater than lower quartile
        z.max(1,n,g) = max(max(y(~z.outliers_IX(:,n,g),n,g)),z.Q3(1,n,g)); % max excl. outliers but not less than upper quartile
        z.outliers{1,n,g} = y(z.outliers_IX(:,n,g),n,g);
    end
end

% check for notches extending beyond box
if (any(z.notch_u(:)>z.Q3(:)) || any(z.notch_l(:)<z.Q1(:))) && (options.notch || options.notchLine)
    warning('Notch extends beyond quartile. Try setting ''notch'' or ''notchLine'' to false') %#ok<WNTAG>
end

%% Plotting

% calculate positions for groups
diffx = min(diff(x));
if isempty(diffx)
    diffx = 1;
end
gRange = 0.7*diffx; % range on x-axis

% size of boxes
if ischar(options.boxWidth) || iscell(options.boxWidth)
    if strcmpi(options.boxWidth,'auto') || any(cellfun(@(x)(strcmpi(x,'auto')),options.boxWidth))
        boxwidth =  0.75*(gRange/nGroups);
    else
        error('Unknown boxWidth set.')
    end
else
    boxwidth = options.boxWidth;
end
halfboxwidth = boxwidth/2;

% notch depth
notchdepth = options.notchDepth*halfboxwidth;

% offset groups for x locations
if nGroups>1
    if ischar(options.boxSpacing) || iscell(options.boxSpacing)
        if strcmpi(options.boxSpacing,'auto') || any(cellfun(@(x)(strcmpi(x,'auto')),options.boxSpacing))
            gOffset = linspace((-gRange/2)+(boxwidth/2),(gRange/2)-(boxwidth/2),nGroups);
        else
            error('Unknown boxSpacing set.')
        end
    else
        gOffset = 0:options.boxSpacing:(nGroups-1)*options.boxSpacing;
        gOffset = gOffset-(((nGroups-1)*options.boxSpacing)/2);
    end
else
    gOffset = 0;
end

% plot
axis on
hold on
hl = zeros(size(z.median));
hb = zeros(size(z.median));
for g = 1:size(y,3)
    for n = 1:size(y,2)
        if options.notch % if notch requested
            % box
            p = patch([x(n)-halfboxwidth x(n)-halfboxwidth x(n)-halfboxwidth+notchdepth x(n)-halfboxwidth x(n)-halfboxwidth ...
                x(n)+halfboxwidth x(n)+halfboxwidth x(n)+halfboxwidth-notchdepth x(n)+halfboxwidth x(n)+halfboxwidth]+gOffset(g),...
                [z.Q1(1,n,g) z.notch_l(1,n,g) z.median(1,n,g) z.notch_u(1,n,g) z.Q3(1,n,g) ...
                z.Q3(1,n,g) z.notch_u(1,n,g) z.median(1,n,g) z.notch_l(1,n,g) z.Q1(1,n,g)],'w');
            % median
            l = line([x(n)-halfboxwidth+notchdepth x(n)+halfboxwidth-notchdepth]+gOffset(g),...
                [z.median(1,n,g) z.median(1,n,g)]);
        else
            % box
            p = patch([x(n)-halfboxwidth x(n)-halfboxwidth x(n)+halfboxwidth x(n)+halfboxwidth]+gOffset(g),...
                [z.Q1(1,n,g) z.Q3(1,n,g) z.Q3(1,n,g) z.Q1(1,n,g)],'w');
            % median
            l = line([x(n)-halfboxwidth x(n)+halfboxwidth]+gOffset(g),[z.median(1,n,g) z.median(1,n,g)]);
        end
        if options.notchLine % if notchLine requested
            line([x(n)-halfboxwidth x(n)+halfboxwidth]+gOffset(g),[z.notch_l(1,n,g) z.notch_l(1,n,g)],...
                'linestyle',notchLineStyle{g},'color',notchLineColor{g},...
                'linewidth',lineWidth{g})
            line([x(n)-halfboxwidth x(n)+halfboxwidth]+gOffset(g),[z.notch_u(1,n,g) z.notch_u(1,n,g)],...
                'linestyle',notchLineStyle{g},'color',notchLineColor{g},...
                'linewidth',lineWidth{g})
        end
        set(l,'linestyle','-','linewidth',lineWidth{g},'color',medianColor{g})
        set(p,'FaceColor',boxColor{g},'linewidth',lineWidth{g},...
            'EdgeColor',lineColor{g})
        % return handles
        hb(1,n,g) = p;
        hl(1,n,g) = l;
        % LQ
        line([x(n) x(n)]+gOffset(g),[z.min(1,n,g) z.Q1(1,n,g)],'linestyle',lineStyle{g},...
            'color',lineColor{g},'linewidth',lineWidth{g})
        % UQ
        line([x(n) x(n)]+gOffset(g),[z.max(1,n,g) z.Q3(1,n,g)],'linestyle',lineStyle{g},...
            'color',lineColor{g},'linewidth',lineWidth{g})
        % whisker tips
        line([x(n)-0.5*halfboxwidth x(n)+0.5*halfboxwidth]+gOffset(g),[z.min(1,n,g) z.min(1,n,g)],...
            'linestyle','-','color',lineColor{g},'linewidth',lineWidth{g})
        line([x(n)-0.5*halfboxwidth x(n)+0.5*halfboxwidth]+gOffset(g),[z.max(1,n,g) z.max(1,n,g)],...
            'linestyle','-','color',lineColor{g},'linewidth',lineWidth{g})
        % outliers
        if ~isempty(z.outliers)
            scatter(repmat(x(n)+gOffset(g),length(z.outliers{1,n,g}),1),z.outliers{1,n,g},...
                'marker',symbolMarker{g},'MarkerEdgeColor',symbolColor{g},...
                'SizeData',outlierSize{g},'linewidth',lineWidth{g})
        end
    end
end

set(gca,'xtick',x,'xlim',[min(x)-0.5*diffx max(x)+0.5*diffx])
hold off

% end of box_plot()


% ----------------------------------------------------------
% Local functions:
% ----------------------------------------------------------

% ----------------------------------------------------------
% groupOption: convert parameter to format for plotting
% ----------------------------------------------------------
function out = groupOption(option,nGroups,name)

% ensure string is cell array
if ischar(option)
    option = cellstr(option);
end

% pre-allocate output
out = cell(1,nGroups);

if iscell(option)
    % if parameter is cell array
    if length(option)==1 % repeat if only one specified
        out = repmat(option,1,nGroups);
    elseif length(option)==nGroups % put into cell array
        for n = 1:nGroups
            assert(ischar(option{n}) || size(option{n},2)==3,['Option ''' name ''' is not in the correct format.'])
            out{n} = option{n};
        end
    else
        error('Option ''%s'' is not the correct size.',name)
    end
elseif isnumeric(option)
    % if parameter is numeric array
    if size(option,1)==1 % repeat if only one specified
        for n = 1:nGroups
            out{n} = option;
        end
    elseif size(option,1)==nGroups % put into cell array
        for n = 1:nGroups
            out{n} = option(n,:);
        end
    else
        error('Option ''%s'' is not the correct size.',name)
    end
end

% ----------------------------------------------------------
% checkAutoColor: if color is 'auto', convert to RGB
% ----------------------------------------------------------
function out = checkAutoColor(color,nGroups)

out = color; % pass input to output unless...

if ~isnumeric(color) % ... string or cellstr 'auto'
    if strcmpi(char(color),'auto') || any(cellfun(@(x)(strcmpi(x,'auto')),cellstr(color)))
        out = lines(nGroups); % default colormap
    end
end

% [EOF]
