function [ozone_lgl,cfg,lgl_leg,ozone_lgl_sum] = langley_data_cell(ozone_raw,ozone_ds,config,varargin)
% 
% Data for langley analysis. 
% 
% INPUT:  
% - readb_ds_develop / readb_data output: ozone_raw, ozone_ds, config
%
% Input optional:
% - O3_summ : This is the defined ozone offset to filtering data. Default 2.5 O3 std / summary
% 
% OUPUT: 
% - ozone_lgl     (langley individual data -> Depured as normal procedure with summaries. See test_recalculation.m)
% - ozone_lgl_sum (langley summaries data  -> Summaries recalculated from individual measurements)
% 
% - lgl_leg: Both outputs share the same data structure
%    
%     'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp' ... % 1-11              
%     'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'   ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
%     'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6' ...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
%     'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'   ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
%     'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6' ...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
%    
% - cfg (cal. constants for each ozone_lgl measurement) old & new
% 
%     'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
%     'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
%     'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_filter_cell';

% input obligatorio
arg.addRequired('ozone_raw',@iscell);
arg.addRequired('ozone_ds',@iscell);
arg.addRequired('config',@iscell);

% input param - value
arg.addParamValue('O3_summ', 2.5, @isfloat); % default 2.5 O3 std / summary

% validamos los argumentos definidos:
arg.parse(ozone_raw,ozone_ds,config, varargin{:});

%% Individual Data
ozone_lgl_=cellfun(@(x,y) [x(:,1:11),x(:,19:25),y(:,8:14),x(:,26:32),y(:,15:21)], ...
                                     ozone_raw, ozone_ds,'UniformOutput',false);

% We look for the following data-structure
lgl_leg.ozone_indv = {
    'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp' ...% 1-11              
    'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'   ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
    'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6' ...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
    'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'   ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
    'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6' ...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
                     };

% We now apply normal summaries filters to depure output. This is quite time-consuming
j_unique=cellfun(@(x) size(x,1)==1,ozone_lgl_); ozone_lgl_=ozone_lgl_(~j_unique);
[m_sum,s_sum,n_sum,gname]=cellfun(@(x) grpstats(x,fix(x(:,3)/10),{'mean','std','numel','gname'}),...
                                                                ozone_lgl_,'UniformOutput',false);

j=cellfun(@(x,y,z) find(x(:,19)<= arg.Results.O3_summ & y(:,19)> 100 & y(:,19)<600 & y(:,2)>0 & z(:,1)==5),...
                     s_sum,m_sum,n_sum,'UniformOutput',false); 
g_valid=cellfun(@(x) str2double(x),...
          cellfun(@(y,z) y(z),gname,j,'UniformOutput',false),'UniformOutput',false);
idx_valid=cellfun(@(x,y) ismember(fix(x(:,3)/10),y),ozone_lgl_,g_valid,'UniformOutput',false);

ozone_lgl=cellfun(@(x,y) x(y,:),ozone_lgl_,idx_valid,'UniformOutput',false);
ozone_lgl=ozone_lgl(cell2mat(cellfun(@(x) ~isempty(x),ozone_lgl,'UniformOutput',false)));

%% Calibration constants
cfg_old=cell2mat(cellfun(@(x) cat(1,x(1,1),x(2:6,1),x(8,1),x(11,1),x(13,1),x(17:22,1)),config','UniformOutput',false)); 
[a,b]=unique(cfg_old(1,:)); cfg.old=cfg_old(:,b);
cfg_new=cell2mat(cellfun(@(x) cat(1,x(1,2),x(2:6,2),x(8,2),x(11,2),x(13,2),x(17:22,2)),config','UniformOutput',false)); 
[a,b]=unique(cfg_new(1,:)); cfg.new=cfg_new(:,b);                                     
lgl_leg.cfg={
    'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
    'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
    'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'
            }; 

%% ... And these are summaries recalculated from indv. measurements. Only produced if we ask for it.
if nargout==4
   ozone_lgl_sum = cellfun(@(x,y) x(y,:),m_sum,j,'UniformOutput',false);
   lgl_leg.ozone_sum={
        'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp'...% 1-11              
        'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'  ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
        'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6'...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
        'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'  ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
        'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6'...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                       
                     };
end


