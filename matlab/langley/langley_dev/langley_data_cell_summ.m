function [ozone_lgl_sum,cfg,lgl_leg] = langley_data_cell_summ(summary,summary_old,config,varargin)

% Data for langley analysis (derived from summaries). 
% Se crea para la salida el mismo formato de la antigua ozone_lgl: 39 campos
% MS9's para las dos configuraciones consideradas: new y old 
% 
% INPUT:  
% - test_recalculation output: summary, summary_old, 
%     
%  Los  summarios están corregidos por filtros (función filter_corr), con lo cual se trabaja con el campo 9 
%  Si no se aplica la función filter_corr, entonces tendríamos que el campo 9 es la MS9 std !!
% 
% - config: 
%
% OUPUT: 
% - ozone_lgl_sum: langley summaries data (same as ozone_lgl_sum output from langley_data_cell).
%                  Celda con tantas matrices como días analizados
%                          
% - cfg: Cal. constants for each day processed (old & new)
% 
% - lgl_leg: Two-field structure with legends 
%          
%      1) ozone_lgl_sum
% 
%      'date'  'lat'  'long' 'sza'  'm2 '  'm3 '  'flag'  'NaN'  'tst'  'filt'  'temp' ... % 1-11              
%      'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...      % 12-18 
%      'O3 old'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 old'  ...  % 19-25 
%      'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...      % 26-32 
%      'O3 new'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 new'  ...  % 33-39 
% 
%      2) cfg
% 
%      'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
%      'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
%      'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'
% 

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_data_cell_summ';

% input obligatorio
arg.addRequired('summary');
arg.addRequired('summary_old');
arg.addRequired('config');

% input param - value
arg.addParamValue('lalo', [28.3090,16.4994], @isfloat); % por defecto, Izana

% validamos los argumentos definidos:
arg.parse(summary,summary_old,config,varargin{:});

%% langley_summ Data
% We look for the following data-structure
lgl_leg.ozone_lgl_sum = {
     'date'  'lat'  'long' 'sza'  'm2 '  'm3 '  'flag'  'NaN'  'tst'  'filt'  'temp' ... % 1-11              
     'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...         % 12-18 
     'O3 old'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 old'  ...  % 19-25 
     'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...         % 26-32 
     'O3 new'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 new'  ...  % 33-39 
                        };

dds=unique(fix(summary(:,1))); y=group_time(fix(summary(:,1)),dds);
ozone_lgl_sum=cell(length(dds),1);
for dd=1:length(dds)
    idx=y==dd;
    [no,no_,tst]=sun_pos(summary(idx,1),arg.Results.lalo(1),-arg.Results.lalo(2));

    ozone_lgl_sum{dd}=NaN*ones(length(find(idx==1)),39);
    ozone_lgl_sum{dd}(:,[1 4 5 6 9 10 11 19 25 33 39])=cat(2,summary(idx,[1 2 3]),summary(idx,3),tst,...
                                                             summary(idx,[5 4]),...
                                                             summary_old(idx,[6 9]),...
                                                             summary(idx,[6 9]));
end
                    
%% Calibration constants
lgl_leg.cfg={
    'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
    'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
    'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'
            }; 
        
cfg_old=cell2mat(cellfun(@(x) cat(1,x(1,1),x(2:6,1),x(8,1),x(11,1),x(13,1),x(17:22,1)),config','UniformOutput',false)); 
[a,b]=unique(cfg_old(1,:)); cfg.old=cfg_old(:,b);
cfg_new=cell2mat(cellfun(@(x) cat(1,x(1,2),x(2:6,2),x(8,2),x(11,2),x(13,2),x(17:22,2)),config','UniformOutput',false)); 
[a,b]=unique(cfg_new(1,:)); cfg.new=cfg_new(:,b);                                     
