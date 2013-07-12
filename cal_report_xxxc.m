% options_pub.outputDir=fullfile(pwd,'latex','xxx','html'); options_pub.showCode=true;
% publish(fullfile(pwd,'cal_report_xxxc.m'),options_pub);

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
catch
    disp('clean');
    save(Cal.file_save);
end

%% Brewer setup
Cal.Date.CALC_DAYS=Cal.calibration_days{Cal.n_inst,1};
Cal.n_ref=15;

%% READ Brewer Summaries
 for i=[Cal.n_ref,Cal.n_inst]
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
    sl{i}=ozone.sl; %first calibration/ bfiles
    sl_cr{i}=ozone.sl_cr; %recalculated with 2º configuration
    hg{i}=ozone.hg;
    bhg{i}=ozone.bhg;
    log{i}=cat(1,log_{:});
    missing{i}=missing_';
    disp(log{i});
 end

save(Cal.file_save,'-APPEND','ozone_raw','dsum','ozone_sum','ozone_ds','config','sl','sl_cr','log','missing');
matrix2latex(log{Cal.n_inst},fullfile(Cal.file_latex,['tabla_fileprocess_',Cal.brw_str{Cal.n_inst},'.tex']));

%% configuration files
change=write_excel_config(config,Cal,Cal.n_inst);

[config_ref,TCref,DTref,ETCref,A1ref,ATref,leg]  =read_icf(Cal.brw_config_files{Cal.n_ref(1),2});
[config_def,TCdef,DTdef,ETCdef,A1def,ATdef]      =read_icf(Cal.brw_config_files{Cal.n_inst,2});
[config_orig,TCorig,DTorig,ETCorig,A1orig,ATorig]=read_icf(Cal.brw_config_files{Cal.n_inst,1});

latexcmd(fullfile(Cal.file_latex,['cal_config_',Cal.brw_str{Cal.n_inst}]),...
                     DTref,'\ETCref',ETCref(1),'\Aref',A1ref(1),...
                     DTdef,'\ETCdef',ETCdef(1),'\Adef',A1def(1),...
                     DTorig,'\ETCorig',ETCorig(1),'\Aorig',A1orig(1));
str_leg={};
 for i=1:size(leg,1)
     str_leg{i,1}=leg(i,:);
 end
rowlabels=regexprep(str_leg, '#', '\\#');
confini=cell2mat(Cal.brw_config_files(Cal.n_inst,1)); confend=cell2mat(Cal.brw_config_files(Cal.n_inst,2));
columnlabels={sprintf('%s %c%s%c','Initial','(',confini(end-11:end),')'),...
              sprintf('%s %c%s%c','Final','(',confend(end-11:end),')')};
matrix2latex_config([config_orig(2:end),config_def(2:end)],...
                     fullfile(Cal.file_latex,['table_config_',Cal.brw_str{Cal.n_inst},'.tex']),...
                                              'rowlabels',rowlabels(2:end),'columnlabels',columnlabels,...
                                              'size','footnotesize');
%%
 makeHtmlTable([config_orig,config_def],[],cellstr(leg),[Cal.brw_config_files(Cal.n_inst,1),Cal.brw_config_files(Cal.n_inst,2)])

%% DT analysis
 DT_analysis(Cal,ozone_raw0,config,'plot_flag',1);% ,'DTv',[38 41]

%%
% figure(findobj('tag','DT_comp'));
% set(get(gca,'title'),'FontSize',8);
% printfiles_report(gcf,Cal.dir_figs,'LockAxes',0,'Height',6);
%
% figure(findobj('tag','raw_counts_187')); title('Day 18711');
% set(findobj(gcf,'Tag','legend'),'FontSize',8);
% printfiles_report(gcf,Cal.dir_figs,'Width',8,'Height',6,'LockAxes',0);
%
% figure(findobj('tag','raw_counts_191')); title('Day 19111'); ylabel('');
% set(findobj(gcf,'Tag','legend'),'FontSize',8);
% printfiles_report(gcf,Cal.dir_figs,'Width',8,'Height',6,'LockAxes',0);
%
% close all
%
%% SL Report
close all;
for ii=[Cal.n_ref,Cal.n_inst]
    sl_mov_o{ii}={}; sl_median_o{ii}={}; sl_out_o{ii}={}; R6_o{ii}={};
    sl_mov_n{ii}={}; sl_median_n{ii}={}; sl_out_n{ii}={}; R6_n{ii}={};
    try
    if ii==Cal.n_inst
% old instrumental constants
      [sl_mov_o{ii},sl_median_o{ii},sl_out_o{ii},R6_o{ii}]=sl_report_jday(ii,sl,Cal.brw_str,...
                               'date_range',datenum(Cal.Date.cal_year,3,1),...
                               'outlier_flag',0,'hgflag',1,'fplot',1);
      fprintf('%s Old constants: %5.0f +/-%5.1f\n',Cal.brw_name{ii},...
                  nanmedian(R6_o{ii}(diajul(R6_o{ii}(:,1))>=Cal.calibration_days{ii,3}(1),2)),...
                  nanstd(   R6_o{ii}(diajul(R6_o{ii}(:,1))>=Cal.calibration_days{ii,3}(1),2)));
% new instrumental constants
      [sl_mov_n{ii},sl_median_n{ii},sl_out_n{ii},R6_n{ii}]=sl_report_jday(ii,sl_cr,Cal.brw_str,...
                               'date_range',datenum(Cal.Date.cal_year,3,1),...
                               'outlier_flag',0,'hgflag',1,'fplot',0);
      fprintf('%s New constants: %5.0f +/-%5.1f\n',Cal.brw_name{ii},...
                  nanmedian(R6_n{ii}(diajul(R6_n{ii}(:,1))>=Cal.calibration_days{ii,3}(1),2)),...
                  nanstd(   R6_n{ii}(diajul(R6_n{ii}(:,1))>=Cal.calibration_days{ii,3}(1),2)));
    else
      [sl_mov_n{ii},sl_median_n{ii},sl_out_n{ii},R6_n{ii}]=sl_report_jday(ii,sl_cr,Cal.brw_str,...
                               'date_range',datenum(Cal.Date.cal_year,3,1),...
                               'outlier_flag',0,'fplot',0);
    end
    catch exception
          fprintf('%s, brewer: %s\n',exception.message,Cal.brw_str{ii});
    end
end
% anadimos el sl
save(Cal.file_save,'-APPEND','sl_mov_o','sl_median_o','sl_out_o','R6_o',...
                             'sl_mov_n','sl_median_n','sl_out_n','R6_n');

sl_report{Cal.n_inst}.sl_mov_n=sl_mov_n{Cal.n_inst};         sl_report{Cal.n_inst}.sl_mov_o=sl_mov_o{Cal.n_inst};
sl_report{Cal.n_inst}.sl_median_n=sl_median_n{Cal.n_inst};   sl_report{Cal.n_inst}.sl_median_o=sl_median_o{Cal.n_inst};
sl_report{Cal.n_inst}.sl_out_n=sl_out_n{Cal.n_inst};         sl_report{Cal.n_inst}.sl_out_o=sl_out_o{Cal.n_inst};
sl_report{Cal.n_inst}.R6_n{Cal.n_inst}=R6_n{Cal.n_inst};     sl_report{Cal.n_inst}.R6_o{Cal.n_inst}=R6_o{Cal.n_inst};
save(Cal.file_save,'-APPEND','sl_report');

%% SL report plot
ix=sort(findobj('-regexp','Tag','SL_R\w+'));
if length(ix)>2
   for i=ix, set( findobj(i,'Tag','legend'),'FontSize',8); end
   set(ix(1),'tag','SL_R6_report_old'); set(ix(2),'tag','SL_R5_report_old');
   Width=8; Height=6;
else
   Width=12; Height=6.5;
end
printfiles_report(ix',Cal.dir_figs,'Width',Width,'Height',Height);

figure(max(findobj('tag','SL_I5_report')));
printfiles_report(gcf,Cal.dir_figs,'LockAxes',0,'no_export');

close all

%% Hg Report
hg_report(Cal.n_inst,hg,Cal,'outlier_flag',1,'date_range',[]);

%% READ Configuration
close all
[A,ETC,SL_B,SL_R,F_corr,cfg]=read_cal_config_new(config,Cal,{sl_median_o,sl_median_n});

try
 tabla_sl=printmatrix([Cal.brw(:)';ETC.old;ETC.new;A.old;A.new;Cal.SL_OLD_REF';Cal.SL_NEW_REF';fix(SL_B)']',4);
 cell2csv(fullfile(Cal.file_latex,'tabla_config.csv'),tabla_sl',';');
catch
  l=lasterror;
  disp(l.message)
  disp('tabla de configuracion posiblemente incompleta')
end

%matrix2latex(round(10000*[Cal.brw(:)';ETC.old;ETC.new;A.old;A.new;Cal.SL_OLD_REF';Cal.SL_NEW_REF';fix(SL_B)']')/10000,...
%    fullfile(Cal.file_latex,['table_SL_',Cal.brw_str{Cal.n_inst},'.tex']));

%%
%makeHtmlTable(round(10000*[Cal.brw;ETC.old;ETC.new;A.old;A.new;SL_OLD_REF';SL_NEW_REF';fix(SL_B)']')/10000);

%% Data recalculation for summaries  and individual observations
for i=[Cal.n_inst Cal.n_ref]
    cal{i}={}; summary{i}={}; summary_old{i}={};
    if i==Cal.n_inst
    [cal{i},summary{i},summary_old{i}]=test_recalculation(Cal,i,ozone_ds,A,SL_R,SL_B,'flag_sl',1);
    else
    [cal{i},summary{i},summary_old{i}]=test_recalculation(Cal,i,ozone_ds,A,SL_R,SL_B,'flag_sl',1);
    end
end

%id_out=find(summary{Cal.n_inst}(:,6)>400 | summary{Cal.n_inst}(:,6)<200);
%disp(unique(diaj(summary{Cal.n_inst}(id_out,1))));
%summary{Cal.n_inst}(id_out,:)=[];

summary_orig=summary;
summary_orig_old=summary_old;
save(Cal.file_save,'-APPEND','summary_old','summary_orig_old','summary','summary_orig');

%% Filter distribution
close all
ozone_filter_analysis_mi(summary,Cal);

%%
printfiles_report(findobj('Tag','FILTER_DISTRIBUTION'),Cal.dir_figs,'Width',13,'Height',7.5);
printfiles_report(findobj('Tag','Ozone_diff_filter_rel'),Cal.dir_figs,'Width',13,'Height',7.5);

close all

%% filter correction 185
% Si queremos eliminar algun filtro CORREGIR a NaN
for ii=[Cal.n_ref Cal.n_inst]
   [summary_old_corr summary_corr]=filter_corr(summary_orig,summary_orig_old,ii,A,F_corr{ii});
   summary_old{ii}=summary_old_corr; summary{ii}=summary_corr;
end
figure; plot(summary{Cal.n_inst}(:,1),summary{Cal.n_inst}(:,6),'r.',...
             summary{Cal.n_ref(1)}(:,1),summary{Cal.n_ref(1)}(:,6),'k.');%,...
%             summary{Cal.n_ref(2)}(:,1),summary{Cal.n_ref(2)}(:,6),'m.');
legend(gca,'inst','IZO#183','IZO#185','Location','NorthEast'); grid;
datetick('x',26,'KeepLimits','KeepTicks');

%% Ozone Calibration
% Reference Brewer #185
close all
n_ref=Cal.n_ref; % Cuidado con cual referencia estamos asignando
n_inst=Cal.n_inst;
brw=Cal.brw; brw_str=Cal.brw_str;

jday_ref=findm((diaj(summary{n_ref}(:,1))),Cal.calibration_days{n_ref,2},0.5);
ref2_b=summary{n_ref}(jday_ref,:);
jday_ref=findm((diaj(summary{n_ref}(:,1))),Cal.calibration_days{n_ref,3},0.5);
ref2=summary{n_ref}(jday_ref,:);

%% Blind Period
% etiquetamos con _b, porque eso sera lo que usamos para plotear los individuales, con la configuración sugerida
blinddays=Cal.calibration_days{Cal.n_inst,2};

if ~isequal(blinddays,Cal.calibration_days{Cal.n_inst,3})

   jday=findm(diaj(summary_old{Cal.n_inst}(:,1)),blinddays,0.5);
   inst1_b=summary_old{Cal.n_inst}(jday,:);

    [x,r,rp,ra,dat,ox,osc_smooth_ini]=ratio_min_ozone(...
       inst1_b(:,[1,6,3,2,8,9,4,5]),ref2_b(:,[1,6,3,2,8,9,4,5]),...
       5,brw_str{n_inst},brw_str{n_ref},'plot_flag',1);% original config
    [x,r,rp,ra,dat,ox,osc_smooth_inisl]=ratio_min_ozone(...
       inst1_b(:,[1,12,3,2,8,9,4,5]),ref2_b(:,[1,6,3,2,8,9,4,5]),...
       5,brw_str{n_inst},brw_str{n_ref},'plot_flag',0);% original config , sl corrected

% Sugerido con los blind_days
A1=A.old(ismember(Cal.Date.CALC_DAYS,blinddays),Cal.n_inst+1); A1_old=unique(A1(~isnan(A1)))
[ETC_SUG,o3c_SUG,m_etc_SUG]=ETC_calibration_C(Cal,summary_old,A1_old,...
                   Cal.n_inst,n_ref,5,.8,0.01,blinddays);
tableform({'ETCorig','ETCnew 1p','ETCnew 2p','O3Abs (ICF)','O3Abs 2p','O3Abs dsp'},...
          [round([ETC.old(n_inst),ETC_SUG(1).NEW,ETC_SUG(1).TP(1), 10000*A.old(n_inst),ETC_SUG(1).TP(2),10000*A.new(Cal.n_inst)])
%         solo el rango seleccionado
           round([ETC.old(n_inst),ETC_SUG(2).NEW,ETC_SUG(2).TP(1), 10000*A.old(n_inst),ETC_SUG(2).TP(2),10000*A.new(Cal.n_inst)])]);
%         todo el rango


% suggested
o3r= (inst1_b(:,8)-ETC_SUG(1).NEW)./(A1_old*inst1_b(:,3)*10);
inst1_b(:,10)=o3r;
    [x,r,rp,ra,dat,ox,osc_smooth_sug]=ratio_min_ozone(...
       inst1_b(:,[1,10,3,2,8,9,4,5]),ref2_b(:,[1,6,3,2,8,9,4,5]),...
       5,brw_str{n_inst},brw_str{n_ref},'plot_flag',0);
% si es suficiente la correccion por sl
% osc_smooth_sug=osc_smooth_inisl;

%%
figure(max(findobj('tag','CAL_2P_SCHIST')));
ax=findobj(gca,'type','text');
set(ax(2),'FontSize',9,'Backgroundcolor','w'); set(ax(3),'FontSize',9,'Backgroundcolor','w');
printfiles_report(gcf,Cal.dir_figs,'aux_pattern',{'sug'},'Width',14,'Height',8);

figure; set(gcf,'tag','RATIO_ERRORBAR');
h=plot_smooth(osc_smooth_ini,osc_smooth_inisl,osc_smooth_sug);
legend(h,'Config. orig','Config. orig, SL corrected','Suggested');
title([ brw_str{n_inst},' - ',brw_str{n_ref},' / ',brw_str{n_ref}]);
printfiles_report(gcf,Cal.dir_figs,'aux_pattern',{'sug'});

close all

%% Blind days table
% m_etc: [date, ref_new_slcorr, +sd, +n, ...
%        inst(6), +sd, inst(10), +sd, inst(6 sl corr), +sd, ...
%        inst(rcalibrated, ETC sug), +sd]
%
% Si no hay sugerida, sino que es la orig.SL corr., hacer
% m_etc=[m_etc_SUG(:,1:6),NaN*m_etc_SUG(:,1),m_etc_SUG(:,9:10)];
m_etc=[m_etc_SUG(:,1:6),NaN*m_etc_SUG(:,1),m_etc_SUG(:,11:12)];
m_etc(:,7)=100*(m_etc(:,5)-m_etc(:,2))./m_etc(:,2);
m_etc(:,10)=100*(m_etc(:,8)-m_etc(:,2))./m_etc(:,2);
M=cell(size(m_etc,1)+1,size(m_etc,2)+1);
label={'Date','Day',['O3\#',brw_str{n_ref}],'O3std','N',...
         ['O3\#',brw_str{n_inst}],'O3 std',...
         ['\%(',brw_str{n_inst},'-',brw_str{n_ref},')/',brw_str{n_ref}]...% old config
         ['O3(*)\#',brw_str{n_inst}],'O3std',...% new config., no SL corrected
         ['(*)\%(',brw_str{n_inst},'-',brw_str{n_ref},')/',brw_str{n_ref}]};
M(1,:)=label;
M(2:end,1)=cellstr(datestr(fix(m_etc(:,1))));
m_etc(:,1)=diaj(m_etc(:,1));
M(2:end,2:end)=num2cell(round(m_etc*10)/10);

disp(M);
matrix2latex_ctable(M(2:end,2:end),fullfile(Cal.file_latex,['table_ETCdatasug_',Cal.brw_str{Cal.n_inst},'.tex']),...
                                   'rowlabels',M(2:end,1),...
                                   'columnlabels',label(2:end),'alignment','c','resize',0.9);
else
    ETC_SUG(1).NEW=NaN; o3c_SUG=NaN;  osc_smooth_sug=NaN*ones(1,7);
    osc_smooth_ini=NaN*ones(1,7);     osc_smooth_inisl=NaN*ones(1,7);
end

latexcmd(fullfile(Cal.file_latex,['cal_etc_',brw_str{n_inst}]),'\ETCblind',num2str(round(ETC_SUG(1).NEW)),...
             '\ETCSOblind',config_def(12),'\SOABSblind',config_def(10),'\OtresSOABSblind',config_def(9),...
             '\NobsCalblind',size(o3c_SUG,1));

etc{Cal.n_inst}.sug=ETC_SUG;
osc_smooth{Cal.n_inst}.ini=osc_smooth_ini; osc_smooth{Cal.n_inst}.ini_sl=osc_smooth_inisl;
osc_smooth{Cal.n_inst}.sug=osc_smooth_sug;

save(Cal.file_save,'-APPEND','etc');

%% Final Period
finaldays=Cal.calibration_days{Cal.n_inst,3};

jday=findm(diaj(summary_old{Cal.n_inst}(:,1)),finaldays,0.5);% quiero mostrar la primera config. con sl
inst1=summary_old{Cal.n_inst}(jday,:);
jday=findm(diaj(summary{Cal.n_inst}(:,1)),finaldays,0.5);% quiero mostrar la primera config. con sl
inst2=summary{Cal.n_inst}(jday,:);

    [x,r,rp,ra,dat,ox,osc_smooth_ini]=ratio_min_ozone(...
       inst1(:,[1,6,3,2,8,9,4,5]),ref2(:,[1,6,3,2,8,9,4,5]),...
       5,brw_str{n_inst},brw_str{n_ref},'plot_flag',1);% original config

if isequal(blinddays,Cal.calibration_days{Cal.n_inst,3})
   osc_smooth{Cal.n_inst}.ini=osc_smooth_ini;
   [x,r,rp,ra,dat,ox,osc_smooth_inisl]=ratio_min_ozone(...
   inst1(:,[1,12,3,2,8,9,4,5]),ref2(:,[1,6,3,2,8,9,4,5]),...
   5,brw_str{n_inst},brw_str{n_ref},'plot_flag',0);
   osc_smooth{Cal.n_inst}.ini_sl=osc_smooth_inisl;
end

%%
A1=A.new(ismember(Cal.Date.CALC_DAYS,finaldays),Cal.n_inst+1); A1_new=unique(A1(~isnan(A1)))
[ETC_NEW,o3c_NEW,m_etc_NEW]=ETC_calibration_C(Cal,summary,A1_new,Cal.n_inst,n_ref,...
                                                                5,0.8,0.03,finaldays);
tableform({'ETCorig','ETCnew 1p','ETCnew 2p','O3Abs (ICF)','O3Abs 2p','O3Abs dsp'},...
          [round([ETC.old(n_inst),ETC_NEW(1).NEW,ETC_NEW(1).TP(1), 10000*A.old(n_inst),ETC_NEW(1).TP(2),10000*A.new(Cal.n_inst)])
%         solo el rango seleccionado
           round([ETC.old(n_inst),ETC_NEW(2).NEW,ETC_NEW(2).TP(1), 10000*A.old(n_inst),ETC_NEW(2).TP(2),10000*A.new(Cal.n_inst)])]);
%         todo el rango
latexcmd(fullfile(['>',Cal.file_latex],['cal_etc_',brw_str{n_inst}]),'\ETCfin',num2str(round(ETC_NEW(1).NEW)),...
    '\ETCSOfin',config_def(12),'\SOABSfin',config_def(10),'\OtresSOABSfin',config_def(9),...
    '\NobsCalfin',size(o3c_NEW,1));
etc{Cal.n_inst}.new=ETC_NEW;
save(Cal.file_save,'-APPEND','etc');
%%
o3r= (inst2(:,8)-ETC_NEW(1).NEW)./(A1_new*inst2(:,3)*10);
inst2(:,10)=o3r;
    [x,r,rp,ra,dat,ox,osc_smooth_fin]=ratio_min_ozone(...
       inst2(:,[1,10,3,2,8,9,4,5]),ref2(:,[1,6,3,2,8,9,4,5]),...
       5,brw_str{n_inst},brw_str{n_ref},'plot_flag',0);
%     [x,r,rp,ra,dat,ox,osc_smooth_fin]=ratio_min_ozone(...
%        inst2(:,[1,6,3,2,8,9,4,5]),ref2(:,[1,6,3,2,8,9,4,5]),...
%        5,brw_str{Cal.n_inst},brw_str{n_ref},'plot_flag',0);

%%
% o3r= (inst2(:,8)-ETC_NEW(1).TP(1))./(ETC_NEW(1).TP(2)/10000*inst2(:,3)*10);
% inst2(:,10)=o3r;
%     [x,r,rp,ra,dat,ox,osc_smooth_2P]=ratio_min_ozone(...
%        inst2(:,[1,10,3,2,8,9,4,5]),ref2(:,[1,6,3,2,8,9,4,5]),...
%        5,brw_str{n_inst},brw_str{n_ref},'plot_flag',0);

osc_smooth{Cal.n_inst}.fin=osc_smooth_fin;
% osc_smooth{Cal.n_inst}.twoP=osc_smooth_2P;
save(Cal.file_save,'-APPEND','osc_smooth');

%%
figure(max(findobj('tag','CAL_2P_SCHIST')));
ax=findobj(gca,'type','text');
set(ax(2),'FontSize',9,'Backgroundcolor','w'); set(ax(3),'FontSize',9,'Backgroundcolor','w');
printfiles_report(gcf,Cal.dir_figs,'aux_pattern',{'fin'},'Width',14,'Height',8);

figure(max(findobj('tag','RATIO_ERRORBAR')));
printfiles_report(gcf,Cal.dir_figs,'aux_pattern',{'fin'});

close all

%% Final days table
% m_etc_(lo que sea) son los datos filtrados por Tsync, OSC y sza !!! -> salida de ETC_calibration
% En ste caso se usa summary, así que la configuración original será 10, y la final 6
m_etc=[m_etc_NEW(:,[1:4 7:8]),NaN*m_etc_NEW(:,1),m_etc_NEW(:,5:6)];
m_etc(:,7)=100*(m_etc(:,5)-m_etc(:,2))./m_etc(:,2);
m_etc(:,10)=100*(m_etc(:,8)-m_etc(:,2))./m_etc(:,2);
% La diferencia relativa anterior se refiere al ozono recalculado con la ETC que resulta de los cálculos
% Esto podría ser una incoherencia: por ejemplo para el 072 sale 3179, pero mantenemos 3185.

%m_etc(:,[end-1,end])=[];
M=cell(size(m_etc,1)+1,size(m_etc,2)+1);
label={'Date','Day',['O3\#',brw_str{n_ref}],'O3std','N',...
         ['O3\#',brw_str{n_inst}],'O3 std',...
         ['\%(',brw_str{n_inst},'-',brw_str{n_ref},')/',brw_str{n_ref}]...
         ['O3(*)\#',brw_str{n_inst}],'O3std',...
         ['(*)\%(',brw_str{n_inst},'-',brw_str{n_ref},')/',brw_str{n_ref}]};
M(1,:)=label;
M(2:end,1)=cellstr(datestr(fix(m_etc(:,1))));
m_etc(:,1)=diaj(m_etc(:,1));
M(2:end,2:end)=num2cell(round(m_etc*10)/10);

disp(M);
matrix2latex_ctable(M(2:end,2:end),fullfile(Cal.file_latex,['table_ETCdatafin_',Cal.brw_str{Cal.n_inst},'.tex']),...
                                   'rowlabels',M(2:end,1),...
                                   'columnlabels',label(2:end),'alignment','c','resize',0.9)

% So2 calibration from icf file
% Pendiente
% latexcmd(['>',file_latex,'_etc_',brw_str{n_inst}],'\ETCSOdos',config_def(12),'\SOdosABS',config_def(10),'\OtresSOdosABS',config_def(9));

%% Summary  Final Comparison all data detailed for osc ranges
TIME_SYNC=5;
blinddays=Cal.calibration_days{Cal.n_inst,2};
finaldays=Cal.calibration_days{Cal.n_inst,3};

jday=findm(diaj(diaj(summary{n_inst}(:,1))),blinddays,0.5); inst1_b=summary_old{n_inst}(jday,:);
o3r= (inst1_b(:,8)-ETC_SUG(1).NEW)./(A.old(Cal.n_inst)*inst1_b(:,3)*10);
inst1_b(:,10)=o3r;
% En este caso nos interesa la correción por SL, así que hacemos
% inst1_b(:,10)=inst1_b(:,12);
jday=findm(diaj(diaj(summary{n_inst}(:,1))),finaldays,0.5); inst2=summary{n_inst}(jday,:);
inst2=inst2(:,[1:5 10 11 8 9 6 7 12:13]);% queremos comparar con la configuración inicial

jday=findm(diaj(diaj(summary{n_ref}(:,1))),blinddays,0.5); ref_b=summary{n_ref}(jday,:);
jday=findm(diaj(diaj(summary{n_ref}(:,1))),finaldays,0.5); ref2=summary{n_ref}(jday,:);

inst=cat(1,inst1_b,inst2); ref=cat(1,ref_b,ref2);
[aa,bb]=findm_min(ref(:,1),inst(:,1),TIME_SYNC/24/60);
o3_c=[ref(aa,1),ref(aa,1)-inst(bb,1),ref(aa,2:end),inst(bb,2:end)];

% por rangos de osc
aux=NaN*ones(size(o3_c,1),size(o3_c,2)+2);
aux(:,1:end-2)=o3_c; aux(:,end-1)=o3_c(:,16).*o3_c(:,19);% osc_ref
tags_={'osc$>$1500' '1500$>$osc$>$1000' '1000$>$osc$>$700' '700$>$osc$>$400' 'osc$<$400'};
aux(find(aux(:,end-1)<400),end)=5; aux(find(aux(:,end-1)>=400 & aux(:,end-1)<700),end)=4;
aux(find(aux(:,end-1)>=700 & aux(:,end-1)<1000),end)=3;
aux(find(aux(:,end-1)>=1000 & aux(:,end-1)<1500),end)=2; aux(find(aux(:,end-1)>=1500),end)=1;

% o3_c: 1=date; 7=O3_new_ref;           19=O3_old_inst (siempre)
%              13=O3_new_ref SL corr.;  23=O3_final_inst (sug o sl corr. en el caso de blinddays)
[m_osc,s_osc,n_osc]=grpstats([o3_c(:,[1,13,19,23]) aux(:,end-1:end)],...
                     {diaj(aux(:,1)),aux(:,end)},{'mean','std','numel'});
ozone_osc_sum=round([diaj(m_osc(:,1)),m_osc(:,2),s_osc(:,2),n_osc(:,2),...
                     m_osc(:,3),s_osc(:,3),100*(m_osc(:,3)-m_osc(:,2))./m_osc(:,2),...
                     m_osc(:,4),s_osc(:,4),100*(m_osc(:,4)-m_osc(:,2))./m_osc(:,2),m_osc(:,end)]*10)/10;

label_={'Day','osc range',['O3\#',brw_str{n_ref}],'O3std','N',...
                          ['O3\#',brw_str{n_inst}],'O3 std',...
                          ['\%(',brw_str{n_inst},'-',brw_str{n_ref},')/',brw_str{n_ref}],...
                          ['(*)O3\#',brw_str{n_inst}],'O3 std',...
                          ['(*)\%(',brw_str{n_inst},'-',brw_str{n_ref},')/',brw_str{n_ref}]};

dat=cat(2,num2cell(ozone_osc_sum(:,1)),tags_(ozone_osc_sum(:,end))',num2cell(ozone_osc_sum(:,2:end-1)));


disp(cat(1,label_,dat));
matrix2latex_ctable(dat,fullfile(Cal.file_latex,['table_summarydetailed_',brw_str{n_inst},'.tex']),...
                                  'columnlabels',label_,...
                                  'alignment','c','resize',0.9);

%%
% si queremos usar la corrección por SL sustituir 19 por 25
[m,s,n,grpn]=grpstats(o3_c(:,[1,13,23]),{diaj(o3_c(:,1))},{'mean','std','numel','gname'});
ozone_day_sum=round([diaj(m(:,1)),m(:,2),s(:,2),n(:,2),m(:,3),s(:,3),100*(m(:,3)-m(:,2))./m(:,2)]*10)/10;% m(:,4),100*(m(:,4)-m(:,2))./m(:,2)
% disp(ozone_day_sum);

 makeHtmlTable(ozone_day_sum,[],cellstr(datestr(ozone_day_sum(:,1)+datenum(Cal.Date.cal_year,1,0))),...
     {'Day',['O3 #',brw_str{n_ref}],'O3 std','N obs',['O3 #',brw_str{n_inst}],'O3 std',[' % ',brw_str{n_ref},'-',brw_str{n_inst},'/',brw_str{n_ref}]})

%% Plot daily summary
close all
figure; set(gcf,'Tag','_GlobalPlot_');
plot(summary{n_ref}(:,1),summary{n_ref}(:,6),'g*','MarkerSize',5);
hold on; plot(summary{Cal.n_inst}(:,1),summary{Cal.n_inst}(:,6),'b.','MarkerSize',12);
legend(gca,Cal.brw_name{n_ref},Cal.brw_name{Cal.n_inst},'Location','Best',...
                                                               'Orientation','Horizontal');
ylabel('Total Ozone (DU)'); xlabel('Date'); grid;
title(Cal.campaign);
datetick('x',6,'keepLimits','KeepTicks');

% blind days: suggested config.
if ~isequal(blinddays,Cal.calibration_days{Cal.n_inst,3})
   inst1_b      =summary_old{Cal.n_inst}(findm(diaj(summary_old{Cal.n_inst}(:,1)),blinddays,0.5),:);
   inst1_b(:,10)=(inst1_b(:,8)-ETC_SUG(1).NEW)./(A1_old*inst1_b(:,3)*10);     
   for dd=1:length(blinddays)
      j=find(diajul(floor(inst1_b(:,1)))==blinddays(dd));
      j_=find(diajul(floor(ref2_b(:,1)))==blinddays(dd));
      if (isempty(j) || length(j)<4), continue; end
         f=figure; set(f,'Tag',sprintf('%s%s','DayPlot_',num2str(blinddays(dd))));
         plot(ref2_b(j_,1),ref2_b(j_,6),'g-s','MarkerSize',6,'MarkerFaceColor','g');
         hold on; plot(inst1_b(j,1),inst1_b(j,10),'b-d','MarkerSize',7,'MarkerFaceColor','b');
         plot(inst1_b(j,1),inst1_b(j,6),'r:.','MarkerSize',9);
         title(sprintf('Suggested configuration \n  Blind day %d%d',blinddays(dd), Cal.Date.cal_year-2000))
         legend(gca,Cal.brw_name{n_ref},Cal.brw_name{Cal.n_inst},[Cal.brw_name{Cal.n_inst} ' old config.'],'Location','SouthEast',...
                                                               'Orientation','Horizontal');
         ylabel('Total Ozone (DU)'); grid;
         datetick('x',15,'keepLimits','KeepTicks');
         set(gca,'YLim',[min(inst1_b(j,10))-8 max(inst1_b(j,10))+8])
   end
end

% final days: final config.
jday=findm(diaj(summary{Cal.n_inst}(:,1)),finaldays,0.5);% quiero mostrar la primera config. con sl
inst2=summary{Cal.n_inst}(jday,:);
for dd=1:length(finaldays)
j=find(diajul(floor(inst2(:,1)))==finaldays(dd));
j_=find(diajul(floor(ref2(:,1)))==finaldays(dd));
if (isempty(j) || length(j)<4), continue; end
f=figure; set(f,'Tag',sprintf('%s%s','DayPlot_',num2str(finaldays(dd))));
plot(ref2(j_,1),ref2(j_,6),'g-s','MarkerSize',6,'MarkerFaceColor','g');
hold on; plot(inst2(j,1),inst2(j,10),'b--d','MarkerSize',7,'MarkerFaceColor','b');
         plot(inst2(j,1),inst2(j,6),'r:.','MarkerSize',9);
title(sprintf('Final configuration \nFinal day %d%02d',finaldays(dd), Cal.Date.cal_year-2000))
legend(gca,Cal.brw_name{n_ref},Cal.brw_name{Cal.n_inst},[Cal.brw_name{Cal.n_inst} ' old config.'],...
                                                      'Location','SouthEast','Orientation','Horizontal');
ylabel('Total Ozone (DU)'); grid;
datetick('x',15,'keepLimits','KeepTicks');
set(gca,'YLim',[min(inst2(j,10))-8 max(inst2(j,10))+8])
end

figure(max(findobj('tag','_GlobalPlot_')));
printfiles_report(gcf,Cal.dir_figs,'Height',7,'Width',13);

printfiles_report(min(findobj('-regexp','Tag','^DayPlot_')):max(findobj('-regexp','Tag','^DayPlot_')),...
                              Cal.dir_figs,'Width',14.5,'Height',7.5);
graph2latex(Cal.file_latex,{'summaryplot','DayPlot_'},brw_str{n_inst},'scale',0.8);

%% detailed comparison
% %save detailed_comparison o3_c
% %load detailed_comparison
% head='Date_matlab date_dif sza_R airm_R temp_R filter_R O3_R sO3_R ms9 sm9 O3_R_o SO3_R_o O3_R_sl sO3_R_sl I_sza I_airm I_temp I_filter O3_I sO3_I ms9_I sm9_I O3_I_o sO3_I_o O3_I_sl sO3_I_sl';
% [o3,i,j]=unique(o3_c(:,1));
% label_detailed=mmcellstr(strtrim(strrep(head,' ','|')));
% columns_detailed_report=[1:8,21,19,23];
% aux=[cellstr(datestr(o3_c(i,1))),num2cell(o3_c(i,columns_detailed_report))];
% head_end={'date.hour','diff (min)','sza ','airm','MS9','O3ref'};
% summary_end=[diaj2(o3_c(i,1)),fix(o3_c(i,2)*24*60),o3_c(i,15),o3_c(i,16),round(o3_c(i,21)),round(o3_c(i,7)*10)/10];
% matrix2latex_config(summary_end,fullfile(Cal.file_latex,['table_summary_end_',Cal.brw_str{Cal.n_inst},'.tex']),...
%                                   'columnlabels',head_end,...
%                                   'alignment','c');
%
% % if ispc
% % xlswrite_(aux,'',['Date';label_detailed(columns_detailed_report)],'detailed_report.xls');
% % else
% %  head1=cellstr(['Date';label_detailed(columns_detailed_report)]');
% %  cell2csv(['comparison_report_',brw_str{n_inst},'.csv'],[head1;aux],',');
% %  % Todo linux outpit
% % end
%
% % %% configration files
% % head2=[cellstr(leg),num2cell(config_def),num2cell(config_orig),num2cell(config_ref)]';
% % head2{2}='Final ICF';
% % head2{3}='Original ICF';
% % head2{4}='Reference ICF';
% % if ispc
% %   xlswrite_(head2','','','config_report.xls');
% % else
% %   cell2csv(['config_report_',brw_str{n_inst},'.csv'],head2',',');
% % end
%
% %%
% %makeHtmlTable(head2,[]);
%   % 'Date, Diff(min), REF
%
% %close all;
%
% %% Stray light
% [ETC_NEW_ST,o3c,m_etc]=ETC_calibration_C(Cal,summary,A.new(Cal.n_inst),Cal.n_inst,Cal.n_ref(2),7,0.8,0.03,[]);
%
% %%
% figure;
% ms9=o3c(:,21);
% o3p=o3c(:,13).*o3c(:,16)*ETC_NEW_ST(1).TP(2); %airmas from instrument
% ozone_slant=o3c(:,13).*o3c(:,16)/1000; %air mass from instrument
% ozone_scale=fix(ozone_slant/.1)*.1;
% o3rc=(ms9-ETC_NEW_ST(1).TP(1))./(ETC_NEW_ST(1).TP(2)/1000*o3c(:,16));
% y=100*(o3rc-o3c(:,13))./o3c(:,13);
%
%
% %%
%
% [m,s,n,name,v,ci]=grpstats(ms9-o3p,ozone_scale,{'mean','std','numel','gname','var','meanci'});
% x=unique(ozone_scale);
% errorbar(x,m,x-s,x+s); hold on;
% [r,gof,c]=fit(x,m,'power2','Robust','on');
%          plot(ozone_slant,ms9-o3p,'.')
%          plot(r,'r.');
%
%          R=coeffvalues(r);
%
%          hline(R(3),'r',num2str(R(3)));
%          hline(ETC_NEW(1).NEW,'g',num2str(ETC_NEW(1).NEW));
%          title({formula(r),num2str(coeffvalues(r))});
%          suptitle(brw_str(n_inst));
%
%  %% cuadratic
%  figure;
%  f=fittype('a+b*x^2');
%  [r,gof,c]=fit(x,m,f,'Robust','on');
%  plot(ozone_slant,ms9-o3p,'.');hold on;
%  plot(r,'r.');
%  R=coeffvalues(r);
%  hline(ETC_NEW(1).NEW,'g',num2str(ETC_NEW(1).NEW));
%
% title({formula(r),num2str(coeffvalues(r))});
%
%
