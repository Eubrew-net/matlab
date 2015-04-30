function [ratio_ref_ ratio_ref_SL_]=report_comp(Cal,comp,varargin)

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'report_comp';

% input obligatorio
arg.addRequired('Cal');
arg.addRequired('comp');

% input param - value
arg.addParamValue('icf_op' , {}, @(x)iscell(x)); %
arg.addParamValue('icf_chk', {}, @(x)iscell(x)); %
arg.addParamValue('summary', {}, @(x)iscell(x)); %

% validamos los argumentos definidos:
arg.parse(Cal,comp, varargin{:});

%% setup
osc_interval=[400,700,1000,1200];

if isempty(arg.Results.summary)
    
%% READ Brewer Summaries
 for i=comp.brws_idx
    ozone_sum{i}={};  config{i}={}; 
    ozone_raw{i}={};  ozone_raw0{i}={};  
    ozone_ds{i}={};   sl{i}={};          
    sl_cr{i}={};      

    ozone=read_bdata(i,Cal,fullfile(Cal.path_root,'bdata'));

    % depuramos datos (ver incidencias en config. matrix)
    ozone=dep_data(Cal.incidences_text{i},ozone);

    ozone_sum{i}=ozone.ozone_sum;
    config{i}=ozone.config;
    ozone_ds{i}=ozone.ozone_ds;
    ozone_raw{i}=ozone.raw;
    ozone_raw0{i}=ozone.raw0;
    sl{i}=ozone.sl; %first calibration/ bfiles
    sl_cr{i}=ozone.sl_cr; %recalculated with 2? configuration
 end  
 
%% Configs
for i=comp.brws_idx
    %% Operative
    try
       fprintf('\nBrewer %s: Operative Config.\n',Cal.brw_name{i});
       events_cfg_op=getcfgs(Cal.Date.CALC_DAYS,arg.Results.icf_op{i});    
       displaytable(events_cfg_op.data(2:end,:),cellstr(datestr(events_cfg_op.data(1,:),1))',12,'.5g',events_cfg_op.legend(2:end));
    catch exception
       fprintf('%s, brewer: %s\n',exception.message,Cal.brw_str{i});
    end
    
    %% Check
    try
       events_cfg_chk=getcfgs(Cal.Date.CALC_DAYS,arg.Results.icf_chk{i});    
       fprintf('\nBrewer %s: Second Config.\n',Cal.brw_name{i});
       displaytable(events_cfg_chk.data(2:end,:),cellstr(datestr(events_cfg_chk.data(1,:),1))',12,'.5g',events_cfg_chk.legend(2:end));
    catch exception
       fprintf('%s, brewer: %s\n',exception.message,Cal.brw_str{i});
    end
 end

%% SL Report
close all;
for ii=comp.brws_idx
    Cal.n_inst=ii;
    sl_mov_o{ii}={}; sl_median_o{ii}={}; sl_out_o{ii}={}; R6_o{ii}={};
    sl_mov_n{ii}={}; sl_median_n{ii}={}; sl_out_n{ii}={}; R6_n{ii}={};
% Operational constants
    [sl_mov_o{ii},sl_median_o{ii},sl_out_o{ii},R6_o{ii}]=sl_report_jday(ii,sl,Cal.brw_str,...
                               'outlier_flag',1,'diaj_flag',0,'events_raw',Cal.events_raw{ii},...
                               'hgflag',1,'fplot',0);
 % Imprimimos valores por eventos  
    fprintf('\nSL means, Op. config (by events). Brewer %s\r\n',Cal.brw_name{ii}); 
    event_info=getevents(Cal,'grp','events'); data_tab=meanperiods(sl_median_o{ii}(:,[1 2 4]), event_info);
    displaytable(cat(2,data_tab.m(:,2),data_tab.std(:,2),data_tab.m(:,3),data_tab.std(:,3),data_tab.N(:,1)),...
                 {'R6','std','R5','std','N'},15,'.4f',data_tab.evnts);

% Alternative constants
    [sl_mov_n{ii},sl_median_n{ii},sl_out_n{ii},R6_n{ii}]=sl_report_jday(ii,sl_cr,Cal.brw_str,...
                               'outlier_flag',1,'diaj_flag',0,'events_raw',Cal.events_raw{ii},...
                               'hgflag',1,'fplot',0);
% Imprimimos valores por eventos  
    fprintf('\nSL means, Chk. config (by events). Brewer %s\r\n',Cal.brw_name{ii}); Cal.n_inst=ii;
    event_info=getevents(Cal,'grp','events'); data_tab=meanperiods(sl_median_n{ii}(:,[1 2 4]), event_info);
    displaytable(cat(2,data_tab.m(:,2),data_tab.std(:,2),data_tab.m(:,3),data_tab.std(:,3),data_tab.N(:,1)),...
                 {'R6','std','R5','std','N'},15,'.4f',data_tab.evnts);
    snapnow
end

%% Creating Summaries
close all
[A,ETC,SL_B,SL_R,F_corr,SL_corr_flag,cfg]=read_cal_config_new(config,Cal,{sl_median_o,sl_median_n});

% Data recalculation for summaries  and individual observations
for i=comp.brws_idx    
   [cal,summary_orig{i},summary_orig_old{i}]=test_recalculation(Cal,i,ozone_ds,A,SL_R,SL_B,...
                                      'flag_sl',1,'plot_sl',0,'flag_sl_corr',SL_corr_flag);
   [summary_old{i} summary{i}]=filter_corr(summary_orig,summary_orig_old,i,A,F_corr{i});
end

%% ETC Transfer
close all

% grp_custom=getevents(Cal,'grp','month');      
% grp_custom=struct('dates',datenum(Cal.Date.cal_year,1,[diaj(Cal.Date.day0) 95 104]),...
%                   'labels',{{'Before','Campaign','After'}});
[ETC_Op ETC_Chk]=report_ETC(Cal,summary,summary_old,ETC,A,...
                    'reference_brw',comp.reference,'analyzed_brw',comp.instrument,'plot',0);

else
 summary_old=arg.Results.summary;    
end

%% Sync data
close all
Cal_work.brw=Cal.brw; Cal_work.sl_c=repmat(1,50,1)';
[ref,ratio_ref_SL]=join_summary(Cal_work,summary_old,comp.reference,comp.brws_idx,10);
Cal_work.sl_c=repmat(0,50,1)';
[ref,ratio_ref]=join_summary(Cal_work,summary_old,comp.reference,comp.brws_idx,10);

%% Data
events_data=getevents(Cal,'grp','events'); date_range=Cal.Date.CALC_DAYS;
y=group_time(date_range',events_data.dates); id_period=unique(y);

ratio_ref_=cell(1,length(id_period)); ratio_ref_SL_=cell(1,length(id_period)); 
for pp=1:length(id_period)          
    jday      =ismember(fix(ratio_ref_SL(:,1)),date_range(y==id_period(pp)));
    ratio_ref_SL_{pp}=ratio_ref_SL(jday,:);
    jday      =ismember(fix(ratio_ref(:,1)),date_range(y==id_period(pp)));
    ratio_ref_{pp}=ratio_ref(jday,:);
end

