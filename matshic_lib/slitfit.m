function [wl,fwhm]=slitfit(slit,type,pl,fignb)
%function [wl,fwhm]=slitfit(slit,type,pl)
% 2 11 2011 JG gauss fit to slit function
% type=0, default, fit with isoceles triangle
% type=1, gaussfit (array SRM)
%type=2, supergauss fit
% slit is two columns,
% 31 7 2013 add young-ohno supergaussian fit
% 20 2 2014 JG, make gaussfit =1.177;

if nargin<4,fignb=[];end
if isempty(fignb),fignb=0;end
        
if nargin<3,pl=[];end
if isempty(pl),pl=0;end
if nargin<2,type=[];end
if isempty(type),type=0;end

slit(:,2)=slit(:,2)/max(slit(:,2));  % normalise to 1
switch type,
    case 0, % standatd isoceless fit
        [wl,fwhm]=isofit(slit,pl);
    case 1, % do gaussfit
        [wl,fwhm]=gaussfit(slit,pl,fignb);
    case 2, % supergaussian fit
        [wl,fwhm]=supergaussfit(slit,pl,fignb);
    case 3, % supergaussian fit
        [wl,fwhm]=gauss2fit(slit,pl,fignb);

end



function [center,fwhm]=gaussfit(slit,pl,fignb)

gauss = @(x,xdata) x(4) + x(3)./(sqrt(2*pi)*x(2)).*exp(-(xdata-x(1)).^2./(2*x(2).^2));

xdata=slit(:,1);
ydata=slit(:,2);
halfwidth = (max(xdata)-min(xdata))/2;
intensity = 1;
background = 0;

x0=[mean(xdata), halfwidth, 1, background];

out = lsqcurvefit(gauss,x0,xdata,ydata, [xdata(1), 0.01, 0.1, -1000], [xdata(end), 100, 10, 1000],optimset('Display','off'));

center=out(1);
if 0,   % geht nicht, da es oft auch aussreisser in den Daten gibt.
f=@(x,c) abs(normpdf(x,c(1),c(2))/normpdf(c(1),c(1),c(2))-0.5);
fwhm=fminbnd(@(x)f(x,out(1:2)),0,out(2)*2)*2;  % is about 17% larger than MU
end
fwhm=out(2)*2*1.177;   % 20 2 2014 JG

if pl,   % do plot
    xi=min(xdata):mean(diff(xdata))/10:max(xdata);
    if ~fignb,
        figure;
    else
        figure(fignb);hold on;
    end
      buf=gauss(out,xi);
       plot(xdata,ydata/max(buf),'.',xi,gauss(out,xi)/max(buf));grid;
end

function [center,fwhm]=isofit(slit,pl);
% 2 11 2011 JG use dsp
x=slit(:,1);
y=slit(:,2);
%indmax=find(y==max(y));
%ind=abs(x-x(indmax))<10;
%x=x(ind);
%y=y(ind);


x=[x;x(end:-1:1)];
y=[y;y(end:-1:1)];
[wl1,wl2,fwhm]=dsp([x y],'',[],[],pl);

center=wl1;

function [center,fwhm]=supergaussfit(slit,pl,fignb)

supergauss = @(x,xdata)  (x(6).*(exp(-((x(1)-xdata).*x(2)./(x(3).*(xdata<x(1))+x(4).*(xdata>=x(1)))).^2)+2.*exp(-(abs(x(1)-xdata)./(x(3).*(xdata<x(1))+x(4).*(xdata>=x(1)))).^x(5))));
bp=@(m,x0,ks,kl,kr,g,x) m*(exp(-((x0-x)*ks./(kl.*(x<x0)+kr.*(x>=x0))).^2)+2*exp(-(abs(x0-x)./(kl.*(x<x0)+kr.*(x>=x0))).^g));

xdata=slit(:,1);
ydata=slit(:,2);
halfwidth = (max(xdata)-min(xdata))/2;
intensity = 1;
background = 0;
center=xdata(ydata==max(ydata));

x0=[center, 3, 1, 1,2,0.3];

[out,a,b,c,d] = lsqcurvefit(supergauss,x0,xdata,ydata, [xdata(1), -1, -1, -1,0,0], [xdata(end), 10, 10,1,3,1],optimset('Display','off','TolFun',1e-8,'maxfunevals',8000,'maxiter',8000));
x00=center;
m0=1/3;  

f=fit(xdata,ydata,bp,'startpoint',[m0,x00,3,1,1,2],'lower',[m0/2,x00-1,0.5,0.8,0.5,1],'upper',[m0*2,x00+1,5,2,4,3],'robust','LAR','maxfunevals',8000,'maxiter',8000,'TolFun',1e-7);
disp(f);


center=out(1);

fwhm=out(2)*2*1.177;   % 5 6 2012 JG

if pl,   % do plot
    xi=min(xdata):mean(diff(xdata))/10:max(xdata);
    if ~fignb,
        figure;
    else
        figure(fignb);hold on;
    end
      buf=supergauss(out,xi);yyy=f(xi);
       %plot(xdata,ydata,'.',xi,supergauss(out,xi),xi,yyy);grid;
       plot(xdata,ydata,'.',xi,supergauss(out,xi));grid;
end

function [center,fwhm]=gauss2fit(slit,pl,fignb)

gauss2 = @(x,xdata)  (x(7)+x(3).*exp(-((xdata-x(1))./x(2)).^2)+x(6).*exp(-((xdata-x(4))./x(5)).^2));

xdata=slit(:,1);
ydata=slit(:,2);
halfwidth = (max(xdata)-min(xdata))/2;
intensity = 1;
background = 0;
center=xdata(ydata==max(ydata));

x0=[center, halfwidth, intensity,center, halfwidth, intensity,0];

[out,a,b,c,d] = lsqcurvefit(gauss2,x0,xdata,ydata, [xdata(1), 0, 0, 0,2,0], [xdata(end), 10, 10,1,3,1e4],optimset('Display','off'));

center=out(1);

fwhm=out(2)*2*1.177;   % 5 6 2012 JG

if pl,   % do plot
    xi=min(xdata):mean(diff(xdata))/10:max(xdata);
    if ~fignb,
        figure;
    else
        figure(fignb);hold on;
    end
      buf=gauss2(out,xi);
       plot(xdata,ydata/max(buf),'.',xi,gauss2(out,xi)/max(buf));grid;
end