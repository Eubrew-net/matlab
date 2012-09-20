function calc_irr(nbrw,date,n_lamp,L_ref)

% Cálculo de los ficheros de irradiancia.
% Para el cálculo de los ficheros de irradiancia se exige la igualdad entre 
% las respuestas calculadas para la lámpara de referencia y la estudiada
% 
% 	uvr(lamp)=uvr(ref)
% 
% de donde, teniendo en cuenta que uvr=ql/irr, resulta
% 
% 	irr(lamp) = ql(lamp)*(irr(ref)/ql(ref)) (W/m2)
% 
% 
%  INPUT:
%  - nbrw, brewerid procesado
%  - date, fecha a partir de la cual vamos a considerar, formato 'yyyy,mm,dd'. 
%          Normalmente estaremos interesados en un día concreto, próximo a 
%          calibración de 1000W
%  - n_lamp, número de lámparas de los que queremos obtener irr's. String
%            o cell array de string's
%  - L_ref, número de lámparas usadas como referencia. String
%           o cell array de string's.
% 
%  OUTPUT: 
%  - ficheros de irradiancia
% 
% Ejemplo de uso: calc_irr(183,'2011,05,10',{'26','34','39'},{'856','1080'})
% El resultado será por ejemplo LAMP39__183ref1080.irr, EN EL PATH DE TRABAJO
% En este caso tendremos 6 ficheros similares. A partir de ellos haremos uso
% de calc_med_irr para hallar un promedio sobre lámparas (o/y instrumentos)
% 

plt=1;
date_initial=datenum(date);
dirirr='.\certificados';

if isfloat(nbrw)
    nbrw=num2str(nbrw);
end    
if isfloat(L_ref)
    L_ref=num2str(L_ref);
end

%Se determinan los ficheros asociados a los datos introducidos
nlamps=cat(2,n_lamp,L_ref);
for i=1:length(nlamps)
    listin=dir(fullfile(['QL',nbrw],strcat('QL*',nlamps{i},'.',nbrw))); 
    file_ql=fullfile(['QL',nbrw],listin.name);
    [ql_avg{i},ql_dat{i}]=ql_check(file_ql,dirirr,[],date_initial,plt);
    ql_info{i}={ql_avg{i}.date,repmat(nlamps{i},length(ql_avg{i}.date),1),ql_avg{i}.temp};
end

% Seleccionamos las lámparas elegidas como referencia
ql_avg_ref=ql_avg(length(n_lamp)+1:end); ql_info_ref=ql_info(length(n_lamp)+1:end);

% Calculo de los irr's
for r=1:length(L_ref)
    irr_ref=loadirr_PLC(str2num(L_ref{r}),dirirr);
    for l=1:length(n_lamp)
        fid=fopen(['LAMP',n_lamp{l},'__',nbrw,'ref',ql_info_ref{r}{2},'.irr'],'w');
        fprintf(fid,'%s\r\n',['lamp',n_lamp{l}]);
        fprintf(fid,' %d\r\n',20.0); % Cuidado aquí. No siempre será 20
        irr=cal_irr([ql_avg{l}.lamda',ql_avg{l}.ql'],ql_avg_ref{r}.ql',irr_ref);
    for i=1:size(irr,1)
        fprintf(fid,'%d %6.4f\r\n',irr(i,1),irr(i,2));
    end
    fclose(fid)
    end
end

function [ql_avg,ql_data]=ql_check(file,pathirr,ref,dateref,plt)

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
j=find(fecha(:,1)<dateref(1));

ql(j,:)=[];
fecha(j,:)=[];

medida=ql(:,[4,5,6,8:2:end-3]); % todas las medidas
lamda =ql(:,7:2:end-3);
meas=ql(:,8:2:end-3);           % solo cuentas   

[path_,file_,ext]=fileparts(file);
file=[file_,ext];
qfile=strrep(file,'_','');      % nombre
lamp=sscanf(qfile,'%*2c%d.%d'); % extraemos el nombre de la lámpara 
inst=lamp(2);                   % intrumento
lamp=lamp(1);                   % lampara                

ql_data.ql=meas;
ql_data.l=lamda;
ql_data.date=fecha;
ql_data.temp=ql(:,4);
ql_data.dark=ql(:,5);

qlamp=[fecha(:,1),lamp*ones(size(ql(:,1))),inst*ones(size(ql(:,1))),fecha(:,2:end),medida];
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


    % PLOTEO MEDIA/ SIGMA -> generado por grpstats

    if plt
        figure;     orient landscape
        suptitle(sprintf('%s%s %s',file,': SCAN´S',' (dif. rel. al promedio, %)'))
        subplot(3,1,1:2);
%         referencia: promedio de los scans
        plot(lamda(1,:),(ql_data.ql-repmat(med_d,size(ql,1),1))./repmat(med_d,size(ql,1),1).*100,'*-');
        
%         referencia: scan particular 
%         ref=ql_data.ql(1,:);
%         plot(lamda(1,:),(ql_data.ql-repmat(ref,size(ql,1),1))./repmat(ref,size(ql,1),1).*100);

        set(gca,'XTickLabel',[],'YLim',[-2 2]); set(findobj(gca,'Type','Line'),'Linewidth',2);
        leg=strcat(datestr(ql_data.date(:,1),15),' T=',num2str(ql(:,4)));
        legend(leg,'Location','SouthEast');  set(gca,'FontWeight','Bold');
        grid

        subplot(3,1,3);    
        plot(lamda(1,:),sigm_d); set(findobj(gca,'Type','Line'),'Linewidth',2);
        legend(datestr(ql_avg.date),'Location','NorthWest');
        set(gca,'FontWeight','Bold'); grid;
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

function irr=cal_irr(ql,ql_ref,irr_ref)

r=ql(:,2:end);
ql_intp1=[]; ql_intp2=[];
indx=find(ql(:,1)==3495);
ql_intp1=spline(ql(1:indx(1),1),ql(1:indx(1),2),2865:5:3500); 
ql_intp2=spline(ql(indx(2):end,1),ql(indx(2):end,2),3505:5:3635);
ql_intp=[2865:5:3635;cat(2,ql_intp1,ql_intp2)]';

ref_intp1=spline(ql(1:indx(1),1),ql_ref(1:indx(1)),2865:5:3500); 
ref_intp2=spline(ql(indx(2):end,1),ql_ref(indx(2):end),3505:5:3635);
ref_intp=[2865:5:3635;cat(2,ref_intp1,ref_intp2)]';

irr=ql_intp(:,2).*(irr_ref(:,2)./ref_intp(:,2));
irr=[irr_ref(:,1),irr];
