function [NTC,ajuste,Fr]=temp_coeff_report(config_file,sl,config,varargin)

% SL temperature analysis
%  
% TODO :
%           -Separar calculos y salidas    
% 
% INPUTS:
%           - config_file  
%           - sl
%           - config
%           - opcionales (ver abajo)  
% 
% OUTPUTS:
%           - NTC
%           - tabla_regress
% calculation from raw counts. Revisar linea 49
%
% MODIFICADO: 
% Alberto 09/2009: plot para elegir el numero de dias a plotear
%                  ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
%                  nrep=ceil(ndays/20);
%                  c=hsv(ceil(ndays/nrep));
%  
% Juanjo 10/11/2009: Redefino los inputs de la función. Tres son
%                    obligatorios; config_file, sl y config. Otros tres opcionales;
%                  - 'daterange' -> array de uno o dos elementos (fecha matlab)
%                  - 'outlier_flag' -> 1=depuración, 0=no depuración
% 
% Juanjo 03/12/2009: No se depuraban las MS9 del sumario.
%                    Modifico el indice del bucle a ii=0:6 para hacerlo (no es tan importante, 
%                    porque se recalculan las ratios a partir de las cuentas de slit, que si se depuran)
%                    Modifico el código que carga datos para contemplar
%                    estructuras (la generada por readb_sll)
% 
% Alberto: Ya contempla mas de un año
% 
% Juanjo 13/04/2010: Modificado el control de inputs. Ahora se hace uso de
%                    clase inputParser (siguen siendo los mismos, ver modificacion del 10/11/2009)
%                    Valores por defecto: date_range=[], no control de fechas
%                                         outlier_flag=0, no filtrado de outliers
%                    Se muestran al final del script los parametros que han tomado un valor por defecto
%                    En el caso de usar la vieja forma de llamar a las funciones tambien funcionará.
%                    
%                    
%                                                                              
% Ejemplo:
% [NTC,tabla_regress]=temp_coeff_report(config_temp,sl_cr,config,...
%                                       'date_range',datenum(cal_year,cal_month-10,1),...
%                                       'outlier_flag',1);
% 

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'temp_coeff_report';

% input obligatorio
arg.addRequired('config_file'); 
arg.addRequired('sl'); 
arg.addRequired('config');

% input param - value
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas

% validamos los argumentos definidos:
try
  arg.parse(config_file, sl, config, varargin{:});
  mmv2struct(arg.Results);
  chk=1;

catch
  if length(varargin)==2
      date_range=varargin{1};
      outlier_flag=varargin{2};
  elseif length(varargin)==1
      date_range=varargin{1};
      outlier_flag=0; % por defecto no depuracion
  else
      date_range=[];   % por defecto no control de fechas
      outlier_flag=[]; % por defecto no depuracion
  end
  chk=0;
end
              
if isstruct(config_file)
     n_inst=config_file.n_inst;
     brw_name{n_inst}=config_file.brw_name;
     FINAL_DAYS(1)=config_file.final_days;
else
     eval(config_file);
end

%% OLD and new configuration files
TC=[];A=[];
TC_old=[]; cfg_old=[];cfg=[];
line={}; ajuste=[];
h=[];
out=[];

for i=n_inst
    a=cell2mat(config{n_inst}');
    % new config
    % falla si solo hay 1
    if size(a,2)>2
    b=unique(a(1:end-1,2:2:end)','rows');
    else
    b=unique(a(1:end-1,2)','rows');
    end
    A(i)=b(8);
    ETC(i)=b(11);
    %cfg(i,1:52)=b;
    TC(i,1:5)=b(2:6);
    
    % old config
    b=unique(a(1:end-1,1:2:end-1)','rows');
    A_old(i)=b(8);
    ETC_old(i)=b(11);
    %cfg_old(i,1:52)=b;
    TC_old(i,1:5)=b(2:6);    
end

%Counts and recalculate conts comp%  idx_inst=i;
%   sls=cell2mat(sl_cr{i});
%  Fr_r=ratio2counts(sls);
%  Fr_r(:,1)=sls(:,1);
%  Fr_r(:,2)=sls(:,13);
%  
%  sls=cell2mat(sl{i})
%  Fr=ratio2counts(sls);
%  Fr(:,1)=sls(:,1);
%  Fr(:,2)=sls(:,13);
% figure;plot(Fr(:,1),Fr_r./Fr)
%  
 
%% SL recalculated with  configuration
% Temperature coefficients calculated with the configuration provided
%
if isfloat(sl)
   Fr=ratio2counts_avg(sl);
   Fr(:,1)=sl(:,1);
   sls=sl;
elseif iscell(sl)
       if iscell(sl{n_inst})
          sls=cell2mat(sl{n_inst});
       else
          sls=sl{n_inst};
       end
elseif isstruct(sl)
    sls=cat(1,sl.c);
end
Fr=ratio2counts(sls);
Fr(:,1)=sls(:,1); %fecha
Fr(:,2)=abs(sls(:,13));

%% control de fechas
% only data in time range
if ~isempty(date_range)
    j=find(sls(:,1)<=(date_range(1)));
    Fr(j,:)=NaN;
    if length(date_range)>1
        j=find(sls(:,1)>=(date_range(2)));
        Fr(j,:)=NaN;
    end
end

figure;
    if outlier_flag
       for ii=0:6
           [a,b,out]=boxparams(Fr(:,3+ii),3);
           if ii==6
               subplot(4,2,7:8);
           else
               subplot(4,2,ii+1);
           end
           plot(Fr(:,2),Fr(:,3+ii),'.','MarkerSize',1);
           hold on;
           plot(Fr(out,2),Fr(out,3+ii),'x','MarkerSize',14);
           Fr_dep=Fr(out,:) ;
           Fr(out,[1,3+ii])=NaN;
       end
    end

%%
f=figure;
set(f,'Tag','TEMP_COEF_DESC');
orient landscape;
suptitle(brw_name{n_inst})
subplot(2,4,1:2)
ploty(Fr(:,[1,3:end-2]),'.');
set(gca,'LineWidth',1);
ylabel('Counts');
xlabel('date');
text(repmat(min(Fr(:,1))+.1,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
datetick('x',6,'keeplimits','keepticks');

%legend({'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'},'BestOutSide');
% hold on; % informativo pero queda feo, estudiar
% plot2(Fr(:,1),Fr(:,2),'p');
% ylabel('Temperature Cº');
subplot(2,4,3:4);
mmplotyy_temp(Fr(:,1),Fr(:,end),'.',Fr(:,end-1),'x');
set(gca,'LineWidth',1);
mmplotyy('R5');
xlabel('date')
legend({'R6','R5'},'Location','NorthEast','HandleVisibility','Off');
datetick('x',6,'keeplimits','keepticks');
mmplotyy('shrink');

subplot(2,4,5:6)
ploty(Fr(:,[2,3:end-2]),'.');
set(gca,'LineWidth',1);
text(repmat(min(Fr(:,2))+1.5,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
%legend({'slit #0','slit #2','slit #3','slit #4','slit #5'},'BestOutside');
ylabel('Counts'); xlabel('temperature (ºC)');
subplot(2,4,7:8);
mmplotyy_temp(Fr(:,2),Fr(:,end),'.',Fr(:,end-1),'x');
set(gca,'LineWidth',1);
mmplotyy('R5');
xlabel('temperature (ºC)')
mmplotyy('shrink');
suptitle(brw_name{n_inst})
legend(gca,{'R6','R5'},'Location','NorthEast','HandleVisibility','Off');
orient portrait;

%% cambio % respecto al valor medio
figure; 
subplot(2,2,1)
plot(Fr(:,2),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
ylabel(' ratio to mean (%) SL counts/seconds');xlabel('Temperature');
% legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','North','Orientation','Horizontal');

subplot(2,2,2);
plot(Fr(:,1),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
ylabel(' ratio to mean (%) SL counts/seconds');xlabel('Time');
% legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','South','Orientation','Horizontal');
datetick('keeplimits');

% subplot(2,2,3)
% plot(Fr(:,1),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
% ylabel(' %ratio to mean SL ratios');xlabel('Time');
% legend({'R6','R5'},'Location','Best','HandleVisibility','Off');

subplot(2,2,3);
plot(Fr(:,1),matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),'.');
ylabel(' Abs diff to mean SL ratios');xlabel('Time');
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');
datetick('keeplimits');

% subplot(2,2,4)
% plot(Fr(:,2),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
% ylabel(' %ratio to mean SL ratios');xlabel('Temperature');
% legend({'R6','R5'},'Location','Best','HandleVisibility','Off');

subplot(2,2,4)
plot(Fr(:,2),matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),'.');
ylabel(' Abs diff  to mean SL ratios');xlabel('Temperature');
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');

%% cambio % respecto al valor medio
%figure; plot(Fr(:,1),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))))
%%
f=figure;
set(f,'tag','TEMP_global');
orient landscape;

  subplot(3,1,1)
  plot(Fr(:,2),Fr(:,9),'x','MarkerSize',1);
[a,b,stats]=robust_line;
ajuste(6,:)=[b(1,:)' b(2,:)' stats(1,:)' stats(2,:)'];

  subplot(3,1,2:3)
  plot(Fr(:,2),Fr(:,3:7),'x','MarkerSize',1);
[a,b,stats]=robust_line;
ajuste(1:5,:)=[b(1,:)' b(2,:)' stats(1,:)' stats(2,:)'];

tc=b(2,:);otc=TC(n_inst,:);
if TC(n_inst,1)==0 % si esta normalizada o no
 NTC=-(tc-tc(1))+otc;
else
 NTC=-tc+otc;
end

title(num2str([TC(n_inst,:);NTC]));
grid;
xlabel('PMT Temperature (C\circ)');
ylabel('counts seconds');
suptitle(brw_name{n_inst})



%% REVISAR
% Comprobamos resultados
O3W=[0.00 -1.00  0.50  2.20  -1.70];

MS9=[Fr(:,2),Fr(:,3:7)*O3W'];
[a,b,out]=boxparams(MS9(:,2),3); MS9(out,2)=NaN;

FN=Fr(:,3:7)+matmul(repmat(Fr(:,2),1,5),NTC-otc);
MS9_cr=[Fr(:,2),FN*O3W'];
[a,b,out]=boxparams(MS9_cr(:,2),3); MS9_cr(out,2)=NaN;

f=figure;
set(f,'tag','TEMP_OLD_VS_NEW');
plot(MS9(:,1),MS9(:,2),'rx');
hold on; plot(MS9_cr(:,1),MS9_cr(:,2),'bo');
[h Lr] = rline(0);
sprintf('  y=%.6f x+ %.6f',Lr(1,1),Lr(2,1))
legend({['R6, TC old: ',sprintf('y=%.6f x+ %.6f',Lr(1,1),Lr(2,1))],['R6, TC new: ',sprintf('y=%.6f x+ %.6f',Lr(1,2),Lr(2,2))]}); 
title('R6 ratios, original TC vs. calculated TC');

%%
f=figure;
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})
hl={};  line={};  stats={}; 
ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/10);
%c=hsv(fix(length(unique(fix(Fr(~isnan(Fr(:,1)),1))))/3));
c=hsv(ceil(ndays/nrep));
for ii=0:5
 subplot(3,2,ii+1)
 if ii==5 
     ii=ii+1;
 end
 plot(Fr(:,2),Fr(:,3+ii),'x','MarkerSize',1);
 [hl{ii+1,n_inst},line{ii+1,n_inst},stats{ii+1,n_inst}]=report_robust_line;
 hold on
 [Y,M,D]=datevec(fix(Fr(:,1)/nrep)*nrep);
 [h]=gscatter(Fr(:,2),Fr(:,3+ii),[Y,M,D],c,[],10);

% Si queremos la legenda en todos los subplots
% lg=legend('show');
% set(lg,'Location','NorthEast','HandleVisibility','off');

% Si solo queremos la legenda en uno de los 6 subplots
 legend('hide');
 if ii==2
 lg=legend('show');
 set(lg,'Location','NorthEast','HandleVisibility','off');
 end
 set(gca,'LineWidth',1);
  if ii==6
     title('MS9 ');       
     xlabel('PMT Temperature (ºC)');
  else
     title(['slit #',num2str(ii+2)]);
  end
 if ii==4
     xlabel('PMT Temperature (ºC)');
 end
end

suptitle(sprintf('%s: %s',brw_name{n_inst},'Temperature coeff.'));

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
     warning('NO INPUT VALIDATION!!') 
end