function [dwl,phi]=powerwl(slitpos,wl);
%function [dwl,phi]=powerwl(slitpos,wl);
% 12 8 98 julian calculates wl shift for different slits.
% is used by powfiu7 and brstps2 to calculate wl from steps and vice-versa
% reference slit is slit 3

nd=3600e-7; % 3600 lines per mm
radius=324; % mm
slitein=50.01;

epsi=2*asin(slitein/radius);

wla=repmat(wl(:),1,length(slitpos));
sla=repmat(slitpos,length(wl),1);

guess(:,:,1)=asin(nd*wla/2/cos(epsi));
for i=2:20,
    guess(:,:,i)=asin(nd*wla-sin(guess(:,:,i-1)+2*asin(sla/324)))+epsi;
end

theta=guess(:,:,i);

phi=2*asin( (slitpos)/radius );  % 30 9 97 new
phi=phi(ones(size(wl)),:);

dwl=1/nd*(sin(theta+phi)-sin(theta+2*asin(slitpos(4)/radius)));

phi=phi*180/pi;