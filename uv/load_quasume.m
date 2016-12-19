% Función que coge los archivos originales del quasume y los transforma en
% una matrix UV similar a la que se emplea para los datos del Brewer.

function uv=load_quasume(year,file,station,code)

%% Nota: Le asignamos como número de instrumento al Bentham el nº 500.

%% Función que lee los archivos qasume y a partir de ellos genera una
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

%     Archivo Slit qasume
%     Archivo Matshic sobre la configuracion del qasume
%     Archivo Station (indica latitud y longitud de la estación)
% EJEMPLO

% load_qasume('2016','C:\qasume','izana.dat',2)

%% Parámetros de entrada.

% YEAR: año en que se realizaron las medidas.
% FILE: Dirección donde están los archivos de medidas del bentham y el
% archivo respuesta.
% RESPONSE: Nombre del archivo respuesta
% CODE: CODE=0, se generan carpetas Shicrivm y Matshic
%       CODE=1, solo se procesa la parte del Shicrivm
%       CODE=2, solo se procesa la parte del Matshic 

% El parametro de entrada file hace referencia a la carpeta donde están
% almacenados los datos. Hay que poner la dirección entera.

%    file='C:\Bentham_Raw_Data\Archivos extra\global'
%-------------------------------------------------------------------------

% Defino la matrix UV.

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
% ejecutado ya que si es así, existen archivos/carpetas que ya existen.
% Nota: los archivos qasume empiezan por uvDDDHHHH, asi que si hacemos un
% dir en la carpeta, serán los últimos archivos que se visualicen. 

existe_archivo=3;
% Carpetas.
a=exist(fullfile(file,'shicrivm'))
if a==7; existe_archivo=existe_archivo+1; end
a=exist(fullfile(file,'uvdata'))
if a==7; existe_archivo=existe_archivo+1; end
a=exist(fullfile(file,'uvanalys'))
if a==7; existe_archivo=existe_archivo+1; end

% Archivos necesarios para el matshic
a=exist(fullfile(file,'500.dat'))
if a>0; existe_archivo=existe_archivo+1; end
a=exist(fullfile(file,'500.sli'))
if a>0; existe_archivo=existe_archivo+1; end
a=exist(fullfile(file,station))
if a>0; existe_archivo=existe_archivo+1; end
a=exist(fullfile(file,'matshic.cfg'))
if a>0; existe_archivo=existe_archivo+1; end

% Contador de medidas realizadas en un día.
cont=ones(366,1)*0

lamda=[];rad_inst=[];rad_std=[];time=[];rtype=[];
date_=[];       
path=fileparts(file)

for i=existe_archivo:1:archivos
    try
        filename=fullfile(file,s(i).name)
        [info]=sscanf(s(i).name,'uv%03d%02d%02d.quasume');
       
        day=info(1); hour=info(2); min=info(3);
        cont(day,1)=cont(day,1)+1;
        pl=cont(day,1);
        
        date_(i,2)=day;
        date_(i,1)=year
        
        f=fopen(filename);
        aux=textscan(f,'', 'commentStyle','%');
        if isempty(cell2mat(aux))
         aux=textscan(f,'%f %f %f ', 'commentStyle','!','HeaderLines',13);
         %aux=cell2mat(aux);
        end
        fclose(f);
        %pasamos los datos de formato celda a una estructura auxiliar
        auxi.l=aux{1}
        auxi.uv=aux{2}
        auxi.time=aux{4}*60
        
        %Guardamos los datos en la estructura UV, similar a la del Brewer.
        
        uv(day).l(:,pl)=auxi.l*10 %longitudes de onda.
        uv(day).raw(:,pl)=auxi.uv
        uv(day).uv(:,pl)=auxi.uv % Irradiancia.
        uv(day).time(:,pl)= auxi.time % Tiempo de la medida.
        uv(day).inst=500;  
        uv(day).date(2,pl)=day
        uv(day).date(1,pl)=year
        uv(day).temp(1,pl)=21
    catch
        %fclose(f);
        lasterr
        disp('warning');
        s(i).name
    end
end

write_interchange_brewer(uv) % Generamos los G-file para el Shicrivm.
mkdir(fullfile(file,'\shicrivm\')) % ... y los guardamos en la carpeta.
mkdir(fullfile(file,'\uvdata\',ano,'500'))
copyfile('*G.500',fullfile(file,'\uvdata\',ano,'500'))
movefile('*G.500',fullfile(file,'\shicrivm\'))
mkdir(fullfile(file,'\uvanalys\',ano,'500'))


for kk=1:1:366 %kk=262
    if isempty(uv(kk).l)==0
       % Parametros que necesito de la matriz UV para correr en matshic
       wl=uv(kk).l(:,1)/10 ; % in and vector in nm
       time=(uv(kk).time/60/24)+datenum(2016,0,kk); % matlab date
       spec=uv(kk).uv; % W/sqm
       uvs=uv(kk);
       nombre=strcat('mat_uv',num2str(kk),'2016.500') 
       filename=fullfile(file,'uvdata',ano,'500',nombre);
       save(filename,'wl','time','spec','uvs');
       
       %Aplicamos el matshic
       
       [s1,s2,s3]=matshic(datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),...
       datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),'izana', '500');
       
       % save shic info
       nombre=strcat('matshic_',num2str(kk),ano,'.500')
       filename=fullfile(file,fullfile('uvanalys',ano,'500',nombre));
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
