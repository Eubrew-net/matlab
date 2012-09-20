function [wlair,dwl]=wlrefrac(wl,p,t)
%function [wlair,dwl]=wlrefrac(wl,p,t)
% 12 5 98 julian
% calculates wavelength shift in nm for P and T
% dwl = wlvac-wlair
% p should be in mbar
% wl is wl vacuum

if nargin<3,t=15;end
if nargin<2,p=[];end % in Pascal

if isempty(p),p=1013.25;end % p in mbar

p=p*100 ;%p in pascal.

corrfac=p*(1+p*(61.3-t)*1e-10)/(96095.4*(1+0.003661*t));

sigma=1./(wl*1e-3); % change to micrometers

nn=8342.13+2406030./(130-sigma.^2)+15997./(38.9-sigma.^2);

nn=nn*corrfac;

wlair=wl./(nn*1e-8+1);

dwl=wl-wlair;

