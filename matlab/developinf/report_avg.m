function [tabla_avg sl_data,dt_data,rs_data,ap_data]=report_avg(Cal,varargin)

% function tabla_avg=a1(Cal,varargin)
% 
% Analisis de los ficheros AVG a partir de la funcion brw_avg_report
% Promedios por eventos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - grp   : Opcional (string). Por defecto promedios mensuales
%           Valores implementados: 'events','month','week','month+events' (see getevents function)
% - outlier_flag: Opcional (cellstring con flags de depuracion). Por defecto no depuracion
%                 7 elementos posibles: sl, dt, rs, ap, hg, h2o, op
% 
% OUTPUT
% - tabla_avg: Estructura con los siguientes campos:
%              
%              1) data    : matriz con el resultado de la estadistica, ordenados 
%                           segun labels en tabla_avg.data_lbl
%              2) events  : cellstr con etiquetas para cada evento registrado
%              3) data_lbl: cellstr con etiquetas para cada campo en tabla_avg.data
%              
%                           'R6','std','R5','std','N','DT high','std','DT low','std','N',
%                           'HT','std','+5V','std','SL current','std','N',
%                           'RS0','std','RS1','std','RS2','std','RS3','std','RS4','std','RS5','std','RS6','std','N'
% 
% EXAMPLE:
%          tabla_avg=a1(Cal,'grp','events','outlier_flag',{'','dt','','','','',''});
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_avg';

arg.addRequired('Cal', @isstruct);
arg.addParamValue('grp', 'month', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); % por defecto
arg.addParamValue('outlier_flag', {'','','','','','',''}, @iscell); % por defecto no depuracion
arg.addParamValue('fpath', Cal.path_root, @ischar);    
arg.addParamValue('date_range', Cal.Date.CALC_DAYS, @isfloat);    

arg.parse(Cal, varargin{:});

%%
[sl_data,dt_data,rs_data,ap_data]=brw_avg_report(Cal.brw_str{Cal.n_inst},Cal.brw_config_files(Cal.n_inst,:),...
                      'path_to_file',arg.Results.fpath,...    
                      'date_range',arg.Results.date_range([1 end]),...
                      'SL_REF',[NaN,NaN],'DT_REF',[NaN,NaN],...
                      'outlier_flag',arg.Results.outlier_flag);

aux=scan_join(scan_join(scan_join(scan_join(Cal.Date.CALC_DAYS',sl_data(:,[1 12 11])),...
                                                                  dt_data(:,[1 4 5])),...
                                                                 rs_data(:,[1 4:10])),...
                                                                  ap_data(:,[1 4:6]));

%% Tabla por eventos 
 lbl_avg={'R6','std','R5','std','N','DT high','std','DT low','std','N','HT','std','+5V','std','SL current','std','N',...
          'RS0','std','RS1','std','RS2','std','RS3','std','RS4','std','RS5','std','RS6','std','N'}; 
 event_info=getevents(Cal,'grp',arg.Results.grp,'period',arg.Results.date_range); data_tab=meanperiods(aux, event_info);
 aux=NaN*ones(size(data_tab.m,1),33);
 aux(:,[1 2 4 7 9 12:2:16 19:2:31])=data_tab.m(:,[1:5 13:15 6:12]);
 aux(:,[3 5 8 10 13:2:17 20:2:32])=data_tab.std(:,[2:5 13:end 6:12]);
 aux(:,[6 11 18 33])=data_tab.N(:,[2 4 15 12]);
 
 tabla_avg.data=aux; tabla_avg.events=data_tab.evnts; tabla_avg.data_lbl=lbl_avg;
  