function tabla_sc=b1(Cal,icf,varargin)

% function tabla_sc=b1(Cal,icf,varargin)
% 
% Analisis de los SC's en periodos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - icf   : Configuraciones a emplear. Por ahora unicamente esta permitida
%           una matriz de configuraciones
% - grp   : Opcional (string). Por defecto promedios mensuales
%           Valores implementados: 'events','month','week','month+events' (see getevents function)
% 
% OUTPUT
% - tabla_sc: Estructura con los siguientes campos:
%              
%              1) data    : matriz con el resultado de la estadistica, ordenados 
%                           segun labels en tabla_sc.data_lbl
%              2) events  : cellstr con etiquetas para cada evento registrado
%              3) data_lbl: cellstr con etiquetas para cada campo en tabla_sc.data
%               
%                           'CSN','[CI-]','[CI+]','Op. CSN','N'
% 
% EXAMPLE:
%        tabla_sc=b1(Cal,icf_n{Cal.n_inst},'grp','month+events');
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='b1';

arg.addRequired('Cal', @isstruct);
arg.addRequired('icf', @(x)isfloat(x) || ischar(x));
arg.addParamValue('grp', 'events', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); % por defecto

arg.parse(Cal, icf, varargin{:});

%% Determinamos los periodos de analisis + configs a aplicar
% periodos
event_info=getevents(Cal,'grp',arg.Results.grp);

% configuraciones (necesitamos tantas como eventos)
icf_=getcfgs(Cal.Date.CALC_DAYS,icf,'events',event_info.dates);    

%% Procesamos los periods determinados
CSN.cal_step={}; 
y=group_time(Cal.Date.CALC_DAYS',event_info.dates); id_period=unique(y);
for pp=1:length(id_period)  
    try
       periods_=Cal.Date.CALC_DAYS(y==id_period(pp)); 
       CSN.cal_step{pp}=sc_report(Cal.brw_str{Cal.n_inst},Cal.brw_config_files{Cal.n_inst,2},...
                     'data_path',fullfile(Cal.path_root,'..',num2str(year(periods_(1))),['bdata',Cal.brw_str{Cal.n_inst}]),...
                     'date_range',[periods_(1) periods_(end)+1],...
                     'one_flag', 0,'CSN_orig',icf_.data(10,pp),...
                     'control_flag',1,'residual_limit',35);
    catch exception
       fprintf('Trouble with Bfile-SC. %s\n',exception.message);
       CSN.cal_step{pp}=NaN*ones(1,5); CSN.cal_step{pp}(1)=periods_(1);
    end
end

%% Tabla
   lbl_sc={'CSN','[CI-]','[CI+]','Op. CSN','N'};
   data_tab=meanperiods(cell2mat(CSN.cal_step'),event_info);
   
   tabla_sc.data=cat(2,data_tab.m(:,:),data_tab.N(:,2)); tabla_sc.events=data_tab.evnts; tabla_sc.data_lbl=lbl_sc;
