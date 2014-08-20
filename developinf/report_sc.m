function tabla_sc=report_sc(Cal,icf,varargin)

% function tabla_sc=report_sc(Cal,icf,varargin)
% 
% Analisis de los SC's en periodos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - icf   : Configuraciones a emplear. Por ahora unicamente esta permitida
%           una matriz de configuraciones
% Opcional
% - grp         : (String). Por defecto, vacio (habra que definir entonces grp_custom)
%                  Valores implementados: 'events','month','week','month+events' (see getevents function)
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
% 
%    grp_custom=struct('dates',datenum(2014,1,[1 100 150 210]),'labels',{{'q','s','s','f'}});
%    tabla_sc=report_sc(Cal,Cal.brw_config_files{Cal.n_inst,2},'grp_custom',grp_custom,'date_range',datenum(2014,1,1:50)); 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_sc';

arg.addRequired('Cal', @isstruct);
arg.addRequired('icf', @(x)isfloat(x) || ischar(x));

arg.addParamValue('grp', '', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); % por defecto
arg.addParamValue('grp_custom', [], @isstruct);    
arg.addParamValue('fpath', Cal.path_root, @ischar);    
arg.addParamValue('date_range', Cal.Date.CALC_DAYS, @isfloat);    

arg.parse(Cal, icf, varargin{:});

%% Determinamos los periodos de analisis + configs a aplicar
% periodos
lbl_sc={'CSN','[CI-]','[CI+]','Op. CSN','N'};
if isempty(arg.Results.grp)
   event_info=arg.Results.grp_custom;
else
   event_info=getevents(Cal,'grp',arg.Results.grp,'period',arg.Results.date_range);      
end
if isempty(event_info)
   fprintf('\rDebes definir una variable de eventos valida (help report_wavelength)\n');
   tabla_sc=NaN;
   return
end

% configuraciones (necesitamos tantas como eventos)
icf_=getcfgs(arg.Results.date_range,icf,'events',event_info.dates);    


%% Procesamos los periods determinados
CSN.cal_step={}; 
y=group_time(arg.Results.date_range',event_info.dates); id_period=unique(y);
for pp=1:length(id_period)  
    try
       periods_=arg.Results.date_range(y==id_period(pp)); 
       CSN.cal_step{pp}=sc_report(Cal.brw_str{Cal.n_inst},Cal.brw_config_files{Cal.n_inst,2},...
                     'data_path',fullfile(arg.Results.fpath,'..',num2str(year(periods_(1))),['bdata',Cal.brw_str{Cal.n_inst}]),...
                     'date_range',[periods_(1) periods_(end)+1],...
                     'one_flag', 0,'CSN_orig',icf_.data(10,pp),...
                     'control_flag',1,'residual_limit',35);
    catch exception
       fprintf('Trouble with Bfile-SC. %s\n',exception.message);
       CSN.cal_step{pp}=NaN*ones(1,5); CSN.cal_step{pp}(1)=periods_(1);
    end
end

%% Tabla
   data_tab=meanperiods(cell2mat(CSN.cal_step'),event_info);
   
   tabla_sc.data=cat(2,data_tab.m(:,:),data_tab.N(:,2)); tabla_sc.events=data_tab.evnts; tabla_sc.data_lbl=lbl_sc;
