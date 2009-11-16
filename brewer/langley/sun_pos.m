% function [sza,saz,tst,snoon,sunrise,sunset,m2,m3]=sun_pos(date,lat,long)
% date en fecha matlab, lat(N+) y long(E+) en grados
% sza solar zenit angle, solar azimut angle en grados deg
% solar noon sunrise sunset en minutos
% tst true solar time en minutos
% m2 y m3 brewer airmass
function [sza,saz,tst,snoon,sunrise,sunset,m2,m3]=sun_pos(date,lat,long)
% function [sza,saz,tst,snoon,sunrise,sunset]=sun_pos(date,lat,long)
% sza solar zenit angle, solar azimut angle en grados deg
% solar noon sunrise sunset en minutos
% tst true solar time en minutos

%diajul=date-datenum(year(date),1,1)+1;

aux=yeardays(date);
year_=year(date);
diajul=aux;
time_min=(date-fix(date))*24*60;


%longitud en minutos
long_min=long;


%pasamos lat y long a radianes


lat=lat*pi/180;


long=long*pi/180;



phi=2*pi*(diajul-1.5)/365; % angulo diario (fractional year)


eqtime=222.18*(0.000075+0.001868*cos(phi)-0.038077*sin(phi)...
               -0.014615*cos(2*phi)-0.040849*sin(2*phi));
           
decl=0.006918-0.399912*cos(phi)  +0.070257*sin(phi)  -0.006758*cos(2*phi)...
             +0.000907*sin(2*phi)-0.002697*cos(3*phi)+0.001480*sin(3*phi);
 
time_ofset=eqtime+4*long_min;   % GMT


tst=time_min+time_ofset;


angulo_horario=deg2rad((tst/4)-180);



sza=acos(sin(lat).*sin(decl)+cos(lat)*cos(decl).*cos(angulo_horario));

%aux=pi/2-sza;aux=acos( (sin(lat).*sin(aux)-sin(decl))./ (cos(aux)*cos(lat)));


aux=acos( (sin(lat).*cos(sza)-sin(decl))./(cos(lat).*sin(sza))  );
saz=pi-aux;
jj=find(angulo_horario>0);
saz(jj)=2*pi-saz(jj);







% suponemos el amanecer a 90.833


%angulo_horario_amanecer=acos(  - ( cos(90.083) ./ ( cos(lat).*cos(decl) )) - tan(lat).*tan(decl) )
angulo_horario_amanecer=acos(  - ( cos(deg2rad(90.083)) ./ ( cos(lat).*cos(decl) )) - tan(lat).*tan(decl) );
ha=rad2deg(angulo_horario_amanecer);


sunrise=720- 4*(long_min+ha)-eqtime;
sunset= 720- 4*(long_min-ha)-eqtime;
%snoon= 720+4*long_min-eqtime;
snoon= 720-4*long_min-eqtime;

   


%airmass from brwewer
 R=6370;
 h2=22;%Km
 h3=5;%km
 m2=R/(R+h2);
 m3=R/(R+h3);
 m3=m3*sin(sza); m3=1./cos(asin(m3));
 m2=m2*sin(sza);  m2=1./cos(asin(m2));
 

%transformacion
sza=sza*180/pi;
saz=saz*180/pi;




function theResult = yeardays(theDate)

date = datenum(theDate);
d = datevec(theDate);
for i = 1:size(d,1)
    d(i,2:6) = [1 1 0 0 0];   % January 1, midnight.
end
newYearsDay = datenum(d);
delta = (theDate-newYearsDay);
theResult = [(1+delta)];

