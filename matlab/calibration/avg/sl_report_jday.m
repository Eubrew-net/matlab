function [sl_mov,sl_median,oulier,R6]=sl_report_jday(idx_inst,sl,brw_name,varargin)

% sl_mov         -> 7 days slavg_prevplot interpolated (to fill in gaps) running mean
% sl_median      -> (median,std) daily values: 'time','R6','R5','T','F1','F5' 
% outlier        -> 2.5 sigma oulier summaries
% R6             -> summaries, outlier removed -> NaN [date R6 Temp]
% 
% Juanjo 10/05/2010: Modificado el control de inputs. Ahora se hace uso de la clase inputParser 
%                   (siguen siendo los mismos)
%                    Valores por defecto: date_range=[], no control de fechas
%                    fplot=0, no ploteo
%                    Se muestran al final del script los parametros que han tomado un valor por defecto
%
% Juanjo 09/02/2011: Se añade nuevo input opcional: diaj_flag (por defecto 1)
%                    Valores posibles:
%                    1-> se trabaja con dia juliano
%                    0-> se trabaja con fecha matlab
% Alberto 04/08/2011:
%                    comentando la salida de valores por defecto para limpiar los report html
%                    TODO: redirigir esta salida a una variable log
% 
% Juanjo 14/09/2011: Se añade condicional del tipo if isempty() return 
%                    para salir en caso de no data

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'sl_report_jday';

% input obligatorio
arg.addRequired('idx_inst');
arg.addRequired('sl');
arg.addRequired('brw_name');

% input param - value
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('fplot',0, @isfloat); % por defecto, no plot
arg.addParamValue('hgflag',1, @isfloat); % por defecto, depurando
arg.addParamValue('diaj_flag',1, @(x)(x==0 || x==1)); % por defecto, dia juliano
arg.addParamValue('events_raw','', @iscell); % por defecto, no events

% validamos los argumentos definidos:
try
arg.parse(idx_inst,sl,brw_name, varargin{:});
mmv2struct(arg.Results);
chk=1;

catch
  errval=lasterror;
  if length(varargin)==2
      date_range=varargin{1};
      fplot=varargin{2};
  elseif length(varargin)==1
      date_range=varargin{1};
      fplot=0;
  else
      date_range=varargin{1};
      fplot=0; % por defecto valores nominales
  end
  chk=0;
end

% leemos las medidas individuales 
sls=cell2mat(sl{idx_inst});
% para corregir defecto puntual en #191
if ~isempty(cell2mat(sl{idx_inst}))
    sls=cell2mat(sl{idx_inst});
else
    sl_mov=NaN*ones(1,11); sl_median=NaN*ones(1,11); oulier=NaN; R6=NaN*ones(1,3);
    fprintf('Brewer#%s: No SL data \n',brw_name{idx_inst});
    return
end
sls(:,13)=abs(sls(:,13));

if ~isempty(date_range)
   sls(sls(:,1)<date_range(1),:)=[];
   if length(date_range)>1
      sls(sls(:,1)>date_range(2),:)=[];
   end
end

% remove 2.5 sigma outlier
if outlier_flag==1
  [ax,bx,cx,dx]=outliers_bp(sls(:,22),2.5);
else 
   dx=[];
end
oulier{1,1}=datestr(sls(dx,1));  oulier{1,2}=sls(dx,:);
sls(dx,[22,21,13,23,24])=NaN;

%jok hg before and after
if hgflag
  jok=find(sls(:,2)==1); jok_no=find(sls(:,2)==0);
  if isempty(jok)
    disp('Warning no SL ok');
    jok=ones(size(sls(:,2)));    jok=find(jok==1);
  end
else
    jok=ones(size(sls(:,2)));    jok=find(jok==1);     jok_no=[];
end
sls_outhg=sls(jok_no,:);
sls=sls(jok,:); R6=sls(:,[1,22,13]);


%   jok(dx)=0;
%   jok=logical(jok);  % cambios motivados por el 064?


% summaries (recalculados, depende de la entrada con 1 o 2 config)
cname={'R6','R5','T','F1','F5'}; 
ncols=[22,21,13,23,24];

try
    [m,s]=grpstats(sls(:,[1,ncols]),fix(sls(:,1)),{@median,'std'});
catch

    [m,s]=grpstats(sls(:,[1,ncols]),fix(sls(:,1)),{'mean','std'});
    
    for i=1:5
        med=grpstats(sls(:,ncols(i)),fix(sls(:,1)),{@nanmedian});
        m(:,i+1)=med;
    end
end
sl_median=orgavg([m,s]); %time and (median,std ) of 'R6','R5','T','F1','F5';
sl_median(:,2)=[]; sl_median=sortrows(sl_median,1);

% sl_mov contiene los valores suavizados (media móvil de 7 días). Entonces,
% ¿por que el if?. Aunque tengamos menos de 5 días podemos seguir
% calculando valores suavizados. Por eso he comentado (si no, cuando size(sl_median,1)<5 entonces no tendríamos una media
% móvil, sino que seguiriamos teniando las medias diarias, sl_median. Además, con sl_mov(:,1)=sl_mov(:,1)+.5; los dos ploteos, 
% aunque idénticos, salen desfasados en medio día)
% Los valores suavizados se calculan, por ejemplo para una ventana de 5,
% según
% 
% yy(1) = y(1)
% yy(2) = (y(1) + y(2) + y(3))/3
% yy(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5
% yy(4) = (y(2) + y(3) + y(4) + y(5) + y(6))/5
% ...
% 
% o sea, a partir de una vecindad del punto considerado. Entonces, ¿por qué
% N_dat=15 por defecto? Si interesa una media móvil a 7 días, creo que
% sería mejor N_dat=7 (tres pa`lante y trs pa´trás)

 if size(sl_median,1)>5 
  sl_mov=interp_sm(sl_median,7);
 else
   sl_mov=sl_median;
 end
% sl_mov(:,1)=sl_mov(:,1)+.5;% ??????? Esto da problemas. Por ejemplo con el 064 CALC_DAYS es 203:209, 
                       % y con esto sale 203:210 

%% PLOT
   if fplot
%   to check hg flag
    figure; plot(R6(:,1),R6(:,2),'*'); 
    if ~isempty(jok_no)
        hold on; ploty(sls_outhg(:,[1 22]),'r*'); 
        title('R6 with bad hg''s'); ylabel('R6'); 
    else
        title('NO bad hg''s'); ylabel('R6'); 
    end
    datetick('x',30,'keeplimits','keepticks'); rotateticklabel(gca,20); grid;

    cname={'R6','F1','F5','T'};
    ncols=[22,23,24,13];
    slaux=sortrows(sl_mov,1);    sls=sortrows(sls,1);
    sl_medianplot=sl_median;
    if diaj_flag
       sl_medianplot(:,1)=diaj(sl_medianplot(:,1))+.5;% sumando .5 aqui colocamos los puntos en 205.5
       sls(:,1)=diaj2(sls(:,1))+.5;       
       slaux(:,1)=diaj(slaux(:,1))+.5;       
    end
    
    figure;
    for i=1:4
        subplot(2,2,i)
        boxplot(sls(:,ncols(i)),fix(sls(:,1))); % summaries
        title([cname{i},' ',brw_name{idx_inst}]);
    end
        
    f=figure;
    set(f,'tag','SL_R6_report');
    p1=errorbard(sl_medianplot(:,1:3),'s');% daily time and (median,std) of 'R6'
    set(p1,'MarkerEdgeColor','k','color','g');
    hold on
    p2=plot(slaux(:,1)+.5,slaux(:,2),'o-','LineWidth',1); % (daily R6) smooth 7 (interpolated to fill in gaps)
    p3=plot(sls(:,1),sls(:,22),'.','Markersize',8); % R6 summaries
    legend([p1(1),p2,p3],'R6 daily median ','R6 smooth 7','R6 summaries','Location','Best');
    title(['Standard Lamp R6   ',brw_name{idx_inst}]);
    if ~diaj_flag
        if ~isempty(events_raw)
           dates=cell2mat(events_raw(:,2)); indx=dates>=sl_median(1,1) & dates<=sl_median(end,1); 
           if any(indx)
              h=vline_v(dates(indx),'-k',events_raw(indx,3)); set(h,'LineWidth',2);
           end
        end
        datetick('x','mm/dd/yy','keeplimits','keepticks');
    else
        if ~isempty(events_raw)
           dates=cell2mat(events_raw(:,2)); indx=dates>=sl_median(1,1) & dates<=sl_median(end,1); 
           if any(indx)
              h=vline_v(diaj(dates(indx)),'-k',events_raw(indx,3)); set(h,'LineWidth',2);
           end                           
        end
    end
    grid;    xlabel('Date');   ylabel('SL R6  ratios');
    set(gca,'LineWidth',1);%,'XTick',diaj(sl_medianplot(:,1))%,'XTickLabel',diaj(sl_medianplot(:,1))
   
    f=figure;
    set(f,'tag','SL_R5_report');
    p1=errorbard(sl_medianplot(:,[1,4,5]),'s');
    set(p1,'MarkerEdgeColor','k','color','g');
    hold on
    p2=plot(slaux(:,1)+.5,slaux(:,4),'o-','LineWidth',1);
    p3=plot(sls(:,1),sls(:,21),'.','Markersize',8);
    legend([p1(1),p2,p3],'R5 daily median ','R5 smooth 7','R5 summaries','Location','Best');
    title(['Standard Lamp R5   ',brw_name{idx_inst}]);
    if ~diaj_flag
    datetick('x','mm/dd/yy','keeplimits','keepticks');  
    end
    xlabel('Date'); ylabel('SL R5  ratios'); grid;
    set(gca,'LineWidth',1);% ,'XTick',diaj(sl_medianplot(:,1)))%,'XTickLabel',diaj(sl_medianplot(:,1))

    % INT
    f=figure;
    set(f,'tag','SL_I5_report');
    p1=errorbard(sl_medianplot(:,[1,8:9]),'s');
    set(p1,'MarkerEdgeColor','k','color','g');
    hold on
    p2=plot(slaux(:,1)+.5,slaux(:,8),'o-','LineWidth',1);
    p3=plot(sls(:,1),sls(:,23),'.','Markersize',8);
    %legend([p1(1),p2,p3],'I_5 smooth 7','I_5 daily mean ','I_5 meas');
    legend([p1(1),p2,p3],'I_5 daily median ','I_5 smooth 7','I_5 summaries','Location','Best');
    title(['Standard Lamp I_5   ',brw_name{idx_inst}]);
    if ~diaj_flag
    datetick('x','mm/dd/yy','keeplimits','keepticks');  
    end
    grid;    xlabel('Date');    ylabel('SL I_5  ratios');
    set(gca,'LineWidth',1); % ,'XTick',diaj(sl_medianplot(:,1)))%,'XTickLabel',diaj(sl_medianplot(:,1))

    % Temperature
    f=figure;    set(f,'tag','SL_TEMP_report');
    plot(sls(:,13),sls(:,22),'.'); hold on; 
    rl=rline; set(rl,'LineWidth',2);
    set(findobj(gca,'Type','Text'),'BackgroundColor','w','Color','r','FontSize',10,'FontWeight','Bold');
    set(findobj(gca,'Marker','.'),'Marker','None');
    gscatter(sls(:,13),sls(:,22),5*fix(diaj(sls(:,1))/5));
    title(['Standard Lamp R6 vs temperature   ',brw_name{idx_inst}]);   grid;
    xlabel('PMT Temperature (C\circ)'); ylabel('SL R6 ratios');
   end

% if chk
%     % Se muestran los argumentos que toman los valores por defecto
%   disp('--------- Validation OK --------------') 
%   disp('List of arguments given default values:') 
%   if ~numel(arg.UsingDefaults)==0
%      for k=1:numel(arg.UsingDefaults)
%         field = char(arg.UsingDefaults(k));
%         value = arg.Results.(field);
%         if isempty(value),   value = '[]';   
%         elseif isfloat(value), value = num2str(value); end
%         disp(sprintf('   ''%s''    defaults to %s', field, value))
%      end
%   else
%      disp('               None                   ')
%   end
%   disp('--------------------------------------') 
% else
%      disp('NO INPUT VALIDATION!!')
%      disp(sprintf('%s',errval.message))
% end

%function rdata=orgavg(data)
% reorganiza las matrices (media_1,media_2,media_3..media_n, ...
% sigma_1,sigma_2,sigma_3....sigma_n.) a
% media1, sigma1 , media2 sigma2
function rdata=orgavg(data)
idx=1:size(data,2)/2;
idx=sort([idx,idx]);
idx(2:2:end)=idx(2:2:end)+size(data,2)/2;
rdata=data(:,idx);


% function data=interp_smooth(data_avg)
% funcion que interpola la serie previamente suavizada
% utilizada para rellenar huecos los valores de standard lamp.
function data=interp_sm(data_avg,N_dat)
if nargin==1
   N_dat=15; %suavizado
end
%if nargin==1
   x0=min(fix(data_avg(:,1)));
   x1=max(fix(data_avg(:,1)));
   x=x0:x1;


   %la interpolacion no permite nan
   % el suavizado si ï¿½?
   j=find(isnan(data_avg(:,1)));
   if ~isempty(j)
     data_avg(j,:)=[];
   % rellenamos con  la mediana
     for ii=2:size(data_avg,2)
     data_avg(isnan(data_avg(:,ii)),ii)=nanmedian(data_avg(:,ii));
     end
   end

  %suavizado
  aux=repmat(data_avg(:,1),1,size(data_avg(:,2:end),2));
  for i=1:size(data_avg,2)-1;
  data_avg(:,i+1)=smooth(data_avg(:,1),data_avg(:,i+1),N_dat,'rlowess');
  end
  data=data_avg;
%     data=interp1(data_avg(:,1),data_avg(:,2:end),x,'pchip');
%     data=[x',data];