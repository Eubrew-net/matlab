function [ZA,m2,m3]=brewer_sza(t0,jd,year,la,lo)
% function [ZA,m2,m3]=brewersza(t0,jd,year,la,lo) formula del brewer 
%  year a�o con dos digitos    t0 hora gmt en minutos
%  jd dia juliano       la=latitud lo=longitud
%  za angulo zenital (grados)
%  m2 masa optica m3 masa optica de ozono 
p0=pi/180;ep=0.999999999999999;



% 7700 REM calc year # from 1965
% 7710 T=0:IF MO%<35 AND YE%/4=INT(YE%/4) THEN T=-1
% 7720 IF YE%<50 THEN T=(T+DA%+25+INT(YE%/4)+(YE%+35)*365-16+MO%)/365.2422
% 7725 IF YE%>50 THEN T=(T+DA%+INT(YE%/4)+(YE%-65)*365-16+MO%)/365.2422
% 7730 RETURN 

t=zeros(size(t0));
%jj=find(jd<35 & rem(year,4)==0);
%t(jj)=-1;
t(jd<35 & rem(year,4)==0)=-1;

t=(t+fix(year/4)+(year-65)*365-16+jd)/365.2422; %angulo diario
 


% 7805 IF FLAG<3 THEN TI=TIMER*60:T0=TI/3600
% 7810 EP=.999999999#:I=(279.4574+360*T+T0/1460.97)*P0
% 7815 IF FLAG=2 OR FLAG=4 THEN GOSUB 8400:GOTO 7830 % LUNAR

I=(279.4574+360*t+t0/1460.97)*p0;

% 7818 E=4.2*SIN(3*I)-2*COS(2*I)+596.5*SIN(2*I)-12.8*SIN(4*I)+19.3*COS(3*I)
% 7820 E=E-(102.5+.142*T)*SIN(I)+(.033*T-429.8)*COS(I):RA=(T0+E/60+720-LO*4)*P0/4
% 7825 A=ATN(.4336*SIN(I-E*P0/240))
% 7830 E=COS(RA)*COS(A)*COS(LA*P0)+SIN(LA*P0)*SIN(A):IF E=>1 THEN E=EP
% 7831 IF E=<-1 THEN E=-EP
 
 e=4.2*sin(3*I)-2*cos(2*I)+596.5*sin(2*I)-12.8*sin(4*I)+19.3*cos(3*I);
 e=e-(102.5+0.142.*t).*sin(I)+(0.033.*t-429.8).*cos(I);
 ra=(t0+e/60+720-lo*4)*p0/4;
 a=atan(0.4336*sin(I-e.*p0/240.0));
 e=cos(ra).*cos(a)*cos(la*p0)+sin(la*p0).*sin(a);
 %jj=find(e<=-1); e(jj)=-ep; 
 %jj=find(e>=1 ); e(jj)=ep; 
 e(e<=-1)=-ep;
 e(e>=1)=ep;
 e=acos(e);
 ra
 % Azimuth
 
% 7835 AZ=(SIN(A)-E*SIN(LA*P0))/SQR(1-E*E)/COS(LA*P0):IF AZ<=-1 THEN AZ=-EP
% 7836 IF AZ=>1 THEN AZ=EP
% 7840 IF AZ=0 THEN AZ=.0000001
% 7841 IF E=0 THEN E=.0000001
% 7845 AZ=ATN(SQR(1-AZ*AZ)/AZ)/P0:E=ATN(SQR(1-E*E)/E):IF E<0 THEN E=E+PI:REM CONVERSION ERROR
 
AZ=(sin(a)-e.*sin(la*p0))./sqrt(1-e.*e)/cos(la*p0);
AZ(AZ<1)=-ep;
AZ(AZ>1)=ep;
AZ(AZ==0)=0.0000001;
AZ(e==0)=.0000001;
AZ=atan(sqrt(1-AZ.*AZ)./AZ)/p0;
E=atan(sqrt(1-e.*e)./e);
E(E<0)=E(E<0)+pi; 

% 7855 RA=SIN(RA):IF AZ=<0 AND RA=<0 THEN AZ=180+AZ
% 7860 IF RA>0 THEN IF AZ=<0 THEN AZ=180-AZ ELSE AZ=360-AZ
ra=sin(ra);
AZ(ra<0 & AZ<=0)=AZ(ra<0 & AZ<=0)+180;
AZ(ra>0 & AZ<0)=180-AZ(ra>0 & AZ<0);
AZ(ra>0 & AZ>=0)=360-AZ(ra>0 & AZ>=0);


% 7865 M2=.999216*SIN(E):GOSUB 7920:M3=M2:M2=.99656*SIN(E):GOSUB 7920
%
% 7920 M2=1/COS(ATN(M2/SQR(1-M2*M2)))
% 7930 M2=INT(P3%*M2+.5)/P3%:RETURN
 %Airmas
 % 1/cos(asin[(R/R+h)*sin(sza)  
 
 
 R=6370;
 h2=22;%Km
 h3=5;%km
 m2=R/(R+h2);
 m3=R/(R+h3);
 m3=m3*sin(e); m3=1./cos(asin(m3));
 m2=m2*sin(e);  m2=1./cos(asin(m2));
 

 
 
 jj=find(e<(90.5*p0));
    %correccion por refraccion
    c1=cos(e(jj));
    d1=1./(0.955+(20.267*c1))-0.047121;  
    c1=c1+0.0083*d1;
    e(jj)=acos(c1);
  
     
  jj=find(e<0) ; a=e(jj);  e(jj)=a+pi; 
 
 %ra=sin(ra);
 
 
 ZA=e/p0;
 jj=find(ZA>90);
 m2(jj)=NaN;
 
 ZA=round(1000*e*180/pi)/1000;
 m2=round(1000*m2)/1000;
 m3=round(1000*m3)/1000;
% 
% 7850 IF FLAG=2 OR FLAG=4 THEN E=E+PL*P0*SIN(E):REM paralax correction
% 7870 IF E>90.5*P0 THEN 7885:REM correct refraction
% 7875   C1=COS(E):D1=1/(.955+(20.267*C1))-.047121
% 7880   C1=C1+.0083*D1:IF C1>-EP AND C1<EP THEN E=PI/2-ATN(C1/SQR(1-C1*C1))
% 7885 ZA=INT(P3%*E/P0+.5)/P3%:ZC=ZA:IF RA<0 THEN ZC=-ZA
% 7890 AZC%=SR%*AZ/360+.5+NC%+UC%:IF AZC%>SR% THEN AZC%=AZC%-SR%
% 7891 IF AZC%<0 THEN AZC%=AZC%+SR%
% 7895 ZEC%=ER%*(1-ZA/180)/2+.5+HC%:RETURN
% 7920 M2=1/COS(ATN(M2/SQR(1-M2*M2)))
% 7930 M2=INT(P3%*M2+.5)/P3%:RETURN

 
 