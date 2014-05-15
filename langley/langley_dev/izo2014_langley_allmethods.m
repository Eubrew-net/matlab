
%% Initial setup
clear all;
file_setup='calizo2014_setup';  eval(file_setup);

Cal.n_inst=find(Cal.brw==145);

%% Some configurations overwriten
br=Cal.n_inst;
Cal.Date.CALC_DAYS=datenum(2014,1,[90:114 118:150]);
Cal.calibration_days={Cal.Date.CALC_DAYS,Cal.Date.CALC_DAYS,Cal.Date.CALC_DAYS};
                 
%% Loading data
    for i=[Cal.n_ref br]
        dsum{i}={};       ozone_raw{i}={};   hg{i}={};
        ozone_sum{i}={};  ozone_raw0{i}={};  bhg{i}={};
        config{i}={};     sl{i}={};          log{i}={};
        ozone_ds{i}={};   sl_cr{i}={};       missing{i}=[];

        [ozone,log_,missing_]=read_bdata(i,Cal);

        dsum{i}=ozone.dsum;
        ozone_sum{i}=ozone.ozone_sum;
        config{i}=ozone.config;
        ozone_ds{i}=ozone.ozone_ds;
        ozone_raw{i}=ozone.raw;
        ozone_raw0{i}=ozone.raw0;
        sl{i}=ozone.sl;               % first calibration/ bfiles
        sl_cr{i}=ozone.sl_cr;         % recalculated with 2º configuration
        hg{i}=ozone.hg;
        bhg{i}=ozone.bhg;
        log{i}=cat(1,log_{:});
        missing{i}=missing_';
    end

 %% SL Report: needed if you want to use summaries (it is no longer necessary, as demonstrated below)
for ii=[Cal.n_ref br]
    sl_mov_o{ii}={}; sl_median_o{ii}={}; sl_out_o{ii}={}; R6_o{ii}={};
    sl_mov_n{ii}={}; sl_median_n{ii}={}; sl_out_n{ii}={}; R6_n{ii}={};
    try
      % old instrumental constants
      [sl_mov_o{ii},sl_median_o{ii},sl_out_o{ii},R6_o{ii}]=sl_report_jday(ii,sl,Cal.brw_str,...
               'outlier_flag',1,'hgflag',1,'diaj_flag',0,'fplot',0,'events_raw',events_raw{ii});
      % new instrumental constants
      [sl_mov_n{ii},sl_median_n{ii},sl_out_n{ii},R6_n{ii}]=sl_report_jday(ii,sl_cr,Cal.brw_str,...
               'outlier_flag',1,'hgflag',1,'diaj_flag',0,'fplot',0);
    catch exception
      fprintf('%s, brewer: %s\n',exception.message,Cal.brw_str{ii});
    end
end

%% READ Configuration: same as before
close all
[A,ETC,SL_B,SL_R,F_corr,cfg]=read_cal_config_new(config,Cal,{sl_median_o,sl_median_n});

for i=[Cal.n_ref br]
    cal{i}={}; summary{i}={}; summary_old{i}={};
    [cal{i},summary{i},summary_old{i}]=test_recalculation(Cal,i,ozone_ds,A,SL_R,SL_B,'flag_sl',1);
end
summary_orig=summary; summary_orig_old=summary_old;

% filter correction 
for ii=[Cal.n_ref br]
   [summary_old_corr summary_corr]=filter_corr(summary_orig,summary_orig_old,ii,A,F_corr{ii});
   summary_old{ii}=summary_old_corr; summary{ii}=summary_corr;
end

%%
cfg_old={}; cfg_new={};
for i=[Cal.n_ref br]
    cfg_o=cell2mat(cellfun(@(x) x([1 2:6 8 11 13 17:22 27:28 29:31],1),config{i}','UniformOutput',false));
    [a,b]=unique(cfg_o(1,:)); events_cfg.old{i}=cfg_o(:,b); cfg_old{i}=cfg_o;
    cfg_n=cell2mat(cellfun(@(x) x([1 2:6 8 11 13 17:22 27:28 29:31],2),config{i}','UniformOutput',false));
    [a,b]=unique(cfg_n(1,:)); events_cfg.new{i}=cfg_n(:,b); cfg_new{i}=cfg_n;
end
events_cfg_legend={'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
         'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)',...
         'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5',...
         'R6','R5','F#2_C','F#3_C','F#4_C'};

     
%% ---- langley from summaries ----
xlim_brw=[1500 1700]; xlim_dbs=[-70 70];
airm_rang=[1.35 4.30]; cfgs=2;  

ozone_lgl_sum={}; cfg_sum={};
for i=[Cal.n_ref br]
 [ozone_lgl_sum{i},cfg_sum{i},lgl_leg] = langley_data_cell_summ(summary{i},summary_old{i},config{i});
end

% ---- summaries ----
[summ_brw_raw{br} summ_dbs_raw{br}] = langley_analys(ozone_lgl_sum,br,Cal);

% ---- summaries dep. ----
ozone_lgl_sum_dep{br} = langley_filter_lvl1(ozone_lgl_sum{br},'airmass',airm_rang,'summ',1,'O3_hday',2.5);
[summ_brw_dep{br} summ_dbs_dep{br}] = langley_analys(ozone_lgl_sum_dep,br,Cal,'res_filt',0);

% ---- summaries dep sync ----
langsumm_sync_data = langley_summ_sync(ozone_lgl_sum,Cal);
langsumm_sync_dep{br} = langley_filter_lvl1(langsumm_sync_data{br},'airmass',airm_rang,'summ',1,'O3_hday',2.5);
[summ_brw_dep_sync{br} summ_dbs_dep_sync{br}] = langley_analys(langsumm_sync_dep,br,Cal);


%% ---- langley from Indiv. Measurements ----
for ii=[Cal.n_ref br]
    [ozone_lgl{ii},cfg_indv,leg,ozone_lgl_sum{ii}] = langley_data_cell(ozone_raw{ii},ozone_ds{ii},config{ii});
end

% ---- Indiv. Measurements ----                   
ozone_lgl_{br}=langley_filter_lvl1(ozone_lgl{br},'F_corr',F_corr{br});
[indv_brw_raw{br} indv_dbs_raw{br}] = langley_analys(ozone_lgl_,br,Cal,'res_filt',1,'plot_flag',0);

% ---- langley from Indiv. Measurements (depured) ----
ozone_lgl_dep{br}=langley_filter_lvl1(ozone_lgl{br},'plots',0,...
                       'F_corr',F_corr{br},'airmass',airm_rang,'O3_hday',2.5);
[indv_brw_dep{br} indv_dbs_dep{br}] = langley_analys(ozone_lgl_dep,br,Cal,'res_filt',1,'plot_flag',0);

% ---- langley from Indiv. Measurements sync. (depured) ----
langindv_sync_data = langley_indv_sync(ozone_lgl,Cal);
ozone_lgl_dep{br}=langley_filter_lvl1(langindv_sync_data{br},'plots',0,'F_corr',F_corr{br},...
                                                        'airmass',airm_rang,'O3_hday',2.5);
[indv_brw_dep_sync{br} indv_dbs_dep_sync{br}] = langley_analys(ozone_lgl_dep,br,Cal,'res_filt',1,'plot_flag',0);

%%
close all; clc

figure; ha=tight_subplot(2,1,.08,.1,.075); hold all;
axes(ha(1)); set(gca,'XTicklabel',[],'box','on','YTickLabelMode','auto'); grid; hold on;
axes(ha(2)); set(gca,'box','on','YTickLabelMode','auto'); grid; hold on;

axes(ha(1)); p1=ploty(summ_brw_raw{br}(:,:,cfgs),'.'); set(gca,'Ylim',xlim_brw);
             p2=ploty(summ_brw_dep{br}(:,:,cfgs),'*'); set(gca,'Ylim',xlim_brw);
             p3=ploty(summ_brw_dep_sync{br}(:,:,cfgs),'o'); set(gca,'Ylim',xlim_brw);

             p4=ploty(indv_brw_raw{br}(:,:,cfgs),'p'); set(gca,'Ylim',xlim_brw);
             p5=ploty(indv_brw_dep{br}(:,:,cfgs),'d'); set(gca,'Ylim',xlim_brw);
             p6=ploty(indv_brw_dep_sync{br}(:,:,cfgs),'^'); set(gca,'Ylim',xlim_brw);

legendflex([p1;p2;p3;p4;p5;p6], {'AM sum raw','PM sum raw','AM sum dep','PM sum dep','AM sum dep sync','PM sum dep sync','AM indv raw','PM indv raw','AM indv dep','PM indv dep','AM indv dep sync','PM indv dep sync'},... 
                                 'anchor', {'s','s'}, 'buffer',[0 -25], 'nrow',2,'fontsize',8,'xscale',0.3);                   

axes(ha(2)); p1=ploty(summ_dbs_raw{br}(:,:,cfgs),'.'); set(gca,'Ylim',xlim_dbs);
             p2=ploty(summ_dbs_dep{br}(:,:,cfgs),'*'); set(gca,'Ylim',xlim_dbs);
             p3=ploty(summ_dbs_dep_sync{br}(:,:,cfgs),'o'); set(gca,'Ylim',xlim_dbs);

             p4=ploty(indv_dbs_raw{br}(:,:,cfgs),'p'); set(gca,'Ylim',xlim_dbs);
             p5=ploty(indv_dbs_dep{br}(:,:,cfgs),'d'); set(gca,'Ylim',xlim_dbs);
             p6=ploty(indv_dbs_dep_sync{br}(:,:,cfgs),'^'); set(gca,'Ylim',xlim_dbs);
              
% Config from icf
  cfg_new=cfg.new{br}; idx=group_time(indv_brw_raw{br}(:,1,cfgs),cfg_new(:,1));
  stairs(ha(1),indv_brw_raw{br}(logical(idx),1,cfgs),cfg_new(idx,11),'-k','LineWidth',2);
  stairs(ha(2),indv_brw_raw{br}(logical(idx),1,cfgs),repmat(0*ones(1,length(idx)),1),'-k','LineWidth',2);
  
datetick('x',19,'keeplimits','keepticks');
title(ha(1),sprintf('Langley plot (%s - %s): %s, airmass range = [%.2f, %.2f]',...
            datestr(indv_brw_raw{br}(1,1,1),22),datestr(indv_brw_raw{br}(end,1,1),22),Cal.brw_name{br},airm_rang)); 
ylabel(ha(1),'ETC (Brw method)','FontSize',8); ylabel(ha(2),'ETC corr. (Dbs method)','FontSize',8);
linkprop(ha,'XLim');
            