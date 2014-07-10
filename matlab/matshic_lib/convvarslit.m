function etconv=convvarslit(et_spec,slit,wlout)
%function etconv=convvarslit(et_spec,slit,wlout)
% slit is struct, with three fields, wl, data, and slit_wl, where the slits are given in data
% vector is slit, column is slit_wl
% 19 6 2014 JG, problem with extrapolations of spline
% 8 7 2014 JG slitint is produced in matshic, no need to do it here

if nargin<3,wlout=[];end

fast=1;    % 28 4 2014 JG neeed slitint

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
    ind=abs(et_spec(:,1)-wl_var(i))<=slitlen & ~isnan(et_spec(:,2));   % 19 6 2014 need also to remove Nans for falt_eqi
    ind_sav=abs(et_spec(:,1)-wl_var(i))<=inc;
    if sum(ind)>1 & sum(ind_sav)>1,
        try
       etconv(ind_sav)=falt_eqi(et_spec(ind,1),et_spec(ind,2),et_spec(ind_sav,1),P_var);
        catch
          %  disp(sprintf('Error duing convvarslit:wl_var=%f',wl_var(i)));
        end
    end
end
if isempty(wlout),
etconv=[et_spec(:,1) etconv];
else
    ind=~isnan(etconv);
    etconv=[wlout(:) spline(et_spec(ind,1),etconv(ind),wlout(:))];
    etconv(wlout<min(et_spec(ind,1)),2)=nan;
    etconv(wlout>max(et_spec(ind,1)),2)=nan;
    
end
