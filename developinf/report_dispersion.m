function [tabla_dsp,dsp_quad,dsp_cubic]=report_dispersion(Cal,varargin)

% function [tabla_dsp]=report_dispersion(Cal,varargin)
%
% Analisis de los dsp's (funcion read_dsp). Promedios por eventos
%
% INPUT
% - Cal        : variable de definiciones (setup)
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
% Si no hemos asignado una valor a ninguno de los parámetros anteriores, entonces no se promedia por eventos,
% sino que se analizan todos los dsp's en date_range.
% 
% - fpath      : (String). Path a los ficheros dsp. Por defecto, Cal.path_root\DSP 
% 
% - date_range  : (Float). PERIODO de analisis. Por defecto, Cal.Date.CALC_DAYS 
%                 (notar que date_range, al contrario de lo usual, se trata de un periodo, no de sus  extremos)
% 
%
% OUTPUT
% - tabla_dsp: Estructura con los siguientes campos:
%
%              1) data    : matriz con el resultado de la estadistica, ordenados
%                           segun labels en tabla_dsp.data_lbl
%              2) events  : cellstr con etiquetas para cada evento registrado
%              3) data_lbl: cellstr con etiquetas para cada campo en tabla_dsp.data
%
%                           'CSN','wl_0','wl_2','wl_3','wl_4','wl_5','wl_6',
%                           'fwhm_0','fwhm_2','fwhm_3','fwhm_4','fwhm_5','fwhm_6',
%                           'A1 quad.','std','A1 cubic','std','N'
%
%                           Los campos wl_# y fwhm_# se refieren a las diffs. quad-cubic
% EXAMPLE:
%  Predefined Events : 
%        tabla_dsp=report_dispersion(Cal,'grp','month+events');
% 
%  Custom Events     : 
%        events=struct('dates',datenum(2014,1,[1 200]),'labels',{{'uno','dos'}}); 
%        tabla_dsp=report_dispersion(Cal,'grp_custom',events);

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_dispersion';

arg.addRequired('Cal', @isstruct);

arg.addParamValue('grp', '', @(x)any(strcmpi(x,{'events','month','week','month+events'})));
arg.addParamValue('grp_custom', [], @isstruct);    
arg.addParamValue('fpath', fullfile(Cal.path_root,'DSP'), @ischar);    
arg.addParamValue('date_range', Cal.Date.CALC_DAYS, @isfloat);    

arg.parse(Cal, varargin{:});

%%
O3W=[0.00 0.00 -1.00 0.50 2.20 -1.70];% ozone weighting factors

[dsp_quad dsp_cubic]=read_dsp(arg.Results.fpath,'brwid',Cal.brw_str{Cal.n_inst},...
            'configs',Cal.brw_config_files,'date_range',arg.Results.date_range([1 end]));

aux=NaN*ones(size(dsp_quad,1),16);
aux(:,[1 2])=cat(2,dsp_quad(:,1),matadd(dsp_quad(:,17),-dsp_quad(:,16)));
aux(:,3:14)=matadd(dsp_quad(:,4:15),-dsp_cubic(:,4:15));
aux(:,15:16)=cat(1,-O3W*abs(dsp_quad(:,18:23))',-O3W*abs(dsp_cubic(:,18:23))')';

%% Table, por periodos
 lbl_dsp={'CSN','wl_0','wl_2','wl_3','wl_4','wl_5','wl_6',...
                'fwhm_0','fwhm_2','fwhm_3','fwhm_4','fwhm_5','fwhm_6',...
                'A1 quad.','std','A1 cubic','std','N'};
 if isempty(arg.Results.grp)
    if ~isempty(arg.Results.grp_custom)
       event_info=arg.Results.grp_custom;
    else
       event_info=struct('dates',arg.Results.date_range,'labels',{cellstr(datestr(fix(arg.Results.date_range)))}); 
    end
 else
    event_info=getevents(Cal,'grp',arg.Results.grp,'period',arg.Results.date_range);      
 end
 if isempty(event_info)
    fprintf('\rDebes definir una variable de eventos valida (help report_dispersion)\n');
    tabla_dsp=NaN;
    return
 end
 
 if isempty(arg.Results.grp) && isempty(arg.Results.grp_custom)
    fprintf('\rProcessing all available dsp''s (not averaging)\n');

    idx=findm(event_info.dates,aux(:,1),.5);
    tabla_dsp.data=cat(2,aux(:,1:15),NaN*ones(length(idx),1),...
                         aux(:,16)  ,NaN*ones(length(idx),1),ones(length(idx),1));
    tabla_dsp.events=event_info.labels(idx);   tabla_dsp.data_lbl=lbl_dsp;
 else
    data_tab=meanperiods(aux, event_info);
    tabla_dsp.data=cat(2,data_tab.m(:,1:14),data_tab.m(:,15),data_tab.std(:,15),...
                         data_tab.m(:,16),data_tab.std(:,16),data_tab.N(:,end));
    tabla_dsp.events=data_tab.evnts;  tabla_dsp.data_lbl=lbl_dsp;
 end 

