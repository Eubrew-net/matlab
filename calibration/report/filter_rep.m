function [ETC_FILTER_CORRECTION,media,fi,fi_avg]=filter_rep(brw_str,varargin)
% function [ETC_FILTER_CORRECTION,media,fi]=filter_rep(brw_str,date_range,outlier_flag)
%  
% Filter Report form FIOAVGG
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
% 
% avgfech-> fi_avg
% 1      2   3           4
% date,year,julian_day,temp, 
%  5    6  7   8    9    10   11     12   13    14   15      16  17
%  AF  CY  N  sl0 ssl0   sl_1 ssl_1  sl_2 ssl_2 sl_3 ssl_3  sl_4 ssl_4 
%             sl_5 ssl_5 
% fi(n,slit,filter) 3 dim matrix (n_measures, 15, 5 ) 
% dim 1 n de medidas
%     2 medidas por slit (slit 0-5) 15 datos : temp CY N slit sigma
%     3 medidas por filtro 5
%  
% Los ficheros FIOAVG.nnn pueden tener 2 tipos de errores:
%       1) el software brewer es incapaz de reconocer ciertos registros. En estos casos suele 
%          aparecer un % en el campo afectado.
%       2) errores de fecha.
%
% Para que el programa funcione tendremos que editar el fichero y corregir
% manualmente los registros afectados por el error dado en 2. 
% Los errores descritos en 1 son superados por el script read_avg_line
%  
%  TODO: ¿Tiene sentido el boxplot refereido a la intensidad, cuando AF(1)=0?
% 
% MODIFICADO:
% Alberto 14/09/2009: Modificada para leer los ficheros de bfiles
%                     Se le puede introducir el nombre del fichero o el 
%                     numero de brewer. Si le introduces el numero de brewer 
%                     busca primero en bfiles y luego en bdataxxx
% 
% Juanjo 10/11/2009: Redefino los inputs de la función. 
%                    Obligatorio; brw_str (o file name, ver arriba)
%                    Otros dos opcionales;
%                  - 'date_range' -> array de uno o dos elementos (fecha matlab)
%                  - 'outlier_flag' -> 1=depuración, 0=no depuración
% 
% Juanjo 06/12/2009: En lugar de plotear las cuentas vs. diajul, las ploteo
%                    vs. datenum. Así mantengo el orden temporal en el caso
%                    de que se consideren datos de años diferentes (para tag=FI_TIME)
% 
% Juanjo 13/04/2010: Modificado el control de inputs. Ahora se hace uso de
%                             clase inputParser (siguen siendo los mismos, ver modificacion del 10/11/2009)
%                             Valores por defecto: date_range=[], no control de fechas
%                                                  outlier_flag=0, no filtrado de outliers
%                             Se muestran al final del script los parametros que han tomado un valor por defecto
% 
% Juanjo 27/04/2010: Añado como input opcional "config". Será el fichero a partir del cual 
%                    obtener las atenuaciones operativas. Por defecto se cogen los 
%                    valores nominales (0 5000 10000 15000 20000 25000)
% 
% Juanjo 14/09/2011: Se añade condicional del tipo if isempty() return 
%                    para salir en caso de no data. Comentado por ahora el análisis mensual

%% Definitions
% ETC correction
% ETC(FILTER)= SUM  W(L)* AFC(L,F)
% AFC=  Attenuation Filter Correction 
% AFC(F,L)= NOMINAL(F)-REAL(F,L)

O3W=[   0.00      0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    -1.00    0.00    0.00    4.20   -3.20];

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'filter_rep';

% input obligatorio
arg.addRequired('brw_str'); 

% input param - value
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('config',[], @isfloat); % por defecto, nominal (ver linea 151)
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1)); % por defecto, no plot
arg.addParamValue('path_to_file', '.', @isstr); % por defecto, current directory

% validamos los argumentos definidos:
try
arg.parse(brw_str, varargin{:});
mmv2struct(arg.Results);
chk=1;

catch
  errval=lasterror;
  if length(varargin)==3
      date_range=varargin{1};
      config=varargin{2};
      outlier_flag=varargin{3};
  elseif length(varargin)==2
      date_range=varargin{1};
      config=varargin{2};
      outlier_flag=0; % por defecto no depuracion
  elseif length(varargin)==1
      date_range=varargin{1};
      config=[]; % por defecto valores nominales
      outlier_flag=0; % por defecto no depuracion  
  else
      date_range=[];   % por defecto no control de fechas
      config=[]; % por defecto valores nominales      
      outlier_flag=[]; % por defecto no depuracion
  end
  chk=0;
end

%% nominal or/and preconfigured values
% nominal values
if ~isempty(config)
    nominal{1}=config;
    flag_sup=1;
    if nominal{1}(1)==0, nominal{1}(1)=1; end
else
    disp('Por defecto atenuaciones nominales');
    nominal{1}=[1,5000,10000,15000,20000,25000]; flag_sup=0;
end

%% Lectura de datos
if length(brw_str)==3;
   fioavg=fullfile(path_to_file,'bfiles',brw_str,['FIOAVG.',brw_str]);
   if ~exist(fioavg,'file');
      fioavg=fullfile(path_to_file,['bdata' brw_str],['FIOAVG.',brw_str]);
   end
else
   fioavg=brw_str;
end

try
 a=textread(fioavg,'');
catch
  try
    % si falla leemos linea a linea  
    a=read_avg_line(fioavg,92);   
    catch
     disp(fioavg);   
     aux=lasterror;
     disp(aux.message)
     return;
  end
end

% control de fechas
fi_avg=avgfech(a); 
if ~isempty(date_range)
   fi_avg(fi_avg(:,1)<date_range(1),:)=[];
   if length(date_range)>1
      fi_avg(fi_avg(:,1)>date_range(2),:)=[];
   end
end

if isempty(fi_avg)
    ETC_FILTER_CORRECTION=NaN; media=NaN; fi=NaN; fi_avg=NaN;
    disp('No data');
    return
end

% fecha
fech=datevec(fi_avg(:,1));
% variable fi
% dim 1 n de medidas
%     2 medidas (slit 0-5) 15 datos
%     3 medidas por filtro (0 intensiad)

try
 fi=reshape(fi_avg(:,5:end),[],15,6);
catch
 %edited files !!   
 fi=reshape(fi_avg(:,5:end-2),[],15,6);
end





%% Depuracion de  outlier
if outlier_flag==1
     for ii=1:6
%         set(fd,'Tag','FILTER_DEPURATION');
        [s,filtered]=medoutlierfilt_nan(fi(:,4:2:end,ii),2,1,plot_flag);
        fi(:,4:2:end,ii)=filtered;
        %[s,filtered]=medoutlierfilt(fi(:,4:2:end,ii),1,1);
        %fi_ilt{i}=filtered;
     end
end


%% calculos
% variables utiles

ref=fi(:,4:2:end,1);  % atenuacion de los filtros
temp=repmat(fi_avg(:,4),1,6); % temperatura
dia=repmat(fi_avg(:,3),1,6); %records = size(dia,1);
dia_mat=repmat(fi_avg(:,1),1,6); %records = size(dia,1);
lamda=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
filter_n=1:5; %filtro
label_lamda=num2str(fix(lamda'/10));
label_filter={'Int.','F{\it#1}','F{\it#2}','F{\it#3}','F{\it#4}','F{\it#5}'};
nmeas=size(fi,1);    % numero de medidas

%chapuzilla para los fallos si hay un solo dato
if nmeas==1
    fi(2,:,:)=fi(1,:,:);
    nmeas=2;
end



% promedio total
media=squeeze(fix(nanmedian(fi(:,4:2:end,2:end),1)));
% en forma de tabla
med=[[0,fix(lamda/10)]',[filter_n;media],];

% ETC correction
% ETC(FILTER)= SUM  W(L)* AFC(L,F)
% AFC=  Attenuation Filter Correction 
% AFC(F,L)= NOMINAL(F)-REAL(F,L)

O3W=[   0.00      0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    -1.00    0.00    0.00    4.20   -3.20];

% correccion media
ETC_FILTER_CORRECTION=round(O3W*media); 

% correccion de filtros
o3w=cell(size(fi,1),1);

for ii=1:size(fi,1), o3w{ii}=O3W*squeeze(fi(ii,4:2:end,2:end)); end
o3f=cell2mat(o3w);


%% estimacion del error por bootstrap
for ii=1:5
    ETC_FILTER_CORRECTION(2,ii)=nanmean(bootstrp(10000,@nanmean,o3f(:,ii)));
    aux=o3f(:,ii);
    aux(isnan(aux))=[];
    CI=bootci(10000,@mean,aux);
    ETC_FILTER_CORRECTION(3:4,ii)=CI;
end

%% promedio mensual
% valor de pesado de ozono
aux_month=meanmonth([datenum(fech),temp(:,1),o3f],2);
filter_month=[aux_month.media(:,1),aux_month.media(:,5:end)];
filter_month=filter_month(~isnan(filter_month(:,2)),:);
%cuetas medias
fi_month=cell(6,1);
for ii=1:6 
    %aux_int=[datenum(fech),temp(:,1),fi(:,4:2:end,ii)]; 
    fi_month{ii}=meanmonth([datenum(fech),temp(:,1),fi(:,4:2:end,ii)],3);
end

%% Salidas

% label_1={'FIOAVG ','slit #0','slit #1','slit #2','slit #3','slit #4','slit #5','mean'};
% label_2={'filter #1','filter #2','filter #3','filter #4','filter #5'};
% 
% 
% filter_table=[label_1',[label_2;num2cell(media);num2cell(fix(mean(media)))]];
% % makeHtmlTable([fix(media);fix(mean(media))],[],label_1,label_2 );
% 
% %printmatrix(ETC_FILTER_CORRECTION)
% table_filter_correction=[label_2;num2cell(round(ETC_FILTER_CORRECTION))];
% % makeHtmlTable(ETC_FILTER_CORRECTION,[],{'ETC FILTER CORR'},label_2 );
% 


%% FIGURAS
try
if plot_flag
    
   fh=figure; set(fh,'tag','FI_TIME');
   subaxis(6,1,1,'sv',0,'sh',0.1)
   for ii=1:6
       subaxis(ii);
       % for ii=1:6
       %subplot(2,3,ii);
       %plot(dia,((fi(:,4:2:end,ii)-repmat(nominal(ii),[nmeas,6]))./repmat(nominal(ii),[nmeas,6])));
       aux_ratio=100*matdiv(matadd(fi(:,4:2:end,ii),-mean(fi(:,4:2:end,ii))),mean(fi(:,4:2:end,ii)));
       %mmplotyy(datenum(fech),fi(:,4:2:end,ii),':*',temp,'^k');
       plot(datenum(fech),aux_ratio)
       %plot(datenum(fech),temp,'^k');
       %plot(dia(:,1),fi(:,4:2:end,ii),'.');
   
   if ii==1 
       legend(label_lamda,'Location','North','orientation','horizontal');
   end
  
   axis('tight');
   datetick('x','mmmyy','keeplimits','keepticks');
   end
   samexaxis('abc','xmt','on','ytac','join','yld',1)
%legend(label_lamda); 
%mmplotyy('shrink');

%% Mensual
fh=figure; set(fh,'tag','FI_TIME_MONTH');
subaxis(3,2,1,'sv',0,'sh',0.1)
for ii=1:6
  subaxis(ii);
  fi_month{ii}.media=fi_month{ii}.media(~isnan(fi_month{ii}.media(:,4)),:);
  ploty(fi_month{ii}.media(:,[1,6:end]),'.-.');
  axis('tight');
  datetick('x','mmmyy','keeplimits','keepticks');
  title(label_filter{ii});
end
%set(subaxis(6),'xticklabelmode','auto')
legend(label_lamda); 


% Mensual2
fh=figure; set(fh,'tag','FI_TIME_MONTH');

for ii=1:6
  subplot(6,1,ii);
  plot( fi_month{ii}.media(:,1),...
      matdiv(fi_month{ii}.media(:,[6:end]),med(2:end,ii)'),'.-.');
  axis('tight');
  datetick('x','mmm','keeplimits','keepticks'); 
  if ii==1 legend(label_lamda,'Location','North','orientation','horizontal'); end
  ylabel(label_filter{ii});
end
samexaxis('abc','xmt','on','ytac','join','yld',1)
suptitle('Month ratios vs mean');

%
fh=figure; set(fh,'tag','FI_TIME_ETC');
for ii=1:6
  subplot(2,3,ii);
  ploty(filter_month(:,[1,ii+1]),'.:');
  if ii~=1
    hline(ETC_FILTER_CORRECTION(:,ii-1),{'k','b','b:','b:'},{'mean','median','ci','ci'});
  end
  axis('tight');
  datetick('x','mmmyy','keeplimits','keepticks')
  title(label_filter{ii});
end
suptitle([brw_str, 'ETC correction factor time evolution']);
%legend(label_lamda); 

% Mensual
fh=figure; set(fh,'tag','FI_TIME_ETC2');
ploty(filter_month(:,[1,3:end]));
legend(label_filter(2:end), 'Orientation','Horizontal','Location','NorthOutside');
datetick;
suptitle([brw_str, ' ETC correction factor time evolution']);
grid;
legend(label_filter(2:end),'Location','North','orientation','horizontal');
%legend(label_lamda); 

end
catch
    disp('Figure Error');
end

%% FI STATS
fh=figure; set(fh,'tag','FI_STATS'); nom=[.001 5 10 15 20 25]*10^3;
ha=tight_subplot(3,2,[.08 .08],[.15 .15],[.1 .05]);% 
for ii=2:6
  axes(ha(ii-1));
  boxplot(100*((fi(:,4:2:end,ii)-repmat(nom(ii),[nmeas,6]))./repmat(nom(ii),[nmeas,6])),...
      'label',label_lamda);
  set(gca,'Linewidth',1, 'XTickLabel', '');   title(sprintf('Filter #%d',ii-1)); ylabel('');
  if ii==6
      set(gca,'XTickLabel',label_lamda); xlabel('Wavelength');
  end
end
axes(ha(6));
boxplot(100*((fi(:,4:2:end,1)-repmat(nom(1),[nmeas,6]))./repmat(nom(1),[nmeas,6])),...
       'label',label_lamda);   set(gca,'Linewidth',1);     
xlabel('Wavelength'); ylabel('');
title('Intensity');
sup=suptitle(sprintf('%s%s\n%s','Attenuation Filter Test, ',fioavg(regexp(fioavg,'AVG')-3:regexp(fioavg,'AVG')+6),...
                                'Difference with respect to nominal values (%)'));
pos=get(sup,'Position'); set(sup,'Position',[pos(1)+.02,pos(2)-.01,1]);

%%
flag_sup_2=0;
if ~isempty(config) && ~isequal([1,config(2:6)'],[1,5000,10000,15000,20000,25000])
    nominal{1}=[1,5000,10000,15000,20000,25000]; nominal{2}=[1,config(2:6)'];
    flag_sup_2=1;
end
for nn=1:length(nominal)
    F1=100*((fi(:,4:2:end,2)-repmat(nominal{nn}(2),[nmeas,6]))./repmat(nominal{nn}(2),[nmeas,6]));
    F2=100*((fi(:,4:2:end,3)-repmat(nominal{nn}(3),[nmeas,6]))./repmat(nominal{nn}(3),[nmeas,6]));
    F3=100*((fi(:,4:2:end,4)-repmat(nominal{nn}(4),[nmeas,6]))./repmat(nominal{nn}(4),[nmeas,6]));
    F4=100*((fi(:,4:2:end,5)-repmat(nominal{nn}(5),[nmeas,6]))./repmat(nominal{nn}(5),[nmeas,6]));
    F5=100*((fi(:,4:2:end,6)-repmat(nominal{nn}(6),[nmeas,6]))./repmat(nominal{nn}(6),[nmeas,6]));

    figure; set(gcf,'tag',['FIOSTATS_',num2str(nn)]); ha=tight_subplot(2,2,[.05 .03],[.15 .15],[.1 .1]);

    axes(ha(1));
    h1=boxplotCsub(F1,1,'o',1,1,'r',true,1,true,[1 1],1.5,0.005,false);
    h2=boxplotCsub(F2,1,'*',1,1,'g',true,1,true,[1 1],1.25,0.05,false);
set(gca,'YLim',[min(min(cat(1,F1,F2))) max(max(cat(1,F1,F2)))],'XTickLabel','');
ll=get(gca,'YLim'); set(gca,'YTick',[ll(1) sum(ll)/2 ll(end)],'YTickLabel',round([ll(1) sum(ll)/2 ll(end)])); ylabel(''); xlabel('');
l=legend([h1(7,1),h2(7,1)],{'Filt#1','Filt#2'},'Location','NorthEast'); set(l,'FontSize',8); grid

    axes(ha(2));
    h2=boxplotCsub(F2,1,'*',1,1,'g',true,1,true,[1 1],1.25,0.05,false);
    h3=boxplotCsub(F3,1,'+',1,1,'m',true,1,true,[1 1],1.05,0.05,false);
set(gca,'YLim',[min(min(cat(1,F2,F3))) max(max(cat(1,F2,F3)))],'XTickLabel', '');
ll=get(gca,'YLim'); set(gca,'YTick',[ll(1) sum(ll)/2 ll(end)],'YTickLabel',round([ll(1) sum(ll)/2 ll(end)])); ylabel(''); xlabel('');
l=legend([h2(7,1),h3(7,1)],{'Filt#2','Filt#3'},'Location','NorthEast'); set(l,'FontSize',8); grid

    axes(ha(3));
    h3=boxplotCsub(F3,1,'+',1,1,'m',true,1,true,[1 1],1.05,0.05,false);
    h4=boxplotCsub(F4,1,'*',1,1,'b',true,1,true,[1 1],1.25,0.05,false);
set(gca,'YLim',[min(min(cat(1,F3,F4))) max(max(cat(1,F3,F4)))],'XTickLabel',label_lamda); 
ll=get(gca,'YLim'); set(gca,'YTick',[ll(1) sum(ll)/2 ll(end)],'YTickLabel',round([ll(1) sum(ll)/2 ll(end)])); ylabel(''); xlabel('');
l=legend([h3(7,1),h4(7,1)],{'Filt#3','Filt#4'},'Location','NorthEast'); set(l,'FontSize',8); grid
    axes(ha(4));
    h4=boxplotCsub(F4,1,'*',1,1,'b',true,1,true,[1 1],1.25,0.05,false);
    h5=boxplotCsub(F5,1,'+',1,1,'k',true,1,true,[1 1],1.05,0.05,false);
set(gca,'YLim',[min(min(cat(1,F4,F5))) max(max(cat(1,F4,F5)))],'XTickLabel',label_lamda);
ll=get(gca,'YLim'); set(gca,'YTick',[ll(1) sum(ll)/2 ll(end)],'YTickLabel',round([ll(1) sum(ll)/2 ll(end)])); ylabel(''); xlabel('');
l=legend([h4(7,1),h5(7,1)],{'Filt#4','Filt#5'},'Location','NorthEast'); set(l,'FontSize',8); grid

xl=xlabel('Wavelength'); set(xl,'Units','normalized','Position',[-0.03 -0.2]);
yl=ylabel('Relative diffs. (%)'); set(yl,'Units','normalized','Position',[-1.2 1]);
    if flag_sup_2
        if nn==1
            sup=suptitle(sprintf('Attenuation Filter Test, %s\nDiff. (%%) with respect to nominal values [%d,%d,%d,%d,%d,%d]',...
                                  fioavg(regexp(fioavg,'AVG')-3:regexp(fioavg,'AVG')+6),nominal{nn}));
        else
            sup=suptitle(sprintf('Attenuation Filter Test, %s\nDiff. (%%) with respect to operational values [%d,%d,%d,%d,%d,%d]',...
                                  fioavg(regexp(fioavg,'AVG')-3:regexp(fioavg,'AVG')+6),nominal{nn}));
        end
    elseif flag_sup 
        sup=suptitle(sprintf('Attenuation Filter Test, %s\nDiff. (%%) with respect to operational values [%d,%d,%d,%d,%d,%d]',...
                              fioavg(regexp(fioavg,'AVG')-3:regexp(fioavg,'AVG')+6),nominal{nn}));
    else
        sup=suptitle(sprintf('Attenuation Filter Test, %s\nDiff. (%%) with respect to nominal values [%d,%d,%d,%d,%d,%d]',...
                               fioavg(regexp(fioavg,'AVG')-3:regexp(fioavg,'AVG')+6),nominal{nn}));
    end
    pos=get(sup,'Position'); set(sup,'Position',[pos(1)-.01,pos(2)-.01,1]);
end

%%
f=figure; set(f,'tag','FI_wavelength');
r=matdiv(100*matadd(media,-mean(media)),media);

p=plot(lamda,r,'*-.');
set(p(1),'Color','r'); set(p(2),'Color','g'); set(p(3),'Color','m'); set(p(4),'Color','b'); set(p(5),'Color','k');
hold on; plot(lamda,mean(r,2),'s-','MarkerFaceColor','k');
set(gca,'XLim',[3020 3212],'XTick',lamda,'XTickLabel',round(lamda)./10,...
        'GridLineStyle','-.','Linewidth',1);
ylabel('Difference to mean, {\it%}'); xlabel('wavelength {\it(nm)}');
H=legend([label_filter(2:end),'mean'],...
                  'Orientation','Horizontal','Location','NorthOutside');
title(gca,sprintf('%s %s','Wavelength dependence of the attenuation filter,  #',brw_str));
set(H,'LineWidth',1);              
grid;
orient portrait;

%%
% sup=title({sprintf('%s %s','Wavelength dependence of the attenuation filter,  #',brw_str),...
%     num2str(ETC_FILTER_CORRECTION)});
% box off


if chk
    % Se muestran los argumentos que toman los valores por defecto
  disp('--------- Validation OK --------------') 
  disp('List of arguments given default values:') 
  if ~numel(arg.UsingDefaults)==0
     for k=1:numel(arg.UsingDefaults)
        field = char(arg.UsingDefaults(k));
        value = arg.Results.(field);
        if isempty(value),   value = '[]';   
        elseif isfloat(value), value = num2str(value); end
        disp(sprintf('   ''%s''    defaults to %s', field, value))
     end
  else
     disp('               None                   ')
  end
  disp('--------------------------------------') 
else
     disp('NO INPUT VALIDATION!!')
     disp(sprintf('%s',errval.message))
end