%% TODO
% auto setup
% time report atenuation by time
% no linearity graph

i=1
brw_str{i}='157'
brw_name{i}=' #157 New Filter';
%fioavg=['.',filesep(),'bdata', brw_str{i},filesep(),'FIOAVG.',brw_str{i}];
fioavg=['FIOAVG.',brw_str{i}];

try
 a=textread(fioavg,'');
catch
  try
    a=read_avg_line(fioavg);   
    catch
     disp(fioavg);   
     aux=lasterror;
     disp(aux.message)
     return;
  end
end
% FIOAVG=load(fioavg)
fi_avg=avgfech(a); fech=datevec(fi_avg(:,1));
fi_avg(find(fech(:,1)<2008),:)=[];

%fi_avg=fi_avg(1:end-3,:);
fi_avg=fi_avg(end-1:end,:);

% IOS description of the fi test output in fioavg.### file (created by V. Savastiouk)
% 
% date Te  AF CY  N  Slit0 std Slit1 std Slit2 std Slit3 std  Slit4  std Slit5 std
% 28003 9  1   1  3  49815 +37 59776 +0  60031 +0  60318  +0  59622  +0  58465 +0 
%          2   3  3  4520  +17  4514 +13  4504 +5   4492  +7   4482  +5   4474 +16 
%          3   8  3  9386  +16  9338 +24  9296 +3   9245  +7   9211  +6   9186 +22 
%          4  30  3 16396  +24 16262 +17 16105 +17 15976  +7  15863 +11  15752 +7 
%          5 100  3 24598  +55 24357 +9  24155 +18 24003  +9  23873  +9  23736 +13 
%          6 250  3 25996  +54 25764 +0  25553 +13 25411  +0  25251  +0  25103 +13
% 
% Te - temperature,
% AF - FW2 position,
% CY-number of cycles for that AF
% N - number of repetition (fi does several loops one inside the other and N is the 
% outer most loop). Slit0-6 are the values for the attenuations, except for AF=1 
% where it represents the absolute intensity.
% avgfech-> fi_avg
% 1      2   3           4
% date,year,julian_day,temp, 
%  5    6  7   8    9    10   11     12   13    14   15      16  17
%  AF  CY  N  sl0 ssl0   sl_1 ssl_1  sl_2 ssl_2 sl_3 ssl_3  sl_4 ssl_4 
%             sl_5 ssl_5 
%               18   19   
try
 fi=reshape(fi_avg(:,5:end),[],15,6);
catch
 %edited files !!   
 fi=reshape(fi_avg(:,5:end-2),[],15,6);
end
 %dim 1 n de medidas
%    2 medidas (slit 0-5) 15 datos
%    3 medidas por filtro 

% ya son directamente las atenuaciones.
% nominal values
nominal=[1,5000,10000,15000,20000,25000];
%nominal=[   1 ,4370,10250,14150,21800,26400];
ref=fi(:,4:2:end,1);
temp=repmat(fi_avg(:,4),1,6);
dia=repmat(fi_avg(:,3),1,6);
lamda=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
f=1:5; %filtro
label_lamda=num2str(fix(lamda'/10));
nmeas=size(fi,1);
fh=figure;
set(fh,'tag','FI_STATS');
for ii=1:6
  subplot(2,3,ii);
  boxplot(100*((fi(:,4:2:end,ii)-repmat(nominal(ii),[nmeas,6]))./repmat(nominal(ii),[nmeas,6])),'label',label_lamda);
  xlabel('wavelength')
  if ii>1
      ylabel('% difference from nominal values','FontSize',11,'FontWeight','normal');
      title(sprintf('Filter #%d',ii-1),'FontSize',10,'FontWeight','normal');
  else
      title('Filter #0');
      ylabel('Intensity','FontSize',11,'FontWeight','normal');
  end
end
suptitle(['Atenuation Filter Test',brw_name{i}]);
orient('landscape');
%
media=squeeze(fix(mean(fi(:,4:2:end,2:end),1)));

med=[[0,fix(lamda/10)]',[f;media],];
a=mat2clip(med);

label_1={' ','slit #0','slit #1','slit #2','slit #3','slit #4','slit #5','mean'};
label_2={'filter #1','filter #2','filter #3','filter #4','filter #5'};

filter_table=[label_1',[label_2;num2cell(media);num2cell(fix(mean(media)))]];

disp(filter_table);

% ETC correction
% ETC(FILTER)= SUM  W(L)* AFC(L,F)
% AFC=  Attenuation Filter Correction 
% AFC(F,L)= NOMINAL(F)-REAL(F,L)

%AFC
O3W=[   0.00      0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    -1.00    0.00    0.00    4.20   -3.20];

%AFC=media-repmat(media(:,3),1,5);
%AFC=((media-repmat(mean(media),6,1)));
AFC2=((media-repmat(nominal(2:end),6,1)));
%ETCF=O3W*AFC;
% ETC correction

%printmatrix(media)

ETC_FILTER_CORRECTION=O3W*media;

%printmatrix(ETC_FILTER_CORRECTION)
table_filter_correction=[label_2;num2cell(ETC_FILTER_CORRECTION)]



% media
%media;mat2clip(fix(mean(media)),'%5d')
f=figure;
set(f,'tag','FI wavelength');
r=matdiv(100*matadd(media,-mean(media)),media);
plot(lamda,mean(r,2),'-','LineWidth',3);
hold on;
plot(lamda,r);
rline;
ylabel('Differences to mean %','FontSize',11,'FontWeight','normal')
xlabel('wavelenght','FontSize',11,'FontWeight','normal')
suptitle(['Wavelength dependence of the attenuation filter', brw_name{i}])
legend('mean','filter 1','filter 2','filter 3','filter 4','filter 5',-1)


% ETC correction
% ETC(FILTER)= SUM  W(L)* AFC(L,F)
% AFC=  Attenuation Filter Correction 
% AFC(F,L)= NOMINAL(F)-REAL(F,L)

%AFC
O3W=[   0.00      0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    -1.00    0.00    0.00    4.20   -3.20];

%AFC=media-repmat(media(:,3),1,5);
%AFC=((media-repmat(mean(media),6,1)));
%AFC2=((media-repmat(nominal(2:end),6,1)));
%ETCF=O3W*AFC;
% ETC correction

printmatrix(media);

ETC_FILTER_CORRECTION=O3W*media;
printmatrix(ETC_FILTER_CORRECTION);

