function tabla_fi=report_filter(Cal,varargin)

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
% - fpath      : (String). Path al fichero FIOAVG. Por defecto, Cal.path_root
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
%            tabla_fi=report_filter(Cal,'grp','month+events'); 

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
filter{Cal.n_inst}={}; 
[ETC_FILTER_CORRECTION,media_fi,fi,fi_avg]=filter_rep(Cal.brw_str{Cal.n_inst},'path_to_file',Cal.path_root,...
                        'outlier_flag',0,'plot_flag',0,'config',config_orig(17:22),...
                        'date_range',arg.Results.date_range([1 end]));
filter{Cal.n_inst}.ETC_FILTER_CORRECTION=ETC_FILTER_CORRECTION;
filter{Cal.n_inst}.media_fi=media_fi;  filter{Cal.n_inst}.fi=fi; filter{Cal.n_inst}.fi_avg=fi_avg;

o3f=filters_data(filter,Cal);

%% Table, por periodos 
lbl_fi={'FW#21 corr','std','FW#22 corr','std','FW#23 corr','std',...
         'FW#24 corr','std','FW#25 corr','std','N'};

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

tabla_fi.data=aux; tabla_fi.events=data_tab.evnts; tabla_fi.data_lbl=lbl_fi;

