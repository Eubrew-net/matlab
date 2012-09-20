%  Juanjo 02/11/2009
%% Modificaciones
% añadido flag de depuracion;
% 28/10/2010 Isabel  Comentados:
%         disp('outliers HT')
%         disp(datestr(apa(dx,1)))
%         disp('outliers 5V voltage')
%         disp(datestr(apa(dx,1)))
% 12/11/2010 Isabel  Introducido nuevo output para los outliers.
%%
function [apa,OutHTSL5V]=ap_avg(file,date_range,outlier_flag)

try
    a = textscan(fopen(file,'rt'), '%f %f %f %f%*[^\n]');
    a = cell2mat(a); a(a(:,1)<100,:) = [];
catch
    try
        a=read_avg_line(file,4);
    catch
        disp(file);
        aux=lasterror; disp(aux.message); return;
    end
end
ap=avgfech(a);
if ~isempty(date_range)
    try
        apa=ap(ap(:,1)>date_range(1),:);
        if length(date_range)>1
            apa=apa(apa(:,1)<date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
    if isempty(apa)
        apa=ap;
    end
else
    apa=ap;
end

%% OUTLIERS
if ~isempty(outlier_flag)
    % outliers HT
    [ax,bx,cx,dx1]=outliers_bp(apa(:,4),3);       apa(dx1,4)=NaN;
    %         disp('outliers HT');                disp(datestr(apa(dx1,1)))
    %         disp(apa(dx1,[1,4]))
    % Outliers SL current..................................................
    [ax,bx,cx,dx2]=outliers_bp(apa(:,end),3);     apa(dx2,end)=NaN;
    %     disp('outliers SL current');                disp(datestr(apa(dx2,1)))
    %     disp(apa(dx2,[1,end]))
    % Outliers 5V voltage..................................................
    [ax,bx,cx,dx3]=outliers_bp(apa(:,5),3);       apa(dx3,5)=NaN;
    %         disp('outliers 5V voltage');        disp(datestr(apa(dx3,1)))
    %         disp(apa(dx3,[1,5]))
end
%%
f=datevec(apa(:,1));ind_lab=[];
for mm=1:8
    indx=find(f(:,2)==mm);
    if ~isempty(indx)
        ind_lab=[ind_lab;indx(1)];
    else continue
    end
end
%%
f=figure; set(f,'tag','APAVG');%apa->4,5 y 6
subplot(2,2,1)
% apa(find(apa(:,6)<1.2),6)=NaN;
plot(apa(:,1),apa(:,6),'-k.');
set(gca,'XLim',[date_range(1)-2,apa(end,1)+2]);
set(gca,'XTick',[date_range(1),date_range(1)+((apa(end,1)+2)-date_range(1))/2,(apa(end,1)+2)],...
    'XTickLabel',[date_range(1),date_range(1)+((apa(end,1)+2)-date_range(1))/2,(apa(end,1)+2)]);
set(gca,'GridLineStyle','-.','Linewidth',1);
datetick('x',12,'keeplimits','keepticks');
ylabel('SL Current {\it(A)}','FontWeight','bold');
grid;

subplot(2,2,2)
% apa(find(apa(:,5)<3),5)=NaN;
plot(apa(:,1),apa(:,5),'-k.');
set(gca,'XLim',[date_range(1)-2,apa(end,1)+2]);
set(gca,'XTick',[date_range(1),date_range(1)+((apa(end,1)+2)-date_range(1))/2,(apa(end,1)+2)],...
    'XTickLabel',[date_range(1),date_range(1)+((apa(end,1)+2)-date_range(1))/2,(apa(end,1)+2)]);
hline([4.95 5.10],'r-')
set(gca,'GridLineStyle','-.','Linewidth',1);
datetick('x',12,'keeplimits','keepticks');
ylabel('+5V Voltage {\it(V)}','FontWeight','bold');
grid;

subplot(2,2,3:4)
% apa(find(apa(:,4)<800),4)=NaN;
plot(apa(:,1),apa(:,4),'-k.');
set(gca,'GridLineStyle','-.','Linewidth',1);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
ylabel('H.T. Voltage {\it(V)}','FontWeight','bold');
grid;

sup=suptitle(sprintf('%s%s','Analog Printout Log, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(sup,'FontWeight','bold')
pos=get(sup,'Position'); set(sup,'Position',[pos(1)+.02,pos(2)+.02,1]);
orient portrait;
%% Outliers
Jul=(([001:365]')*100)+10;                Fecha=brewer_date(Jul);
MFecha=Fecha(:,1);                        FechaAnual=datestr(MFecha);
OutliersHT   =[Fecha(:,1)]; OutliersHT (:,end)=0;  try for i=1:size(dx1,1);  O1=find(Fecha(:,1)==apa(dx1(i),1));  OutliersHT (O1,:) =NaN; end; end
OutliersSL   =[Fecha(:,1)]; OutliersSL (:,end)=0;  try for i=1:size(dx2,1);  O2=find(Fecha(:,1)==apa(dx2(i),1));  OutliersSL (O2,:) =NaN; end; end
Outliers5V   =[Fecha(:,1)]; Outliers5V (:,end)=0;  try for i=1:size(dx3,1);  O3=find(Fecha(:,1)==apa(dx3(i),1));  Outliers5V (O3,:) =NaN; end; end
OutHTSL5V  =[Fecha OutliersHT OutliersSL Outliers5V];
