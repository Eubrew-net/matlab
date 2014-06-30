function [tabla_dsp,dsp_quad,dsp_cubic]=b3(Cal,varargin)

% function [tabla_dsp]=b3(Cal,varargin)
% 
% Analisis de los dsp's (funci?n read_dsp). Promedios por eventos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - grp   : Opcional (string). Por defecto promedios mensuales
%           Valores implementados: 'events','month','week','month+events' (see getevents function)
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
%        tabla_dsp=b3(Cal,'grp','month+events');
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='b3';

arg.addRequired('Cal', @isstruct);
arg.addParamValue('grp', 'events', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); % por defecto

arg.parse(Cal, varargin{:});

%%
O3W=[0.00 0.00 -1.00 0.50 2.20 -1.70];

[dsp_quad dsp_cubic]=read_dsp(fullfile(Cal.path_root,'..','DSP'),...
       'brwid',Cal.brw_str{Cal.n_inst},'configs',Cal.brw_config_files,'date_range',Cal.Date.CALC_DAYS([1 end]));

aux=NaN*ones(size(dsp_quad,1),16);
aux(:,[1 2])=cat(2,dsp_quad(:,1),matadd(dsp_quad(:,17),-dsp_quad(:,16)));
aux(:,3:14)=matadd(dsp_quad(:,4:15),-dsp_cubic(:,4:15));
aux(:,15:16)=cat(1,-O3W*abs(dsp_quad(:,18:23))',-O3W*abs(dsp_cubic(:,18:23))')';

%% Table, por periodos
 lbl_dsp={'CSN','wl_0','wl_2','wl_3','wl_4','wl_5','wl_6',...
                'fwhm_0','fwhm_2','fwhm_3','fwhm_4','fwhm_5','fwhm_6',...
                'A1 quad.','std','A1 cubic','std','N'};
 event_info=getevents(Cal,'grp',arg.Results.grp);
 data_tab=meanperiods(aux, event_info);
 
 tabla_dsp.data=cat(2,data_tab.m(:,1:14),data_tab.m(:,15),data_tab.std(:,15),...
                      data_tab.m(:,16),data_tab.std(:,16),data_tab.N(:,end));   
 tabla_dsp.events=data_tab.evnts;  tabla_dsp.data_lbl=lbl_dsp;
             
