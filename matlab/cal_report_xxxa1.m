% options_pub.outputDir=fullfile(pwd,'latex','xxx','html'); options_pub.showCode=true;
% publish(fullfile(pwd,'cal_report_xxxa1.m'),options_pub);

%% Brewer Evaluation
clear all;
file_setup='arenos2013_setup';

eval(file_setup);     % configuracion por defecto
Cal.n_inst=find(Cal.brw==xxx);
Cal.file_latex=fullfile('.','latex',Cal.brw_str{Cal.n_inst});
Cal.dir_figs=fullfile('latex',filesep(),Cal.brw_str{Cal.n_inst},...
                              filesep(),[Cal.brw_str{Cal.n_inst},'_figures'],filesep());
mkdir(Cal.dir_figs);
try
 save(Cal.file_save,'-Append','Cal'); %sobreescribimos la configuracion guardada.
 load(Cal.file_save);
catch exception
      fprintf('Error: %s, brewer %s\n',exception.message,Cal.brw_name{Cal.n_inst});
      save(Cal.file_save);
end

%% Brewer setup
Station.OSC=680;
Station.name='';
Station.lat=67;
Station.long=50;
Station.meanozo=350;

CALC_DAYS=Cal.calibration_days{Cal.n_inst,1};
if ~isempty(Cal.calibration_days{Cal.n_inst,2})
   BLIND_DAYS=Cal.calibration_days{Cal.n_inst,2};
else
   BLIND_DAYS=[NaN,NaN];
end
FINAL_DAYS=Cal.calibration_days{Cal.n_inst,3};

latexcmd(fullfile(Cal.file_latex,['cal_setup_',Cal.brw_str{Cal.n_inst}]),...
                    '\CALINI',CALC_DAYS(1),'\CALEND',CALC_DAYS(end),...
                    '\calyear',Date.cal_year,'\calyearold',Date.cal_year-2,...
                    '\slrefOLD',Cal.SL_OLD_REF(Cal.n_inst),'\slrefNEW',Cal.SL_NEW_REF(Cal.n_inst),...
                    '\BLINDINI',BLIND_DAYS(1),'\BLINDEND',BLIND_DAYS(end),...
                    '\FINALINI',FINAL_DAYS(1),'\FINALEND',FINAL_DAYS(end),...
                    '\caldays',length(Date.FINAL_DAYS),'\Tsync',Cal.Tsync,...
                    '\brwname',Cal.brw_name(Cal.n_inst),'\brwref',Cal.brw_name(Cal.n_ref(2)),...
                    '\BRWSTATION',Station.name,'\STATIONOSC',Station.OSC,...
                    '\DCFFILE',Cal.FCal.DCFFILE,'\LFFILE',Cal.FCal.LFFILE,...
                    '\campaign',Cal.campaign);

Cal.Date=Date;
save(Cal.file_save,'-Append','Cal');

%% configuration files
try
[config_ref,TCref,DTref,ETCref,A1ref,ATref,leg]=read_icf(Cal.brw_config_files{Cal.n_ref(2),2});
[config_def,TCdef,DTdef,ETCdef,A1def,ATdef,leg]=read_icf(Cal.brw_config_files{Cal.n_inst,2});
[config_orig,TCorig,DTorig,ETCorig,A1orig,ATorig,leg]=read_icf(Cal.brw_config_files{Cal.n_inst,1});

latexcmd(fullfile(Cal.file_latex,['cal_config_',Cal.brw_str{Cal.n_inst}]),...
                     DTref,'\ETCref',ETCref(1),'\Aref',A1ref(1),...
                     DTdef,'\ETCdef',ETCdef(1),'\Adef',A1def(1),...
                     DTorig,'\ETCorig',ETCorig(1),'\Aorig',A1orig(1));
%%
makeHtmlTable([config_orig,config_def],[],cellstr(leg),[Cal.brw_config_files(Cal.n_inst,1),Cal.brw_config_files(Cal.n_inst,2)])

catch exception
      fprintf('%s, brewer: %s\n',exception.message,Cal.brw_name{Cal.n_inst});
      DTorig=NaN; DTdef=NaN;
end

%% Historical review AVG info
% all period
close all;
[sl_data,dt_data,rs_data,ap_data,hg_data,h2o_data,op_data,Args]=brw_avg_report(Cal.brw_str{Cal.n_inst},Cal.brw_config_files(Cal.n_inst,:),...
                                      'date_range',[datenum(Cal.Date.cal_year-2,7,25),datenum(Cal.Date.cal_year,Cal.Date.cal_month+1,5)],...
                                      'SL_REF',[Cal.SL_OLD_REF(Cal.n_inst),Cal.SL_NEW_REF(Cal.n_inst)],...
                                      'DT_REF',[DTorig,DTdef],...
                                      'outlier_flag',{'','','','','','',''});
try
    
    if ~isempty(sl_data)
       day_ini=find(sl_data(:,2)==Cal.Date.cal_year & sl_data(:,3)>=Cal.Date.FINAL_DAYS(1));
       day_last=find(sl_data(:,2)==Cal.Date.cal_year & sl_data(:,3)<=Cal.Date.FINAL_DAYS(end));
       RseisAVG=round(nanmean(sl_data(day_ini(1):day_last(end),12)));
       RcincoAVG=round(nanmean(sl_data(day_ini(1):day_last(end),11)));
    end
    if ~isempty(dt_data)
       day_ini=find(dt_data(:,2)==Cal.Date.cal_year & dt_data(:,3)>=Cal.Date.FINAL_DAYS(1));
       day_last=find(dt_data(:,2)==Cal.Date.cal_year & dt_data(:,3)<=Cal.Date.FINAL_DAYS(end));
       DTAVG=sprintf('%g',10^-9*round(nanmean(dt_data(day_ini(1):day_last(end),4))));
    end
    latexcmd(fullfile(Cal.file_latex,['cal_status_',Cal.brw_str{Cal.n_inst}]),RseisAVG,RcincoAVG,DTAVG);
    format short g;
    tableform({'SLR6  orig',   'Calc. AVG','SLR5  orig','Calculated','DT  orig','Calculated'},...
              [Cal.SL_OLD_REF(Cal.n_inst), RseisAVG,      NaN,      RcincoAVG,   DTorig, str2double(DTAVG)]);

    avg_report{Cal.n_inst}.RseisAVG=RseisAVG;  avg_report{Cal.n_inst}.RcincoAVG=RcincoAVG;
    avg_report{Cal.n_inst}.DTorig  =DTorig;    avg_report{Cal.n_inst}.DTAVG    =DTAVG;
    
catch exception
      fprintf('Error: %s, brewer %s\n',exception.message,Cal.brw_name{Cal.n_inst});
end
    
avg_report{Cal.n_inst}.sl_data=sl_data; avg_report{Cal.n_inst}.dt_data=dt_data;
avg_report{Cal.n_inst}.rs_data=rs_data; avg_report{Cal.n_inst}.ap_data=ap_data;
avg_report{Cal.n_inst}.hg_data=hg_data; avg_report{Cal.n_inst}.op_data=op_data;
if exist('Args','var')
   avg_report{Cal.n_inst}.Args=Args;
else disp('No se están guardando los inputs de la función!!')
end
save(Cal.file_save,'-APPEND','avg_report');

%%
ix=sort(findobj('Type','figure'));
printfiles_report(ix',Cal.dir_figs);

ix=sort([findobj('tag','SLAVG_F5') findobj('tag','HGOAVG')])';
printfiles_report(ix',Cal.dir_figs,'LockAxes',0,'no_export');

figure(max(findobj('tag','RSAVG')));
printfiles_report(gcf,Cal.dir_figs,'Width',12.5,'Height',17);

close all;

%% CZ REPORT
br=sprintf('%03d',Cal.brw(Cal.n_inst));
try
    analyzeCZ(fullfile(Cal.path_root,['bdata',br],['CZ*.',br]),...
                             'date_range',datenum(Cal.Date.cal_year,Cal.Date.cal_month-1,1));
catch exception
      fprintf('Error: %s, brewer %s\n',exception.stack.name,Cal.brw_name{Cal.n_inst});
end

%%
try
    figure(findobj('tag','CZ_Report'));
    printfiles_report(gcf,fullfile(Cal.path_root,Cal.dir_figs));
catch exception
      fprintf('Error: %s, brewer %s\n',exception.message,Cal.brw_name{Cal.n_inst});
end
close all

%% HL Report
br=sprintf('%03d',Cal.brw(Cal.n_inst));
try
    analyzeCZ(fullfile(Cal.path_root,['bdata',br],['HL*.',br]),...
                              'date_range',datenum(Cal.Date.cal_year,1,[Cal.Date.day0-30 Cal.Date.dayend]));
catch exception
      fprintf('Error: %s, brewer %s\n',exception.stack.name,Cal.brw_name{Cal.n_inst});
end

%% HS Report
br=sprintf('%03d',Cal.brw(Cal.n_inst));
try
    analyzeCZ(fullfile(Cal.path_root,['bdata',br],['HS*.',br]),...
                              'date_range',datenum(Cal.Date.cal_year,1,[Cal.Date.day0-30 Cal.Date.dayend]));
catch exception
      fprintf('Error: %s, brewer %s\n',exception.stack.name,Cal.brw_name{Cal.n_inst});
end

%% CI REPORT
close all; br=sprintf('%03d',Cal.brw(Cal.n_inst));
try
    [LRatPFHT Error]=analyzeCI(fullfile(Cal.path_root,['bdata',br],['CI*.',br]),...
                           fullfile(Cal.path_root,['bdata',br],'CI18711.xxx'),'depuracion',0,...
                          'date_range',datenum(Cal.Date.cal_year,1,[Cal.Date.day0-30 Cal.Date.dayend]));
catch exception
      fprintf('Error: %s, brewer %s\n',exception.stack.name,Cal.brw_name{Cal.n_inst});
end

%%
try
    figure(findobj('tag','CI_Report'));
    printfiles_report(gcf,fullfile(Cal.path_root,Cal.dir_figs),'LockAxes',0,'no_export');
catch exception
      fprintf('Error: %s, brewer %s\n',exception.message,Cal.brw_name{Cal.n_inst});
end
close all

%% FV REPORT
br=sprintf('%03d',Cal.brw(Cal.n_inst));
try
    [azimut zenit]=analyze_FV(fullfile(Cal.path_root,['bdata',br],['FV*.',br]),...
                         'date_range',datenum(Cal.Date.cal_year,1,[Cal.calibration_days{Cal.n_inst,1}(1) Cal.calibration_days{Cal.n_inst,1}(end)]),...
                         'plot_flag',0);
catch exception
      fprintf('Error: %s, brewer %s\n',exception.stack.name,Cal.brw_name{Cal.n_inst});
end

%%
try
    figure(findobj('tag','FV_Report'));
    printfiles_report(gcf,fullfile(Cal.path_root,Cal.dir_figs),'LockAxes',0,'no_export');
catch exception
      fprintf('Error: %s, brewer %s\n',exception.message,Cal.brw_name{Cal.n_inst});
end
close all

%% TEMP REPORT from AVG
% close all;
% for ii=Cal.n_inst
%     f0=figure;
%     disp(Cal.brw_str{Cal.n_inst})
%     config_temp.n_inst=Cal.n_inst;
%     config_temp.brw_name=Cal.brw_str{Cal.n_inst};
%     config_temp.final_days=Cal.Date.FINAL_DAYS(1);
%
%     [NTCN,tabla]=temp_coeff_report(config_temp,sl_data,config_def,...
%                                       'date_range',[datenum(Cal.Date.cal_year-2,7,15),datenum(Cal.Date.cal_year,Cal.Date.cal_month+1,5)],...
%                                       'outlier_flag',0);
%     R6TEMP=sprintf('MS9: %5.0f +/-%2.0f  %3.1f +/- %3.2f  ',tabla(7,[1 3 2 4]));
%     disp(R6TEMP);
%
%     try
%         cat(1,tabla{7,:})
%         snapnow;
%         close all;
%     catch
%         disp('rrr');
%     end
% end
