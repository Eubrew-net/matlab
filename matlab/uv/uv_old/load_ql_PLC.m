function [ql_avg,ql_data]=load_ql_PLC(file,pathirr,ref,dateref)

% Lectura de los ficheros QL
% 
%  INPUT:
%  - file: fichero ql de interés
%  - pathirr: path a llos ficheros de irradiancia
%  - ref: ql dde referencia. Por defecto el  primero del fichero ql 
%         en el rango temporal de interés
%  - dateref: date_range
% 
%  OUTPUT:
%  - ql_avg: estructura promedios diarios del fichero ql, con los siguientes campos    
%            QL, cuentas diarias, std, ratio cuentas/ref, temp, dark, dias, wl, respuesta
%  - ql_data: igual que antes (sin QL, std, ratio, resp), pero todos (normalmente 4 por día)
% 

if nargin==0
   [file,path]=uigetfile('ql*');
   od=pwd;
   cd(path)
end

if nargin==2 
    iref=1;
    dateref=datenum(2000,1,1);
end
if isempty(ref)
    iref=1;
end
%inicializacion de variables
leg=[];

% leemos el archivo en memoria
f=fopen(file);s=fread(f);fclose(f);
s=char(s)';lin=mmstrtok(s,char(13));
nlin=size(lin); %numero de lineas
fecha=0;

% cargamos  el archivo
l0=sscanf(lin{1},'%f');
ql=[NaN*zeros(nlin(1),length(l0)+2)];

for i=1:nlin(1)
    if length(lin{i})>100
        l=sscanf(lin{i},'%f');        % nos queda por leer min y seg del ql (último campo de cada registro)
        [aux,time]=strtok(lin{i},':');% aquí lo hacemos
        time=sscanf(time,':%02d:%02d');
        if length(l)==length(l0)
           ql(i,:)=[l;time];
        else
           warning([file, sprintf(' Linea erronea-> %d',i)]);
        end
    end
end
ql(find(isnan(ql(:,1))),:)=[];% ya tenemos leído el archivo ql

%fecha en formato matlab
fecha=brewer_date(ql(:,2)); fecha(:,1)=fecha(:,1) + ql(:,end-2)/24 + ql(:,end-1)/24/60;

if length(dateref)==1
    j=find(fecha(:,1)<dateref);
else
    j=find(fecha(:,1)>dateref(2) | fecha(:,1)<dateref(1));
end

ql(j,:)=[];
fecha(j,:)=[];

medida=ql(:,[4,5,6,8:2:end-3]); % todas las medidas
lamda =ql(:,7:2:end-3);
meas=ql(:,8:2:end-3);           % solo cuentas   

[path_,file_,ext]=fileparts(file);
file=[file_,ext]
qfile=strrep(file,'_','');      % nombre
lamp=sscanf(qfile,'%*2c%d.%*d');% extraemos el nombre de la lámpara 
inst=sscanf(qfile,'%*2c%*d.%d');% extraemos el nombre del intrumento

% cargamos el fichero de la lámpara
ir=[];
try
 ir=loadirr(lamp,pathirr);
catch
 warning('\r LOAD QL irr file not found in matlab path\r ');
end 
    
% SALIDA INDIDUAL
% salida del fichero medidas individuales
ql_data.ql=meas;
ql_data.l=lamda;
ql_data.date=fecha;
ql_data.temp=ql(:,4);
ql_data.dark=ql(:,5);

% FICHERO EXCEL
%leg=mmcellstr(sprintf('%05d  %02d:%02d\n',ql(:,[2, end-2:end-1])'));

 qlamp=[fecha(:,1),lamp*ones(size(ql(:,1))),inst*ones(size(ql(:,1))),fecha(:,2:end),medida];

if ~isempty(qlamp)
    % RESUMEN DIARIO
    % agrupamos por dias usando grpstatss
    med=meas;

    % dias de calibracion  
        [nd_,a,b]=unique(fix(fecha(:,1)));
    % media por dias    
        [m,s,n2,n]=grpstats(medida,b);

    % solo las medidas de lamparas    
     med_d=m(:,4:end);    
     sigm_d=s(:,4:end);

     %REFERENCIA
     refer=repmat(med_d(iref,:),size(med_d,1),1);
    
    ql_avg.lamp=file_;
    ql_avg.ql=med_d;
    ql_avg.qls=sigm_d;
    ql_avg.ref=med_d./refer;
    ql_avg.temp=m(:,1);
    ql_avg.dark=m(:,2);
    ql_avg.date=nd_; 
    ql_avg.lamda=lamda(1,:);


    % CALCULO DE RESPUESTA
    if ~isempty(ir)
     uvr=cal_ql([ql_avg.lamda',ql_avg.ql'],ir);
     ql_avg.qlc=uvr(:,2:end);
    end

    % PLOTEO MEDIA/ SIGMA -> generado por grpstats

    % deteccion de outlier experimental
        figure;     orient landscape
        subplot(2,1,1);
        x1=matdiv(matadd(sigm_d,-mean(sigm_d)),mean(sigm_d));
        h=plot(lamda(1,:),x1);% sigm_d
        grid;
        [x,i]=find(mean(x1,2)>0.25);
        set(h(x),'lineWidth',2)
        legend(h(x),strcat(datestr(nd_(x)),' (',num2str(ql(a(x),2)),')'),'Location','NorthWest');
        title({file,'QL  Intensity standard deviation  (differences to mean)'});

        subplot(2,1,2);
        x1=matdiv(matadd(med_d,-mean(med_d)),mean(med_d));
        h2=plot(lamda(1,:),x1);
        xdate=datestr(nd_,2);
        [x,i]=find(abs(mean(x1,2))>0.05);
        set(h2(x),'lineWidth',2)
        legend(h2(x),datestr(nd_(x)));
        grid;
        title('QL Mean Intesity  % differences to mean')

% PLOTEO UVR
     figure;
     ploty(uvr);
     suptitle('RESPONSES');
     title(file);xlabel('wavelength');
     ylabel('couts/w*m^2')
     legend(datestr(ql_avg.date),-1)

% PLOTEO DE RATIO
if length(nd_>1) && ~isempty(ref)
            figure
            orient landscape
            plot(nd_,med_d./refer);
            suptitle('RATIO');
            title(file);
            set(gca,'xtick',nd_);
            set(gca,'xticklabel',xdate)
            legend(num2str(lamda(1,:)'),-1);
            grid;
            rotateticklabel(gca,30);
    end
else    
    ql_avg.ql=qlamp;
    ql_avg.qls=qlamp;
    ql_avg.ref=qlamp;
    ql_avg.temp=NaN;
    ql_avg.dark=NaN;
    ql_avg.date=NaN; 
    ql_avg.lamda=NaN;
    ql_avg.qlc=qlamp;
end

function xl=cal_ql(ql,irx)

% calcula la respuesta  a partir de un ql usando el fichero de lampara irx

r=ql(:,2:end);
% metodo clasico no rula por las lamdas repetidas de ql   
%    [comm,ia,ib]=intersect(ql(:,1),irx(:,1)); %porsi las moscas
%    irx_(ia,:)=irx(ib,:);
%    
%   chapuzilla % longitud de onda repetida del ql
%    j_0=find(irx_(:,1)==0);
%    irx_(j_0,:)=irx_(j_0+1,:);
%    
% nuevo metodo usando ismember
[c,ia]=ismember(ql(:,1),irx(:,1),'rows');
ia=ia(find(ia)); % pone ceros si no existe respuesta
irx_=irx(ia,:);
r_=r(c,:);

   resp=matdiv(r_,irx_(:,2));
   xl=[irx_(:,1),resp];

 
