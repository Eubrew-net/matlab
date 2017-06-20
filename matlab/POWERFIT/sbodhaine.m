%RAYLEIGH3 optical depth
%tau = rayleigh3(wl)
%      wl in nm;      
%Ref: B.Bodhaine et al. J.Atm. and Ocean. Tech., 16, 1854-1861 (1999)
% TODO UNITS
function [xb,xs] = sbodhaine(x) % x in nm
% Calculate Rayleigh Xsecs as in Bodhaine et al.
x=x(:);
x=x/1000;

%xs0=0.02152 (sea level 45)   %(PA/ma g)

xs= 0.002152*(1.0455996 - (341.29061 * x.^-2) - (0.90230850 * x.^2));
xs= xs ./ (1+0.0027059889 * x.^-2 - 85.968563 * x.^2);
xb=xs*10^4/log(10);