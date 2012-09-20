% function [qlamp_m,m,lamda,leg]=load_ql(file,pathirr,ref,dateref)
% todo-> average per day 
% pathirr: directorio en el que se encuentran los ficheros de irradiancia absoluta
% file:    
% ref:     
% dateref fechas entre las que toman los ql
% TODO: date control see line 54
function [ql_avg,ql_data]=load_ql(file,pathirr,ref,dateref)

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
s=char(s)';lin=mmstrtok(s,char(13));nlin=size(lin); %numero de lineas
fecha=0;

% cargamos  el archivo PARSE
l0=sscanf(lin{1},'%f');
ql=[NaN*zeros(nlin(1),length(l0)+2)];

for i=1:nlin(1)
    if length(lin{i})>100
        l=sscanf(lin{i},'%f');% nos queda por leer min y seg del ql (último campo de cada registro)
        [aux,time]=strtok(lin{i},':');% aquí lo hacemos
        time=sscanf(time,':%02d:%02d');
        if length(l)==length(l0)
           ql(i,:)=[l;time];
        else
           warning([file, sprintf(' Linea erronea-> %d',i)]);
        end
    end
end
% ya tenemos leído el archivo ql
ql(find(isnan(ql(:,1))),:)=[];

%fecha en formato matlab
fecha=brewer_date(ql(:,2)); fecha(:,1)=fecha(:,1) + ql(:,end-2)/24 + ql(:,end-1)/24/60;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(dateref)==1
    j=find(fecha(:,1)<dateref);
else
    j=find(fecha(:,1)>dateref(2) | fecha(:,1)<dateref(1));
end

ql(j,:)=[];
fecha(j,:)=[];
%warning('date > 2004 01 01');

medida=ql(:,[4,5,6,8:2:end-3]); % todas las medidas
lamda =ql(:,7:2:end-3);
meas=ql(:,8:2:end-3);           % solo cuentas   

[path_,file_,ext]=fileparts(file);
file=[file_,ext]
qfile=strrep(file,'_','');      % nombre
lamp=sscanf(qfile,'%*2c%d.%d'); % extraemos el nombre de la lámpara 
inst=lamp(2)                    % intrumento
lamp=lamp(1);                   % lampara                

% intentamos cargar el fichero de la lámpara
% ponerlo en el path del matlab
ir=[];
try
 ir=loadirr(lamp(1),pathirr);
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
% line1={'FECHA','LAMP','INST','AAAA','MM__','DD__','DDD_','TEMP','DARK','_%%_'};	%
% line2=mmcellstr(sprintf(' %.0f, ',lamda(1,:)),',');
% head=[line1,line2'];
% xlswrite_d(qlamp,file,head,[file,'.xls']);

if ~isempty(qlamp)
    % SALIDA RESUMEN DIARIO
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

%      SALIDA EXCEL PROMEDIO
%      qlamp_m=[fecha(a,1),lamp*ones(size(ql(a,1))),inst*ones(size(ql(a,1))),fecha(a,2:end),m];
%      medida=med_d;    
%      line1={'FECHA','LAMP','INST','AAAA','MM__','DD__','DDD_','TEMP','DARK','_%%_'};	%
%      line2=mmcellstr(sprintf(' %.0f, ',lamda(1,:)),',');
%      head=[line1,line2'];
%      xlswrite_d(qlamp_m,file,head,[file,'_avg.xls']);

% PLOTEO MEDIA/ SIGMA -> generado por grpstats


    % deteccion de outlier experimental
        figure;     orient landscape
        suptitle(sprintf('%s%s %s',file,': SCAN´S',' (dif. rel. al promedio, %)'))
        subplot(3,1,1:2);
%         referencia: promedio de los scans
        plot(lamda(1,:),(ql_data.ql-repmat(med_d,size(ql,1),1))./repmat(med_d,size(ql,1),1).*100);
%         referencia: scan particular 
%         ref=ql_data.ql(1,:);
%         plot(lamda(1,:),(ql_data.ql-repmat(ref,size(ql,1),1))./repmat(ref,size(ql,1),1).*100);
        set(gca,'XTickLabel',[]); set(findobj(gca,'Type','Line'),'Linewidth',2);
        leg=strcat(datestr(ql_data.date(:,1),15),' T=',num2str(ql(:,4)));
        legend(leg,'Location','SouthEast');  set(gca,'FontWeight','Bold');
        grid
        subplot(3,1,3);    
        plot(lamda(1,:),sigm_d); set(findobj(gca,'Type','Line'),'Linewidth',2);
        set(gca,'FontWeight','Bold'); grid;

%     % PLOTEO DE RATIO
%     if length(nd_>1) && ~isempty(ref)
%             figure
%             orient landscape
%             plot(nd_,med_d./refer);
%             suptitle('RATIO');
%             title(file);
%             set(gca,'xtick',nd_);
%             set(gca,'xticklabel',xdate)
%             legend(num2str(lamda(1,:)'),-1);
%             grid;
%             rotateticklabel(gca,30);
%     end
    %  
    % % PLOTEO UVR
    %  figure
    %  ploty(uvr);
    %  suptitle('RESPONSES');
    %  title(file);xlabel('wavelength');
    %  ylabel('couts/w*m^2')
    %  legend(datestr(ql_avg.date),-1)
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

if nargin==0
    cd(od);
end


%function xl=cal_uv_xl(xl,irx)
% calclula la respuesta  a partir de un ql usando el fichero de lampara irx
function xl=cal_ql(ql,irx)

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

 
