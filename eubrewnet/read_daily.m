%1    2    3   4   5     6   7   8    9   10 
%año diaj ty  ozo  ndat h0  h1  so2  airm std      
function [ozo,ozods,ozozs]=read_sumary(file)
try                                  
[a1,a2,a3,a4,a5,a6,a7,a8,a9,a10]=textread(file,...
    '%d %d %2c %f %d %d %d %f %f %f ');
catch
[a1,a2,a3,a4,a5,a6,a7,a8,a9,a10]=textread(file,...
    '%*02d/%*02d/%04d %d %2c %f %d %d %d %f %f %f ');

end    
%1    2    3   4   5     6   7   8    9   10 
%año diaj ty  ozo  ndat h0  h1  so2  airm std      

if a1<1900
   j=find(a1>80);a1(j)=a1(j)+1900;
   j=find(a1<80);a1(j)=a1(j)+2000;
end

date=datenum(a1,1,1)+a2-1;
jds=strmatch('DS',a3);ty(jds)=1;
jzs=strmatch('ZS',a3);ty(jzs)=2;
ozo_ds=[date(jds),a4(jds),a10(jds),a5(jds)];
ozo_zs=[date(jzs),a4(jzs),a10(jzs),a5(jzs)];
ozo=[date,a4,a10,a5,ty'];

