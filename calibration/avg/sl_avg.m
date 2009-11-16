% alberto 24/09/2009 
%  añandido flag de depuracion;
%  TODO cuando cambia el sl durante la calibracion los toma como outlier.
%       reportar tambien los outlier    

function [sla,dx]=sl_avg(file,date_range,ref,flag_outlier)

try
 a=textread(file,'');
catch
    try
     a=read_avg_line(file);   
    catch
     disp(file);
     
     aux=lasterror;
      disp(aux.message)
      return;
    end
end
sl=avgfech(a);

if nargin>1
    try
     sla=sl(sl(:,1)>=date_range(1) & sl(:,1)<=date_range(2),:);
    catch
     disp('errror de seleccion de fecha');   
    end
    if isempty(sla)
        sla=sl;
    end
else
    sla=sl;
end

% OUTLIERS R6
if nargin>3
    if flag_outlier
        [ax,bx,cx,dx]=outliers_bp(sla(:,12),3);
        disp(sla(dx,[1,12,19]))
        sla(dx,[12,13])=NaN;
        [ax,bx,cx,dx]=outliers_bp(sla(:,13),3);
        disp(sla(dx,[1,12,19]))
        sla(dx,[12,13])=NaN;
        
        % outliers r5
        [ax,bx,cx,dx]=outliers_bp(sla(:,19),3);
        disp(sla(dx,[1,12,19]))
        sla(dx,[12,19])=NaN;
    end
end

%j=find(dta(:,4)>60 | dta(:,4)<20 | dta(:,5)>60 | dta(:,5)<20 );
%dta(j,:)=[];

num_lab=11;
labs=linspace(sla(1,1),sla(end,1),num_lab);

f=figure; set(f,'tag','SLAVG_R6')
p1=errorbard(sla(:,[1,12,19]),'ks');
set(p1,'MarkerEdgeColor','k','color','g');
set(gca,'XLim',[date_range(1)-1 date_range(2)+1]);
if nargin==3
    l=hline(ref(:,1),'r-',num2str(ref(:,1)));
end
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
ylabel('R6 {\it(Ozone)}');
title(sprintf('%s%s','Standard Lamp Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)))
grid; orient portrait 

% outliers R5
if nargin>3
    if flag_outlier

[ax,bx,cx,r5x]=outliers_bp(sla(:,11),3);
disp(sla(r5x,[1,11,18]))
sla(r5x,[11,18])=NaN;
% outliers sigma
[ax,bx,cx,r5x]=outliers_bp(sla(:,18),3);
disp(sla(r5x,[1,11,18]))
sla(r5x,[11,18])=NaN;
    end
end
f=figure; set(f,'tag','SLAVG_R5')
p1=errorbard(sla(:,[1,11,18]),'ks');
set(p1,'MarkerEdgeColor','k','color','g');
set(gca,'XLim',[date_range(1)-1 date_range(2)+1]);
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
ylabel('R5 {\it(SO2)}');
title(sprintf('%s%s','Standar Lamp Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
grid; orient portrait 


% outliers F5
[ax,bx,cx,F5x]=outliers_bp(sla(:,13),3);
disp(sla(F5x,[1,13,20]))
sla(F5x,13)=NaN;
% outliers sigma
[ax,bx,cx,F5x]=outliers_bp(sla(:,18),3);
disp(sla(F5x,[1,13,20]))
sla(F5x,[13,20])=NaN;

f=figure; set(f,'tag','SLAVG_F5')
p1=errorbard(sla(:,[1,13,20]),'ks');  
set(p1,'MarkerEdgeColor','k','color','g');
set(gca,'XLim',[date_range(1)-1 date_range(2)+1]);
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
ylabel('F5');
title(sprintf('%s%s','Standar Lamp Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
grid; orient portrait 
  
% subplot(2,2,4);
   temp=mean(sla(:,4:5),2);
%   p1=plot(temp,sla(:,12),'s');hold on;
%   legend(p1,'{\bfTemp cº}',2);
%   xlabel('{\bfTemperature}','FontSize',11,'FontWeight','normal');
%   ylabel('{\bfR6}','FontSize',11,'FontWeight','normal');
%   %datetick('x',12,'keepticks','keeplimits');
%   grid
  
f=figure;
set(f,'tag','SL_TEMP');

hold on
try
 h=gscatter(temp,sla(:,12),{year(sla(:,1)),month(sla(:,1))},'','.ox+sp',10,'on');%5+(1:12) 
 set(gca,'FontSize',11,'FontWeight','Bold','GridLineStyle','-.'); 
 text=findobj(gcf,'Type','Text');  %set(text(end),'FontWeight','bold');
 xlabel('Temperature','FontSize',12,'FontWeight','bold');
 ylabel('R6','FontSize',12,'FontWeight','bold');
 title(sprintf('%s%s','Standard Lamp Test by month, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)),...
                      'FontSize',12,'FontWeight','bold');
 set(findobj(gcf,'Tag','legend'),'Location','Best');
 grid; box on;
catch  
 disp('mensual plot error');
 disp(file);
end
%   try
%      r_norm_line;
%   catch
%     disp('');
%   end          
%   

  
%  ylabel('Time 10^-^9 seconds');
%  xlabel('Date');
  
%   if nargin>2
%       p3=hline(ref.*1e9,'r-',num2str(ref));
%       legend([p1,p2,p3],'dt high','dt low','ref',0);
%   end

