function [f,saveslitpos,rmsf,pwl,pstps,parm]=powfiu7(x,wl,A,p,fit288,per288,per48,fname);
% function [f,saveslitpos,rmsf,pwl,pstps,parm]=powfiu7(x,wl,A,p,fit288,per288,per48,fname);
% 27 10 97 use with fmins to minimise all slit positions.
% 7 1 98 julian new theta
% 8 1 98 julian NEIN some more add linear fit term to dwl calculation for every slit.
% 9 1 98 julian theta muss berechnet werden bei jedem slit.
% 9 1 98 Julian Einzig richtige Version .
% 12 1 98 julian new slitpositions defined
%slitein=x(1);
% 13 1 98 julian for narrow slit0 pos=46.783 mm;
% 22 1 98 julian leave slit 3 fixed, is good enough for fit, even better because fewer param.
% 12 8 98 julian. remove fmin for theta calculation. works. takes about 0.8 secs  versus 10 secs
%                 most time is spent in printing out to screen!!

% here are constants:
radius=324;% mirror radius
slitsp=107.77;% input-output slit separation 
% symmetric around slit 1.
%slitpos0=([-.393 -.2763 -.1317 0 .1407 .2760]) * 25.4 +58; % 27 10 97 control on Br#80 OK is ok 13 1 98
% 23/12/97 julian new from david W.
slitpos0=([-10.122 -7.158 -3.485 0 3.434 6.871])+57.90;  % 13 1 98 julian NEW
nd=3600; % grating (n/d) per mm converted to per Angstrom
nd=nd*1e-7;


if nargin==0,
   f=slitpos0;
   return
end


if nargin==1,  % request old slitposition.
   f=slitpos0;f(1)=46.783;
   return
end

if isempty(x),x=slitpos0;end

if nargin<4,p=[];end
if nargin<5,fit288=[];end
if ~isempty(fit288),
 if nargin<6,per288=288;end
 if nargin<7,per48=48;end
else
   per288=[];
   per48=[];
end


%if isempty(per288),per288=288;end
%if isempty(per48),per48=48;end


slitpos=x(1:6);
%if isempty(slitein),slitein=50;end % control on Br#80 ok.

loopmax=1:10; % 12 1 98 julian 5 is enough.
if isempty(slitpos),
   slitpos=slitpos0;loopmax=1:10;
else 
 if length(slitpos)==1,slitpos=slitpos0+slitpos;  loopmax=1:10;end
end
if slitpos(1)<30, % only differnences were given here
   slitpos=slitpos+slitpos0;loopmax=1:10;
end

slitnb=size(slitpos,2);
if isempty(p),p=3;end
%wl=A(:,1); % all wavelengths in matrix.

parm=zeros(1,p+5);% check number of parameters in function:powerfit.m

pdwl=[]; 
nwl=size(wl,1); % number of wavelengths
theta=zeros(nwl,slitnb);

slitpos00=slitpos;

%epsi=2*asin(slitein/radius)*180/pi;  

%if slitpos(1)<47.5  % old slit
% loopmax=1:20;  % do more iterations.
%end

for loop=loopmax, % loop for different slit positions.
   
%for j=1:slitnb,
%   for i=1:nwl, % do it in loop to change slitpos(4) if needed.
%     theta(i,j)=fmin('thetafit',0,90,[],wl(i)*nd,epsi,2*asin(slitpos(j)/324)*180/pi);
%  end
%end

   saveslitpos(loop,:)=slitpos;

[dwl,phi]=powerwl(slitpos,wl); % reference is slit 3. defined in function
   wlslits=wl(:,ones(1,slitnb))-dwl; % make wavelength matrix.
   
   
   % fit resulting values to power law.
   xi=A(:,[1:(slitnb)]); % steps
   inda=xi==0;
   xi=xi(:);% this are steps
   yi=wlslits(:); % this are wavelengths modified by dwl
   ind=(xi~=0); 
   
   if isempty(fit288),
     pstps=polyfitm(xi(ind),yi(ind),p); % fit steps, wl with scaling
     ycalc=polyval(pstps,xi); % fit data to polynomial returns wavelength
     pwl=polyfitm(yi(ind),xi(ind),p); % fit wl,steps
     parm=[];
  else
     % fit data to arbitrary function in powerfit.m
      parm=fsolve('powerfit',parm,[],xi(ind),yi(ind),per288,per48);
      ycalc=yi-powerfit(parm,xi,yi,per288,per48);
  end %of if
  dslit=zeros(nwl,slitnb);
  dslit(:)=yi-ycalc;
  dslit(inda)=zeros(size(dslit(inda)));
  %f=std(dslit(:));   %is equal to : sum(dslit(:).^2)/length(dslit(:))

% 30 9 97 julian new.
  inds=dslit~=0;
  dphi=zeros(size(dslit));
  
  dphi(inds)=nd*dslit(inds)./cos(pi/180*(theta(inds)+phi(inds))); % in radians
  
  
  slitpos=1/1*(radius*sin(mean(phi*pi/180+dphi)/2)-slitpos) + slitpos;
  slitpos(4)=slitpos00(4); % do not move slit 3
  %slitpos(slitsym)=slitpos0(slitsym); % keep slit 1 fixed;
  %slitpos-slitpos00   % rem out 5 9 2007 julian
  
  missingslits=sum(all(dslit==0)); % returns 1 for every column of zeros.
  %freecoef=5*(loop>1)+p+1+4*(~isempty(fit288))
  freecoef=5*(loop>1)+p+1+2*(~isempty(per288)+~isempty(per48))-missingslits
  rmsf(loop)=sigma(dslit,freecoef);
  f(:,:,loop)=dslit;
end % of for loop


if nargout==1,
 f=sigma(dslit(dslit~=0),freecoef);
else
% f=dslit;
% disp(['Dsl=' sprintf('%5.3f,',slitpos-slitpos00) 'mm']);
end

if nargin<8, return;end

% here save data to mat file.

metadata=['datafile used:' inputname(3)];

disp(sprintf('saving data to file:%s',fname))
save(fname,'pwl','pstps','slitpos','metadata');

