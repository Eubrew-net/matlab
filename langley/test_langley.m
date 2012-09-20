%% some constants definitions
filter=[0,64,128,192,256];
% Weight definition for the seven slits
% slit 0 used for hg calibration slit 1-> dark

O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    0  -1.00    0.00    0.00    4.20   -3.20];
WN=[302.1,306.3,310.1,313.5,316.8,320.1];
% MS8 SO2 ms9 o3 en el soft del brewer.
% single ratios used in brewer software
rms4=[0 0 -1  0  0  1  0];
rms5=[0 0  0 -1  0  1  0];
rms6=[0 0  0  0 -1  1  0];
rms7=[0 0  0  0  0 -1  1];
% matriz de ratios
% Ratios=F*W;0.
W=[rms4;rms5;rms6;rms7;SO2W;O3W]';

%%
o3.ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
           'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1º
           'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25  
           'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32Segund configuracion                          
           'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)               
         };
     
%o3.ozone_raw=[timeds(:,1:9),ds(:,2),ds_temp,ds(:,7:13),F,F2];
o3.ozone_raw_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...
           'OS0'  'OS1'	'OS2'	'OS3'	'OS4'	'OS5'	'OS6'	...  %  12:18 cuentas brutas
           'iS0'  'iS1'	'iS2'	'iS3'	'iS4'	'iS5'	'iS6'	...  % cuentas/segundo  config 1
           'fs0'	'fs1'	'fs2'	'fs3'	'fs4'	'fs5'	'fs6'	...  %  cuentas/segundo config 2
 }  

%load Triad2011
%%
icf={};cfg={};
load(Cal.file_save,'ozone_raw','dsum','ozone_sum','ozone_ds','config','sl','sl_cr','hg','log','missing');
ozone_lgl=cell(Cal.n_brw,1);
for i=1:Cal.n_brw
    o3_raw=cell2mat(ozone_raw{i});
    o3_ds=cell2mat(ozone_ds{i});
    cfg_aux=cell2mat(config{i});

    
ozone_lgl{i}=[o3_raw(:,1:11),o3_raw(:,19:25),o3_ds(:,8:14),...
            o3_raw(:,26:32),o3_ds(:,15:21)];
icf{i}=[cfg_aux(53:53:end,1),cfg_aux(1:53:end,1),cfg_aux(8:53:end,:),cfg_aux(11:53:end,:)];
cfg{i}=reshape(cfg_aux,53,[],3);
end
ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
          'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  %   % 12-18 cuentas/segundo  config 1                    
          'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... %  % 19-25ratios (Rayleight corrected !!)                 
          'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  % % 26-32Segund configuracion                           
          'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... % 33-39ratios (Rayleight corrected !!) 
                                                    
         };
icf_legend={
        'A1cfg1' 'A1cfg2' 'A1bf' 'ETCcfg1' 'ETCcfg2' 'ETCbf'  ...  % 40-42 (A1) 43-45 (EtC)
 }
%%
aux=ozone_lgl{3};
auxb=icf{3};
auxc=cfg{3};
j=find(fix(aux(:,1))==datenum(2011,04,10));
o3.ozone_lgl=aux(j,:);
lgl=aux(j,:);

j=find(auxc(end,:,1)==datenum(2011,04,10));
setup=squeeze(auxc(:,j,:))
%% recalculation
[o_3,so_2,rat]=ozone_cal_raw(lgl(:,12:18),lgl(:,5),770,lgl(:,6),setup(:,1));

%% depuracion de observaciones
[m,s,n,g]=grpstats(lgl(:,[2,19,33]),fix(lgl(:,3)/10));
j=find(s(:,2)<1.0 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
idx=cellfun(@str2num,g(j));
t=ismember(fix(lgl(:,3)/10),idx);
lgl=lgl(t,:);
%% data plot
figure;
mmplotyy_temp(lgl(:,9)/60,lgl(:,12:18),lgl(:,[19,33]),'.')
legend(o3.ozone_lgl_legend(12:18));
ylabel('counts second');
mmplotyy('ozone')

figure

plot(o3.ozone_lgl(:,5),o3.ozone_lgl(:,19:25))
legend(o3.ozone_lgl_legend(19:25));
title('ratios ');



figure
plot(lgl(:,5),lgl(:,25),':k')
hold on;  
%%cortamos en airmass 6
lgl=lgl(lgl(:,5)<5,:);
plot(lgl(:,5),lgl(:,25),'g:')
    
% separamos la mañana de la tarde (tst-> true solar time)
jpm=(lgl(:,9)/60>12) ; jam=~jpm;


plot(lgl(jam,5),lgl(jam,25),'.r')
hold on
plot(lgl(jpm,5),lgl(jpm,25),'.b')
legend('am','pm')
xlabel('time')
ylabel('ms9 ratios');
%   
figure;
gscatter(lgl(:,5),lgl(:,25),[jam,lgl(:,10)])
xlabel('air mass')
ylabel('ms9 ratios');

%%
%% Obtenemos el posible valor de los filtros
% mejor el valor de la regresion
% regresion por filtros
% X=[lgl(:,5),jam,jam.*lgl(:,5),lgl(:,10)==128,lgl(:,10)==192];
%igual pendiente
 X=[lgl(:,5),jam,lgl(:,10)==128,lgl(:,10)==192]; 

%X=[lgl(:,5),jam,jam.*lgl(:,5)];
[b,bi]=robustfit(X,lgl(:,39));
printmatrix([b'],1);
printmatrix([bi.se'],1);
[b,bi.se];
%% diferencia de configuracion
[b1,bi1]=robustfit(X,lgl(:,25));
printmatrix([b1'],1);
printmatrix([bi1.se'],1);

[b2,bi2]=robustfit(X,lgl(:,39));
printmatrix([b2'],1);
printmatrix([bi2.se'],1);

%%
whichstats = {'yhat','r','beta_i','cookd'};
stats = regstats(lgl(:,39),'X','linear',whichstats);
yhat = stats.yhat;
r = stats.r'


% plot(lgl(:,5),ms9,'.g:')  
% hold on
% plot(lgl(jam,5),ms9(jam),'o:r')
% plot(lgl(jpm,5),ms9(jpm),'s:b')
% legend('all','am','pm')
% xlabel('air mass')
% ylabel('ms9 ratios');
% [h,r,r_stats]=robust_line;

ms9=lgl(:,25)
%% aplicamos depuracion michalsky
depam=michalsky([lgl(jam,[1,5]),ms9(jam)]);
deppm=michalsky([lgl(jam,[1,5]),ms9(jam)]);
ms9(jpm(isnan(deppm(:,3))))=NaN;


%jpm=(lgl(:,9)/60>12) ; jam=~jpm;
figure
subplot(2,2,1); hold off;
plot(lgl(:,5),ms9,':')
subplot(2,2,2)
plot(lgl(jam,1),ms9(jam),'.:r')
hold on
plot(lgl(jpm,1),ms9(jpm),'.:b')
legend('am','pm')
xlabel('time')
ylabel('ms9 ratios');
%   
subplot(2,2,3)
 plot(lgl(jam,5),ms9(jam),'.:r')
 hold on
 plot(lgl(jpm,5),ms9(jpm),'.:b')
legend('am','pm')
xlabel('air mass')
ylabel('ms9 ratios');
%[h,r,r_stats]=robust_line;
subplot(2,2,4)
gscatter(lgl(:,5),ms9,[jam,lgl(:,10)])
xlabel('air mass')
ylabel('ms9 ratios');


%%

% %% data plot
% figure;
% subplot(2,2,1);
% plot(o3.ozone_raw(:,12:18))
% legend(o3.ozone_raw_legend(12:18));
% title('raw data');
% 
% subplot(2,2,2);
% plot(o3.ozone_raw(:,19:25))
% legend(o3.ozone_raw_legend(19:25));
% title('counts/second');
% 
% 
%  subplot(2,2,3);
%  plot(o3.ozone_raw(:,26:32))
%  legend(o3.ozone_raw_legend(26:32));
% % title(' counts/second config 2 ');
% 
% 
% subplot(2,2,4);
% plot(o3.ozone_raw(:,19:25)-o3.ozone_raw(:,26:32))
% legend(o3.ozone_raw_legend(19:25));
% title('counts/second config 1 - counts/second config 2 ');

% 
% %% ds
% figure;
% subplot(2,2,1);
% plot(o3.ozone_ds(:,9:14))
% legend(o3.ozone_ds_legend(9:14));
% title('ratios config1 ');
% 
% subplot(2,2,2);
% plot(o3.ozone_ds(:,16:21))
% legend(o3.ozone_ds_legend(16:21));
% title('ratios config 2');
% 
% 
%  subplot(2,2,3);
%  ploty(o3.ozone_ds(:,[1,14,21]));
%  datetick;
%  legend(o3.ozone_ds_legend([14,21]));
%  title(' ms9  ');
% 
% 
% subplot(2,2,4);
% plot(o3.ozone_ds(:,9:14)-o3.ozone_ds(:,16:21))
% legend(o3.ozone_ds_legend(16:21));
% title('ratios  config 1 -  config 2 ');

