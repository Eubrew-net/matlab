% Función que coge los archivos originales del quasume y los transforma en
% una matrix UV similar a la que se emplea para los datos del Brewer.

function uv=load_quasume(file)

addpath(genpath('C:\CODE\iberonesia\matlab'))

addpath(genpath('G:\DATABENTHAM\matlab'))


file='C:\Bentham_Raw_Data\Archivos extra\global'
% El parametro de entrada file hace referencia a la carpeta donde están
% almacenados los datos. Hay que poner la dirección entera.

%    file='C:\Bentham_Raw_Data\Archivos extra\global'
%-------------------------------------------------------------------------

% Defino la matrix UV.

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

% Empiezo a procesar los datos del quasume...

dia=ones(366,1)*0

s=dir(file);
lamda=[];rad_inst=[];rad_std=[];time=[];rtype=[];
date_=[];       
path=fileparts(file)

archivos=length(s)

a= exist('uvdata')
if a==7
    archivos=archivos-1
end


for i=3:archivos
    try
        
        filename=fullfile(file,s(i).name)
        [info]=sscanf(s(i).name,'uv%03d%02d%02d.quasume');
       
        day=info(1); hour=info(2); min=info(3);
        dia(day,1)=dia(day,1)+1;
        pl=dia(day,1);
        
        date_(i,2)=day;
        date_(i,1)=16; %año actual 2016-->16
        
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
        uv(day).inst=300;  
        uv(day).date(2,pl)=day
        uv(day).date(1,pl)=16
        uv(day).temp(1,pl)=21
    catch
        %fclose(f);
        lasterr
        disp('warning');
        s(i).name
    end
end

write_interchange_brewer(uv)

mkdir uvdata

movefile('*G.300','uvdata')
mkdir(fullfile(file,'\Matshic\'))
for kk=1:1:366 %kk=262
    if isempty(uv(kk).l)==0
       % Parametros que necesito de la matriz UV para correr en matshic
       wl=uv(kk).l(:,1)/10 ; % in and vector in nm
       time=(uv(kk).time/60/24)+datenum(2016,0,kk); % matlab date
       spec=uv(kk).uv; % W/sqm
       uvs=uv(kk);
       nombre=strcat('mat_uv',num2str(kk),'2016.300') 
       filename=fullfile(file,'\Matshic\nombre');
       save(filename,'wl','time','spec','uvs');
       
       %Aplicamos el matshic
       
       [s1,s2,s3]=matshic(datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),...
       datestr(datenum(2016,1,kk),'dd-mmm-yyyy'),'izana', '300');
       
       % save shic info
       filename=fullfile(file,sprintf('uvanalys/2016/matshic_%03d%04d.%s',kk,2016,'300'));
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