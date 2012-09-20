%  Juanjo 02/11/2009
%% Modificaciones
% añandido flag de depuracion;
% 27.05.10 Isabel Introducido el antiguo valor para DT (aparece color rojo)
%           p3=hline(ref(1).*1e9,'r-',num2str(ref(1)));
%           p3=hline(ref(2).*1e9,'c-',num2str(ref(2)));
% 28/10/2010 Isabel  Comentados:
%         disp('outliers HT DTAVG')
%         disp(datestr(dta(dx,1)))
%         disp('outliers LT DTAVG')
%         disp(datestr(dta(dx,1)))
% 12/11/2010 Isabel  Introducido nuevo output para los outliers.

%%
function [dta,OutHTLT]=dt_avg(file,date_range,ref,outlier_flag)
if nargin==1
    date_range=[];
    outlier_flag=0;
    ref=[NaN,NaN];
elseif nargin==2
    outlier_flag=0;
    ref=[NaN,NaN];
elseif nargin==3
    outlier_flag=0;
end
    
try
    a=textread(file,'');
catch
    try
        %% DT file has 3 columns
        a=read_avg_line(file,3);
    catch
        disp(file);
        aux=lasterror;
        disp(aux.message)
        return;
    end
end
dt=avgfech(a);
if ~isempty(date_range)
    try
        dta=dt(dt(:,1)>date_range(1),:);
        if length(date_range)>1
            dta=dta(dta(:,1)<date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
    if isempty(dta)
        dta=dt;
    end
else
    dta=dt;
end

%% OUTLIERS
if ~isempty(outlier_flag)
    % outliers HT
    [ax,bx,cx,dx1]=outliers_bp(dta(:,4),3);         
    outHT=dta(dx1,:);  dta(dx1,4)=NaN;
    % Outliers LT
    [ax,bx,cx,dx2]=outliers_bp(dta(:,end),3);        
    outLT=dta(dx2,:);  dta(dx2,end)=NaN;

    outHT(:,end)=NaN; outLT(:,end-1)=NaN;
    [eq id_HT id_LT]=intersect(outHT(:,1),outLT(:,1));
    if ~isempty(eq)
       outHT(id_HT,end)=outLT(id_LT,end);
       outLT(id_LT,:)=[];
    end
    OutHTLT=sortrows(cat(1,outHT,outLT));
    if isempty(OutHTLT)
       OutHTLT=NaN*ones(1,5); OutHTLT(1)=fix(now);
    end  
else
    OutHTLT=NaN*ones(1,5); OutHTLT(1)=fix(now);
end

%%
f=figure; set(f,'tag','DTAVG');
num_lab=10;         labs=linspace(dta(1,1),dta(end,1),num_lab);
plot(dta(:,1),dta(:,4),'ks',dta(:,1),dta(:,5),'bo');
if nargin>1
set(gca,'XLim',[date_range(1)-4 dta(end,1)+4]);
end
p3=hline(ref(1).*1e9,'r-',num2str(ref(1)));
p3=hline(ref(2).*1e9,'c-',num2str(ref(2)));
set(gca,'XTick',labs,'GridLineStyle','-.','Linewidth',1);
ylabel('Time {\it(x10^-^9 seconds)}','FontWeight','bold');
T=title(sprintf('%s%s','Dead Time Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(T,'FontWeight','bold')
legend('dt high','dt low','Location','NorthEast');
grid; orient portrait
if any(OutHTLT(1,2:end))
    ix_h=abs(OutHTLT(:,4))<50;
    ix_l=OutHTLT(:,5)<50 & OutHTLT(:,5)>-10;
    hold on; p=plot(OutHTLT(ix_h,1),OutHTLT(ix_h,4),'sk',...
                    OutHTLT(ix_l,1),OutHTLT(ix_l,5),'ob');
               set(p,'MarkerFaceColor','r')
end
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
