
function [ZA,m2,m3]=sza(date,la,lo)
% function [ZA,m2,m3]=sza(date,la,lo) formula del brewer 
%  date: matlab format GMT
%  jd dia juliano       la=latitud lo=longitud
%  za angulo zenital (grados)
%  m2 masa optica m3 masa optica de ozono
if nargin==1
    la=28.3090
    lo=16.4994
end
date=date(:);

date_vec=datevec(date);
t0=date_vec(:,4)*60+date_vec(:,5)+date_vec(:,6)/60;
year=date_vec(1)-1900;
jd=diajul(date); %(date_vec(3),date_vec(2),date_vec(1));
jd=fix(jd);
p0=pi/180;ep=0.999999999999999;

t=zeros(size(t0));
jj=find(jd<35 & rem(year,4)==0);
t(jj)=-1;
 
 t=(t+fix(year/4)+(year-65)*365-16+jd)/365.2422; %angulo diario
 
 I=(279.4574+360*t+t0/1460.97)*p0;

 
 e=4.2*sin(3*I)-2*cos(2*I)+596.5*sin(2*I)-12.8*sin(4*I)+19.3*cos(3*I);
 e=e-(102.5+0.142.*t).*sin(I)+(0.033.*t-429.8).*cos(I);
 
 ra=(t0+e/60+720-lo*4)*p0/4;
 a=atan(0.4336*sin(I-e.*p0/240.0));
 
 e=cos(ra).*cos(a)*cos(la*p0)+sin(la*p0).*sin(a);
 
 jj=find(e<=-1); e(jj)=ep; 
 jj=find(e>=1 ); e(jj)=ep; 
 
 e=acos(e);
 
 m3=0.999216*sin(e); m3=1./cos(asin(m3));
 m2=0.99656*sin(e);  m2=1./cos(asin(m2));
 
 jj=find(e<(90.5*p0));
    %correccion por refraccion
    c1=cos(e(jj));
    d1=1./(0.955+(20.267*c1))-0.047121;  
    c1=c1+0.0083*d1;
    e(jj)=acos(c1);
  
     
  jj=find(e<0) ; a=e(jj);  e(jj)=a+pi; 
 
 ra=sin(ra);
 
 
 ZA=e/p0;
 jj=find(ZA>90);
 m2(jj)=NaN;
 
 ZA=round(1000*e*180/pi)/1000;
 m2=round(1000*m2)/1000;
 m3=round(1000*m3)/1000;
   