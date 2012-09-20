function [f,type,IT,dt,CY,dark,time,JD,YR,lat,long,temp]=loaduv(filename);
%function [a,IT,dt,CY,dark,time,JD,YR,lat,long,temp]=loaduvstd(filename);
% 13 5 97 julian. read xl file with special header items.
% 29 nov 96 julian
% 2 header lines and 1 endline
% 14 may 97 funktioniert mit xl files.
% 14 5 98 julian
% change fgets to fgets4.
% 26 8 98 julian read ul files. and uv files from 009. Only uv files now
% 12 2 98  Resuelto el uv
IT=0.1147;
%IT=[];
f=[];type=[];dt=[];CY=[];dark=[];time=[];JD=[];YR=[];lat=[];long=[];temp=[];
count=0;flag=0;
[fid,m]=fopen(filename,'rt');
if isempty(m),   % all ok
  buf=0;
  while buf~=-1,
    count=count+1;
     for i=1:13
       buf=fgets(fid);% read in header values
       if buf==-1 , break;end
       
       switch i
       case 1,   
            if ~isempty(findstr(buf,'Integration')) 
                         type_='sx';
            else
               if(buf(length(buf))==char(13))
                        buf(length(buf))=[]; 
                        type_=buf; 
                        buf
               end
            end
                              
       case 2,      if isempty(findstr(buf,'Integration')) 
                       buf=-1;
                       break;
                    else 
                       type=[type; type_];
                       IT=[IT IT(1)];

                   end   
 
                    
                    
                    
         case 3, dt=[dt sscanf(buf,'dt %f')];
         case 4, CY=[CY sscanf(buf,'cy %f')];
         case 6, days=buf;
         case 7, months=buf;
         case 8, YR=[YR str2num(buf)];years=buf;
         case 9, JD=[JD julianday([months '/' days '/' years])];
         case 10, lat=[lat str2num(buf)];
         case 11, long=[long str2num(buf)];
         case 12, temp=[temp str2num(buf)];
            
        end
     end
     
        
   
 
  

     
if buf==-1,break; 
else   
   fgets(fid);
   dark1=sscanf(fgets(fid),'%f');

  
  a=fscanf(fid,'%f',inf);
  a=reshape(a,4,length(a)/4)';
  %a=a(:,[2 4]);
  buf=fgets(fid);% read 'DARK' or 'end'
  if strmatch('dark',buf)
    dark2=sscanf(fgets(fid),'%f');
    a2=fscanf(fid,'%f',inf);
    a2=reshape(a2,4,length(a2)/4)';
    a2=a2(end:-1:1,:);
    a(:,4)=mean([a(:,4) a2(:,4)]')';
    a(:,1)=mean([a(:,1) a2(:,1)]')'; %is mean time of scan
    a(:,5)=a(:,3);
    dark1=mean([dark1, dark2]);
    buf=fgets(fid); % read 'end'
 end  
    
  dark=[dark dark1 ];

  if count==1  
     a(:,5)=a(:,3); 
     time=[time a(:,1)];
  else 
     % gestiona que los scanes tengan la misma longitud rellenando con nan si es preciso
     n=size(f,2);
     l_0=f(:,n-2);
     l=a(:,2);
     [D,d,d_0]=setxor(l,l_0);
     if isempty(d) & isempty(d_0) % son iguales los scanes               
        a(:,5)=a(:,3); 
        time=[time a(:,1)];

     elseif ~isempty(d_0)             % esta incluido en los anteriores (ej uv en ux)
        [I,il,il_0]=intersect(l,l_0);
         c=[];
         c(il_0,:)=a(il,:);
         c(d_0,:)=NaN;
         a=c;
         a(:,5)=a(:,3); 
         time=[time a(:,1)];
      else                             % el scan no esta incluido  hay que modificar f   
         [I,il,il_0]=intersect(l,l_0);
         f(il,:)=f;
         f(d,:)=NaN;
         time(il,:)=time;
         time(d,:)=NaN;
         a(:,5)=a(:,3); 
         time=[time a(:,1)];


     end     

  end %count  
   f=[f a(:,[2 4 5])];

end  % of while
end; % buf==-1
fclose(fid);
temp=-33.27+temp*18.64;% 12 5 98 new
IT(1)=[];
% if not found, a=[]
else disp(m);
end

