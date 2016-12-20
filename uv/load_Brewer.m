function uv=load_Brewer(year,file,response,station,Brewerid,code)
%% Función que lee los archivos Bentham y a partir de ellos genera una
% matriz UV, similar a la que se tiene para los brewer. Tambien ejecuta el
% matshic sobre los datos de ultravioleta. Además, esta función genera 2 
% carpetas:

%   Shicrivm... donde se guardan los arvhivos en formato Write_interchange
%   para se ejecuatamos manualmente por shicrivm

%   Matshic... donde se guardan los archios de salida del matshic.


% PARA QUE FUNCIONE CORRECTAMENTE SE NECESITA COLOCAR EN LA MISMA CARPETA 
% QUE LOS ARCHIVOS BREWER, los siguiente archivos:

%     Archivo respuesta Brewer
%     Archivo Slit Brewer
%     Archivo Matshic con la configuracion inicial del matshic 
%     Archivo Station (indica latitud y longitud de la estación)
% EJEMPLO

% load_Brewer('2016','C:\Brewer\185\','resp_brewer.185','izana.dat','185',2)

%% Parámetros de entrada.

% YEAR: año en que se realizaron las medidas.
% FILE: Dirección donde están los archivos de medidas del bentham y el
% archivo respuesta.
% RESPONSE: Nombre del archivo respuesta
% STATION: Datos sobre la estación (nombre, latitud y longitud)
% BREWERID: Numero del brewer'
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

% Como el archivo respuesta del brewer tiene la misma 

a=exist(fullfile(file,response))
if a>0
    mkdir respuesta
    movefile(response,fullfile(file,'\respuesta\'))
end

% localizamos archivo de datos UVDDDYY

d1= 'UV*'
d3= num2str(year)
d4= strcat(d1,d3,'.',Brewerid)
ano=str2num(ano)
uv=loaduvl(fullfile(file,d4),fullfile(file,'respuesta',response),'date_range',datenum(ano,1,[1 366]))

write_interchange_brewer(uv) % Generamos los G-file para el Shicrivm.
mkdir(fullfile(file,'\shicrivm\')) % ... y los guardamos en la carpeta.

Bid=str2num(Brewerid)
ano=num2str(ano)

if Bid==157
    d=dir('*G.iz1');
    for k=1:length(d)
        fname=d(k).name;
        [pathstr, name, ext] = fileparts(fname);
        movefile(fname, fullfile(file, [name '.157']),'f')
        mkdir(fullfile(file,'\uvdata\',ano,Brewerid))
        copyfile('*G.157',fullfile(file,'\uvdata\',ano,Brewerid))
        movefile('*G.157',fullfile(file,'\shicrivm\'))
    end
elseif Bid==183
    d=dir('*G.iz2');
    for k=1:length(d)
        fname=d(k).name;
        [pathstr, name, ext] = fileparts(fname);
        movefile(fname, fullfile(file, [name '.183']),'f')
        mkdir(fullfile(file,'\uvdata\',ano,Brewerid))
        copyfile('*G.183',fullfile(file,'\uvdata\',ano,Brewerid))
        movefile('*G.183',fullfile(file,'\shicrivm\'))
    end
elseif Bid==185
    d=dir('*G.iz3');
    if size(d,1)>0 
        for k=1:length(d)
            fname=d(k).name;
            [pathstr, name, ext] = fileparts(fname);
            movefile(fname, fullfile(file, [name '.185']),'f')
            mkdir(fullfile(file,'\uvdata\',ano,Brewerid))
            copyfile('*G.185',fullfile(file,'\uvdata\',ano,Brewerid))
            movefile('*G.185',fullfile(file,'\shicrivm\'))
        end
    else
        d=dir('*G.185');
        mkdir(fullfile(file,'\uvdata\',ano,Brewerid))
        copyfile('*G.185',fullfile(file,'\uvdata\',ano,Brewerid))
        movefile('*G.185',fullfile(file,'\shicrivm\'))
    end
else
    d=dir('*G.*');
    mkdir(fullfile(file,'\uvdata\',ano,Brewerid))
    copyfile('*G.*',fullfile(file,'\uvdata\',ano,Brewerid))
    movefile('*G.*',fullfile(file,'\shicrivm\'))
end   

% Procesamos ahora los datos con el Matshic
for kk=1:1:366 %kk=264
    if isempty(uv(kk).l)==0
       % Parametros que necesito de la matriz UV para correr en matshic
       wl=uv(kk).l(:,1) ; % in and vector in nm
       time=(uv(kk).time/60/24)+datenum(2016,0,kk); % matlab date
       spec=uv(kk).uv; % W/sqm
       uvs=uv(kk);
       % Salida formato .mat
       filename=fullfile(pwd,sprintf('uvanalys/2016/',Brewerid,'/matshic_%03d%04d.%s',kk,ano,Brewerid))
       nombre=strcat('mat_uv',num2str(kk),ano,'.',Brewerid) 
       filename=fullfile(file,'uvdata',nombre);
       save(filename,'wl','time','spec','uvs');
       
       % Aplicamos el matshic
       
       [s1,s2,s3]=matshic(datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),...
       datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),'izana', Brewerid);
       
       % save shic info
       nombre=strcat('matshic_',num2str(kk),ano,'.',Brewerid)
       filename=fullfile(file,fullfile('uvanalys',ano,Brewerid,nombre));
       aux=load(filename,'-mat');
       [nwl,ns]=size(uv(kk).l);
            
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
