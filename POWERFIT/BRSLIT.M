function [f,P]=brslit(fwhm,wl,plateau);
% function [f,P]=brslit(fwhm,wl,plateau);
% 18 6 97 julian
% calculates exact slit triangle for certain slit width.

if nargin<3,plateau=0.87;end

x=(-1*fwhm):0.05:(1*fwhm);
if nargin<2,wl=[];end

if ~isempty(wl),x=wl(:)';end



a1=1/fwhm;  % slopes of slit function
a2=-1/fwhm;
b=1; % offset (center)

y1=polyval([a1 b],x(x<0));
y2=polyval([a2 b],x(x>=0));

y=[y1 y2];

ind=y>plateau;
y(ind)=plateau*ones(size(y(ind)));

y(y<0)=zeros(size(y(y<0)));

y=y/max(y);
f=[x' y'];

if nargout==2,P=csapi(f(:,1),f(:,2));end



