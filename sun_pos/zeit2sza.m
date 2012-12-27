function [sza,az,szac,pm]=zeit2sza(nn,la,lo,meth);
%[sza,az,szac,pm]=zeit2sza(nn,la,lo,meth) calculates
%the solar zenith angle sza [°], the azimuth az [°] (0=north,90=east),
%the refraction corrected solar zenith angle szac [°] and 
%pm, which is 0 in the "local" morning and 1 in the "local" afternoon
%from UT-time nn
%la, lo are latitude (+=north) and longitude (+=east) in degrees
%meth=1: from Michalski, 1988, valid until 2050 with accuracy 0.01deg
%meth=2: old method (von Innsbruck)
%meth=3: Brewer method (von xmain.asc 7700-7885)

if nargin<4
    meth=1;
end;
if nargin<3
    [lo,la]=koordinaten;
end;
if la>89.99
    la=89.99;
end;
if la<-89.99
    la=-89.99;
end;

[yy,mm,dd,stu,minu,seku]=datevec(nn);
tn=tagnum(yy,mm,dd);
utstu=stu+minu/60+seku/3600;%[0,24)

%---------------------------------------------------------------------------
%meth=1: from Michalski, 1988, valid until 2050 with accuracy 0.01deg
if meth==1

%Jahr 4-stellig
ik=yy<=50;
yy(ik)=yy(ik)+2000;
ik=yy<100;
yy(ik)=yy(ik)+1900;

%current julian date
delta=yy-1949;
leap=floor(delta/4);
jd=32916.5+365*delta+leap+tn+utstu/24;
n=jd-51545;

%ecliptic coordinates, mean longitude and mean anomaly
mnlong=280.46+0.9856474*n;
mnlong=mod(mnlong,360);
mnanom=357.528+0.9856003*n;
mnanom=mod(mnanom,360)/180*pi;%[rad]

%ecliptic longitude and obliquity of ecliptic
eclong=mnlong+1.915*sin(mnanom)+0.02*sin(2*mnanom);
eclong=mod(eclong,360)/180*pi;%[rad]
oblqec=(23.439-0.0000004*n)/180*pi;%[rad]

%right ascension and declination
num=cos(oblqec).*sin(eclong);
den=cos(eclong);
ra=atan(num./den);
ik=den<0;
ra(ik)=ra(ik)+pi;
ik=num<0;
ra(ik)=ra(ik)+2*pi;
dec=asin(sin(oblqec).*sin(eclong));
dek=dec*180/pi;

%Greenwich mean sidereal time [h]
gmst=6.697375+0.0657098242*n+utstu;
gmst=mod(gmst,24);

%local mean sidereal time [rad]
lmst=gmst+lo/15;
lmst=mod(lmst,24)*15/180*pi;

%hour angle [rad]
ha=lmst-ra;
ha=bring2int(ha,-pi,pi);
pm=ha*0;
ig=ha>0;
pm(ig)=1;

%latitude in rad
lat=la/180*pi;

%azimuth and elevation [rad]
el=asin(sin(dec)*sin(lat)+cos(dec)*cos(lat).*cos(ha));
az=asin(-cos(dec).*sin(ha)./cos(el));

ig=(abs(lat)-abs(dec))>=0;
i0=lat==0;
elk=el*0+9999;
elk(ig&i0)=1;
elk(ig&~i0)=asin(sin(dec(ig&~i0))/sin(lat));
ig=(el-elk)>=0;
az(ig)=pi-az(ig);

%in deg
el=el*180/pi;
az=mod(az,2*pi)*180/pi;

%refraction correction (ist unstetig bei -0.56!?!)
refrac=3.51561*(0.1594+0.0196*el+0.00002*el.^2)./(1+0.505*el+0.0845*el.^2);
ik=el<=-0.56;
refrac(ik)=0.56;
elc=el+refrac;

sza=90-el;
szac=90-elc;

%---------------------------------------------------------------------------
%meth=2: 
elseif meth==2

%zeitkorr in min
zk=-lo*4+7.6*sin(0.0172*(tn-4))+9.8*sin(0.0344*(tn+9));
%wahre Ortszeit in stu
woz=mod(utstu-zk/60,24);
pm=woz*0;
ig=woz>12;
pm(ig)=1;
%deklin   
h=0.985609*(tn-0.5+(yy-1979)*365+floor((yy-1977)/4)-3.96);
h=h+283.975+1.916*sin(h*pi/180);
h=sin(23.45*pi/180)*sin(h*pi/180);
dek=180/pi*atan(h./sqrt(1-h.*h));
%sza
h=sin(la/180*pi)*sin(dek/180*pi)+cos(la/180*pi)*cos(dek/180*pi).*cos((woz-12)*pi/12);
sh=atan(h./sqrt(1-h.*h))*180/pi;
sza=90-sh;
szac=sza;
%azim
h1=cos(dek/180*pi)./cos(sh/180*pi).*sin((woz-12)*pi/12);
h1=atan(h1./sqrt(1-h1.*h1));
h2=(sin(sh/180*pi).*sin(la/180*pi)-sin(dek/180*pi))./cos(sh/180*pi)/cos(la/180*pi);
az=h1;
ig=(h2<0)&(h1<0);
az(ig)=-pi-h1(ig);
ig=(h2<0)&(h1>=0);
az(ig)=pi-h1(ig);
az=(az+pi)/pi*180;
az=mod(az,360);

%---------------------------------------------------------------------------
%meth=3: 
elseif meth==3

%Jahr 2-stellig
ye=mod(yy,100);

utmins=utstu*60;
tn1=tagnum(mm*0+1999,mm,mm*0+1)-1;
loc=-lo;

t=tn1*0;
ig=(tn1<35)&(ye/4==floor(ye/4));
t(ig)=-1;

ig=ye<50;
t(ig)=(t(ig)+dd(ig)+25+floor(ye(ig)/4)+(ye(ig)+35)*365-16+tn1(ig))/365.2422;
t(~ig)=(t(~ig)+dd(~ig)+floor(ye(~ig)/4)+(ye(~ig)-65)*365-16+tn1(~ig))/365.2422;

ep=0.999999999;
i=(279.4574+360*t+utmins/1460.97)*pi/180;
e=4.2*sin(3*i)-2*cos(2*i)+596.5*sin(2*i)-12.8*sin(4*i)+19.3*cos(3*i);
e=e-(102.5+0.142*t).*sin(i)+(0.033*t-429.8).*cos(i);
ra=(utmins+e/60+720-loc*4)*pi/180/4;

pm=bring2int(ra,-pi,pi);
ig=pm>0;
pm(ig)=1;
pm(~ig)=0;

a=atan(0.4336*sin(i-e*pi/180/240));
e=cos(ra).*cos(a)*cos(la*pi/180)+sin(la*pi/180).*sin(a);
ig=e>=1;
e(ig)=ep;
ig=e<=-1;
e(ig)=-ep;
az=(sin(a)-e*sin(la*pi/180))./sqrt(1-e.*e)/cos(la*pi/180);
ig=az<=-1;
az(ig)=-ep;
ig=az>=1;
az(ig)=ep;
ig=az==0;
az(ig)=0.0000001;
ig=e==0;
e(ig)=0.0000001;
az=atan(sqrt(1-az.*az)./az)*180/pi;
e=atan(sqrt(1-e.*e)./e);
ig=e<0;
e(ig)=e(ig)+pi;
ra=sin(ra);
ig=(az<=0)&(ra<=0);
az(ig)=az(ig)+180;
ig1=ra>0;
ig2=az<=0;
az(ig1&ig2)=180-az(ig1&ig2);
az(ig1&~ig2)=360-az(ig1&~ig2);

sza=e*180/pi;

%Refraction correction
c1=cos(e);
d1=1./(0.955+(20.267*c1))-0.047121;
c1=c1+0.0083*d1;
ig=(e<=90.5/180*pi)&(c1>-ep)&(c1<ep);
e(ig)=pi/2-atan(c1(ig)./sqrt(1-c1(ig).*c1(ig)));
szac=e*180/pi;

end;

