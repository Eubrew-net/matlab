%1 2 3   4   5  6   % 7   8    9   10  11 12 13
%hora   dia mes year sza airm temp type filt  o3 std      
function [ozo,ozods,ozozs]=read_sumary(file)
                                  
[a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13]=textread(file,...
    '%02d:%02d:%02d %d %d %04d %f %f %d %2c %d %f %f ');

    %1 2 3   4   5  6   % 7   8    9   10    11   12 13
    %hora   dia mes year sza airm temp type filt  o3 std

%j=find(a1>80);a1(j)=a1(j)+1900;
%j=find(a1<80);a1(j)=a1(j)+2000;


date=datenum(a6,a4,a5,a1,a2,a3);
jds=strmatch('ds',a10);ty(jds)=1;
jzs=strmatch('zs',a10);ty(jzs)=2;
ozo_ds=[date(jds),a12(jds),a13(jds),a7(jds),a8(jds),a9(jds),a11(jds)];
ozo_zs=[date(jzs),a12(jzs),a13(jzs),a7(jzs),a8(jzs),a9(jzs),a11(jzs)];
ozo=[date,a12,a13,a7,a8,a9,a11,ty'];


