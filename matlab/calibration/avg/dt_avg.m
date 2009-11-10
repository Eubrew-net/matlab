% Juanjo 02/11/2009 
%  añandido flag de depuracion;

function dta=dt_avg(file,date_range,ref,flag_outlier)

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
dt=avgfech(a);

% only six principal slits
if nargin>1
    try
     dta=dt(dt(:,1)>=date_range(1) & dt(:,1)<=date_range(2),:);
    catch
     disp('errror de seleccion de fecha');   
    end
    if isempty(dta)
        dta=dt;
    end
else
    dta=dt;
end

% OUTLIERS
if nargin>3
    if flag_outlier
        % outliers HT
        [ax,bx,cx,dx]=outliers_bp(dta(:,4),3);
        disp(dta(dx,[1,4]))
        dta(dx,4)=NaN;
        
        % outliers LT
        [ax,bx,cx,dx]=outliers_bp(dta(:,end),3);
        disp(dta(dx,[1,end]))
        dta(dx,end)=NaN;
    end
end

j=find(dta(:,4)>60 | dta(:,4)<10 | dta(:,5)>60 | dta(:,5)<10 );
dta(j,:)=[];

num_lab=10;
labs=linspace(dta(1,1),dta(end,1),num_lab);

f=figure; set(f,'tag','DTAVG');
plot(dta(:,1),dta(:,4),'ks',dta(:,1),dta(:,5),'bo');
set(gca,'XLim',[date_range(1)-1 date_range(2)+1]);
if nargin>2
   p3=hline(ref.*1e9,'r-',num2str(ref)); 
end
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
ylabel('Time {\it(x10^-^9 seconds)}');
title(sprintf('%s%s','Dead Time Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
legend('dt high','dt low','Location','NorthEast');
grid; orient portrait 