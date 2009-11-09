function [resumen,salida_m,salida]=ozonecoeff3(fname,ozonepos,dcfname,outfname,uvr);
%function ozonecoeff2(fname,ozonepos,dcfname,outfname);
% 4 2 98 julian
% ozonepos is total steps from uvzero.
% dcfname is dcfile name for brstps.
% fname is data from alldsp
% dcfname is file ontained from savedsp
% outfname is were log should be written

% 12 nov 97 julian
% finally works.
% 22 12 97 julian Add rayleigh scattering use nicolet.m
% 22 5 98 julian add so2 data
% 13 9 98 julian use new constants from powfiu7

%load \brewer\dsp\oct97\oct97_4; % 14 11 97 new fwhm calculation.
%fwhm=fwhmoct97;

%load \brewer\ausgldir\o3coeff\o3x1t.dat;
%load \brewer\ausgldir\o3coeff\o3x1wl.dat;
%load \brewer\ausgldir\o3coeff\o3x1.dat;
%o3x1wl=o3x1wl*10;

%T=-45+273.15  % as defined for ozone calc.

%o3x1T=zeros(size(o3x1wl));
%for j=1:length(o3x1wl),
%      o3x1T(j)=polyval(polyfit(o3x1t,o3x1(j,:),1),T);
%end

%figure;plot(o3x1wl,[o3x1],o3x1wl,o3x1T,'.')
%f=liesfile('\brewer\ausgldir\o3coeff\ozxsec.dat',1,7);
%T=4; % Column 4 is temp=-45;
%To3=[-70 -55 -45 -30 0  25]; % in deg C

%ind=find(f(:,4)==f(1,4))';  % not existant values.
%for j=ind,
%      f(j,4)=polyval(polyfit(To3([1 2 4 5 6]),f(j,[2 3 5 6 7]),2),-45);
%end

%k=1.38e-23; % bolzmann
%o3x1T=f(:,4)*1.013*1e5/(k*273.1)*1e-6; %in %1/cm
%o3x1wl=f(:,1)*10;

%save \brewer\ausgldir\o3coeff\ozxsec2.dat  f -ascii
resumen=[];
resumen_=[];
if nargin>=4,
    fid=fopen(outfname,'at');
    fprintf(fid,'Analysis on %s using files:%s,%s\n',date,fname,dcfname);
    fprintf(fid,'%s              %8s %8s %8s %8s %8s %8s\n','step','slit#0','slit#1','slit#2','slit#3','slit#4','slit#5');

end
if nargin==4
    uvr=[];
end

eval(['load ' fname ' -mat']); % get data from powfiu6;
if ~exist('wl'),
    wl=wlstd;
end

if nargin<3,
    dcfname='';
end
if nargin<2,
    ozonepos=[];
end
if isempty(ozonepos),
    ozonepos=brstps2(3063.0,1,[],dcfname);
end


% here load paur-bass
%load g:\brewer\ausgldir\o3coeff\ozxsec2.dat
load OZXSEC2.DAT
f=OZXSEC2;

% here load brion.
%load \brewer\xsections\brion
%f(:,1)=brion(:,1)/10;
%f(:,4)=brion(:,2);

% load so2;
%load g:\brewer\xsections\so2_jim\so2295sm.dat;  % calculated by jim.
%load so2295sm.dat;  % calculated by jim.
load SO2295SM.DAT;  % calculated by jim.
so2295sm=SO2295SM;
fso2(:,1)=so2295sm(:,6)*10;
fso2(:,2)=so2295sm(:,7);

k=1.38062e-23; % bolzmann
o3x1T=f(:,4)*1.013*1e5/(k*273.1)*1e-6; %in %1/cm
o3x1wl=f(:,1)*10;

ind=(wl>2950 & wl<3500);
wl=wl(ind);  % 21 2 98 julian new.
fwhm=fwhm(ind,:);
fwhm(isnan(fwhm))=0;
%absrayl=nicolet(slitwl/10,P); % rayl for natural log

%if nargin<2,ozonepos=977+3700;end % for br#119.

ozonepos=round(ozonepos);
%if length(ozonepos)==1,oposrange=ozonepos-5:ozonepos+5;
%else
%   oposrange=ozonepos;
%end

oposrange=ozonepos-16:ozonepos+12;
if length(ozonepos)==1
    mic_ozonepos=ozonepos;
    cal_ozonepos=0;
else
    mic_ozonepos=ozonepos(1);
    cal_ozonepos=ozonepos(2);
end

% 13 7 2001 Julian Use atlas3 to calculate ET at ozone wavelengths
%at3=load('atlas3_br.dat'); % wl in vacuum (correct by about 0.1nm)
%at3(:,1)=wlrefrac(at3(:,1))*10;  % change to air
% real spectra
at3=load('spectra');
at3=at3.spectra;
jj=0;
for opos=oposrange;
    jj=jj+1;
    for i=1:6,  % slits 0 to 5
        ind=fwhm(:,i)~=0;  % use only without zero!!!!
        if sum(ind)>1,
            thiswl(i)=brstps2(opos,i-1,1,dcfname); % wl for ozone position
            wlstep(i)=diff(brstps2(opos-1:opos,i-1,1,dcfname)); % one step is ... wl at this position
            pp(i,:)=polyfit(wl(ind),fwhm(ind,i),1); % fit fwhm in wl //step space
            fwhmwl(i)=polyval(pp(i,:),thiswl(i))*wlstep(i); % transform to steps //wl
            [buf,slit_aux]=brslit(fwhmwl(i),o3x1wl-thiswl(i)); % calculate slitfunction
            salida{jj}.slit{i}=buf'; 
            o3coeff(i)=sum(buf(:,2).*o3x1T)/sum(buf(:,2)); % integrate
            o3coeff(i)=o3coeff(i)/log(10); % need in log10 units, as in brewer
            %figure;semilogy(buf(:,1)+thiswl(i),buf(:,2),o3x1wl,o3x1T/max(o3x1T));
            %disp(sprintf('%10.0f steps:slit %d has FW=%10.4f  A at wl=%15.5f A and o3coeff of %15.5f',opos,i,fwhmwl(i),thiswl(i),o3coeff(i)));
            % now rayleigh:
            %wlx=-100:0.1:100; % in nm % 17 4 98 angstroem
            %slitray=brslit(fwhmwl(i),wlx);
            %raycoeff(i)=sum(slitray(:,2).*nicolet(wlx+thiswl(i)/10,1013.25)')/sum(slitray(:,2));
            raycoeff(i)=nicolet(thiswl(i)/10);
            raycoeff(i)=raycoeff(i)/log(10);
            %disp(sprintf('%10.0f steps:slit %d has rayleigh in log10 units of %15.5f',opos,i,raycoeff(i)));
            % calculate so2
            buf=brslit(fwhmwl(i),fso2(:,1)-thiswl(i));
            so2coeff(i)=sum(buf(:,2).*fso2(:,2))/sum(buf(:,2));
            so2coeff(i)=so2coeff(i)/log(10);

            % 13 7 2001 julian now I0 from atlas3
            buf=brslit(fwhmwl(i),at3(:,1)-thiswl(i));
            if ~isempty(uvr)
                uvr_i=interp1(uvr(:,1),uvr(:,2),at3(:,1));
                at3_r=at3(:,2).*uvr_i;
                % counts
            else
                at3_r=at3(:,2);
            end
            I0(i)=nansum(buf(:,2).*at3_r)/nansum(buf(:,2));
        else
            o3coeff(i)=nan;
            raycoeff(i)=nan;
            thiswl(i)=nan;
            fwhm(i)=nan;
            so2coeff(i)=NaN;

        end


        
    end

    O3Coeff=(o3coeff(2+1))-0.5*(o3coeff(3+1))-2.2*(o3coeff(4+1))+1.7*(o3coeff(5+1));
    RAYCoeff=(raycoeff(2+1)-0.5*raycoeff(3+1)-2.2*raycoeff(4+1)+1.7*raycoeff(5+1));
    So2coeff=(so2coeff(1+1)-4.2*so2coeff(4+1)+3.2*so2coeff(5+1));
    O34So2cc=o3coeff(1+1)-4.2*o3coeff(4+1)+3.2*o3coeff(5+1);
    I0Coeff=((log10(I0(2+1)))-0.5*(log10(I0(3+1)))-2.2*(log10(I0(4+1)))+1.7*(log10(I0(5+1))))*1e4;
    
    
    salida{jj}.thiswl=thiswl;
    salida{jj}.fwhmwl=2*fwhmwl;
    salida{jj}.o3coeff=o3coeff;
    salida{jj}.raycoeff=raycoeff;
    salida{jj}.so2coeff=so2coeff;
    salida{jj}.I0=I0;
    salida{jj}.ozone_pos=opos;
    salida{jj}.cal_ozonepos=cal_ozonepos;
    salida{jj}.resumen=[thiswl;fwhmwl;o3coeff;raycoeff;so2coeff;I0];
    
    resumen_=[opos-cal_ozonepos,O3Coeff,RAYCoeff*1e4,So2coeff,O34So2cc,-I0Coeff];
    
    resumen=[resumen;resumen_];
    salida_m(:,:,jj)=[thiswl;fwhmwl;o3coeff;raycoeff;so2coeff;I0];
    

    s1=sprintf('%5.0f WL(A)        %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f',opos-cal_ozonepos,thiswl);
    s2=sprintf('      Res(A)       %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f',fwhmwl*2);
    s3=sprintf('      O3abs(1/cm)  %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f O3:%8.4f',o3coeff,O3Coeff);
    s3b=sprintf('     So2abs(1/cm)  %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f',so2coeff);
    s4=sprintf('  1e4*Rayabs(1/cm) %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f R:%8.4f',raycoeff*1e4,RAYCoeff);
    s4b=sprintf(' I0(mW m^-2nm^-1)  %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f',I0);
    s5=sprintf('Ozone offset due to Rayleigh: %3.1f DU',-RAYCoeff./O3Coeff*1e3);
    s6=sprintf('Ratio Ozone for So2(A3)=%8.4f, So2/O3(A2)=%8.4f', O34So2cc,So2coeff/O34So2cc);
    if abs(opos-mic_ozonepos)<5
       disp(s1)
       disp(s2)
       disp(s3)
       disp(s3b)
       disp(s4)
       disp(s4b)
       disp(s5)
       disp(s6)
          if nargin>=4,  % print to file
            fprintf(fid,'%s\n',s1);
            fprintf(fid,'%s\n',s2);
            fprintf(fid,'%s\n',s3);
            fprintf(fid,'%s\n',s3b);
            fprintf(fid,'%s\n',s4);
            %fprintf(fid,'%s\n',s4b);
            fprintf(fid,'%s\n',s5);
            fprintf(fid,'%s\n\n',s6);
         end
    end
    %disp(sprintf('%10.0f steps has ozonecoeff:%10.4f',opos,(o3coeff(2))-0.5*(o3coeff(3))-2.2*(o3coeff(4))+1.7*(o3coeff(5))));
    %disp(sprintf('%10.0f steps has raycoeff:%10.4f',opos,(raycoeff(2)-0.5*raycoeff(3)-2.2*raycoeff(4)+1.7*raycoeff(5))));
end

if nargin==4,fclose(fid);end
