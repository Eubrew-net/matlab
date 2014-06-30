function [tabla_HS tabla_HL]=b2(Cal,varargin)

% function [tabla_HS tabla_HL]=b2(Cal,varargin)
% 
% Analisis de los CZ's. Promedios por eventos
% 
% INPUT
% - Cal   : variable de definiciones (setup)
% - grp   : Opcional (string). Por defecto promedios mensuales
%           Valores implementados: 'events','month','week','month+events' (see getevents function)
% 
% OUTPUT
% - tabla_HS (wl=2967.28) y tabla_HL (wl=3341.48): Estructura con los siguientes campos:
%              
%              1) data    : matriz con el resultado de la estadistica, ordenados 
%                           segun labels en tabla_HS/HL.data_lbl
%              2) events  : cellstr con etiquetas para cada evento registrado
%              3) data_lbl: cellstr con etiquetas para cada campo en tabla_HS/HL.data
%              
%                          'wl real','wl, método pendientes','std','Diferencia',
%                          'wl, método centro masas','std','Diferencia','fwhm','std','N'
% 
% EXAMPLE:
%       [tabla_HS tabla_HL]=b2(Cal,'grp','month+events');
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='b2';

arg.addRequired('Cal', @isstruct);
arg.addParamValue('grp', 'events', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); % por defecto

arg.parse(Cal, varargin{:});

%%
wl_={}; fwhm_={};
try
   [wl fwhm]=analyzeCZ(fullfile(Cal.path_root,['bdata',Cal.brw_str{Cal.n_inst}],['HS*.',Cal.brw_str{Cal.n_inst}]),...
             'date_range',Cal.Date.CALC_DAYS([1 end]),'plot_flag',1); wl_{1}=wl{1}; fwhm_{1}=fwhm{1};             
catch exception
   fprintf('Brewer %s, no HS files (%s)\n',Cal.brw_str{Cal.n_inst},exception.identifier);
   [wl fwhm]=analyzeCZ(fullfile(Cal.path_root,['bdata',Cal.brw_str{Cal.n_inst}],['CZ*.',Cal.brw_str{Cal.n_inst}]),...
             'date_range',Cal.Date.CALC_DAYS([1 end]),'plot_flag',1); wl_{1}=wl{1}; fwhm_{1}=fwhm{1};             
end

try
   [wl fwhm]=analyzeCZ(fullfile(Cal.path_root,['bdata',Cal.brw_str{Cal.n_inst}],['HL*.',Cal.brw_str{Cal.n_inst}]),...
             'date_range',Cal.Date.CALC_DAYS([1 end]),'plot_flag',1); wl_{2}=wl{3}; fwhm_{2}=fwhm{3};             
catch exception
   fprintf('Brewer %s, no HL files (%s)\n',Cal.brw_str{Cal.n_inst},exception.identifier);
   wl_{2}=NaN*ones(1,7); fwhm_{2}=NaN*ones(1,1);             
end

%% Table, por periodos
event_info=getevents(Cal,'grp',arg.Results.grp); 
tab_cz=cell(1,2);
for cz=1:2
    wl=wl_{cz}; fwhm=fwhm_{cz}; 
    id=find(abs(fwhm)>25); wl(id,:)=[]; fwhm(id)=[];
    id=find(isnan(fwhm));  wl(id,:)=[]; fwhm(id)=[];

    wl(:,end)=fwhm';   
    tab_cz{cz}=meanperiods(wl, event_info);
end

 lbl_cz={'wl real','wl, Slopes','std','Diferencia','wl, C.M.','std','Diferencia','fwhm','std','N'}; 
 aux=NaN*ones(size(tab_cz{1}.m,1),11); 
 aux(:,[1 2 3 5 6 8 9])=tab_cz{1}.m; aux(:,[4 7 10])=tab_cz{1}.std(:,[3 5 7]); aux(:,end)=tab_cz{1}.N(:,end);
 tabla_HS.data=aux; tabla_HS.events=tab_cz{1}.evnts; tabla_HS.data_lbl=lbl_cz;

 aux=NaN*ones(size(tab_cz{2}.m,1),11); 
 aux(:,[1 2 3 5 6 8 9])=tab_cz{2}.m; aux(:,[4 7 10])=tab_cz{2}.std(:,[3 5 7]); aux(:,end)=tab_cz{2}.N(:,end);
 tabla_HL.data=aux; tabla_HL.events=tab_cz{1}.evnts; tabla_HL.data_lbl=lbl_cz;
