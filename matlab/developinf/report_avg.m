function [tabla_avg sl_data,dt_data,rs_data,ap_data]=report_avg(Cal,varargin)

% function tabla_avg=report_avg(Cal,varargin)
% 
% Analisis de los ficheros AVG a partir de la funcion brw_avg_report
% Promedios por eventos
% 
% INPUT
% - Cal         : variable de definiciones (setup)
% 
% Opcional
% - grp         : (String). Por defecto promedios mensuales
%                  Valores implementados: 'events','month','week','month+events' (see getevents function)
% 
% - grp_custom  : (Struct). Eventos personalizados 
%                  Estructura con los campos siguientes (see getevents function)
%                  1) dates  : Fechas asociadas a los eventos definidos
%                  2) labels : Etiquetas asociadas a los eventos definidos
% 
% - outlier_flag: (Cellstring con flags de depuracion). Por defecto no depuracion
%                  7 elementos posibles: sl, dt, rs, ap, hg, h2o, op
% 
% - fpath      : (String). Path a la raiz de los bdata. Por defecto, Cal.path_root
% 
% - date_range  : (Float). PERIODO de analisis. Por defecto, Cal.Date.CALC_DAYS 
%                 (notar que date_range, al contrario de lo usual, se trata de un periodo, no de sus  extremos)
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
%  Eventos predefinidos  : 
%                  report_avg(Cal,'grp','events','outlier_flag',{'','dt','','','','',''});
% 
%  Eventos personalizados: 
%                  events=struct('dates',datenum(2014,1,[1 200]),'labels',{{'Bef.  ND change','After. ND change'}}); 
%                  report_avg(Cal,'grp_custom',events,'outlier_flag',{'','dt','','','','',''});
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_avg';

arg.addRequired('Cal', @isstruct);

arg.addParamValue('grp', '', @(x)any(strcmpi(x,{'events','month','week','month+events'})));
arg.addParamValue('grp_custom', [], @isstruct);    
arg.addParamValue('outlier_flag', {'','','','','','',''}, @iscell);
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
 if isempty(arg.Results.grp)
    event_info=arg.Results.grp_custom;
 else
    event_info=getevents(Cal,'grp',arg.Results.grp,'period',arg.Results.date_range);      
 end
 if isempty(event_info)
    fprintf('\rDebes definir una variable de eventos valida (help report_avg)\n');
    tabla_avg=NaN; sl_data=NaN; dt_data=NaN; rs_data=NaN; ap_data=NaN;
    return
 end
 data_tab=meanperiods(aux, event_info);
 
 aux=NaN*ones(size(data_tab.m,1),33);
 aux(:,[1 2 4 7 9 12:2:16 19:2:31])=data_tab.m(:,[1:5 13:15 6:12]);
 aux(:,[3 5 8 10 13:2:17 20:2:32])=data_tab.std(:,[2:5 13:end 6:12]);
 aux(:,[6 11 18 33])=data_tab.N(:,[2 4 15 12]);
 
 tabla_avg.data=aux; tabla_avg.events=data_tab.evnts; tabla_avg.data_lbl=lbl_avg;
  