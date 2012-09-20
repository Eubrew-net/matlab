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
arg.addParamValue('r_flag', 0, @(x)(x==0 || x==1)); % por defecto no son las recalculadas 
arg.addParamValue('TCB', [], @(x)(size(x,1)==5 || size(x,2)==5 )); % por defecto esta vacio
% depuracion
% validamos los argumentos definidos:
try
  arg.parse(config_file, sl, config, varargin{:});
  mmv2struct(arg.Results);
  chk=1;

catch
  errval=lasterror;
  disp(errval.message)
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
line={};
h=[];
out=[];
%i=n_inst;
%idx_inst=n_inst;


if isnumeric(config)
    b=config;
    TC(1:5)=b(2:6);
    TC_old(1:5)=b(2:6);
    TC_B=TC_old;
    warning('configuraion file must be the same of bfiles')           
elseif iscell(config)
   
    a=cell2mat(config{n_inst}');
    % new config
    %falla si solo hay 1
    jk=find(~cellfun(@isempty,config{n_inst}),1,'first');
    size(config{n_inst}{jk},2);
    n_rows=size(config{n_inst}{1},2);
    if size(a,2)>2 
        if n_rows==3
          TC_B=unique(a(2:6,3:n_rows:end)','rows');
          TC_N=unique(a(2:6,2:n_rows:end)','rows');
          TC_O=unique(a(2:6,1:n_rows:end)','rows');
        elseif n_rows==2
          TC_B=unique(a(2:6,1:n_rows:end)','rows');
          TC_N=unique(a(2:6,2:n_rows:end)','rows');
          TC_O=TC_B;
          warning('Asuming TC is form first configuration');
        else
          TC_B=unique(a(2:6,1:n_rows:end)','rows');
          TC_O=TC_B;
          warning('Asuming TC is form first configuration');
        end
    else   
        TC_B=unique(a(2:6,2)','rows');
        TC_N=TC_B;
        TC_O=TC_B;
    end
end
   
if size(TC_B,1)>1
    error('Diferent TC configuration in b files');
end

 if ~isempty(TCB)
     TC_B=TCB;
 end



 
%% SL recalculated with  configuration
% Temperature coefficients calculated with the configuration provided
%
% input AVG, ojo se supone que el TC es el de la configuracion
if isfloat(sl)
   Fr=ratio2counts_avg(sl);
   sls=sl;
   
elseif iscell(sl)  % ojo r_flag tiene que estar acorde con lo que se envia
       
    if iscell(sl{n_inst})
          sls=cell2mat(sl{n_inst});
    else
          sls=sl{n_inst};
    end
          Fr=ratio2counts(sls);
          Fr(:,1)=diaj2(sls(:,1)); %fecha
          Fr(:,2)=abs(sls(:,13));         
                    
elseif isstruct(sl)
    if r_flag==1  % segunda configuracion
      sls=cat(1,sl.rc);
      
    else
      sls=cat(1,sl.c);
    end
    Fr=ratio2counts(sls);    
    Fr(:,1)=diaj2(sls(:,1)); %fecha
    Fr(:,2)=abs(sls(:,13));
end


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
           [a,b,out]=boxparams(Fr(:,3+ii),1.5);
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
xlabel('day');
text(repmat(min(Fr(:,1))+.1,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
%legend({'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'},'BestOutSide');
% hold on; % informativo pero queda feo, estudiar
% plot2(Fr(:,1),Fr(:,2),'p');
% ylabel('Temperature Cº');
subplot(2,4,3:4);
mmplotyy_temp(Fr(:,1),Fr(:,end),'.',Fr(:,end-1),'x');
set(gca,'LineWidth',1);
mmplotyy('R5');
xlabel('day')
% ylabel('R6');
mmplotyy('shrink');
legend({'R6','R5'},'Location','NorthEast','HandleVisibility','Off');
%legend('R6','R5');

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
subplot(2,2,3)
plot(Fr(:,2),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
ylabel(' %ratio to mean SL (cnts/sec)');xlabel('Temperature'); grid;
legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','North','Orientation','Horizontal');

subplot(2,2,1)
mmplotyy(Fr(:,1),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.',Fr(:,2),'k+');
ylabel(' %ratio to mean SL (cnts/sec)');xlabel('Time'); grid;

% subplot(2,2,1)
% plot(Fr(:,1),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
% ylabel(' ratio to mean (%) SL counts/seconds');xlabel('Time');
% legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','South','Orientation','Horizontal');

subplot(2,2,2)
plot(Fr(:,1),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
ylabel(' %ratio to mean SL ratios');xlabel('Time'); grid;
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');

subplot(2,2,4)
plot(Fr(:,2),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
ylabel(' %ratio to mean SL ratios');xlabel('Temperature'); grid;
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');


%%
f=figure;
set(f,'tag','TEMP_global');
orient landscape;

  subplot(3,1,1)
  plot(Fr(:,2),Fr(:,9),'x','MarkerSize',1);
  [a,b,stats]=robust_line;
  stats=stats.se;
  ajuste(7,:)=[b(1,:)' b(2,:)' stats(1,:)' stats(2,:)'];

  subplot(3,1,2:3)
  plot(Fr(:,2),Fr(:,3:7),'x','MarkerSize',3);
  [a,b,stats]=robust_line;
  stats=cat(2,stats.se);
  ajuste(1:5,:)=[b(1,:)' b(2,:)' stats(1,:)' stats(2,:)'];
  ylabel('counts seconds');
  xlabel('PMT Temperature (C\circ)');

tc=b(2,:);otc=TC_B(:)'; % has to be how the sl was processed
tc=tc(:)';
if otc(1)==0 % si esta normalizada o no
 NTC=-(tc-tc(1))+otc;
else
 NTC=-tc+otc;
end

suptitle(num2str([otc;NTC]));  grid;


%% REVISAR
O3W=[   0.00   -1.00    0.50    2.20   -1.70];
f=figure;
set(f,'tag','TEMP_OLD_VS_NEW');
FN=Fr;
FN(:,3:7)=Fr(:,3:7)+matmul(repmat(FN(:,2),1,5),(NTC)-otc);

 MS9=[Fr(:,1),Fr(:,2),Fr(:,3:7)*O3W'];
 MS9_cr=[Fr(:,1),Fr(:,2),FN(:,3:7)*O3W'];

 if outlier_flag
   [a,b,out]=boxparams(MS9(:,3),3); MS9(out,3)=NaN;
   [a,b,out]=boxparams(MS9_cr(:,3),3); MS9_cr(out,3)=NaN;
 end
 
plot(MS9(:,2),MS9(:,3),'rx');
hold on; plot(MS9_cr(:,2),MS9_cr(:,3),'bo');
[a,r6tc]=rline(1); % input lo que sea. Si no hay input, el comportamiento de siempre
legend({[sprintf('R6, TC old:  y = %06.1f + %3.1fT',r6tc(2,1),r6tc(1,1))],...
        [sprintf('R6, TC new: y = %06.1f + %3.1fT',r6tc(2,2),r6tc(1,2))]});
xlabel('Temperature'); ylabel('R6');
title('R6 ratios, original TC vs. calculated TC');


%%
f=figure;
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})


hl={};  line={};  stats={};

ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/20);
%c=hsv(fix(length(unique(fix(Fr(~isnan(Fr(:,1)),1))))/3));
c=bone(ceil(ndays/nrep));
for ii=0:5
 subplot(3,2,ii+1)
 if ii==5 
     ii=ii+1;
 end
 plot(Fr(:,2),Fr(:,3+ii),'x','MarkerSize',1);
 [hl{ii+1},line{ii+1},stats{ii+1}]=report_robust_line;
 hold on
 
 [h]=gscatter(Fr(:,2),Fr(:,3+ii),fix(Fr(:,1)/nrep)*nrep,c,[],10);

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
     title(['slit #',num2str(ii+2),' ',num2str(line{ii+1}(2))]);
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
     disp('NO INPUT VALIDATION!!')
     disp(sprintf('%s',errval.message))
end