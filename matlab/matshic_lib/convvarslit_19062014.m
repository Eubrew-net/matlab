function etconv=convvarslit(et_spec,slit,wlout)
%function etconv=convvarslit(et_spec,slit,wlout)
% slit is struct, with three fields, wl, data, and slit_wl, where the slits are given in data
% vector is slit, column is slit_wl

if nargin<3,wlout=[];end

fast=0;    % 28 4 2014 JG neeed slitint

if ~fast,  % 7 2 2014, is done external to speedup
    slitlen=ceil((max(slit.wl)-min(slit.wl))/2+0.1);   % wavelength range given by slit in nm
    
    inc=slitlen/2;
    wl_var=[min(et_spec(:,1)):inc:max(et_spec(:,1))]';
    
    if wl_var(1)<min(slit.slit_wl),
        slit.slit_wl=[wl_var(1) slit.slit_wl];
        slit.data=[slit.data(:,1) slit.data];
    end
    if wl_var(end)>max(slit.slit_wl),
        slit.slit_wl=[slit.slit_wl wl_var(end)];
        slit.data=[slit.data slit.data(:,end) ];
    end
    
    
    slit.slitint=griddata(slit.slit_wl,slit.wl,slit.data,wl_var',slit.wl,'cubic');  % takes about 2.5 seconds , jg machine...
end

slitlen=ceil((max(slit.wl)-min(slit.wl))/2+0.1);   % wavelength range given by slit in nm
inc=slitlen/2;
wl_var=[min(et_spec(:,1)):inc:max(et_spec(:,1))]';

etconv=repmat(nan,size(et_spec,1),1);

for i=1:length(wl_var),
    P_var=csapi(slit.wl,slit.slitint(:,i));   % take correct slit
    ind=abs(et_spec(:,1)-wl_var(i))<=slitlen;   
    ind_sav=abs(et_spec(:,1)-wl_var(i))<=inc;
    etconv(ind_sav)=falt_eqi(et_spec(ind,1),et_spec(ind,2),et_spec(ind_sav,1),P_var);
   
end
if isempty(wlout),
etconv=[et_spec(:,1) etconv];
else
    etconv=[wlout(:) spline(et_spec(:,1),etconv,wlout(:))];
end
