function [h,Lr] = rline(varargin)
% LSLINE Add least-squares fit line to scatter plot.
%   LSLINE superimposes the least squares line on each line object
%   in the current axis (Except LineStyles '-','--','.-'.)
% 
%   H = LSLINE returns the handle to the line object(s) in H.
%   function [h,Lr] = Lr regress lines
%
%   See also POLYFIT, POLYVAL.   

%   B.A. Jones 2-2-95
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 2.9 $  $Date: 2002/01/17 21:31:06 $

lh = findobj(get(gca,'Children'),'Type','line');
if nargout > 0, 
   h = [];
end
%if nargout > 1, 
   Lr= [];
%end

count = 0;
for k = 1:length(lh)
    xdat = get(lh(k),'Xdata'); xdat = xdat(:);
    ydat = get(lh(k),'Ydata'); ydat = ydat(:);
    ok = ~(isnan(xdat) | isnan(ydat));
    datacolor = get(lh(k),'Color');
    style = get(lh(k),'LineStyle');
    if ~strcmp(style,'-') & ~strcmp(style,'--') & ~strcmp(style,'-.')
       count = count + 1;
       [beta,i,r,rint,p] = linregress(ydat(ok,:),xdat(ok,:),0.05);
       newline = refline(beta);
       set(newline,'Color',datacolor);
       x=get(newline,'XData');y=get(newline,'YData');
       if isempty(varargin)
       t=text(x(1),y(1),sprintf('  y=%.6f x+ %.6f r=%.6f',[beta;p(1)]));
       set(t,'Color',datacolor);
       end
       if nargout > 0
           h(count) = newline;
       end
       Lr(:,count)=[beta;p(1)];
    
       
   end
end
if count == 0
   disp('No allowed line types found. Nothing done.');
end
 
 Lr=fliplr(Lr);
 if nargout<1
       disp(Lr);
       Lr=[];
 end