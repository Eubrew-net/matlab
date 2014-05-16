function [ozone_lgl,cfg,icf,ozone_lgl_legend ] = langley_data(ozone_raw,ozone_ds,config)
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

o3_raw=cell2mat(ozone_raw);
o3_ds=cell2mat(ozone_ds);
cfg_aux=cell2mat(config);
    
ozone_lgl=[o3_raw(:,1:11),o3_raw(:,19:25),o3_ds(:,8:14),o3_raw(:,26:32),o3_ds(:,15:21)];
icf=[cfg_aux(53:53:end,1),cfg_aux(1:53:end,1),cfg_aux(8:53:end,:),cfg_aux(11:53:end,:)];

cfg=reshape(cfg_aux,53,[],3);

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

