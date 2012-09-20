function [res,detail,DSP_QUAD,QUAD_SUM,QUAD_DETAIL,CUBIC_SUM,CUBIC_DETAIL,salida...
    ]=dsp_report(day,year,brewnb,path,cfg,comment,uvr)


% Modificaciones:
% 05/11/2009 Juanjo: modificada la línea 361 para mostrar las WL con 2
% decimales
% 

day=day-1:day+1;
%year=08;
%brewnb=193;
Lines=1:14;
%path='f:\red_brewer\brewer193\bdata193\193\dsp078\';
%comment='#193';
% polinomial order
polynb=3;
% ozone pos-> from icf
% using read_icf= cfg(14)+cfg(44)
%cfg=read_icf('icf07808.193');
ozonepos=cfg(14)+cfg(44);


%% Ozone Dispersion analysis
%function [wl,DSP,DSPstd,fwhm,fwhmstd,backlash,resup]=alldsp_(day,year,brew,lines,minslit,maxslit,usewl,dspp)
h0=gcf;
[wl,dsp,dspstd,fwhm,fwhmstd,backlash]=alldsp_(day,year,brewnb,1:14,[],[],[],path);
dsp_orig=dsp;
wl_orig=wl;
 if isempty(wl)
    return;
 else
    fplotdsp=sprintf('lines_dsp_%03d%02d_%s%03d',day(1),year,'_',brewnb);
    h1=gcf;
    for i=h0:h1
       figure(i)
       set(i,'Tag',['DSP_LINES_',num2str(i)]);
    end
    %printfigures(h0,h1,[fplotdsp]);
    %close all
end






fnamealldsp=sprintf('alldsp_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
disp(sprintf('saving alldsp to %s',[path fnamealldsp]));

%Bewer ozone lines
  jl=find(wl<3410);
  jnul=find(wl>wl(max(jl)))
  dsp(jnul,:)=[];
  wl(jnul,:)=[];
  dspstd(jnul,:)=[];
  fwhm(jnul,:)=[];
  fwhmstd(jnul,:)=[];
  backlash(jnul,:)=[];

dsp_orig=dsp;
wl_orig=wl;
  
  fnamealldsp=sprintf('ozonedsp_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
  save([path fnamealldsp],'wl','dsp','dspstd','fwhm','fwhmstd','backlash');

  %h1=gcf;
  %fplotdsp=sprintf('alldsp_%03d%02d_%s%03d',day(1),year,comment,brewnb);
  %printfigures(h0,h1,[fplotdsp]);
  %close all


%% now calculate normaldsp
% for ozone only use wv <3340
%j=find(wl<3400);

[fwl,fstps,pwl,pstps]=normaldsp(wl,dsp);  % quad for every slit
fnameN=sprintf('dspnorm_%03d%02d_%s.%03d',day(1),year,comment,brewnb);


%% Depuracion
% si el residuo es mayor que 0.1 y hay mas de tres lineas por slit se
% elimina
jbad=[];
lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
flag_reprocess=0;
for j=1:5
 for i=1:6 %slit 

    jbad=[];
    fwll=fwl(:,i);
    len=size(find(fwll),1);
    if j==1     jbad=find(abs(fwll)>0.15);
    else jbad=find(abs(fwll)>0.12);
    end
    
    if ~isempty(jbad)
    %ordenamos por el mayor residuo
    %[a,b]=sort(abs(fwll(jbad)),'descend');
    %ordenamos por el mayor alejamiento de la nominal
    [a,b]=sort(abs(wl(jbad)-lamda_nominal(2)),'descend');
    jbad=jbad(b);
      
         for ii=1:length(jbad) 
             if len>3
               dsp(jbad(ii),i)=0;
               disp(sprintf('eliminamos la linea slit %d %f %f',i,wl(jbad(ii)),fwll(jbad(ii))));
               flag_reprocess=1;
               len=len-1;
               if flag_reprocess
                  [fwl,fstps,pwl,pstps]=normaldsp(wl,dsp);  % quad for every slit
                  i=i-1;
                  %if i==0 i=1; end
                  break;
               end
             else
                warning('not enough lines if remove');
             end
         end
      end

if flag_reprocess
 [fwl,fstps,pwl,pstps]=normaldsp(wl,dsp);  % quad for every slit
 fnameN=sprintf('dspnorm_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
 
 
end      
end
end
if flag_reprocess
 [fwl,fstps,pwl,pstps]=normaldsp(wl,dsp);  % quad for every slit
 fnameN=sprintf('dspnorm_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
end
 
%%

lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];

fnamealldsp=sprintf('ozonedsp_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
save([path fnamealldsp],'wl','dsp','dspstd','fwhm','fwhmstd','backlash');

disp_lines=[
            2893.600    1   1%  hg  9
            2967.280    3   1%  Hg  12
            3018.360	4	3%	Zn	1
            3035.780	5	3%	Zn	2
            3133.167	7	2%	Cd	4
            3261.055	8	2%	Cd	5
            3282.330	9	3%	Zn	3
            3341.480	10	1%	Hg	13
            3403.652	11	2%	Cd	6
            3499.950	12	2%	Cd	7
            3611.630	13	2%	Cd	8
            ];
lamp_name=[  'Hg';'Hg';'Zn';'Zn';'Cd';...
            'Cd' ;'Zn';'Hg';'Cd';'Cd';'Cd'];
lamp_name=cellstr(lamp_name);

f3=figure;  warning off MATLAB:tex;
set(f3,'tag','DSP_QUAD_RES');
plot(wl,fwl,'o-');
set(gca,'Xlim',[2850,3450],'LineWidth',1);
% title(sprintf('%s\ndspnorm%c%03d%02d%c%s.%03d','Normaldsp','-',day(1),year,'-',comment,brewnb),'FontWeight','normal');
title(sprintf('Normaldsp BREWER#%03d\ndspnorm %s',brewnb,path),'FontWeight','normal');
ylabel('Residuals [A]');  xlabel('wavelength [A]');
legend('slit #0','slit #1','slit #2','slit #3','slit #4','slit #5','Location','SouthEast');
hline([-0.1,0.1],'r-'); vline(disp_lines(:,1:2),'k-.',lamp_name); 
orient('portrait');  

%f1=figure;
%set(f1,'Tag','DSP')
%plot(wl(j),fwl,'o-');
%title(['Normaldsp ' path fnameN '-' datestr(now)]);
%ylabel('Residuals [ï¿½]');
%xlabel('wavelength [ï¿½]');
%legend('slit #0','slit #1','slit #2','slit #3','slit #4','slit #5');


disp(sprintf('saving normaldsp to %s as brewer compatible file',[path fnameN]));

%save([path fnameN],'pwl','pstps');
data=pwl(:,end:-1:1)';
mydata=data(:);
savefmt([path fnameN],[mydata(4:end);mydata(1:3)],'','%.7e');
DSP_QUAD=[mydata(4:end);mydata(1:3)];
disp('Use polyval(pwl(2,:),wl) for calculating normal wavelengths')

%% now calculate ozonecoeffs

outfname_cuadratic=sprintf('opos%03d%02d_%s.%03d',day(1),year,comment,brewnb);
disp(sprintf('Saving ozonecoeffs to %s',[path outfname_cuadratic]));

salida=[path outfname_cuadratic];
% ozonepos is total steps from uvzero. #mircometer zero + ozone position
% dcfname is dcfile name for brstps.
% fname is data from alldsp
% dcfname is file ontained from savedsp
% outfname is were log should be written

% ozone pos-> from icf
% using read_icf= cfg(14)+cfg(44)
%cfg=read_icf('icf07808.193');
%ozonepos=cfg(14)+cfg(44);
CALC_STEP=cfg(14);
[res,detail,salida]=ozonecoeff3([path fnamealldsp],[ozonepos,cfg(44)],[path fnameN],[path outfname_cuadratic]);

jcal=find((res(:,1)==CALC_STEP),1);
jumk=find((res(:,1)==CALC_STEP),1,'last');


%% ozone vs UV comparison

% Sun Scan simulation
% asuming mo3=mRay=2 and o3=300UD ct during sc
%Fi=300*res(:,2)*2-res(:,end);
%o3sc=( Fi+res(16,end))/(2*res(16,2));


%% now do dispersion fit using Groebner analysis
  dsp=dsp_orig;
  wl=wl_orig;

dsp(~dsp)=NaN;
nslit=min(sum(~isnan(dsp)));
if nslit<=polynb
   polynb=nslit-1;
end
dsp(isnan(dsp))=0;
fname7=sprintf('dsp_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
disp(sprintf('saving powfiu7 to %s',[path fname7]));
pos0=powfiu7;
if nanmean(fwhm(fwhm(:,1)~=0,1))<65,pos0=powfiu7(1);end
[fstd,slitpos,rmsf]=powfiu7(pos0,wl,dsp,polynb,[],[],[],[path fname7]);
% disp('Residuals using powfiu7 [RMS]:');
% disp(rmsf);

% check slitpos residuals.

dsl=slitpos(end,:)-pos0;
if any(abs(dsl)>0.05),  % do again with this one slit corrected
 ind=find(dsl==max(dsl));
 pos0(ind)=pos0(ind)+dsl(ind);% shift slitpos and recalculate
 disp(sprintf('Too large slitpos deviation: Recalc with slit #%d shifted by %.3f',ind,dsl(ind)));
 [fstd,slitpos,rmsf]=powfiu7(pos0,wl,dsp,polynb,[],[],[],[path fname7]);
 disp('Residuals using powfiu7 [RMS]:');
disp( rmsf);
end


ind=fstd==0;fstd(ind)=nan;
%figure;plot(wl,fstd(:,:,end)/10,'o-');
%f2=figure;
%set(f2,'Tag','DSP')
%plot(wl,fstd(:,:,end),'o-');
%title(['Powfiu7 RMS=' sprintf('%.4f',(min(rmsf/10))) ' ' fname7 '-' datestr(now)]);
%ylabel('Residuals  [ï¿½]');
%xlabel('wavelength [ï¿½]');
%legend('slit #0','slit #1','slit #2','slit #3','slit #4','slit #5');
f2=figure;
plot(wl,fstd(:,:,end),'o-'); set(gca,'FontSize',11,'FontWeight','bold');
title(sprintf('%s%.4f \ndsp%c%03d%02d%c%s.%03d%s%s','Powfiu7 RMS=',...
               min(rmsf/10),'-',day(1),year,'-',comment,brewnb,'  ',datestr(now,29)),...
              'FontSize',15,'FontWeight','normal');
ylabel('Residuals  [A]','FontSize',12,'FontWeight','bold');
xlabel('wavelength [A]','FontSize',12,'FontWeight','bold');
legend('slit #0','slit #1','slit #2','slit #3','slit #4','slit #5','Location','SouthEast');
hl=hline([-0.1,0.1]); set(hl,'Linewidth',2,'color','r');
vl=vline(disp_lines(:,1:2),'y:',lamp_name); set(vl,'Linewidth',2);
%vlabel=findobj('color','y'); set(vlabel,'color','k','Fontweight','bold')
set(f2,'tag','DSP_CUBIC_RES');
set(gca,'Xlim',[2850,3450]);


disp('Use brstps2 to calculate steps and wavelengths');

%% And now show difference between both methods for slits 1 and 5.

testwl1=3000:10:3500;
testwl5=3500:10:3650;
stps17=brstps2(testwl1,1,[],[path fname7]);  % reference steps to use
stps57=brstps2(testwl5,5,[],[path fname7]);

%quad1=polyval(pwl(2,:),stps17);
%quad5=polyval(pwl(6,:),stps57);

for i=1:6
 stps(i,:)=brstps2(testwl1,i-1,[],[path fname7])';  % reference steps to use
 quad1(i,:)=polyval(pwl(i,:),stps(i,:)')';
end

f1=figure;
plot(testwl1,matadd(quad1,-testwl1)); %testwl5,quad5-testwl5);
legend('slit #0','slit #1','slit #2','slit #3','slit #4','slit #5');
hline([-0.1,0.1]);
title('Normaldsp versus powfiu7 using slit 1 (3000:3500) and 5 (3500:3650)')
ylabel('Quad - Cubic  [A]','FontSize',12,'FontWeight','bold');
xlabel('wavelength [A]','FontSize',12,'FontWeight','bold');
set(f1,'tag','DSP_QUAD_CUBIC');
set(gca,'Xlim',[2850,3450]);



%f3=figure;
%set(f3,'Tag','DSP')
%plot(testwl1,quad1-testwl1);%,testwl5,quad5-testwl5);
%title('Normaldsp versus powfiu7 using slit 1 (3000:3500) and 5 (3500:3650)')
%ylabel('normaldsp-powfiu7 [ï¿½]');
%hline([-0.1,0.1]);



%%
outfname_cubic=sprintf('opos_pow7_%03d%02d_%s.%03d',day(1),year,comment,brewnb);
disp(sprintf('Saving ozonecoeffs to %s',[path outfname_cubic]));


% ozonepos is total steps from uvzero. #mircometer zero + ozone position
% dcfname is dcfile name for brstps.
% fname is data from alldsp
% dcfname is file ontained from savedsp
% outfname is were log should be written

% ozone pos-> from icf
% using read_icf= cfg(14)+cfg(44)
%cfg=read_icf('icf07808.193');
%ozonepos=cfg(14)+cfg(44);

[res2,detail2,salida2]=ozonecoeff3([path fnamealldsp],[ozonepos,cfg(44)],[path fname7],[path outfname_cubic]);


%% Power fit vs Quadratic
jcal=find(res(:,1)==cfg(14),1,'first');
% disp('Quadratic')
%quad_dsp_coef=printmatrix(res(j,:),4);
 QUAD_SUM=res(jcal,:);% printmatrix(res(jcal,:),4);
 QUAD_DETAIL=detail(:,:,jcal);% printmatrix(detail(:,:,jcal),4);

%disp('Cubic')
%cubic_dsp_coef=printmatrix(res2(j,:),4);
% disp('Cubic')
CUBIC_SUM=res2(jcal,:);% printmatrix(res2(jcal,:),4);
for ii=-1:1
CUBIC_DETAIL{ii+2}=detail2(:,:,jcal+ii); % printmatrix(detail2(:,:,jcal+ii),4);
end

label_1={'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'};
label_2={sprintf('step= %d ',res(jcal,1));'WL(A)';'Res(A)';'O3abs(1/cm)';'Ray abs(1/cm)';'SO2abs(1/cm)'};
label_r={'step  ','O3abs  ','Rayabs  ','SO2abs  ','O3SO2Abs'};
quad_report=num2cell(res(jcal,1:end-2));
quad_report=[label_r;quad_report];


QUAD_DETAIL=[]; temp_res=[' ',label_r,' '];
for ii=-1:1
label_1={'slit\#0','slit\#1','slit\#2','slit\#3','slit\#4','slit\#5'};
label_2={sprintf('step= %d ',res(jcal+ii,1));'WL(A)';'Res(A)';'O3abs(1/cm)';'Ray abs(1/cm)';'SO2abs(1/cm)'};
label_r={'step','O3abs','Rayabs','SO2abs','O3SO2Abs'};
    
% modificado el 05/11/2009
 detail(1,:,jcal+ii)=str2num(sprintf('%7.2f %7.2f %7.2f %7.2f %7.2f %7.2f',detail(1,:,jcal+ii)));%round(detail(1,:,jcal+ii));
 step_report=num2cell(detail(1:end-1,:,jcal+ii));
 %  end -2 introducimos daumont
 quad_res=num2cell(res(jcal+ii,1:end-2));
 step_report=[label_2,[label_1;step_report]];
 QUAD_DETAIL=[QUAD_DETAIL;step_report];
 temp_res=[temp_res;[' ',quad_res,' ']];
end
QUAD_DETAIL=[QUAD_DETAIL;temp_res];
% 
% disp('Quadratic')
% quad_dsp_res=printmatrix(detail(:,:,jcal),4);
% disp('Cubic')
% cubic_dsp_coef=printmatrix(detail2(:,:,jcal),4);
% 
f4=figure;
set(f4,'Tag','DSP');
% res(1,end-1) los dos ulitimos son el umkher

limits=round([min(res(1:end-2,2))-0.01,max(res2(1:end-2,2))+0.01]*100)/100;
%mmplotyy(res(:,1),res(:,2),limits,res2(:,2),limits);
mmplotyy(res(1:end-2,1),[res(1:end-2,2),res2(1:end-2,2)],limits,[gradient(res(1:end-2,2)),gradient(res2(1:end-2,2))]);
mmplotyy('gradient');
% hold on
%mmplotyy(res(:,1),res(:,2),limits,res2(:,2),limits);
xlabel('Calc Step');
title(['Ozone Absortion Coefficient  #', num2str(brewnb)]);
legend('Quadratic','Cubic');


% res=cat(3,res(jcal-2:jcal+2,:),res2(jcal-2:jcal+2,:));
res=cat(3,[res(jcal-6:jcal+6,:);res(end-1:end,:)],[res2(jcal-6:jcal+6,:);res2(end-1:end,:)]);
detail=cat(4,detail(:,:,[jcal-6:jcal+6,end-1:end]),detail2(:,:,[jcal-6:jcal+6,end-1:end]));
salida.QUAD=salida([jcal-6:jcal+6,end-1:end]); salida.CUBIC=salida2([jcal-6:jcal+6,end-1:end]);


