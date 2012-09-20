% plotea el fichero run/stop
% Juanjo 02/11/2009
%% Modificaciones
%  añandido flag de depuracion;
% 28/10/2010 Isabel  Comentados:
%     disp(datestr(rsa(dx,1)))
%     disp(datestr(rsa(dx,1)))
% 12/11/2010 Isabel  Introducido nuevo output para los outliers.

%%
function [rsa,OutRS]=rs_avg(file,date_range,outlier_flag)

try
    a=textread(file,'');
catch
    try
        a=read_avg_line(file,9);
    catch
        disp(file);
        aux=lasterror;
        disp(aux.message)
        return;
    end
end
rs=avgfech(a);
% Hg + 5 operational + DT slit
rsa=rs(:,[1:3 4 6:end]);
rsa_=rsa;
if ~isempty(date_range)
    try
        rsa_=rsa(rsa(:,1)>date_range(1),:);
        if length(date_range)>1
            rsa_=rsa_(rsa_(:,1)<date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
    if isempty(rsa_)
        rsa_=rsa;
    else rsa=rsa_;
    end
else
    date_range(1)=min(rsa(:,1));
    date_range(2)=max(rsa(:,1));
end

%% OUTLIERS
% Aqui no es trivial construir una tabla. No queremos perder varios rs en
% el mismo día -> no se puede usar igual método que en sl
if ~isempty(outlier_flag)
    dx={}; out={};
    for sl=1:6
        [ax,bx,cx,dx{sl}]=outliers_bp(rsa(:,sl+3),3); 
        out{sl}=rsa(dx{sl},[1:3 sl+3]);%  rsa(dx(sl),sl+3)=NaN;
    end
    OutRS=out;
else
    OutRS=[];
end

%% RSOAVG ploteos
f=figure; set(f,'Tag','RSAVG');
num_lab=6;  labs=linspace(rsa(1,1),rsa(end,1),num_lab);
for i=1:6,
    sub=subplot(6,1,i);
    h=ploty(rsa(:,[1,i+3]),'.'); set(h,'MarkerSize',11);
    set(gca,'XLim',[date_range(1)-4 rsa(end,1)+4]);
    set(gca,'YTick',[.997 1.003],'YTickLabel',[.997 1.003],...
        'YLim',[0.990,1.010],'XTick',labs,'XTickLabel',[],...
        'GridLineStyle','-.','Linewidth',1);
    hl=hline([0.997,1.003],'r-.');     hl=hline(1,'k-');
    if ~isempty(OutRS)
        hold on; p=plot(OutRS{i}(:,1),OutRS{i}(:,4),'.r');
    end
    if i==1
        text(rsa(1,1)+1,1.0075,'SLIT 0');
    else
        text(rsa(1,1)+1,1.0075,sprintf('SLIT %d',i));
    end
    grid;
    ylabel('Ratio','FontWeight','bold');
end
samexaxis('xmt','off','join','yld',1);%
if i==6
    set(gca,'YTick',[.988 .997 1.003],'YTickLabel',{'','0.997','1.003'},'XTick',labs);
    datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
end
sup=suptitle(sprintf('%s%s','Run/Stop Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(sup,'FontWeight','bold');
pos=get(sup,'Position');
set(sup,'Position',[pos(1)+.02,pos(2)-.05,1]);

%% Outliers
% Jul=(([001:365]')*100)+10;                Fecha=brewer_date(Jul);
% MFecha=Fecha(:,1);                        FechaAnual=datestr(MFecha);
% OutliersRS   =[Fecha(:,1)]; OutliersRS (:,end)=0;
% try for i=1:size(dx1,1);  O1=find(Fecha(:,1)==rsa(dx1(i),1));  OutliersRS (O1,:) =NaN; end; end
% try for i=1:size(dx2,1);  O2=find(Fecha(:,1)==rsa(dx2(i),1));  OutliersRS (O2,:) =NaN; end; end
% try for i=1:size(dx3,1);  O3=find(Fecha(:,1)==rsa(dx3(i),1));  OutliersRS (O3,:) =NaN; end; end
% try for i=1:size(dx4,1);  O4=find(Fecha(:,1)==rsa(dx4(i),1));  OutliersRS (O4,:) =NaN; end; end
% try for i=1:size(dx5,1);  O5=find(Fecha(:,1)==rsa(dx5(i),1));  OutliersRS (O5,:) =NaN; end; end
% OutRS =[Fecha OutliersRS ];

