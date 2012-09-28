function f=nicolet(wl,P)
%function f=nicolet(wl,P)
% calculates rayleigh optical depth from nicolet(19) assuming
% columnar number desnity = 2.154e25/cm^2 from Teillet(1990)
% wl in nanometers.
% P is station pressure in millibar.default is 1013.25

if nargin <2,P=1013.25;end

N=2.154e25;

wl=wl/1000; % microm

f=4.02e-28./wl.^(4+0.389*wl+0.09426./wl-0.3228)*N*P/1013.25;

%f(:,2)=0.00838.*wl.^(-3.916-0.074*wl-0.05./wl)*P/1013.25;  % froehlich und shaw
