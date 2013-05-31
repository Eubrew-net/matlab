function [ozone_lgl,ozone_lgl_sum,cfg,lgl_leg] = langley_data_cell(ozone_raw,ozone_ds,config)

% Data for langley analysis. 
% 
% iNPUT:  
% - readb_ds_develop / readb_data output: ozone_raw, ozone_ds, config
% 
% OUPUT: 
% - ozone_lgl (langley individual data)
% - ozone_lgl_sum (langley summaries data). Summaries recalculated from individual measurements
%                  Additional fields are added for later filtering (40, 41 & 42 fields)
% - cfg (cal. constants for each ozone_lgl measurement) old & new
% - lgl_leg

%% Common
ozone_lgl=cellfun(@(x,y) [x(:,1:11),x(:,19:25),y(:,8:14),x(:,26:32),y(:,15:21)], ...
                                     ozone_raw, ozone_ds,'UniformOutput',false);
lgl_leg.ozone_indv = {
    'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp' ...% 1-11              
    'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'   ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
    'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6' ...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
    'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'   ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
    'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6' ...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
                     };

% cfg=cellfun(@(x) cat(1,x(1,:),x(2:6,:),x(8,:),x(11,:),x(13,:),x(17:22,:)), ...
%                                             config,'UniformOutput',false);
cfg_old=cell2mat(cellfun(@(x) cat(1,x(1,1),x(2:6,1),x(8,1),x(11,1),x(13,1),x(17:22,1)),config','UniformOutput',false)); 
[a,b]=unique(cfg_old(1,:)); cfg.old=cfg_old(:,b);
cfg_new=cell2mat(cellfun(@(x) cat(1,x(1,2),x(2:6,2),x(8,2),x(11,2),x(13,2),x(17:22,2)),config','UniformOutput',false)); 
[a,b]=unique(cfg_new(1,:)); cfg.new=cfg_new(:,b);                                     
lgl_leg.cfg={
    'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
    'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
    'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'
            }; 

j_unique=cellfun(@(x) size(x,1)==1,ozone_lgl); ozone_lgl=ozone_lgl(~j_unique);

[m_sum,s_sum,n_sum]=cellfun(@(x) grpstats(x,fix(x(:,3)/10),{'mean','std','numel'}),...
                           ozone_lgl,'UniformOutput',false);
% We add to recalc. summ. necessary fields to depure: (40,41) = o3_std & 42 = N)                       
ozone_lgl_sum=cellfun(@(x,y,z) cat(2,x,y(:,[19 33]),z(:,1)),m_sum,s_sum,n_sum,'UniformOutput', false);    
lgl_leg.ozone_sum={
    'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp'...% 1-11              
    'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'  ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
    'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6'...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
    'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'  ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
    'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6'...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
    'O3_1 std'  'O3_2 std'  'N summaries'  
                  };


