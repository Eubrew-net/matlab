function [ZA,M2,M3,AZ,ZC]=brewersza(T0,jday,yr,lat,long,mode,ho3,hray)
% function [ZA,M2,M3,AZ,ZC]=brewersza(T0,jday,yr,lat,long,mode,ho3,hray);
% OR [ZA,M2,M3,AZ,ZC]=brewersza(TIME_MATLAB,[],[],lat,long,mode,ho3,hray);  13 7 2007 JG
% same as basic program.
% 10 12 97 julian
% works and is same as brewer!!.
% M2 is ozone, M3 is rayleigh passlength.
% 20 6 98 julian add azimuth.
% 12 11 98 julian use moon calculation, choose with mode
% mode='sun','azimuth','moon';
% Brewers calculate Longitude positive going west. True it should be going EAST
% 23 1 99 julian. default is for brewer
% 25 1 99 julian change possible heights of ozone and rayleigh
% 31 5 99 julian support azimuth
% 28 2 2000 julian y2k error
% 26 11 2012 JG, error when checking for matlab time
% 21 1 2013 JG add correct moon algorithm from natalia

% 1 calculate yeardecimal starting in 1956

global BREWER PMOD

[bjday,dd,mm,byr]=julianday;

if nargin==0,
% [jday,dd,mm,yr]=julianday;
 T0=rem(now,1)*24*60;
% lat=BREWER.latitude;
% long=BREWER.longitude;
% mode=[];
% ho3=[];
% hray=[];
end
if nargin<8,hray=[];end
if nargin<7,ho3=[];end
if nargin<6,mode=[];end
if isempty(ho3),ho3=22;end
if isempty(hray),hray=5;end
if isempty(mode),mode='sun';end
if nargin<5,long=[];end;if isempty(long),long=PMOD.long;end
if nargin<4,lat=[];end;if isempty(lat),lat=PMOD.lat;end
if nargin<3,yr=[];end;if isempty(yr),yr=byr;end
if nargin<2,jday=[];end;if isempty(jday),jday=bjday;end

%13 7 2007 julian add matlab time format
%if T0(1)>1e5,   % then it is matlab time
   if any(T0>1e5),
    [yr,m,d,h,mi,s] = datevec(T0);
    jday=julianday(T0);
    T2=h*60+mi+s/60;
   else
       T2=T0; % 24 1 2013 JG need to set T2 to minutes
end


R=6370;
 EP=1-eps;%0.999999999999999;

if strcmp(lower(mode),'moon'),
 %[RA,A]=moonsza(T0,long,jday,yr);
 if T0<1e5,
     T0=datenum(yr,1,jday,0,T0,0);
 end
 [AZ,el]=LunarAzEl(T0,lat,-long,0);  % 21 1 2013 JG no height information, long is pos going east
 ZA=90-el;
 E=ZA*pi/180;
M3=R./(R+hray).*sin(E);
M3=1./cos(atan(M3./sqrt(1-M3.^2)));
%M2=.99656*sin(E);
M2=R./(R+ho3).*sin(E);
M2=1./cos(atan(M2./sqrt(1-M2.^2)));
return
else
%if strcmp(lower(mode),'sun') | strcmp(lower(mode),'azimuth'),
 if yr<65,yr=yr+100;end % in case 2010 will be only 10.
 if yr<1900,yr=yr+1900;end
 T=(datenum(yr,1,1)-datenum(1965,1,1)+jday)/365.2422;  % yeardecimal starting 1965
 I=(279.4574+360*T+T2/1460.97)*pi/180; %can be vector

 E=4.2*sin(3*I)-2*cos(2*I)+596.5*sin(2*I)-12.8*sin(4*I)+19.3*cos(3*I);
 E=E-(102.5+.142*T).*sin(I)+(.033*T-429.8).*cos(I);
 RA=(T2+E/60+720-long*4)*pi/180/4;
 A=atan(.4336*sin(I-E*pi/180/240));
%else % here moon
% [RA,A]=moonsza(T0,long,jday,yr);
end 
E=cos(RA).*cos(A)*cos(lat*pi/180)+sin(lat*pi/180)*sin(A);
E(E>=1)=EP; %if E>=1,E=EP*ones(size(E));end
E(E<=-1)=-EP; %if E<=-1,E=-EP*ones(size(E));end

AZ=(sin(A)-E*sin(lat*pi/180))./sqrt(1-E.*E)/cos(lat*pi/180);
AZ(AZ<=-1)=-EP;%if AZ<=-1, AZ=-EP*ones(size(AZ));end
AZ(AZ>=1)=EP;%if AZ>=1, AZ=EP*ones(size(AZ));end
AZ(AZ==0)=eps;%if AZ==0, AZ=.0000001;end
E(E==0)=eps;%if E==0,E=.0000001;end

AZ=atan(sqrt(1-AZ.*AZ)./AZ)*180/pi;
E=atan(sqrt(1-E.*E)./E);
E(E<0)=E(E<0)+pi;%if E<0,E=E+pi;end%REM ** ERROR ON CONVERSION **
RA=sin(RA);
AZ(AZ<=0&RA<=0)=AZ(AZ<=0&RA<=0)+180;%if AZ<=0 & RA<=0, AZ=180+AZ;end

ind1=AZ<=0;
ind2=~ind1;
AZ(RA>0&ind1)=180-AZ(RA>0&ind1);
AZ(RA>0&ind2)=360-AZ(RA>0&ind2);

%M3=.999216*sin(E);
M3=R./(R+hray).*sin(E);
M3=1./cos(atan(M3./sqrt(1-M3.^2)));
%M2=.99656*sin(E);
M2=R./(R+ho3).*sin(E);
M2=1./cos(atan(M2./sqrt(1-M2.^2)));
refract=E<=90.5*pi/180;
%if E<=90.5*pi/180, %:REM DO NOT correct refraction if zenith < 90.5
   C1=cos(E);
   D1=1./(.955+(20.267*C1))-.047121;
   C1=C1+.0083*D1;
   ind=refract&C1>-EP&C1<EP;
   E(ind)=pi/2-atan(C1(ind)./sqrt(1-C1(ind).^2));%if C1>-EP & C1<EP, E=pi/2-atan(C1/sqrt(1-C1^2));end
   %end
ZA=E*180/pi;
ZC=ZA;
ZC(RA<0)=-ZA(RA<0);

if nargout==1,
 ZA=ZC;
end

function [RA,A]=moonsza(T0,LO,jday,YE)
%function moonsza()
% 3 2 99 julian
% moon position from brewer
% 21 1 2013 JG gives wrong results...

MO=str2num(datestr(datenum(YE,1,jday)));

P0=pi/180;

%REM -8499 calculate lunar position
TT=(YE-84)*365+fix((YE-80)/4);
if MO<3 & rem(YE,4)==0, TT=TT-1;end

TT=(TT-5845.5+jday+T0/1440)/36525;
T2=TT.*TT;T3=T2.*TT;E=(84381.448-46.815*TT-.00059*T2+.001813*T3)/3600;
C=fun1(36000.7701,TT);
DT=100.460618+C+(.093104*T2-.0000062*T3)/240+T0/4;
DT=rem(DT,360);
LB=218.32+fun1(481267.883,TT);
LB=LB+6.29*sin((134.9+fun1(477198.85,TT))*P0);
LB=LB-1.27*sin((259.2-fun1(413335.38,TT))*P0);
LB=LB+.66*sin((235.7+fun1(890534.23,TT))*P0);
LB=LB+.21*sin((269.9+fun1(954397.7,TT))*P0);
LB=LB-.19*sin((357.5+fun1(35999.05,TT))*P0);
LB=LB-.11*sin((186.6+fun1(966404.05,TT))*P0);
DT=rem(DT,360);
BT=5.13*sin((93.3+fun1(483202.03,TT))*P0);
BT=BT+.28*sin((228.2+fun1(960400.87,TT))*P0);
BT=BT-.28*sin((318.3+fun1(6003.18,TT))*P0);
BT=BT-.17*sin((217.6-fun1(407332.2,TT))*P0);
PL=.9508+.0518*cos((134.9+fun1(477198.85,TT))*P0);
PL=PL+.0095*cos((259.2-fun1(413335.38,TT))*P0);
PL=PL+.0078*cos((235.7+fun1(890534.23,TT))*P0);
PL=PL+.0028*cos((269.9+fun1(954397.7,TT))*P0);
SD=.2725*PL;R=1./sin(PL*P0);
L=cos(BT*P0).*cos(LB*P0);
M=cos(E*P0).*cos(BT*P0).*sin(LB*P0)-sin(E*P0).*sin(BT*P0);
N=sin(E*P0).*cos(BT*P0).*sin(LB*P0)+cos(E*P0).*sin(BT*P0);
DC=atan(N/sqrt(1-N.*N))/P0;LF=sign(L.*M)*90;

ind=L~=0;LF(ind)=atan(M(ind)./L(ind))/P0;
ind=L<0;LF(ind)=LF(ind)+180;
HA=rem(DT-LF,360);
RA=(HA-LO)*P0;
A=DC*P0;


function f=fun1(C,TT)
f=C.*(TT-fix(TT.*C/360)*360./C);

