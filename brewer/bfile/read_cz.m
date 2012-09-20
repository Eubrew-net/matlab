function A=read_cz(filename,ncol)
%
% lee los ficheros cz   
%
if nargin==1
    ncol=5;
end
%ncol=15; % numero de columnas
fid=fopen(filename);
i=1;
if(fid==-1)
   disp('error de fichero');
else
   feof(fid);
   while(feof(fid)~=1)
      fgets(fid);
      
      if feof(fid)==1
         break
      else
         A(i)=read_cz_scan(fid,ncol);
      end;
      i=i+1;      
   end   
   fclose(fid);
end

% lee el numero de las lineas 

function a=getstr(aux)

  [r,s]=strtok(aux,'-');
  [r,s]=strtok(s,'- ');
  a=str2num(r);
  
  
function S=read_cz_scan(fid,ncol)
  
    %fgets(fid) ********
   info.puerto=fgets(fid); % puerto
   fgets(fid); % *********
   fgets(fid); % integration
   fgets(fid); % dh
   info.dia=str2num(fgets(fid));
   info.mes=str2num(fgets(fid));
   info.ano=str2num(fgets(fid));
   info.location=fgetl(fid);
   info.lat=str2num(fgets(fid));
   info.lon=str2num(fgets(fid));
   info.temp=str2num(fgets(fid));
   fgets(fid); % pr
   info.presion=str2num(fgets(fid));
   fgets(fid); %****************************
   info.dt=1E-8*sscanf(strrep(fgets(fid),'-',''),'Dead Time %f')/1E8;
   %getstr(fgets(fid));
   info.cy=getstr(fgets(fid));    
   info.lamda_start=getstr(fgets(fid));
   info.lamda_end=getstr(fgets(fid));
   info.lamda_inc=getstr(fgets(fid));
   info.filter1=getstr(fgets(fid));
   info.filter2=getstr(fgets(fid));
   fgets(fid);
   info.coment=fgets(fid); % comentario
   fgets(fid);
   fgets(fid); % ****************
   info.time_start=fgets(fid); % time start
   info.dark=fgets(fid); % dark
   fgets(fid); %
   fgets(fid); %
   titulos=fgets(fid); %tiltulos
   fgets(fid); % 
   [a,count]=fscanf(fid,'%f'); %A es un vector
   if(mod(count,ncol)==0) 
      a=reshape(a,ncol,count/ncol)';
   else
      cnt=count-mod(count,5);
%       a(cnt+1:count)
      a(cnt+1:count)=[];
      a=reshape(a,5,cnt/5)';
      disp('warning cz scan no complete read ');
      disp(sprintf(' line %d ',cnt/5));
      fgets(fid);
   end   
   info.time_end=fgets(fid);
   S=struct('info',info,'scan',a);
   fgets(fid);% end
