% modificar para testear 3 configuraciones con SL
% obtener solo los ajustes no plotear.

function [NTC,ajuste,Fr]=temp_coeff_report_raw(setup_file,sl,config,varargin)

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
arg.addRequired('setup_file'); 
arg.addRequired('sl'); 
arg.addRequired('config');

% input param - value
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('r_flag', 0, @(x)(x==0 || x==1)); % por defecto no son las recalculadas 
arg.addParamValue('TCB', [], @(x)(size(x,1)==5 || size(x,2)==5 )); % por defecto esta vacio
arg.addParamValue('N_TC', [], @(x)(size(x,1)==5 || size(x,2)==5 )); % por defecto esta vacio% depuracion
% validamos los argumentos definidos:
try
  arg.parse(setup_file, sl, config, varargin{:});
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
              
if isstruct(setup_file)
     n_inst=setup_file.n_inst;
     brw_name{n_inst}=setup_file.brw_name;
     FINAL_DAYS(1)=setup_file.final_days;
else
     eval(config_file);
end

%% configuration 
O3W=[    0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  -1.00    0.00    0.00    4.20   -3.20];
WN=[302.1,306.3,310.1,313.5,316.8,320.1];
% MS8 SO2 ms9 o3 en el soft del brewer.
% single ratios used in brewer software
rms4=[ -1  0  0  1  0];
rms5=[  0 -1  0  1  0];
rms6=[  0  0 -1  1  0];
rms7=[  0  0  0 -1  1];
W=[rms4;rms5;rms6;rms7;SO2W;O3W]';

% OLD and new configuration files
TC=[];A=[];TC_B=[];
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
    n_rows=size(config{n_inst}{1},2)
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
%% SL recalculated with  configuration
% Temperature coefficients calculated with the configuration provided
%
% 
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
           plot(Fr(:,2),Fr(:,3+ii),'.','MarkerSize',2);
           hold on;
           plot(Fr(out,2),Fr(out,3+ii),'rx','MarkerSize',20);
           Fr_dep=Fr(out,:) ;
           Fr(out,[1,3+ii])=NaN;
       end
    end


%% time dependence removed
% Fr_seg=Fr;
% Fx=Fr;
% 
% aux=nanmean(Fr(:,3:7),2);
% x=[aux,Fr(:,2),ones(size(Fr(:,1)))];
% y=Fr(:,3:7);
% cx={};
% 
% for i=1:5
%     [bx,cx{i}]=regress(y(:,i),x,0.01); %dependencia del tiempo
%     Fx(:,i+2)=Fr(:,i+2)-(bx(1)*x(:,1)+bx(end))+nanmean(Fr(:,i+2));
% end
% O3W=[     0.00   -1.00    0.50    2.20   -1.70];
% SO2W=[    -1.00    0.00    0.00    4.20   -3.20];
% 
% Fx(:,end-1)=Fr(:,3:7)*SO2W';
% Fx(:,end)=Fr(:,3:7)*O3W';
% 
% Fr=Fx;

%% regression calculation
b=zeros(2,7);
for i=1:7 
    [b(:,i),stats]=robustfit(Fr(:,2),Fr(:,i+2));
    stats=stats.se;
    ajuste(i,:)=[b(1,i)' b(2,i)' stats(1,:)' stats(2,:)'];
end

tc=b(2,1:5);otc=TC_B; % TC wich where used for ratios calculations
if TC_B(1)==0 % si esta normalizada o no
 NTC=-(tc-tc(1))+otc;
else
 NTC=-tc+otc;
end

%% test of new coefficients

%redondeamos a las cifras significativas

FC=10*10.^abs(round(log10(ajuste(1:5,end))));
NTC=matdiv(round(NTC'.*FC),FC)';

if ~isempty(N_TC)
     NTC=N_TC;
end



%% 


%  original counts/second with TC=0

F0=Fr;
F0(:,3:7)=F0(:,3:7)+matmul(repmat(F0(:,2),1,5),-otc);

%   original double ratios  TC=0
F0=[F0(:,1:7),F0(:,3:7)*SO2W',F0(:,3:7)*O3W'];

% counts/seconds with NTC
FN=Fr;
FN(:,3:7)=F0(:,3:7)+matmul(repmat(F0(:,2),1,5),NTC);
%   original double ratios  TC=0
FN=[FN(:,1:7),FN(:,3:7)*SO2W',FN(:,3:7)*O3W'];

% counts/seconds with TC config 2
FN2=Fr;
FN2(:,3:7)=F0(:,3:7)+matmul(repmat(F0(:,2),1,5),TC_N);
FN2=[FN2(:,1:7),FN2(:,3:7)*SO2W',FN2(:,3:7)*O3W'];

% counts/seconds with TC config 1
FN1=Fr;
FN1(:,3:7)=F0(:,3:7)+matmul(repmat(F0(:,2),1,5),TC_N);
FN1=[FN1(:,1:7),FN1(:,3:7)*SO2W',FN1(:,3:7)*O3W'];



%%testing procedure  
figure;  
plot(F0(:,2),F0(:,9),'rx');
hold on;
plot(FN(:,2),FN(:,9),'bo');
hold on;
plot(Fr(:,2),Fr(:,9),'k+');

%plot(FN1(:,2),FN1(:,9),'gp');
%plot(FN2(:,2),FN2(:,9),'ys');



 
 [a,r6tc]=rline(1); % input lo que sea. Si no hay input, el comportamiento de siempre
 legend({[sprintf('R6, TC=0  :  y = %06.1f + %3.1fT',r6tc(2,1),r6tc(1,1))],...
         [sprintf('R6, TC new: y = %06.1f + %3.1fT',r6tc(2,2),r6tc(1,2))],...
         [sprintf('R6, TC old: y = %06.1f + %3.1fT',r6tc(2,3),r6tc(1,3))],...
        % [sprintf('R6, TC 1c: y = %06.1f + %3.1fT',r6tc(2,4),r6tc(1,4))],...
        % [sprintf('R6, TC 2c: y = %06.1f + %3.1fT',r6tc(2,5),r6tc(1,5))]
        });
 xlabel('Temperature'); ylabel('R6');
 title('R6 ratios, original TC vs. calculated TC');



%% FIGURES-------------> PASARLO A FUNCION EXTERNA
f=figure;
set(f,'tag','TEMP_global');
orient landscape;

  subplot(3,1,1)
  plot(Fr(:,2),Fr(:,9),'x','MarkerSize',1);
  [a,b,stats]=robust_line;
  subplot(3,1,2:3)
  plot(Fr(:,2),Fr(:,3:7),'x','MarkerSize',3);
  [a,b,stats]=robust_line;

  ylabel('counts seconds');
  xlabel('PMT Temperature (C\circ)');


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
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})


hl={};  line={};  stats={};

ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/20);
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


%%
f=figure;
set(f,'tag','TEMP_day_new');
orient tall;
suptitle(brw_name{n_inst})


ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/20);
c=bone(ceil(ndays/nrep));

for ii=0:5
 subplot(3,2,ii+1)
 if ii==5 
     ii=ii+1;
 end
 plot(FN(:,2),FN(:,3+ii),'x','MarkerSize',1);
 [hl{ii+1},line{ii+1},stats{ii+1}]=report_robust_line;
 hold on
 
 [h]=gscatter(FN(:,2),FN(:,3+ii),fix(FN(:,1)/nrep)*nrep,c,[],10);

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

suptitle(sprintf('%s: %s',brw_name{n_inst},'Temperature coeff new.'));






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