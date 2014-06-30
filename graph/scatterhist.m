function h = scatterhist(x,y,nbins)
%SCATTERHIST 2D scatter plot with marginal histograms.
%   SCATTERHIST(X,Y) creates a 2D scatterplot of the data in the vectors X
%   and Y, and puts a univariate histogram on the horizontal and vertical
%   axes of the plot.  X and Y must be the same length.
%
%   SCATTERHIST(X,Y,NBINS) also accepts a two-element vector specifying
%   the number of bins for the X and Y histograms.  The default is to
%   compute the number of bins using Scott's rule based on the sample
%   standard deviation.
%
%   Any NaN values in either X or Y are treated as missing data, and are
%   removed from both X and Y.  Therefore the plots reflect points for
%   which neither X nor Y has a missing value.
%
%   Use the data cursor to read precise values and observation numbers 
%   from the plot.
%
%   H = SCATTERHIST(...) returns a vector of three axes handles for the
%   scatterplot, the histogram along the horizontal axis, and the histogram
%   along the vertical axis, respectively.
%
%   Example:
%      Independent normal and lognormal random samples
%         x = randn(1000,1);
%         y = exp(.5*randn(1000,1));
%         scatterhist(x,y)
%      Marginal uniform samples that are not independent
%         u = copularnd('Gaussian',.8,1000);
%         scatterhist(u(:,1),u(:,2))
%      Mixed discrete and continuous data
%         cars = load('carsmall');
%         scatterhist(cars.Weight,cars.Cylinders,[10 3])

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/02/29 13:12:27 $

% Check inputs
error(nargchk(2, 3, nargin, 'struct'))

if ~isvector(x) || ~isnumeric(x) || ~isvector(y) || ~isnumeric(y)
    error('stats:scatterhist:BadXY', ...
          'Both X and Y must be numeric vectors.');
end
if numel(x)~=numel(y)
    error('stats:scatterhist:BadXY','X and Y must have the same length.');
end
x = x(:);
y = y(:);
obsinds = 1:numel(x);
t = isnan(x) | isnan(y);
if any(t)
    x(t) = [];
    y(t) = [];
    obsinds(t) = [];
end

if nargin < 3 || isempty(nbins)
    % By default use the number of bins given by Scott's rule
    xctrs = dfhistbins(x);
    yctrs = dfhistbins(y);
    if length(xctrs)<2
        xctrs = 1;  % bin count 1 for constant data
    end
    if length(yctrs)<2
        yctrs = 1;
    end
elseif ~isnumeric(nbins) || numel(nbins)~=2 || ...
       any(nbins<=0)     || any(nbins~=round(nbins))
    error('stats:scatterhist:BadBins',...
          'NBINS must be a vector of two positive integers.');
else
    xctrs = nbins(1); % use nbins in place of bin centers
    yctrs = nbins(2);
end

% Create the histogram information
[nx,cx] = hist(x,xctrs);
if length(cx)>1
    dx = diff(cx(1:2));
else
    dx = 1;
end
xlim = [cx(1)-dx cx(end)+dx];

[ny,cy] = hist(y,yctrs);
if length(cy)>1
    dy = diff(cy(1:2));
else
    dy = 1;
end
ylim = [cy(1)-dy cy(end)+dy];

yoff = 0;
if prod(ylim)<0, yoff = min(y)*2; end

% Put up the plots in preliminary positions
clf
hScatter = subplot(2,2,2);
hScatterline = plot(x,y,'o'); 
axis([xlim ylim]);
xlabel('x'); ylabel('y');

hHistX = subplot(2,2,4);
bar(cx,-nx,1);
if nx==0
    nx = 1;
end
axis([xlim, -max(nx), 0]);
axis('off');

hHistY = subplot(2,2,1);
barh(cy-yoff,-ny,1); 
if ny==0
    ny = 1;
end
axis([-max(ny), 0, ylim-yoff]); 
axis('off');

% Make scatter plot bigger, histograms smaller
set(hScatter,'Position',[0.35 0.35 0.55 0.55],'tag','scatter');
set(hHistX,'Position',[.35 .1 .55 .15],'tag','xhist');
set(hHistY,'Position',[.1 .35 .15 .55],'tag','yhist');

colormap([.8 .8 1]); % more pleasing histogram fill color

% Attach custom datatips
hB = hggetbehavior(hScatterline,'datacursor');
set(hB,'UpdateFcn',@scatterhistDatatipCallback);
setappdata(hScatterline,'obsinds',obsinds);


% Leave scatter plot as current axes
set(get(hScatter,'parent'),'CurrentAxes',hScatter);

if nargout>0
    h = [hScatter hHistX hHistY];
end

% -----------------------------
function datatipTxt = scatterhistDatatipCallback(obj,evt)

target = get(evt,'Target');
ind = get(evt,'DataIndex');
pos = get(evt,'Position');

obsinds = getappdata(target,'obsinds');
obsind = obsinds(ind);

datatipTxt = {...
    ['x: ' num2str(pos(1))]...
    ['y: ' num2str(pos(2))]...
    ''...
    ['Observation: ' num2str(obsind)]...
    };


function [centers,edges] = dfhistbins(data,cens,freq,binInfo,F,x)
%DFHISTBINS Compute bin centers for a histogram
%   [CENTERS,EDGES] = DFHISTBINS(DATA,CENS,FREQ,BININFO,F,X) computes
%   histogram bin centers and edges for the rule specified in BININFO.  For
%   the Freedman-Diaconis rule, DFHISTBINS uses the empirical distribution
%   function F evaluated at the values X to compute the IQR.  When there is
%   censoring, DFHISTBINS cannot compute the Scott rule, and F-D is
%   substituted.
%
%   This function is called by SCATTERHIST with just one argument.

%   $Revision: 1.1.6.5 $  $Date: 2006/11/11 22:57:30 $
%   Copyright 2001-2006 The MathWorks, Inc.

xmin = min(data);
xmax = max(data);
xrange = xmax - xmin;

if nargin<2
    cens = [];
end
if nargin<3
    freq = [];
end

if isempty(freq)
    n = length(data);
else
    n = sum(freq);
end

if nargin>=4
    rule = binInfo.rule;
else
    rule = 2;
end

% Can't compute the variance for the Scott rule when there is censoring,
% use F-D instead.
if (rule == 2) && ~isempty(cens) && any(cens)
    rule = 1; % Freedman-Diaconis
end

switch rule
case 1 % Freedman-Diaconis
    % Get "quartiles", which may not actually be the 25th and 75th points
    % if there is a great deal of censoring, and compute the IQR.
    iqr = diff(interp1q([F;1], [x;x(end)], [.25; .75]));
    
    % Guard against too small an IQR.  This may be because most
    % observations are censored, or because there are some extreme
    % outliers.
    if iqr < xrange ./ 10
        iqr = xrange ./ 10;
    end

    % Compute the bin width proposed by Freedman and Diaconis, and the
    % number of bins needed to span the data.  Use approximately that
    % many bins, placed at nice locations.
    [centers,edges] = binpicker(xmin, xmax, 'FD', n, iqr);

case 2 % Scott
    if isempty(freq)
        s = sqrt(var(data));
    else
        s = sqrt(var(data,freq));
    end

    % Compute the bin width proposed by Scott, and the number of bins
    % needed to span the data.  Use approximately that many bins,
    % placed at nice locations.
    [centers,edges] = binpicker(xmin, xmax, 'Scott', n, s);

case 3 % number of bins given
    % Do not create more than 1000 bins.
    [centers,edges] = binpicker(xmin, xmax, min(binInfo.nbins,1000));
    
case 4 % bins centered on integers
    xscale = max(abs([xmin xmax]));
    % If there'd be more than 1000 bins, center them on an appropriate
    % power of 10 instead.
    if xrange > 1000
        step = 10^ceil(log10(xrange/1000));
        xmin = step*round(xmin/step); % make the edges bin width multiples
        xmax = step*round(xmax/step);
        
    % If a bin width of 1 is effectively zero relative to the magnitude of
    % the endpoints, use a bigger power of 10.
    elseif xscale*eps > 1;
        step = 10^ceil(log10(xscale*eps));
        
    else
        step = 1;
    end
    centers = floor(xmin):step:ceil(xmax);
    edges = (floor(xmin)-.5*step):step:(ceil(xmax)+.5*step);
    
case 5 % bin width given
    % Do not create more than 1000 bins.
    binWidth = max(binInfo.width, xrange/1000);
    if (binInfo.placementRule == 1) % automatic placement: anchored at zero
        anchor = 0;
    else % anchored
        anchor = binInfo.anchor;
    end
    leftEdge = anchor + binWidth*floor((xmin-anchor) ./ binWidth);
    nbins = max(1,ceil((xmax-leftEdge) ./ binWidth));
    edges = leftEdge + (0:nbins) .* binWidth; % get exact multiples
    centers = edges(2:end) - 0.5 .* binWidth;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [centers,edges] = binpicker(xmin, xmax, nbins, nobs, extraArg)
%BINPICKER Generate pleasant bin locations for a histogram.
%   CENTERS = BINPICKER(XMIN,XMAX,NBINS) computes centers for histogram
%   bins spanning the range XMIN to XMAX, with extremes of the bins at
%   locations that are a multiple of 1, 2, 3, or 5 times a power of 10.
%
%   CENTERS = BINPICKER(XMIN,XMAX,'FD',N,IQR) uses the Freedman-Diaconis
%   rule for bin width to compute the number of bins.  N is the number of
%   data points, and IQR is the sample interquartile range of the data.
%
%   CENTERS = BINPICKER(XMIN,XMAX,'Scott',N,STD) uses Scott's rule for the
%   bin width to compute the number of bins.  N is the number of data
%   points, and STD is the sample standard deviation of the data.  Scott's
%   rule is appropriate for "normal-like" data.
%
%   CENTERS = BINPICKER(XMIN,XMAX,'Sturges',N) uses Sturges' rule for the
%   number of bins.  N is the number of data points.  Sturges' rule tends
%   to give fewer bins than either F-D or Scott.
%
%   For the Freedman-Diaconis, Scott's, or Sturges' rules, BINPICKER
%   automatically generates "nice" bin locations, where the bin width is 1,
%   2, 3, or 5 times a power of 10, and the bin edges fall on multiples of
%   the bin width.  Thus, the actual number of bins will often differ
%   somewhat from the number defined by the requested rule.
%
%   [CENTERS,EDGES] = BINPICKER(...) also returns the bin edges.

%   References:
%      [1] Freedman, D. and P. Diaconis (1981) "On the histogram as a
%          density estimator: L_2 theory", Zeitschrift fur
%          Wahrscheinlichkeitstheorie und verwandte Gebiete, 57:453–476.
%      [2] Scott, D.W. (1979) "On optimal and data-based histograms",
%          Biometrika, 66:605-610.
%      [3] Sturges, H.A. (1926) "The choice of a class interval",
%          J.Am.Stat.Assoc., 21:65-66.

if nargin < 3
    error('stats:binpicker:TooFewInputs', ...
          'Requires at least three inputs.');
elseif xmax < xmin
    error('stats:binpicker:MaxLessThanMin', ...
          'XMAX must be greater than or equal to XMIN.');
end

% Bin width rule specified
if ischar(nbins)
    ruleNames = ['fd     '; 'scott  '; 'sturges'];
    rule = strmatch(lower(nbins),ruleNames); % 1, 2, or 3
    if isempty(rule)
        error('stats:binpicker:UnknownRule', ...
              'RULE must be one of ''FD'', ''Scott'', or ''Sturges''.');
    elseif nobs < 1
        nbins = 1; % give 1 bin for zero-length data
        rule = 0;
    end

% Number of bins specified
else
    if nbins < 1 || round(nbins) ~= nbins
        error('stats:binpicker:NegativeNumBins', ...
            'NBINS must be a positive integer.');
    end
    rule = 0;
end

xscale = max(abs([xmin,xmax]));
xrange = xmax - xmin;

switch rule
case 1 % Freedman-Diaconis rule
    % Use the interquartile range to compute the bin width proposed by
    % Freedman and Diaconis, and the number of bins needed to span the
    % data.  Use approximately that many bins, placed at nice
    % locations.
    iqr = extraArg;
    rawBinWidth = 2*iqr ./ nobs.^(1/3);

case 2 % Scott's rule
    % Compute the bin width proposed by Scott, and the number of bins
    % needed to span the data.  Use approximately that many bins,
    % placed at nice locations.
    s = extraArg;
    rawBinWidth = 3.49*s ./ nobs.^(1/3);

case 3 % Sturges' rule for nbins
    nbins = 1 + log2(nobs);
    rawBinWidth = xrange ./ nbins;

otherwise % number of bins specified
    rawBinWidth = xrange ./ nbins;
end

% Make sure the bin width is not effectively zero.  Otherwise it will never
% amount to anything, which is what we knew all along.
rawBinWidth = max(rawBinWidth, eps*xscale);
% it may _still_ be zero, if data are all zeroes

% If the data are not constant, place the bins at "nice" locations
if xrange > max(sqrt(eps)*xscale, realmin)
    % Choose the bin width as a "nice" value.
    powOfTen = 10.^floor(log10(rawBinWidth)); % next lower power of 10
    relSize = rawBinWidth ./ powOfTen; % guaranteed in [1, 10)
    if  relSize < 1.5
        binWidth = 1*powOfTen;
    elseif relSize < 2.5
        binWidth = 2*powOfTen;
    elseif relSize < 4
        binWidth = 3*powOfTen;
    elseif relSize < 7.5
        binWidth = 5*powOfTen;
    else
        binWidth = 10*powOfTen;
    end

    % Automatic rule specified
    if rule > 0
        % Put the bin edges at multiples of the bin width, covering x.  The
        % actual number of bins used may not be exactly equal to the requested
        % rule. Always use at least two bins.
        leftEdge = min(binWidth*floor(xmin ./ binWidth), xmin);
        nbinsActual = max(2, ceil((xmax-leftEdge) ./ binWidth));
        rightEdge = max(leftEdge + nbinsActual.*binWidth, xmax);

    % Number of bins specified
    else
        % Put the extreme bin edges at multiples of the bin width, covering x.
        % Then recompute the bin width to make the actual number of bins used
        % exactly equal to the requested number.
        leftEdge = min(binWidth*floor(xmin ./ binWidth), xmin);
        rightEdge = max(binWidth*ceil(xmax ./ binWidth), xmax);
        binWidth = (rightEdge - leftEdge) ./ nbins;
        nbinsActual = nbins;
    end

else % the data are nearly constant
    % For automatic rules, use a single bin.
    if rule > 0
        nbins = 1;
    end
    
    % There's no way to know what scale the caller has in mind, just create
    % something simple that covers the data.
    if xscale > realmin
        % Make the bins cover a unit width, or as small an integer width as
        % possible without the individual bin width being zero relative to
        % xscale.  Put the left edge on an integer or half integer below
        % xmin, with the data in the middle 50% of the bin.  Put the left
        % edge similarly above xmax.
        binRange = max(1, ceil(nbins*eps*xscale));
        leftEdge = floor(2*(xmin-binRange./4))/2;
        rightEdge = ceil(2*(xmax+binRange./4))/2;
    else
        leftEdge = -0.5;
        rightEdge = 0.5;
    end
    binWidth = (rightEdge - leftEdge) ./ nbins;
    nbinsActual = nbins;
end

edges = [leftEdge + (0:nbinsActual-1).*binWidth, rightEdge];
centers = edges(2:end) - 0.5 .* binWidth;
