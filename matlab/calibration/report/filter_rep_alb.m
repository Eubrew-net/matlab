%% Filter Report form FIOAVGG
%function [ETC_FILTER_CORRECTION,media,fi,fi_avg]=filter_rep(brw_str,date_range,outlier_flag)
%
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
% 
% 14 09 2009 Modificada para leer los ficheros de bfiles (Alberto)
%
%            se le puede introducir el nombre del fichero o el numero de brewer
%            si le introduces el numero de brewer busca primero en bfiles y luego en bdataxxx
function [ETC_FILTER_CORRECTION,media,fi,fi_avg]=filter_rep(brw_str,date_range,outlier_flag)
%function [ETC_FILTER_CORRECTION,media,fi]=filter_rep(brw_str,date_range)


% Los ficheros FIOAVG.nnn pueden tener 2 tipos de errores:
%  1) el software brewer es incapaz de reconocer ciertos registros. En estos casos suele 
%     aparecer un % en el campo afectado.
%  2) errores de fecha.
% Para que el programa funcione tendremos que editar el fichero y corregir
% manualmente los registros afectados por el error dado en 2. Los errores descritos en 1
% son superados por el script read_avg_line


% se le puede introducir el nombre del fichero o el numero de brewer
% si le introduces el numero de brewer busca primero en bfiles y luego en bdataxxx

  if length(brw_str)==3;
     fioavg=['.',filesep(),'bfiles',filesep(),brw_str,filesep(),'FIOAVG.',brw_str];
     if ~exist(fioavg,'file');
       fioavg=['.',filesep(),'bdata', brw_str,filesep(),'FIOAVG.',brw_str];
     end
  else
     fioavg=brw_str;
  end


try
 a=textread(fioavg,'');
catch
  try
    a=read_avg_line(fioavg,92);   
    catch
     disp(fioavg);   
     aux=lasterror;
     disp(aux.message)
     return;
  end
end
% FIOAVG=load(fioavg)
fi_avg=avgfech(a);
if nargin>1 && ~isempty(date_range)
  fi_avg(find(fi_avg(:,1)<date_range(1)),:)=[];
  if length(date_range)>1
   fi_avg(find(fi_avg(:,1)>date_range(2)),:)=[];
  end
end

fech=datevec(fi_avg(:,1));

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
%  sl_5 ssl_5 
%  18   19   
% 15 campos por 6 slits
%  Filter,cy,N,sl0 ssl0 sl_1 ssl_1 sl_2 ssl_2 sl_3 ssl_3 sl_4 ssl_4 sl_5
%  
%   1,2,3       4   5       6   7       8    9    10   11    12   13  
try
 fi=reshape(fi_avg(:,5:end),[],15,6);
catch
 %edited files !!   
 fi=reshape(fi_avg(:,5:end-2),[],15,6);
 end
% dim 1 n de medidas
%     2 medidas (slit 0-5) 15 datos
%     3 medidas por filtro 

% ya son directamente las atenuaciones.
% nominal values
nominal=[1,5000,10000,15000,20000,25000];
%nominal=[   1 ,4370,10250,14150,21800,26400];
ref=fi(:,4:2:end,1);
temp=repmat(fi_avg(:,4),1,6);
dia=repmat(fi_avg(:,3),1,6); %records = size(dia,1);
lamda=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
filter_n=1:5; %filtro
label_lamda=num2str(fix(lamda'/10));
nmeas=size(fi,1);

if nmeas==1
    fi(2,:,:)=fi(1,:,:);
    nmeas=2;
end

fh=figure; set(fh,'tag','FI_TIME');
%mmplotyy(fi_avg(:,1),ref,'.:',temp,'-*');
%mmplotyy('temperature');
%grid;
%datetick('x','mmm/dd','keeplimits','keepticks')
for ii=1:6
  subplot(2,3,ii);
  %plot(dia,((fi(:,4:2:end,ii)-repmat(nominal(ii),[nmeas,6]))./repmat(nominal(ii),[nmeas,6])));
  mmplotyy(datenum(fech),fi(:,4:2:end,ii),':*',temp,':.k');
  %mmplotyy(dia(:,1),fi(:,4:2:end,ii),':*',temp,'^k');
  %plot(dia(:,1),fi(:,4:2:end,ii),'.');
  axis('tight');
  xlabel('Day')
  datetick('keeplimits')
end

legend(label_lamda); 
mmplotyy('shrink');

if exist('outlier_flag','var') 
    if outlier_flag==1
     for ii=1:6
        fd=figure;
        set(fd,'Tag','FILTER_DEPURATION');
        [s,filtered]=medoutlierfilt_nan(fi(:,4:2:end,ii),1,1,1);
        fi(:,4:2:end,ii)=filtered;
        %[s,filtered]=medoutlierfilt(fi(:,4:2:end,ii),1,1);
        %fi_ilt{i}=filtered;
     end
    end
end
media=squeeze(fix(nanmedian(fi(:,4:2:end,2:end),1)));
med=[[0,fix(lamda/10)]',[filter_n;media],];


% ETC correction
% ETC(FILTER)= SUM  W(L)* AFC(L,F)
% AFC=  Attenuation Filter Correction 
% AFC(F,L)= NOMINAL(F)-REAL(F,L)

O3W=[   0.00      0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    -1.00    0.00    0.00    4.20   -3.20];
ETC_FILTER_CORRECTION=round(O3W*media);


o3w=cell(size(fi,1));
for ii=1:size(fi,1), o3w{ii}=O3W*squeeze(fi(ii,4:2:end,2:end)); end
o3f=cell2mat(o3w);

for ii=1:5
    ETC_FILTER_CORRECTION(2,ii)=nanmean(bootstrp(10000,@nanmean,o3f(:,ii)));
    aux=o3f(:,ii);
    aux(isnan(aux))=[];
    CI=bootci(10000,@mean,aux);
    ETC_FILTER_CORRECTION(3:4,ii)=CI;
end





fh=figure; set(fh,'tag','FI_STATS');
for ii=2:6
  subplot(3,2,ii-1);
  boxplot(100*((fi(:,4:2:end,ii)-repmat(nominal(ii),[nmeas,6]))./repmat(nominal(ii),[nmeas,6])),...
          'label',label_lamda);   set(gca,'Linewidth',1);      
  xlabel('wavelength'); %ylabel(sprintf('%s\n%s','%difference from ','nominal values'),'FontSize',9); 
  ylabel(''); 
  title(sprintf('Filter #%d',ii-1));
end
subplot(3,2,6);
boxplot(100*((fi(:,4:2:end,1)-repmat(nominal(1),[nmeas,6]))./repmat(nominal(1),[nmeas,6])),...
        'label',label_lamda);   set(gca,'Linewidth',1);      
xlabel('wavelength'); ylabel('');
% ylabel('Intensity','FontSize',9);  
title('Intensity');

sup=suptitle(sprintf('%s%s\n%s','Attenuation Filter Test, ',fioavg(regexp(fioavg,'AVG')-3:regexp(fioavg,'AVG')+6),...
                                'Difference from nominal values, %'));
pos=get(sup,'Position'); set(sup,'Position',[pos(1)+.02,pos(2)-.01,1]);

f=figure; set(f,'tag','FI_wavelength');
r=matdiv(100*matadd(media,-mean(media)),media);

plot(lamda,r,'*-.');
hold on; plot(lamda,mean(r,2),'s-');
set(gca,'XLim',[3020 3212],'XTick',lamda,'XTickLabel',round(lamda)./10,...
        'GridLineStyle','-.','Linewidth',1);
ylabel('Difference to mean, {\it%}'); xlabel('wavelength {\it(nm)}')
H=legend('F{\it#1}','F{\it#2}','F{\it#3}','F{\it#4}','F{\it#5}','mean',...
                  'Orientation','Horizontal','Location','NorthOutside');
set(H,'LineWidth',1);              
grid;
orient portrait;
sup=title({sprintf('%s %s','Wavelength dependence of the attenuation filter,  #',brw_str),...
    num2str(ETC_FILTER_CORRECTION)});
% box off

label_1={'FIOAVG ','slit #0','slit #1','slit #2','slit #3','slit #4','slit #5','mean'};
label_2={'filter #1','filter #2','filter #3','filter #4','filter #5'};

filter_table=[label_1',[label_2;num2cell(media);num2cell(fix(mean(media)))]];
% makeHtmlTable([fix(media);fix(mean(media))],[],label_1,label_2 );

%printmatrix(ETC_FILTER_CORRECTION)
table_filter_correction=[label_2;num2cell(round(ETC_FILTER_CORRECTION))];
% makeHtmlTable(ETC_FILTER_CORRECTION,[],{'ETC FILTER CORR'},label_2 );

