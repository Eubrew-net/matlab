function [tabla_fi, filter]=report_filter(Cal,varargin)
% function tabla_fi=report_filter(Cal,varargin)
% 
% Analisis de los filtros de atenuacion (FIOAVG). Promedios por eventos
% 
% INPUT
% - Cal        : variable de definiciones (setup)
% 
% Opcional
% - grp        : (String). Por defecto promedios mensuales
%                Valores implementados: 'events','month','week','month+events' (see getevents function)
% 
% - grp_custom : (Struct). Eventos personalizados 
%                 Estructura con los campos siguientes (see getevents function)
%                 1) dates  : Fechas asociadas a los eventos definidos
%                 2) labels : Etiquetas asociadas a los eventos definidos
% 
% - fpath      : (String). Path a la raiz de los bdata. Por defecto, Cal.path_root
% 
% - date_range  : (Float). PERIODO de analisis. Por defecto, Cal.Date.CALC_DAYS 
%                 (notar que date_range, al contrario de lo usual, se trata de un periodo, no de sus  extremos)
% 
% OUTPUT
% - tabla_fi: Estructura con los siguientes campos:
%              
%              1) data    : matriz con el resultado de la estadistica, ordenados 
%                           segun labels en tabla_fi.data_lbl
%              2) events  : cellstr con etiquetas para cada evento registrado
%              3) data_lbl: cellstr con etiquetas para cada campo en tabla_fi.data
%              
%                       'ETC corr (FW#21)','std','ETC corr (FW#22)','std','ETC corr (FW#23)','std',
%                       'ETC corr (FW#24)','std','ETC corr (FW#25)','std','N'
% 
% EXAMPLE
%  Eventos predefinidos  : 
%            tabla_fi=report_filter(Cal,'grp','month+events'); 
% 
%  Eventos personalizados: 
%                  events=struct('dates',datenum(2014,1,[1 200]),'labels',{{'Bef.  ND change','After. ND change'}}); 
%                  report_filter(Cal,'grp_custom',events);
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_filter';

arg.addRequired('Cal', @isstruct);
arg.addParamValue('grp', '', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); 
arg.addParamValue('grp_custom', [], @isstruct);    
arg.addParamValue('fpath', Cal.path_root, @ischar);    
arg.addParamValue('date_range', Cal.Date.CALC_DAYS, @isfloat);    

arg.parse(Cal, varargin{:});

%%
config_orig=read_icf(Cal.brw_config_files{Cal.n_inst,1},mean(arg.Results.date_range([1 end])));      
         
%  All data
[ETC_FILTER_CORRECTION,media_fi,fi,fi_avg]=filter_rep(Cal.brw_str{Cal.n_inst},'path_to_file',arg.Results.fpath,...
                        'outlier_flag',0,'plot_flag',0,'config',config_orig(17:22),...
                        'date_range',arg.Results.date_range([1 end]));
                    
filter.ETC_FILTER_CORRECTION=ETC_FILTER_CORRECTION;
filter.media_fi=media_fi; 
filter.fi=fi; filter.fi_avg=fi_avg;
filt{Cal.n_inst}=filter; 
o3f=filters_data(filt,Cal);
filter.o3f=o3f;

%% Table, por periodos 
lbl_fi={'F#1 corr','se','F#2 corr','se','F#3 corr','se',...
         'F#4 corr','se','F#5 corr','se','N'};

 if isempty(arg.Results.grp)
    event_info=arg.Results.grp_custom;
 else
    event_info=getevents(Cal,'grp',arg.Results.grp,'period',arg.Results.date_range);      
 end
 if isempty(event_info)
    fprintf('\rDebes definir una variable de eventos valida (help report_filter)\n');
    tabla_fi=NaN;
    return
 end
 
 
 data_tab=meanperiods(o3f, event_info);

  aux=NaN*ones(size(data_tab.m,1),12);
  aux(:,[1 2:2:10])=data_tab.m(:,[1 3:end]);
  aux(:,3:2:end)=data_tab.std(:,3:end);
  aux(:,end)=data_tab.N(:,end);
  try
      matdiv(data_tab.std(:,3:end),sqrt(data_tab.std(:,3:end)));
  catch
      disp('error std error');
  end
tabla_fi.data=aux;
tabla_fi.events=data_tab.evnts;
tabla_fi.data_lbl=lbl_fi;

