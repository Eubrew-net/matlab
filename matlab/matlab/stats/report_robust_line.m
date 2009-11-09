function [h,L,stats] = robust_line
% LSLINE Add least-squares fit line to scatter plot.
%   LSLINE superimposes the least squares line on each line object
%   in the current axis (Except LineStyles '-','--','.-'.)
% 
%   H = LSLINE returns the handle to the line object(s) in H.
%   
%   See also POLYFIT, POLYVAL.   

%   B.A. Jones 2-2-95
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.1.1.1 $  $Date: 2008-05-13 14:21:41 $

lh = findobj(get(gca,'Children'),'Type','line');
if nargout == 1,
    h = [];
end
count = 0;
L=[];
stats=[];
for k = 1:length(lh)
    %k=1
    xdat = get(lh(k),'Xdata'); xdat = xdat(:);
    ydat = get(lh(k),'Ydata'); ydat = ydat(:);
    ok = ~(isnan(xdat) | isnan(ydat));
    datacolor = get(lh(k),'Color');
    style = get(lh(k),'LineStyle');
    if ~strcmp(style,'-') & ~strcmp(style,'--') & ~strcmp(style,'-.')
        count = count + 1;
        [beta,stats] = robustfit(xdat(ok,:),ydat(ok,:));
        newline = report_refline(beta(2),beta(1));
        set(newline,'Color',datacolor);
        x=get(newline,'XData');y=get(newline,'YData');
%         t=text(x(1)+1,y(end)-1,...
%         sprintf('  y=%f + %f x +/- [%f %f]',[beta,stats.se]));
%         set(t,'Color',datacolor);
        L(:,count)=[beta];       
        if nargout >= 1
            h(count) = newline;
        end
    end
end
L=fliplr(L);
if count == 0
    disp('No allowed line types found. Nothing done.');
%else 
%    %disp(L);
end

function h = report_refline(slope,intercept)
%REFLINE Add a reference line to a plot.
%   REFLINE(SLOPE,INTERCEPT) adds a line with the given SLOPE and
%   INTERCEPT to the current figure.
%
%   REFLINE(SLOPE) where SLOPE is a two element vector adds the line
%        y = SLOPE(2) + SLOPE(1)*x 
%   to the figure. (See POLYFIT.)
%
%   H = REFLINE(SLOPE,INTERCEPT) returns the handle to the line object
%   in H.
%
%   REFLINE with no input arguments superimposes the least squares line on 
%   each line object in the current figure (Except LineStyles '-','--','.-'.)
%
%   See also POLYFIT, POLYVAL.   

%   B.A. Jones 2-2-95
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.1 $  $Date: 2004/01/24 09:36:49 $

if nargin == 0
  lh = findobj(get(gca,'Children'),'Type','line');
  if nargout == 1, 
     h = [];
  end
  count = 0;
  for k = 1:length(lh)
      xdat = get(lh(k),'Xdata');
      ydat = get(lh(k),'Ydata');
      datacolor = get(lh(k),'Color');
      style = get(lh(k),'LineStyle');
      if ~strcmp(style,'-') & ~strcmp(style,'--') & ~strcmp(style,'-.')
         count = count + 1;
         beta = polyfit(xdat,ydat,1);
         newline = refline(beta);
         set(newline,'Color',datacolor);
         if nargout == 1
            h(count) = newline;    
         end
      end
   end
   if count == 0
      disp('No allowed line types found. Nothing done.');
   end
   return;
end

if nargin == 1
   if max(size(slope)) == 2
      intercept=slope(2);
      slope = slope(1);
   else
      intercept = 0;
   end
end

xlimits = get(gca,'Xlim');
ylimits = get(gca,'Ylim');

np = get(gcf,'NextPlot');
set(gcf,'NextPlot','add');

xdat = xlimits;
ydat = intercept + slope.*xdat;
maxy = max(ydat);
miny = min(ydat);

if maxy > ylimits(2)
  if miny < ylimits(1)
     set(gca,'YLim',[miny maxy]);
  else
     set(gca,'YLim',[ylimits(1) maxy]);
  end
else
  if miny < ylimits(1)
     set(gca,'YLim',[miny ylimits(2)]);
  end
end

if nargout == 1
   h = plot(xdat,ydat,'-');
%    set(h,'LineStyle','-');
else
   hh = plot(xdat,ydat,'-');
%    set(hh,'LineStyle','-');
end

set(gcf,'NextPlot',np);
