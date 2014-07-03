function [lgl_data,cfg,ozone_lgl,config,icf,ozone_lgl_legend ] = lgl_data_cell(ozone_raw,ozone_ds,config)
% function [ozone_lgl,cfg,icf,ozone_lgl_legend ] = langley_data(ozone_raw,ozone_ds,config);
% 
% Input : readb_ds_develop / readb_data output
% Output: Ozone_lgl
% 
% ozone_lgl_legend={
%     'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp'...% 1-11              
%     'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'  ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
%     'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6'...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
%     'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'  ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
%     'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6'...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
%                  };
% 
% EXAMPLE
% load(Cal.file_save,'ozone_raw','ozone_ds','config');
% ozone_lgl=cell(Cal.n_brw,1);
% 
% icf={};cfg={};icf={};lgl={};
% for i=1:Cal.n_brw
%    [lgl{i},cfg{i},icf{i},legend]=langley_data(ozone_raw{i},ozone_ds{i},config{i});
% end
% save(Cal.file_save,'-append','ozone_lgl','cfg','icf','ozone_lgl_legend');

% cell outputs by juanjo
lgl_data=cellfun(@(x,y) [x(:,1:11),x(:,19:25),y(:,8:14),x(:,26:32),y(:,15:21)], ...
                                     ozone_raw, ozone_ds,'UniformOutput',false);
                                 
%% Calibration constants
cfg_old=cell2mat(cellfun(@(x) cat(1,x(1,1),x(2:6,1),x(8,1),x(11,1),x(13,1),x(17:22,1)),config','UniformOutput',false)); 
[a,b]=unique(cfg_old(1,:));
cfg.old=cfg_old(:,b);
cfg_new=cell2mat(cellfun(@(x) cat(1,x(1,2),x(2:6,2),x(8,2),x(11,2),x(13,2),x(17:22,2)),config','UniformOutput',false)); 
[a,b]=unique(cfg_new(1,:)); 
cfg.new=cfg_new(:,b);   


cfg.leg={
    'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
    'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
    'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'
            }; 
        

o3_raw=cell2mat(ozone_raw);
o3_ds=cell2mat(ozone_ds);
cfg_aux=cell2mat(config);
    
ozone_lgl=[o3_raw(:,1:11),o3_raw(:,19:25),o3_ds(:,8:14),o3_raw(:,26:32),o3_ds(:,15:21)];
icf=[cfg_aux(53:53:end,1),cfg_aux(1:53:end,1),cfg_aux(8:53:end,:),cfg_aux(11:53:end,:)];

config=reshape(cfg_aux,53,[],3);

ozone_lgl_legend={
    'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp'...% 1-11              
    'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'  ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
    'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6'...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
    'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'  ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
    'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6'...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
                 };
     
% icf_legend={
%         'A1cfg1' 'A1cfg2' 'A1bf' 'ETCcfg1' 'ETCcfg2' 'ETCbf'  ...  % 40-42 (A1) 43-45 (EtC)
%  }

end

