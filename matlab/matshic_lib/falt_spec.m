function I=falt_spec(specwl,spec,wlout,P),
%function I=falt_spec(specwl,spec,wlout,P),
% 4 3 2014 JG
% convolves spec with P on wlout
% uses falt_eqi
% 9 7 2014, JG error when nans at begin of spectrum, then removes too much of convolved spectrum.

d1=diff(specwl);d2=diff(wlout);md1=min(d1);md2=min(d2);per=md2/md1;

if max(d1)-min(d1)>1e-6 | max(d2)-min(d2)>1e-6 | abs(per-round(per))>1e-6
    eqi=0;
else
    eqi=1;
end

spec(isnan(spec))=0; % 9 7 2014 JG

if eqi,
I=falt_eqi(specwl,spec,wlout,P);
else
etc_temp=falt_eqi(specwl,spec,specwl,P);
I=spline(specwl,etc_temp,wlout);  % non equidistant grid...
end
