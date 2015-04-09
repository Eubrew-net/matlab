%RAYLEIGH3 optical depth
%tau = rayleigh3(wl)
%      wl in nm; weak parameters set for Davos      
%Ref: B.Bodhaine et al. J.Atm. and Ocean. Tech., 16, 1854-1861 (1999)
% 14 4 2007 julian: Compare with nicolet.m, and results are over range
% 300-900 within +-0.001 in optical depth

function tr=bodhaine(wl,pr)
%function tr=bodhaine(wl,pr)

if nargin<2,pr=[];end
if isempty(pr),pr=1013.25;end
    
siz=size(wl);
wl=wl(:)';  % 9 5 2014 JG

cco2=360;         %[ppm] assumed CO2 concentration
lat=47; hei=1600; %assumed latitude [deg] and height [m]
%hei=0;
%calculate refractive index of dry air at 1013.25hPa, 288.15K
%and 300 ppm CO2, after Peck and Reeder (1972)
wlm2=1.e+6./wl.^2; %wl^-2 in microns
Nm1=8060.51 + 2480990./(132.274-wlm2) +17455.7./(39.32957-wlm2);
%scale to assumed CO2 as given by Edlén (1966)
Nair=1+1.e-8*Nm1*(1+0.54e-6*(cco2-300));
nm1=(Nair.^2-1).^2; %(n^2-1)^2
np2=(Nair.^2+2).^2; %(n^2+2)^2
%calculate King factor using Bates (1984) depolarization 
n2=1.034+3.17e-4*wlm2; %N2
o2=1.096+1.385e-3*wlm2 +1.448e-4*(wlm2.^2); %O2
ar=ones(size(n2)); %Argon is isotropic
coo=1.15*ones(size(n2)); %constant for CO2
%   N2,    O2,    Ar,   CO2
dp=[n2;    o2;    ar;    coo];
%volume composition, percent 
vr=[78.084,20.946,0.934,cco2*1.e-4];
F=vr*dp/sum(vr); %King factor
%molecular density cm^-3 at 1013.25hPa and 288.15K
A=6.0221367e+23; %Avogadro's number
MV=22414.1; %molar volume [ccm]
N=A/MV*273.15/288.15;
%molecular scattering cross section in [cm^2 / molecule]
wlm4=1.e28./(wl.^4); %1/wl^4 in cm
sgm=24*pi^3/N^2.*wlm4.*nm1./np2.*F;
%mean molecular weight
MW=28.9595+1.50556e-5*cco2; %cco2 [ppm]
G=gravy(lat,hei);
tr=sgm*1013250*A/MW/G;
tr=tr*pr/1013.25;
tr=reshape(tr,siz);

function g=gravy(phi,hei) %pun intended
c2fi=cos(pi*phi/90); %cos(2*phi)
g0=980.616*(1-2.6373e-3*c2fi+5.9e-6*c2fi.^2);
%mass weighted mean height of US std.atmosphere
%as a function of geometric height.
z=0.73737*hei+5517.56;
g=g0 - (3.085462e-4+2.27e-7*c2fi)*z ...
   + (7.254e-11+1.e-13*c2fi)*z.^2 ...
   - (1.517e-17+6.e-20*c2fi)*z.^3;
