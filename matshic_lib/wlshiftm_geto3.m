function a=wlshiftm_geto3(x,wl,I,etc,m,ozxsec)
% 4 11 2013 JG add airmass

atmos=ozxsec.*x/1e3;

ind=~isnan(atmos);

rat=I(ind)./(exp(-atmos(ind).*m).*etc(ind));


a=std(rat);
%a=abs(buf(1));


