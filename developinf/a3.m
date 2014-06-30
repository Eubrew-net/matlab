function tabla_fi=a3(Cal,varargin)

% function tabla_fi=a3(Cal,varargin)
% 
% Analisis de los filtros de atenuacion (FIOAVG). Promedios por eventos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - grp   : Opcional (string). Por defecto promedios mensuales
%           Valores implementados: 'events','month','week','month+events' (see getevents function)
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
%            tabla_fi=a3(Cal,'grp','month+events'); 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='a3';

arg.addRequired('Cal', @isstruct);
arg.addParamValue('grp', 'events', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); % por defecto

arg.parse(Cal, varargin{:});

%%
config_orig=read_icf(Cal.brw_config_files{Cal.n_inst,1},mean(Cal.Date.CALC_DAYS));      
         
%  All data
filter{Cal.n_inst}={}; 
[ETC_FILTER_CORRECTION,media_fi,fi,fi_avg]=filter_rep(Cal.brw_str{Cal.n_inst},'path_to_file',Cal.path_root,...
                        'outlier_flag',0,'plot_flag',0,'config',config_orig(17:22),...
                        'date_range',Cal.Date.CALC_DAYS([1 end]));
filter{Cal.n_inst}.ETC_FILTER_CORRECTION=ETC_FILTER_CORRECTION;
filter{Cal.n_inst}.media_fi=media_fi;  filter{Cal.n_inst}.fi=fi; filter{Cal.n_inst}.fi_avg=fi_avg;

o3f=filters_data(filter,Cal);

%% Table, por periodos 
lbl_fi={'FW#21 corr','std','FW#22 corr','std','FW#23 corr','std',...
         'FW#24 corr','std','FW#25 corr','std','N'};
event_info=getevents(Cal,'grp',arg.Results.grp); data_tab=meanperiods(o3f, event_info);

aux=NaN*ones(size(data_tab.m,1),12);
aux(:,[1 2:2:10])=data_tab.m(:,[1 3:end]);
aux(:,3:2:end)=data_tab.std(:,3:end);
aux(:,end)=data_tab.N(:,end);

tabla_fi.data=aux; tabla_fi.events=data_tab.evnts; tabla_fi.data_lbl=lbl_fi;

