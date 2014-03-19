%   Alberto 24/09/2009
%  añandido flag de depuracion;
%  TODO cuando cambia el sl durante la calibracion los toma como outlier.
%       reportar tambien los outlier
%% Modificaciones
%  27.05.10 Isabel. Cambio el color de las lineas (antiguo rojo, nuevo cian)
%                       hline(ref(1),'c-',num2str(ref(1)));
%                       hline(ref(2),'r-',num2str(ref(2)));
% 28/10/2010 Isabel  Comentados:
%     disp('OUTLIERS R6');
%     disp(datestr(sla(dx,1)))
%     disp('OUTLIERS R6, sigma');
%     disp(datestr(sla(dx,1)))
%     disp('OUTLIERS F5');
%     disp(datestr(sla(F5x,1)))
%     disp('OUTLIERS F5, sigma');
%     disp(datestr(sla(F5x,1)))
%     disp('OUTLIERS R5');
%     disp(datestr(sla(r5x,1)))
%     [ax,bx,cx,r5x]=outliers_bp(sla(:,18),3);
%     disp('OUTLIERS R5, sigma');

% 12/11/2010 Isabel  Introducido nuevo output para los outliers.
% 18/02/2013 Juanjo  Añadida regression para R5 vs Temp.

%%
function [sla,OutR6R5F5]=sl_avg(file,date_range,ref,outlier_flag)

try
    a=textread(file,'');
catch
    try
        a=read_avg_line(file,18);
    catch
        disp(file);
        aux=lasterror;
        disp(aux.message)
        return;
    end
end
sl=avgfech(a);
if ~isempty(date_range)
    try
        sla=sl(sl(:,1)>date_range(1),:);
        if length(date_range)>1
            sla=sla(sla(:,1)<date_range(2),:);
        end
    catch
        disp('errror de seleccion de fecha');
    end
    if isempty(sla)
        sla=sl;
    end
else
    sla=sl;
end

%% DEPURACIÖN DE OUTLIERS
if ~isempty(outlier_flag)
    % Outliers R6
    [ax,bx,cx,dx1]=outliers_bp(sla(:,12),3.5);    
     outR6=sla(dx1,[1:3 12 19]);  sla(dx1,[12,19])=NaN;
    % Outliers sigma
    [ax,bx,cx,dx2]=outliers_bp(sla(:,19),5); 
     outR6_sig=sla(dx2,[1:3 12 19]);  sla(dx2,[12,19])=NaN;

    % Outliers R5
    [ax,bx,cx,r5x1]=outliers_bp(sla(:,11),3.5);    
     outR5=sla(r5x1,[1:3 11 18]);  sla(r5x1,[11,18])=NaN;
    % Outliers sigma
    [ax,bx,cx,r5x2]=outliers_bp(sla(:,18),5);    
     outR5_sig=sla(r5x2,[1:3 11 18]);  sla(r5x2,[11,18])=NaN;

    % Outliers F5
    [ax,bx,cx,F5x1]=outliers_bp(sla(:,13),20);     
     outF5=sla(F5x1,[1:3 13 20]);      sla(F5x1,[13,20])=NaN;
    % Outliers sigma
    [ax,bx,cx,F5x2]=outliers_bp(sla(:,20),6);     
     outF5_sig=sla(F5x2,[1:3 13 20]);  sla(F5x2,[13,20])=NaN;

    %   Tabla     
    outR6_=outR6; outR6_(:,6)=6;
    outR5_=outR5; outR5_(:,6)=5;
    outF5_=outF5; outF5_(:,6)=20;

    OutR6R5F5_=sortrows(cat(1,outR6_,outR5_,outF5_));
    [a b c]=unique(OutR6R5F5_(:,1),'first');
    OutR6R5F5=NaN*ones(length(a),size(OutR6R5F5_,2)+3);
    OutR6R5F5(:,1:3)=OutR6R5F5_(b,1:3);

    %    vamos colocando
    for j=1:length(c)
        param=OutR6R5F5_(j,end);
        switch param
            case 5 % R5
               OutR6R5F5(c(j),[6,7])=OutR6R5F5_(j,[4,5]);
            case 6 %R6
               OutR6R5F5(c(j),[4,5])=OutR6R5F5_(j,[4,5]);
            case 20 %F5
               OutR6R5F5(c(j),[8,9])=OutR6R5F5_(j,[4,5]);
        end
    end
else
    OutR6R5F5=NaN*ones(1,9);  OutR6R5F5(1)=fix(now);
end
    
%% SLOAVG ploteos
% R6 plot
num_lab=11;  
labs=linspace(sla(1,1),sla(end,1),num_lab);
f=figure; set(f,'tag','SLAVG_R6');
p1=errorbard(sla(:,[1,12,19]),'ks');
set(p1,'MarkerEdgeColor','k','color','g');
set(gca,'XLim',[date_range(1)-1 sla(end,1)+4]);
if length(ref)==2
    hline(ref(1),'r-',num2str(ref(1)));
    hline(ref(2),'c-',num2str(ref(2)));
else
    hline(ref(1),'g-',num2str(ref(1)));
end
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
ylabel('R6 {\it(Ozone)}','FontWeight','bold');
T=title(sprintf('%s%s','Standard Lamp Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(T,'FontWeight','bold');
grid; orient portrait
if ~isempty(OutR6R5F5)    
    idx=OutR6R5F5(:,4)<mean(sl(:,12))+std(sl(:,12))*2 & OutR6R5F5(:,4)>mean(sl(:,12))-std(sl(:,12))*2;
    hold on; plot(OutR6R5F5(idx,1),OutR6R5F5(idx,4),'sg','MarkerFaceColor','r');
end
datetick('x',25,'keeplimits','keepticks');         rotateticklabel(gca,20);

% R5 plot
f=figure; set(f,'tag','SLAVG_R5')
p1=errorbard(sla(:,[1,11,18]),'ks');
set(p1,'MarkerEdgeColor','k','color','g');
set(gca,'XLim',[date_range(1)-1 sla(end,1)+4]);
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
ylabel('R5 {\it(SO2)}','FontWeight','bold');
title(sprintf('%s%s','Standar Lamp Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)),'FontWeight','bold');
grid; orient portrait
if ~isempty(OutR6R5F5)
    idx=OutR6R5F5(:,6)<mean(sl(:,11))+std(sl(:,11))*2 & OutR6R5F5(:,6)>mean(sl(:,11))-std(sl(:,11))*2;
    hold on; plot(OutR6R5F5(idx,1),OutR6R5F5(idx,6),'sg','MarkerFaceColor','r');
end
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);

% F5 plot
f=figure; set(f,'tag','SLAVG_F5')
p1=errorbard(sla(:,[1,13,20]),'ks');
set(p1,'MarkerEdgeColor','k','color','g');
set(gca,'XLim',[date_range(1)-1 sla(end,1)+4]);
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
ylabel('F5','FontWeight','bold');
title(sprintf('%s%s','Standar Lamp Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)),'FontWeight','bold');
grid; orient portrait
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);

% subplot(2,2,4);
temp=mean(sla(:,4:5),2);
%   p1=plot(temp,sla(:,12),'s');hold on;
%   legend(p1,'{\bfTemp cº}',2);
%   xlabel('{\bfTemperature}','FontSize',11,'FontWeight','normal');
%   ylabel('{\bfR6}','FontSize',11,'FontWeight','normal');
%   %datetick('x',12,'keepticks','keeplimits');
%   grid

f=figure; set(f,'tag','SL_TEMP');
try
    ha=tight_subplot(2,1,.05,[.1 .1],[.1,.1]);   
    
    axes(ha(1)); plot(temp,sla(:,12),'.'); hold on; 
    rl=rline; set(rl,'LineWidth',2);
    set(findobj(gca,'Type','Text'),'BackgroundColor','w','Color','r','FontSize',10,'FontWeight','Bold');
    set(findobj(gca,'Marker','.'),'Marker','None');
    gscatter(temp,sla(:,12),{year(sla(:,1)),month(sla(:,1))},'','.ox+sp',10,'off');
    set(gca,'FontSize',11,'FontWeight','Bold','GridLineStyle','-.','XtickLabel',[]);
    xlabel('');    ylabel('R6','FontSize',12,'FontWeight','bold');
    title(sprintf('%s%s','Standard Lamp Tests by month, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)),...
        'FontSize',12,'FontWeight','bold');    grid; box on;       
    
    axes(ha(2)); plot(temp,sla(:,11),'.'); hold on; 
    rl=rline; set(rl,'LineWidth',2);
    set(findobj(gca,'Type','Text'),'BackgroundColor','w','Color','r','FontSize',10,'FontWeight','Bold');
    set(findobj(gca,'Marker','.'),'Marker','None');
    gscatter(temp,sla(:,11),{year(sla(:,1)),month(sla(:,1))},'','.ox+sp',10,'on');%5+(1:12)
    set(gca,'FontSize',11,'FontWeight','Bold','GridLineStyle','-.');
    xlabel('Temperature','FontSize',12,'FontWeight','bold');    ylabel('R5','FontSize',12,'FontWeight','bold');
    set(findobj(gcf,'Tag','legend'),'FontSize',7);    grid; box on;   linkprop(ha,'XLim');
     
catch exception
      fprintf('%s in File %s',exception.message,file);
end

%% Outliers
% format short
% Jul=(([001:365]')*100)+10;                Fecha=brewer_date(Jul);
% MFecha=Fecha(:,1);                        FechaAnual=datestr(MFecha);
% OutliersR6   =[Fecha(:,1)]; OutliersR6 (:,end)=0;  try for i=1:size(dx1,1);  O1=find(Fecha(:,1)==sla(dx1(i),1));  OutliersR6 (O1,:) =NaN; end; end
% OutliersSR6  =[Fecha(:,1)]; OutliersSR6(:,end)=0;  try for i=1:size(dx2,1);  O2=find(Fecha(:,1)==sla(dx2(i),1));  OutliersSR6(O2,:) =NaN; end; end
% OutliersF5   =[Fecha(:,1)]; OutliersF5 (:,end)=0;  try for i=1:size(F5x1,1); O3=find(Fecha(:,1)==sla(F5x1(i),1)); OutliersF5 (O3,:) =NaN; end; end
% OutliersSF5  =[Fecha(:,1)]; OutliersSF5(:,end)=0;  try for i=1:size(F5x2,1); O4=find(Fecha(:,1)==sla(F5x2(i),1)); OutliersSF5(O4,:) =NaN; end; end
% OutliersR5   =[Fecha(:,1)]; OutliersR5 (:,end)=0;  try for i=1:size(r5x1,1); O5=find(Fecha(:,1)==sla(r5x1(i),1)); OutliersR5 (O5,:) =NaN; end; end
% OutliersSR5  =[Fecha(:,1)]; OutliersSR5(:,end)=0;  try for i=1:size(r5x2,1); O6=find(Fecha(:,1)==sla(r5x2(i),1)); OutliersSR5(O6,:) =NaN; end; end
% OutR6F5R5    =[Fecha OutliersR6 OutliersSR6  OutliersF5  OutliersSF5  OutliersR5  OutliersSR5];
% 
