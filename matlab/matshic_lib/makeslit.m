function slit=makeslit(wl,fwhm)
%function slit=makeslit(wl,fwhm)
% 20 2 2014 JG
% produce slit function matrix for matSHIC using FWHM function and wavelength range
% return structure compatible with matSHIC
% wl in nm, fwhm in nm
% default, produce gauss slitfunction


%slit function bounds:
wlbound=ceil(max(fwhm)*2);
step=wlbound/100;  % for 1 nm fwhm, gives value every 0.05 nm.
slit.wl=(-wlbound:step:wlbound)';

slit.slit_wl=wl;
sigma=fwhm/2/1.177;  % to go from FWHM to STD of a normal pdf function (see slitfit.m)
slit.data=repmat(nan,length(slit.wl),length(fwhm));
for i=1:length(wl),
 buf=normpdf(slit.wl,0,sigma(i));
slit.data(:,i)=buf./max(buf);
end



