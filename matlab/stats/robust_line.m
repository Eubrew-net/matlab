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
L=[];leg={};
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
        newline = refline(beta(2),beta(1));
        set(newline,'Color',datacolor);
        x=get(newline,'XData');y=get(newline,'YData');
        leg{k}=sprintf('  y=%f + %f x +/- [%f %f]',[beta,stats.se]);
        t=text(x(1)+1,y(end)-1-10*(k-1),...
        sprintf('  y=%f + %f x +/- [%f %f]',[beta,stats.se]));
        set(t,'Color',datacolor);
        L(:,count)=[beta];       
        if nargout >= 1
            h(count) = newline;
        end
           
           
           

            
    end
end
L=fliplr(L);
if count == 0
    disp('No allowed line types found. Nothing done.');
else 
    legend(leg)
end
