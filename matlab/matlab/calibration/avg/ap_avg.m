% Juanjo 02/11/2009 
%  a�adido flag de depuracion;

function apa=ap_avg(file,date_range,flag_outlier)

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
ap=avgfech(a);

% only data in time range
if nargin>1
    try
     apa=ap(ap(:,1)>=date_range(1) & ap(:,1)<=date_range(2),:);
    catch
     disp('errror de seleccion de fecha');   
    end
    if isempty(apa)
        apa=ap;
    end
else
    apa=ap;
end

% OUTLIERS
if nargin==3
    if flag_outlier
        % outliers HT
        [ax,bx,cx,dx]=outliers_bp(apa(:,4),3);
        disp(apa(dx,[1,4]))
        apa(dx,4)=NaN;
        
%         % outliers SL current
%         [ax,bx,cx,dx]=outliers_bp(apa(:,end),3);
%         disp(apa(dx,[1,end]))
%         apa(dx,end)=NaN;

%         % outliers 5V voltage
%         [ax,bx,cx,dx]=outliers_bp(apa(:,5),3);
%         disp(apa(dx,[1,5]))
%         apa(dx,5)=NaN;
    end
end

% j=find(apa(:,4)>60 | apa(:,4)<20 | apa(:,5)>60 | apa(:,5)<20 );
% apa(j,:)=[];

f=datevec(apa(:,1));ind_lab=[];
for mm=1:8
    indx=find(f(:,2)==mm);
    if ~isempty(indx)
    ind_lab=[ind_lab;indx(1)];
    else continue
    end
end

f=figure; set(f,'tag','APAVG');%apa->4,5 y 6

subplot(2,2,1)
% apa(find(apa(:,6)<1.2),6)=NaN;
plot(apa(:,1),apa(:,6),'-k.');
set(gca,'XLim',[date_range(1)-2,date_range(2)+2]);
set(gca,'XTick',[date_range(1),date_range(1)+(date_range(2)-date_range(1))/2,date_range(2)],...
        'XTickLabels',[date_range(1),date_range(1)+(date_range(2)-date_range(1))/2,date_range(2)]);
set(gca,'GridLineStyle','-.','Linewidth',1);
datetick('x',12,'keeplimits','keepticks');
ylabel('SL Current {\it(A)}');
grid; 

subplot(2,2,2)
% apa(find(apa(:,5)<3),5)=NaN;
plot(apa(:,1),apa(:,5),'-k.');
set(gca,'XLim',[date_range(1)-2,date_range(2)+2]);%,'YLim',[4.7 5.3]
set(gca,'XTick',[date_range(1),date_range(1)+(date_range(2)-date_range(1))/2,date_range(2)],...
        'XTickLabels',[date_range(1),date_range(1)+(date_range(2)-date_range(1))/2,date_range(2)]);
hline([4.95 5.10],'r-')
set(gca,'GridLineStyle','-.','Linewidth',1);
datetick('x',12,'keeplimits','keepticks'); 
ylabel('+5V Voltage {\it(V)}');
grid; 

subplot(2,2,3:4)
% apa(find(apa(:,4)<800),4)=NaN;
plot(apa(:,1),apa(:,4),'-k.');
set(gca,'GridLineStyle','-.','Linewidth',1);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
ylabel('H.T. Voltage {\it(V)}');
grid; 

sup=suptitle(sprintf('%s%s','Analog Printout Log, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
pos=get(sup,'Position'); set(sup,'Position',[pos(1)+.02,pos(2)+.02,1]);
orient portrait;
