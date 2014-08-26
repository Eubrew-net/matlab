function [tabla_tc sl_rw]=report_temperature(Cal,icf,varargin)

% function tabla_tc=report_temperature(Cal,icf,varargin)
%  
% Analisis de la dependencia con la temperatura a partir de SL individual 
% (funcion temp_coef_raw). Promedios por eventos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - icf   : Configuraciones a emplear. Por ahora unicamente esta permitida
%           una matriz de configuraciones
% 
% Opcionales
% - grp        : (String). Por defecto promedios mensuales
%                 Valores implementados: 'events','month','week','month+events' (see getevents function)
% 
% - grp_custom  : (Struct). Eventos personalizados 
%                  Estructura con los campos siguientes (see getevents function)
%                  1) dates  : Fechas asociadas a los eventos definidos
%                  2) labels : Etiquetas asociadas a los eventos definidos
% 
% - fpath      : (String). Path a la raiz de los bdata. Por defecto, Cal.path_root
% 
% - date_range  : (Float). PERIODO de analisis. Por defecto, Cal.Date.CALC_DAYS 
%                 (notar que date_range, al contrario de lo usual, se trata de un periodo, no de sus  extremos)
% 
% OUTPUT
% - tabla_tc: Estructura con los siguientes campos:
%              
%              1) data    : matriz con el resultado de la estadistica, ordenados 
%                           segun labels en tabla_tc.data_lbl
%              2) events  : cellstr con etiquetas para cada evento registrado
%              3) data_lbl: cellstr con etiquetas para cada campo en tabla_tc.data
%               
%                          'MaxT','MinT','ORIG R6','std','ORIG slope','std',
%                          'NEW R6','std','NEW slope','std'
%                          'coeff#1','coeff#2','coeff#3','coeff#4','coeff#5'
% 
% EXAMPLE:
% 
%        tabla_tc=report_temperature(Cal,Cal.brw_config_files{Cal.n_inst,2},'grp','month+events');
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_temperature';

arg.addRequired('Cal', @isstruct);
arg.addRequired('icf', @(x)isfloat(x) || ischar(x));

arg.addParamValue('grp', '', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); 
arg.addParamValue('grp_custom', [], @isstruct);    
arg.addParamValue('fpath', Cal.path_root, @ischar);    
arg.addParamValue('date_range', Cal.Date.CALC_DAYS, @isfloat);    

arg.parse(Cal, icf, varargin{:});

%% Todos los datos en date_range
config_temp.n_inst=Cal.n_inst;  config_temp.brw_name=Cal.brw_name{Cal.n_inst};        
% if ~exist('sl_rw.mat','file')
   sl_rw=readb_sl_rawl(fullfile(arg.Results.fpath,['bdata',Cal.brw_str{Cal.n_inst}],['B*.',Cal.brw_str{Cal.n_inst}]),...
                                                   'date_range',arg.Results.date_range([1 end]),'f_plot',1);
%     save('sl_rw.mat','sl_rw');
% else
%      load('sl_rw.mat');
% end

%% Determinamos los periodos de analisis + configs a aplicar
% periodos
 if isempty(arg.Results.grp)
    event_info=arg.Results.grp_custom;
 else
    event_info=getevents(Cal,'grp',arg.Results.grp,'period',arg.Results.date_range);      
 end
 if isempty(event_info)
    fprintf('\rDebes definir una variable de eventos valida (help report_avg)\n');
    tabla_tc=NaN;
    return
 end

% configuraciones (necesitamos tantas como eventos)
icf_=getcfgs(arg.Results.date_range,icf,'events',event_info.dates);    
                                        
%% Table, por periodos 
tabl_TC=[]; tabl_TC_std=[]; NTC={}; ajuste={}; 
y=group_time(arg.Results.date_range',event_info.dates); id_period=unique(y);
if any(id_period==0)
   fprintf('\rRemoving data before 1st event as input.\n');
   date_range=arg.Results.date_range(y~=0); y(y==0)=[]; id_period(id_period==0)=[]; 
else
   date_range=arg.Results.date_range; 
end
for pp=1:length(id_period)        
    %%
    try       
     periods_=date_range(y==id_period(pp));
     [NTC{pp},ajuste{pp},Args,Fraw,Fnew]=temp_coeff_raw(config_temp,sl_rw,'outlier_flag',1,...
                                         'date_range',periods_([1,end]),'plots',0); 
     [NTCx,ajustex,Argsx,Fraw,Forig]    =temp_coeff_raw(config_temp,sl_rw,'outlier_flag',1,'N_TC',icf_.data(2:6,pp)',...
                                         'date_range',periods_([1,end]),'plots',0); Forig(isnan(Forig(:,1)),:)=[];
                                                          
     tabl_TC=[tabl_TC; cat(2,nanmean(Forig(:,1)),min(Forig(:,2)),max(Forig(:,2)),ajuste{pp}.orig(7,1),ajuste{pp}.orig(7,2),ajuste{pp}.new(7,1),ajuste{pp}.new(7,2),...
                           -matadd(ajuste{pp}.cero(1:5,2),-ajuste{pp}.cero(1,2))')];
     tabl_TC_std=[tabl_TC_std; cat(2,nanmean(Forig(:,1)),ajuste{pp}.orig(7,3),ajuste{pp}.orig(7,4),ajuste{pp}.new(7,3),ajuste{pp}.new(7,4),...
                        sqrt(ajuste{pp}.cero(1:5,end).^2+ajuste{pp}.cero(1,end)^2)')];   
                    
     figure;  set(gcf,'Tag',sprintf('TEMP_COMP_%s',Cal.brw_str{Cal.n_inst}));
     ha=tight_subplot(2,1,.08,.1,.075); hold all;
     axes(ha(1)); set(gca,'box','on','XTickLabelMode','auto','YTickLabelMode','auto'); grid; hold on;
     axes(ha(2)); set(gca,'box','on','XTickLabelMode','auto','YTickLabelMode','auto'); grid; hold on;
      
     axes(ha(1));
     plot(Forig(:,1),Forig(:,end),'Color','g','Marker','s'); 
     ax1 = gca;      grid on; 
     title(sprintf('R6 Temperature dependence Brewer#: %s. Operative temperature coeffs.\n%s to %s',...
            Cal.brw_str{Cal.n_inst},datestr(Forig(1,1),2),datestr(Forig(end,1),2))); 
     datetick('x',6,'KeepTicks','KeepLimits'); pos=get(ax1,'Position');
     ax2 = axes; plot(Forig(:,1),Forig(:,2),'b.','MarkerSize',6); ylabel('Temperature','Color','b');
     lg=legend(ax1,'Operative temperature coeffs.'); 
     set(lg,'HandleVisibility','Off');  set(findobj(lg,'Type','text'),'FontSize',8,'HandleVisibility','Off');    
     set(ax2,'Color','none','YAxisLocation','right','XTicklabel',{' '},'TickLength',[0 0],'Position',pos); 

     axes(ha(2));    
     plot(Forig(:,2),Forig(:,end),'Color','g','Marker','s','LineStyle','None'); grid on; 
     yl=ylabel('Standard Lamp R6 ratio (summaries)','Units','Normalized'); xlabel('Temperature'); 
     [g h]=rline; set(g,'LineWidth',2,'Color','r','Marker','None'); set(findobj(gcf,'Type','Text'),'Visible','Off');
     lg=legend(g,sprintf('%d \\pm %.2f \\times T',round(h(2)),round(h(1)*10)/10));
     pos_yl=get(yl,'Position'); set(yl,'Position',[pos_yl(1) pos_yl(2)+0.6 pos_yl(3)]);
     
     catch exception
       tabl_TC=[tabl_TC; cat(2, mean(periods_), NaN*ones(1,11))];
       tabl_TC_std=[tabl_TC_std; cat(2, mean(periods_), NaN*ones(1,9))];
    end
    snapnow
end
aux=NaN*ones(size(tabl_TC,1),16);
aux(:,[1:4 6 8 10 12:end])=tabl_TC(:,[1:7 8:end]);
aux(:,5:2:11)=tabl_TC_std(:,4:7);

lbl_TC={'MaxT','MinT','ORIG R6','std','ORIG slope','std','NEW R6','std','NEW slope','std',...
         'coeff#1','coeff#2','coeff#3','coeff#4','coeff#5'};

data_tab=meanperiods(aux,event_info);
tabla_tc.data=aux; tabla_tc.events=data_tab.evnts; tabla_tc.data_lbl=lbl_TC;
     