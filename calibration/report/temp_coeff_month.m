function [NTC,ajuste,Args,Fr,FN]=temp_coeff_raw(setup_file,sl,varargin)
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
% Juanjo 01/09/2010: Se añade el input opcional 'temp_flag', para seleccionar rango de T 
%                    (por defecto empty). Además se añade como nueva salida una estructura 
%                    con la configuración usada como entrada. Atender al
%                    orden de salida!!!  
% Alberto 01/11/2010: Se añade el input opcional 'intesity_flag', elimina por regresion cambios de intensidad
%                     (por defecto empty).
%                   : añadido la saida FN, cuentas recalculadas con la nueva TC  
%                                                                                                
% Ejemplo:
% [NTC,tabla_regress]=temp_coeff_report(config_temp,sl_cr,config,...
%                                       'date_range',datenum(cal_year,cal_month-10,1),...
%                                       'outlier_flag',1);
% 

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'temp_coeff_raw';

% input obligatorio
arg.addRequired('setup_file'); 
arg.addRequired('sl'); 

% input param - value
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('intensity_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('temp_flag', [], @isfloat); % por defecto todas la temperaturas 
arg.addParamValue('TCB', [], @(x)(size(x,1)==5 || size(x,2)==5 )); % por defecto esta vacio
arg.addParamValue('N_TC', [], @(x)(size(x,1)==5 || size(x,2)==5 )); % por defecto esta vacio% depuracion
% validamos los argumentos definidos:
try
  arg.parse(setup_file,sl,varargin{:});
  mmv2struct(arg.Results); Args=arg.Results;
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

if ~isempty(TCB)
      TC_B=TCB;
else
      TC_B=[0,0,0,0,0]
end


%% Por compatibilidad generamos la matriz Fr a partir de sl_raw 
%SL_RAW (32 columns)
%  1     	2	3	4	    5	    6	    7	8	 9	    10	
%  fexha	hg	idx	temp	filter1	filter2	min	sli0 slit1	cy	
%raw couts
%   11	12	13	14	15	16  17	
%   rL0	rL1	rL2	rL3	rL4	rL5	rL6
%counts/second calculated with TC=0
% cL0	cL1	cL2	cL3	cL4	cL5	cL6	
% 18	19	20	21	22	23	24	
% single ratios and F1 F5 from file (calculated with TC of the file)
% ms4	ms5	ms6	ms7	ms8	ms9	R1	R5
% 25	26	27	28	29	30	31	32
aux=sl;
sls=sl;
if ~isempty(date_range)
    j=find(sls(:,1)<=(date_range(1)));
    aux(j,:)=[]; sls(j,:)=[];
    if length(date_range)>1
        if length(date_range)==4
           j=find(sls(:,1)>=date_range(4));
           aux(j,:)=[]; sls(j,:)=[];

           sls_f=[]; aux_f=[];
           aux_f=sls(sls(:,1)<=date_range(2),:); sls_f=sls(sls(:,1)<=date_range(2),:);
           sls_l=[]; aux_l=[];
           aux_l=sls(sls(:,1)>=date_range(3),:); sls_l=sls(sls(:,1)>=date_range(3),:);
           
           aux=cat(1,aux_f,aux_l); sls=cat(1,sls_f,sls_l);           
        else
        j=find(sls(:,1)>=(date_range(2)));
        aux(j,:)=[]; sls(j,:)=[];
        end
    end
end

if ~isempty(temp_flag)
    j=find(sls(:,4)<=temp_flag(1));
    aux(j,:)=[]; sls(j,:)=[];
    if length(temp_flag)>1
        j=find(sls(:,4)>=temp_flag(2));
        aux(j,:)=[]; sls(j,:)=[];
    end
end

Fr=[aux(:,1),aux(:,4),aux(:,20:24),aux(:,20:24)*SO2W',aux(:,20:24)*O3W'];
% R5 and R6 from bfile , only F1 and F5 are correct
F_orig=[aux(:,1),aux(:,4),NaN*aux(:,20:24),aux(:,29:30)];
F_orig(:,3)=aux(:,31);
F_orig(:,7)=aux(:,32);

%% control de fechas
% only data in time range
% if ~isempty(date_range)
%     j=find(sls(:,1)<=(date_range(1)));
%     Fr(j,:)=[]; aux(j,:)=[];
%     if length(date_range)>1
%         j=find(sls(:,1)>=(date_range(2)));
%         Fr(j,:)=[]; aux(j,:)=[];
%     end
% end


%% intensity dependence removed
if intensity_flag
    Fr_seg=Fr;
    Fx=Fr;
    
    Iaux=nanmean(Fr(:,3:7),2);
    Iaux=Iaux/nanmean(Iaux);
    x=[Iaux,Fr(:,2),ones(size(Fr(:,1)))];
    y=Fr(:,3:7);
    cx={};
    
    for i=1:5
        [bx,cx{i}]=regress(y(:,i),x,0.01); %dependencia de la intensidad
        Fx(:,i+2)=Fr(:,i+2)-(bx(1)*x(:,1)+bx(end))+nanmean(Fr(:,i+2));
    end
    O3W=[     0.00   -1.00    0.50    2.20   -1.70];
    SO2W=[    -1.00    0.00    0.00    4.20   -3.20];
    
    Fx(:,end-1)=Fx(:,3:7)*SO2W';
    Fx(:,end)=Fx(:,3:7)*O3W';
    
    Fr=Fx;
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
j=isnan(Fr);
F_orig(j)=NaN;


%% regression calculation
b=zeros(2,7);
A=zeros(2,7);
Frm=grpstats(Fr,Fr(:,2))
for i=1:7 
    [b(:,i),stats]=robustfit(Frm(:,2),Frm(:,i+2));
    stats=stats.se;
    ajuste.cero(i,:)=[b(1,i)' b(2,i)' stats(1,:)' stats(2,:)'];
    
    if any(i==[1,5,6,7])
     [A(:,i),stats]=robustfit(F_orig(:,2),F_orig(:,i+2));
     stats=stats.se;
     ajuste.orig(i,:)=[A(1,i)' A(2,i)' stats(1,:)' stats(2,:)'];
    end    
        
end

% a partir de ahora NTC siempre se obtendra a partir de las cuentas con TC=0
tc=b(2,1:5); otc=TC_B;% TC wich where used for ratios calculations
if otc(1)==0 % si esta normalizada o no
 NTC=-((tc-tc(1))-otc);
else
 NTC=-(tc-otc);
end

%% test of new coefficients

%redondeamos a las cifras significativas

FC=10*10.^abs(round(log10(ajuste.cero(1:5,end))));
NTC=matdiv(round(NTC'.*FC),FC)';

if ~isempty(N_TC)
     NTC=N_TC;
end



%% 
% % TO CHECK.
% % double ratios  with TC_B (deberia ser lo mismo que Fr_orig si TC_B = bfiles)
% F_TCB=Fr;
% F_TCB(:,3:7)=Fr(:,3:7)+matmul(repmat(Fr(:,2),1,5),TC_B);
% F_TCB=[F_TCB(:,1:7),F_TCB(:,3:7)*SO2W',F_TCB(:,3:7)*O3W'];
% figure; plot(F_orig(:,end),'*'); hold on; plot(F_TCB(:,end),'r*');

%  original counts/second with TC=0 (salida de readb_sl_raw) + original double ratios  TC=0
F0=Fr;
F0(:,3:7)=F0(:,3:7)+matmul(repmat(F0(:,2),1,5),-otc);

%  original double ratios  TC=0 (es lo mismo que F0 ??)
F0=[F0(:,1:7),F0(:,3:7)*SO2W',F0(:,3:7)*O3W'];

% counts/seconds with NTC
FN=Fr;
FN(:,3:7)=F0(:,3:7)+matmul(repmat(F0(:,2),1,5),NTC);
%   original double ratios  TC=0
FN=[FN(:,1:7),FN(:,3:7)*SO2W',FN(:,3:7)*O3W'];
FNm=grpstats(FN,FN(:,2));

% original counts(seconds)
% F_orig already calculated
b=zeros(2,7);
A=zeros(2,7);
for i=1:7 
    [b(:,i),stats]=robustfit(FNm(:,2),FNm(:,i+2));
    stats=stats.se;
    ajuste.new(i,:)=[b(1,i)' b(2,i)' stats(1,:)' stats(2,:)'];        
end

% mean of every six sl measurements (summaries)
indx=aux(:,[1 3]);
indx(:,1)=floor(aux(:,1));

FN_aux=NaN*ones(size(FN,1),11);
FN_aux(:,1:9)=FN; FN_aux(:,[10 11])=indx(:,:);
mean_FN=grpstats(FN_aux,{FN_aux(:,end-1) FN_aux(:,end)},'mean');

F0_aux=NaN*ones(size(F0,1),11);
F0_aux(:,1:9)=F0; F0_aux(:,[10 11])=indx(:,:);
mean_F0=grpstats(F0_aux,{F0_aux(:,end-1) F0_aux(:,end)},'mean');

%%testing procedure  
f=figure;  
set(f,'tag','TEMP_OLD_VS_NEW');

plot(mean_F0(:,2),mean_F0(:,9),'ro','MarkerSize',6);
hold on;
plot(mean_FN(:,2),mean_FN(:,9),'go','MarkerSize',6);
plot(F_orig(:,2),F_orig(:,9),'k+');
[a,r6tc]=rline(1); % input lo que sea. Si no hay input, el comportamiento de siempre

plot(FN(:,2),FN(:,9),'gx','MarkerSize',3);
plot(F0(:,2),F0(:,9),'rx','MarkerSize',3);
hold off;
%plot(FN1(:,2),FN1(:,9),'gp');
%plot(FN2(:,2),FN2(:,9),'ys'); 

  legend({[sprintf('R6, TC=0  :  y = %06.1f + %3.1fT',r6tc(2,1),r6tc(1,1))],...
         [sprintf('R6, TC new: y = %06.1f + %3.1fT',r6tc(2,2),r6tc(1,2))],...
         [sprintf('R6, TC old: y = %06.1f + %3.1fT',r6tc(2,3),r6tc(1,3))],...
        % [sprintf('R6, TC 1c: y = %06.1f + %3.1fT',r6tc(2,4),r6tc(1,4))],...
        % [sprintf('R6, TC 2c: y = %06.1f + %3.1fT',r6tc(2,5),r6tc(1,5))]
        },'Location','SouthWest');
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

datetick('keepticks','keeplimits');        
        
subplot(2,4,3:4);
mmplotyy_temp([Fr(:,1)],[F_orig(:,end),FN(:,end)],'.',[F_orig(:,end-1),FN(:,end-1)],'rx');
%mmplotyy_temp(Fr(:,1),Fr(:,end),'.',Fr(:,end-1),'x');
set(gca,'LineWidth',1);
mmplotyy('R5');
ylabel('R6');
xlabel('day')
mmplotyy('shrink');
%legend({'R6','R5'},'Location','NorthEast','HandleVisibility','Off');
legend(gca,{'R6','R6 new','R5','R5 new'},'HandleVisibility','Off');
datetick('keepticks','keeplimits');        



subplot(2,4,5:6)
ploty(Fr(:,[2,3:end-2]),'.');
set(gca,'LineWidth',1);
text(repmat(min(Fr(:,2))+1.5,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
ylabel('Counts'); xlabel('temperature (ºC)');


subplot(2,4,7:8);
%mmplotyy_temp(Fr(:,2),Fr(:,end),'.',Fr(:,end-1),'x');

mmplotyy_temp([Fr(:,2)],[F_orig(:,end),FN(:,end)],'.',[F_orig(:,end-1),FN(:,end-1)],'rx');
set(gca,'LineWidth',1);
mmplotyy('R5');
ylabel('R6');
xlabel('temperature (ºC)')
mmplotyy('shrink');
suptitle(brw_name{n_inst})
legend(gca,{'R6','R6 new','R5','R5 new'},'Location','NorthEast','HandleVisibility','Off');
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
datetick('keeplimits');
% subplot(2,2,1)
% plot(Fr(:,1),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
% ylabel(' ratio to mean (%) SL counts/seconds');xlabel('Time');
% legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','South','Orientation','Horizontal');

subplot(2,2,2)
plot(Fr(:,1),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
ylabel(' %ratio to mean SL ratios');xlabel('Time'); grid;
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');
datetick('keeplimits');
subplot(2,2,4)
plot(Fr(:,2),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
ylabel(' %ratio to mean SL ratios');xlabel('Temperature'); grid;
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');



%%
f=figure;
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})
line={};


ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/20);
c=hot(ceil(ndays/nrep)+5);
for ii=0:5
    subplot(3,2,ii+1)
    if ii==5       ii=ii+1;  end
    
    plot(F_orig(:,2),F_orig(:,3+ii),'x','MarkerSize',1);
    try
     [h,line{ii+1},s]=report_robust_line;
    catch
      line{ii+1}=[NaN,NaN];
    end
    hold on
    %[h]=gscatter(Fr(:,2),Fr(:,3+ii),fix(Fr(:,1)/nrep)*nrep,c,[],10);
    [h]=gscatter(F_orig(:,2),F_orig(:,3+ii),{year(fix(F_orig(:,1)/nrep)*nrep),diaj(fix(F_orig(:,1)/nrep)*nrep)},c,[],10);
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
line={};

ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/20);
c=bone(ceil(ndays/nrep)+5);

for ii=0:5
 subplot(3,2,ii+1)
 if ii==5 
     ii=ii+1;
 end
 plot(FNm(:,2),FNm(:,3+ii),'x','MarkerSize',3);
 [hl,line{ii+1},s]=report_robust_line;
 hold on
 
 [h]=gscatter(FN(:,2),FN(:,3+ii),{year(fix(F_orig(:,1)/nrep)*nrep),diaj(fix(F_orig(:,1)/nrep)*nrep)},c,[],10);
  
% Si queremos la legenda en todos los subplots
% lg=legend('show');
% set(lg,'Location','NorthEast','HandleVisibility','off');

% Si solo queremos la legenda en uno de los 6 subplots
 legend('hide');
%  if ii==2
%  lg=legend('show');
%  set(lg,'Location','NorthEast','HandleVisibility','off');
%  end
 set(gca,'LineWidth',1);
  if ii==6
     pos_y=get(gca,'Ylim');      pos_x=get(gca,'Xlim')
     h=text( min(pos_x)+2, max(pos_y),'MS9 '); set(h,'BackgroundColor','w');       
     xlabel('PMT Temperature (ºC)');
  else
     pos_y=get(gca,'Ylim');      pos_x=get(gca,'Xlim');
     h=text( min(pos_x)+2,min(pos_y)+30,sprintf('slit#%d slp: %f cts/sc/ºC',(ii+2),(line{ii+1}(2))));
     set(h,'BackgroundColor','w');
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