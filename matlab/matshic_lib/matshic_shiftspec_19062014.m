function [wlout,Iinst,Inom]=matshic_shiftspec(spec,dwl,etc,slit,slitnom,wlout)
%function [wlout,Iinst,Inom]=matshic_shiftspec(spec,dwl,etc,slit,slitnom,wlout)
%17 4 2013 JG
% shift spectrum and convolve with supplied slit function, based on ET Spectrum
% ET Spectrum has here air wavelengths
% fwhm is for nominal slit function (default 1 nm)
% 28 1 2014, add wlout optional
% 7 2 2014 JG, make variable slit here
% 3 3 2014, JG add option not to calculate instrument slit
% 4 3 2014, add non equidistant grid for single slit
% 5 3 2014, add try catch, in case of error write out nans in specs

global MATSHIC

if nargin<6,wlout=[];end

try
    warning off MATLAB:chckxy:nan
    
    wl=spec(:,1);
    if isempty(wlout),wlout=wl;end
    convwl=min(wl):0.01:max(wl);
    
    p=linint(wl',dwl');
    convdwl=ppual(p,convwl);
    
    if ~MATSHIC.varslit
        P=csapi(slit(:,1),slit(:,2));
        I=falt_spec(etc(:,1),etc(:,2),convwl,P);
    else
        I=convvarslit(etc,slit,convwl);
        I=I(:,2);
    end
    Iinst=spline(convwl-convdwl,I,wl);
    
    ratio=spec(:,2)./Iinst;
    
    if 0,
        buf=linint(wl'+dwl',ratio');   % put back on correct wl grid
        myetc=etc(:,2).*ppual(buf,etc(:,1));
    else
        myetc=etc(:,2).*spline(wl'+dwl',ratio',etc(:,1));
    end
    
    if ~MATSHIC.varslit,
        I2=falt_spec(etc(:,1),myetc,convwl,P);
    else
        I2=convvarslit([etc(:,1),myetc],slit,convwl);
        I2=I2(:,2);
    end
    Iinst2=spline(convwl-convdwl,I2,wl);
    ratio2=spec(:,2)./Iinst2;
    
    if 0,
        buf2=linint(wl'+dwl',ratio'.*ratio2');
        myetc=etc(:,2).*ppual(buf2,etc(:,1));
    else
        myetc=etc(:,2).*spline(wl'+dwl',ratio'.*ratio2',etc(:,1));
    end
    
    if ~MATSHIC.varslit,
        I3=falt_spec(etc(:,1),myetc,convwl,P);
    else
        I3=convvarslit([etc(:,1),myetc],slit,convwl);
        I3=I3(:,2);
    end
    Iinst3=spline(convwl-convdwl,I3,wl);   % this should be identical to measurement
    
    if ~MATSHIC.noinstspec,    % 3 3 2014, JG option
        if ~MATSHIC.varslit,
            Iinst=falt_spec(etc(:,1),myetc,wlout,P);
        else
            Iinst=convvarslit([etc(:,1) myetc],slit,wlout);
            Iinst=Iinst(:,2);
        end
        ind=wlout<min(wl) | wlout>max(wl);   % 28 1 2014 remove extrapolated values
        Iinst(ind)=nan;
    else
        Iinst=repmat(nan,length(wlout),1);
    end
    Pnom=csapi(slitnom(:,1),slitnom(:,2));
    Inom=falt_spec(etc(:,1),myetc,wlout,Pnom);
    ind=wlout<min(wl) | wlout>max(wl);   % 28 1 2014 remove extrapolated values
    Inom(ind)=nan;
    
catch
    disp(sprintf('Error during matshic_shiftspec: %s',lasterr));
    Iinst=repmat(nan,size(wlout));
    Inom=repmat(nan,size(wlout));
end