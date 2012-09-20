%read CI function ci=read_ci(filename)
%
function ci=read_ci(filename)
global ncol;
ncol=5;
fid=fopen(filename);
i=1;

if(fid==-1) 
    disp('error de fichero');
else
   feof(fid);
   while(feof(fid)~=1)
      if feof(fid)==1 
          break
      else
          ci(i)=read_ci_scan(fid);
      end;
      i=i+1;
      fgets(fid)% end


   end
   fclose(fid);
end


function a=getstr(aux)

  [r,s]=strtok(aux,'-');
  r=strtok(s,'- ');
  a=str2num(r);


function S=read_ci_scan(fid)
   global ncol;
   try
   fgets(fid); %dh
   info.dia=str2num(fgets(fid));
   info.mes=str2num(fgets(fid));
   info.ano=str2num(fgets(fid));
   info.location=fgetl(fid);
   info.lat=str2num(fgets(fid));
   info.lon=str2num(fgets(fid));
   info.temp=str2num(fgets(fid));
   fgets(fid); % pr
   info.presion=str2num(fgets(fid));
   info.dt=fgets(fid);
   info.cy=fgets(fid);
   info.dark=fgets(fid);
   [a,count]=fscanf(fid,'%f'); %A es un vector
   a=reshape(a,ncol,count/ncol)';
   info.time_end=fgets(fid);
   S=struct('info',info,'scan',a);
   catch
       info.locaton='read error';
       a=[];
       S=struct('info',info,'scan',a);
   end



















