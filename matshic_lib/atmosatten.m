function [extinction,to3,tray]=atmosatten(wls,O3,pr,o3type)
%function [extinction,to3,tray]=atmosatten(wls,O3,pr,o3type))
% 28 9 99 julian
% calculate extinction for ozone, rayleigh at wavelengths wl (nm)
% use result as exp(-exp*m)
% airmass is up to external use
% o3type is :
% 1 = paurbas
% 2 = brion
% 3 = GOME (also visible)

% 28 4 2005 julian adapt for mac.
% 7 6 2012 JG add o3 gome in chappuis band and change output

if nargin<4,o3type=[];end
if isempty(o3type),o3type=1;end
if nargin<2,O3=[];end
if isempty(O3),O3=350;end
if nargin<3,pr=[];end
if isempty(pr),pr=1013;end

switch o3type,
 case 1,  % paurbass
%  load g:\brewer\ausgldir\o3coeff\ozxsec2.dat 
%   load /mnt/D/matlab_files/data_files/ozxsec2.dat
   load ozxsec2.dat
  f=ozxsec2;
 case 2,  % brion
 % load /matlab_files/data_files/xsections/brion
 load brion
  ozxsec2(:,1)=brion(:,1)/10;
  ozxsec2(:,4)=brion(:,2);
case 3,  % GOME
  f=liesfile('/matlab_files/data_files/xsections/volodya/xo3_221.dat',11,2);
  ozxsec2(:,1)=f(:,1);
  ozxsec2(:,4)=f(:,2);
end

% 7 6 2012 JG add chappuis band
load o3gome_chappuis
o3xsec=[ozxsec2(:,[1 4]); o3gome(901:end,:)];  % at 901 wl=332.46 nm;

k=1.3806e-23;
%o3x=ozxsec2(:,4).*1.013*1e5/(k*273.1)*1e-6;  
%o3wl=ozxsec2(:,1); % in nm
o3x=o3xsec(:,2).*1.013*1e5/(k*273.1)*1e-6;  
o3wl=o3xsec(:,1); % in nm

ind=diff(o3wl)==0;
o3x(ind)=[];
o3wl(ind)=[];


dray=nicolet(wls,pr);
dray=dray(:);

pp=spline(o3wl,o3x);
O3=O3(:)';
%do3=ppval(pp,wls)*O3/1000; % total absorption
do3=ppval(pp,wls);%*O3/1000; % total absorption

do3(wls>max(o3wl))=0;
do3(wls<min(o3wl))=nan;
do3=do3(:);

%extinction=do3+dray;

extinction=repmat(do3,1,length(O3)).*repmat(O3,size(do3,1),1)/1000+repmat(dray,1,length(O3));
 
to3=repmat(do3,1,length(O3)).*repmat(O3,size(do3,1),1)/1000;
tray=+repmat(dray,1,length(O3));


