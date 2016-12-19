function [uv]=load_bentham(year,file,response,station,code)

%% Nota: Le asignamos como número de instrumento al Bentham el nº 900.

%% Función que lee los archivos Bentham y a partir de ellos genera una
% matriz UV, similar a la que se tiene para los brewer. Tambien ejecuta el
% matshic sobre los datos de ultravioleta. Además, esta función genera 3 
% carpetas:

%   Shicrivm... donde se guardan los arvhivos en formato Write_interchange
%   para se ejecuatamos manualmente por shicrivm

%   uvdata... donde se guardan los archios de entrada para el matshic.
%   (formato write_interchange)
%   uvanalys...... donde se guardan los archios de salida del matshic.
%   (formato .mat)

% PARA QUE FUNCIONE CORRECTAMENTE SE NECESITA COLOCAR EN LA MISMA CARPETA 
% QUE LOS ARCHIVOS BENTHAN, los siguiente archivos:

%     Archivo respuesta Bentham
%     Archivo Slit Bentham
%     Archivo Matshic sobre la configuracion del Bentham 
%     Archivo Station (indica latitud y longitud de la estación)
% EJEMPLO

% load_bentham('2016','C:\Bentham','resp_atmoz.bth','izana.dat',2)

%% Parámetros de entrada.

% YEAR: año en que se realizaron las medidas.
% FILE: Dirección donde están los archivos de medidas del bentham y el
% archivo respuesta.
% RESPONSE: Nombre del archivo respuesta
% CODE: CODE=0, se generan carpetas Shicrivm y Matshic
%       CODE=1, solo se procesa la parte del Shicrivm
%       CODE=2, solo se procesa la parte del Matshic 

%% Comenzamos con el programa.
% Año de la medida.
ano=num2str(year)
year=str2num(year)
if year<=2000
    year=2000-year
else
    year=year-2000
end

% Definimos la matrix UV.
for kk=1:1:366
    uv(kk).l=[]; 
    uv(kk).raw=[];  
    uv(kk).uv=[];
    uv(kk).time=[];
    uv(kk).slc=[];
    uv(kk).type=[];
    uv(kk).dark=[];
    uv(kk).date=[];
    uv(kk).temp=[];
    uv(kk).file=[];
    uv(kk).resp=[];
    uv(kk).inst=[];
    uv(kk).filter=[];
    uv(kk).duv=[];
    uv(kk).spikes=[];
end

s=dir(file);
archivos=length(s)

% Antes de comenzar a ejecutar el programa se busca si previamente se ha
% ejecutado ya que si es así, la variable "archivos" contabiliza las
% carpetas

% Carpetas.
a=exist(fullfile(file,'shicrivm'))
if a==7; archivos=archivos-1; end
a=exist(fullfile(file,'uvdata'))
if a==7; archivos=archivos-1; end
a=exist(fullfile(file,'uvanalys'))
if a==7; archivos=archivos-1; end

% Archivos necesarios para el matshic
a=exist(fullfile(file,'900.dat'))
if a>0; archivos=archivos-1; end
a=exist(fullfile(file,'900.sli'))
if a>0; archivos=archivos-1; end
a=exist(fullfile(file,station))
if a>0; archivos=archivos-1; end
a=exist(fullfile(file,response))
if a>0; archivos=archivos-1; end
a=exist(fullfile(file,'matshic.cfg'))
if a>0; archivos=archivos-1; end
% Contador de medidas realizadas en un día.
cont=ones(366,1)*0

% Cargamos archivo respuesta del Bentham.  
resp=load(fullfile(file,response))

for i=3:1:archivos
    landa=[];
    medida=[];
    b=s(i).name
    dia=str2num(b(1,3:5));
    hora=str2num(b(1,7:8))*60+str2num(b(1,9:10))
    fid=fopen(s(i).name)
    contador=1;
    tline = fgets(fid);
    while ischar(tline)
        disp(tline);
        if contador==49 % corriente de oscuridad
            dark=str2num(tline(1,26:39));
            
        elseif contador==51 % temperatura
            temp=str2num(tline(1,16:19))
            
        elseif contador>=53 && contador<=313 %Datos
            landa1=str2num(tline(1,15:20));
            landa=[landa;landa1];
            medida1=str2num(tline(1,23:34));
            medida=[medida;medida1];
        end
        contador=contador+1;
        tline = fgets(fid);
    end
    % Actualizamos contador y guardamos datos en la matrix UV.
    % Contador
    cont(dia,1)=cont(dia,1)+1
    pl=cont(dia,1) % para abreviar la programación en las líneas inferiores. 
    % Matrix UV.
    uv(dia).raw(pl,:)=medida;
    uv(dia).l(pl,:)=landa;
    uv(dia).dark(1,pl)=dark;
    paso=(uv(dia).raw(pl,:)-dark)'
    uv(dia).uv(pl,:)=paso(:,1)./resp(:,2);
    uv(dia).temp(1,pl)=temp;
    uv(dia).date(1,pl)=year;
    uv(dia).date(2,pl)=dia;
    ti=[0:1:(length(medida)-1)]'
    uv(dia).time(pl,:)=hora+ti(:,1)*0.16667
    uv(dia).slc(1,pl)=1;
    uv(dia).inst=900

    fclose all
end
% Es necesario transponer algunas columnas.    
for kk=1:1:366
    uv(kk).l=uv(kk).l'
    uv(kk).l=uv(kk).l*10
    uv(kk).raw=uv(kk).raw'
    uv(kk).uv=uv(kk).uv'
    uv(kk).time=uv(kk).time'
end

write_interchange_brewer(uv) % Generamos los G-file para el Shicrivm.
mkdir(fullfile(file,'\shicrivm\')) % ... y los guardamos en la carpeta.
mkdir(fullfile(file,'\uvdata\',ano,'900'))
copyfile('*G.900',fullfile(file,'\uvdata\',ano,'900'))
movefile('*G.900',fullfile(file,'\shicrivm\'))
mkdir(fullfile(file,'\uvanalys\',ano,'900'))
% Procesamos ahora los datos con el Matshic
for kk=1:1:366 %kk=264
    if isempty(uv(kk).l)==0
       % Parametros que necesito de la matriz UV para correr en matshic
       wl=uv(kk).l(:,1) ; % in and vector in nm
       time=(uv(kk).time/60/24)+datenum(2016,0,kk); % matlab date
       spec=uv(kk).uv; % W/sqm
       uvs=uv(kk);
       % Archivo entrada en formato .mat
       nombre=strcat('mat_uv',num2str(kk),'2016.900') 
       filename=fullfile(file,'uvdata',ano,'900',nombre);
       save(filename,'wl','time','spec','uvs');
       
       % Aplicamos el matshic
       
       [s1,s2,s3]=matshic(datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),...
       datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),'izana', '900');
       
       % save shic info
       nombre=strcat('matshic_',num2str(kk),ano,'.900')
       filename=fullfile(file,fullfile('uvanalys',ano,'900',nombre));
       aux=load(filename,'-mat');
       [nwl,ns]=size(uv(kk).l);
       
       % Añadimos los resultados a la Matrix UV.
       uv(kk).specraw=cell2mat(aux.specraw);    
       specout=reshape(cell2mat(aux.specout),nwl,3,[]);
       uv(kk).uv_shift=squeeze(specout(:,2,:));
       uv(kk).uv_norm=squeeze(specout(:,3,:));
            
       wl_shift=reshape(cell2mat(aux.dwl),nwl,6,[]);
            
       uv(kk).wl=squeeze(wl_shift(:,1,:));
       uv(kk).wl_shift_int=squeeze(wl_shift(:,2,:)); % nm
       uv(kk).wl_shift_raw=squeeze(wl_shift(:,3,:)); % nm
       uv(kk).wl_shift_res=squeeze(wl_shift(:,4,:));
       uv(kk).wl_shift_dep=squeeze(wl_shift(:,5,:));
       uv(kk).wl_shift_aflag=squeeze(wl_shift(:,6,:));
            
       dep=squeeze(wl_shift(:,2,:));
       dep(~uv(kk).wl_shift_aflag)=NaN;
       uv(kk).wl_shift=dep;
            
            %f=figure;
            %waterfall(uv(ii).l,uv(ii).time,dep);
            %title(sprintf(' Day = %03d  Inst = %03d',ii,uv(ii).inst))
%       dep_=scan_join(dep_,[uv(kk).l(:,1),dep]);
%             %tm_=scan_joinCI(tm_,[uv(ii).l(:,1),uv(ii).time]);
%       dy_=[dy_,ii+uv(ii).time(1,:)/24/60];
            
      uvs=uv(kk);
      save(filename,'-append','uvs')
      
    end
end
