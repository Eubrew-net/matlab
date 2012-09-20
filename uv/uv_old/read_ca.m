% lee los ficheros cz     function A=readcz(filename)
function A=readcz(filename)
ncol=5; % numero de columnas
fid=fopen(filename);
i=1;
if(fid==-1) disp('error de fichero')
else
   feof(fid)
   while(feof(fid)~=1)
      fgets(fid);
      
      if feof(fid)==1 break
      else   A(i)=read_cz_scan(fid);
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
  
  
function S=read_cz_scan(fid)
  
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
   info.dt=getstr(fgets(fid));
   info.cy=getstr(fgets(fid));    
   info.lamda_start=getstr(fgets(fid));
   info.lamda_end=getstr(fgets(fid));
   info.lamda_inc=getstr(fgets(fid));
   info.filter1=fgets(fid);
   info.filter2=fgets(fid);
   fgets(fid);
   info.coment=fgets(fid); % comentario
   fgets(fid);
   fgets(fid); % ****************
   info.time_start=fgets(fid); % time start
   info.dark=fgets(fid); % dark
   fgets(fid); %
   fgets(fid); %
   titulos=fgets(fid) %tiltulos
   fgets(fid); % 
   [a,count]=fscanf(fid,'%f'); %A es un vector
   
   if(mod(count,10)==0) 
      a=reshape(a,10,count/10)';
   elseif(mod(count,5)==0) 
      a=reshape(a,5,count/5)';
   else
      cnt=count-mod(count,5);
      a(cnt+1:count)
      a(cnt+1:count)=[];
      a=reshape(a,5,cnt/5)';
      disp('warning cz scan no complete read ');
      disp(sprintf(' line %d ',cnt/5))
      fgets(fid)
   end   
   info.time_end=fgets(fid) 
   S=struct('info',info,'scan',a);
   fgets(fid);% end
