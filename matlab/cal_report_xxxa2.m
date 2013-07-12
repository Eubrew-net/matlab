% options_pub.outputDir=fullfile(pwd,'latex','xxx','html'); options_pub.showCode=true;
% publish(fullfile(pwd,'cal_report_xxxa2.m'),options_pub);

%% Brewer Setup
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

%% configuration files
close all;

[config_def,TCdef,DTdef,ETCdef,A1def,ATdef]=read_icf(Cal.brw_config_files{Cal.n_inst,2});
[config_orig,TCorig,DTorig,ETCorig,A1orig,ATorig]=read_icf(Cal.brw_config_files{Cal.n_inst,1});

config_temp.n_inst=Cal.n_inst;
config_temp.brw_name=Cal.brw_name{Cal.n_inst};
config_temp.final_days=Cal.Date.FINAL_DAYS(1);

NTC={}; tabla_regress={}; ajuste={}; Args={};

%% Temperature dependence.  During campaign
[sl_rw,tc]=readb_sl_rawl(['.\bfiles','\B*.',Cal.brw_str{Cal.n_inst}]);% cambio nombres para poder seguir

[NTC{1},ajuste{1},Args{1},Fr]=temp_coeff_raw(config_temp,sl_rw,'outlier_flag',0,...
                                     'date_range',datenum(Cal.Date.cal_year,1,Cal.calibration_days{Cal.n_inst,1}([1 end])));

disp(sprintf(' ORIG MS9: %5.0f +/-%2.0f  %3.1f +/- %3.2f  ',ajuste{1}.orig(7,[1 3 2 4])));
disp(sprintf('  NEW MS9: %5.0f +/-%2.0f  %3.1f +/- %3.2f  ',ajuste{1}.new(7,[1 3 2 4])));

%%
 makeHtmlTable([ajuste{1}.cero(:,[1 3]) ajuste{1}.cero(:,[2 4])],[],...
        {'slit#2','slit#3','slit#4','slit#5','slit#6','R5','R6'},{'a','a SE','b','b SE'},[],4);

%%
 makeHtmlTable(NTC{1});

%% Check previous results
if exist('sl_raw','var')
    if iscell(sl_raw) && size(sl_raw,2)>=Cal.n_inst
        if isempty(sl_raw{Cal.n_inst})
           [sl_raw{Cal.n_inst},TC{Cal.n_inst}]=readb_sl_rawl(['.\bdata',Cal.brw_str{Cal.n_inst},...
                                                              '\B*.'   ,Cal.brw_str{Cal.n_inst}],'f_plot',1);
           save(Cal.file_save,'-APPEND','sl_raw','TC');
        end
    else
        [sl_raw{Cal.n_inst},TC{Cal.n_inst}]=readb_sl_rawl(['.\bdata',Cal.brw_str{Cal.n_inst},...
                                                           '\B*.'   ,Cal.brw_str{Cal.n_inst}],'f_plot',1);
        save(Cal.file_save,'-APPEND','sl_raw','TC');
    end
else
    [sl_raw{Cal.n_inst},TC{Cal.n_inst}]=readb_sl_rawl(['.\bdata',Cal.brw_str{Cal.n_inst},...
                                                       '\B*.'   ,Cal.brw_str{Cal.n_inst}],'f_plot',1);
    save(Cal.file_save,'-APPEND','sl_raw','TC');
end

%% SL summary from bfiles temperature
figure; set(gcf,'Tag','DailySL');
hl1=ploterr(TC{Cal.n_inst}(1,:),TC{Cal.n_inst}(2,:),[],TC{Cal.n_inst}(3,:),'*k');
set(hl1,'LineWidth',2);
ylabel('SL double ratio MS9');
title(sprintf('Daily means for sl ozone ratio & temperature. Brewer %s\r\n (from bfile sl summaries)',Cal.brw_name{Cal.n_inst}));
set(gca,'XTickLabels',datestr(get(gca,'XTick'),2));  grid;
ax(1)=gca; set(ax(1),'Position',[0.1  0.12  0.75  0.72]);% [left bottom width height]
rotateticklabel(gca,30);
ax(2)=axes('Position',get(ax(1),'Position'),...
   'XAxisLocation','top',...
   'YAxisLocation','right',...
   'Color','none','FontSize',10,...
   'XColor','k','YColor','b'); set(ax,'box','off');
hold on; hl2=ploterr(TC{Cal.n_inst}(1,:),TC{Cal.n_inst}(7,:),[],TC{Cal.n_inst}(8,:),'*b');
set(hl2,'LineWidth',2);  set(gca,'XTicklabels',[],'YLim',[0 45]);
ylb=ylabel('Temperature','Rotation',-90); pos=get(ylb,'Position'); pos(1)=pos(1)+3;
set(ylb,'Position',pos);

[NTC{2},ajuste{2},Args{2},Fraw,Fnew]=temp_coeff_raw(config_temp,sl_raw{Cal.n_inst},'outlier_flag',1,...
                                  'date_range',datenum(Cal.Date.cal_year,1,[1,Cal.calibration_days{Cal.n_inst,1}(1)]));
% figure(max(findobj('Tag','TEMP_OLD_VS_NEW'))); set(gca,'YLim',[1750 1920]);

disp(sprintf(' ORIG MS9: %5.0f +/-%2.0f  %3.1f +/- %3.2f  ',ajuste{2}.orig(7,[1 3 2 4])));
disp(sprintf('  NEW MS9: %5.0f +/-%2.0f  %3.1f +/- %3.2f  ',ajuste{2}.new(7,[1 3 2 4])));

 %%
 makeHtmlTable([ajuste{2}.cero(:,[1 3]) ajuste{2}.cero(:,[2 4])],[],...
        {'slit#2','slit#3','slit#4','slit#5','slit#6','R5','R6'},{'a','a SE','b','b SE'},[],4);

%%
 makeHtmlTable(NTC{2});

%%  Check changes
[NTCx,ajustex,Argsx,Fraw,Forig]=temp_coeff_raw(config_temp,sl_raw{Cal.n_inst},'outlier_flag',1,'plots',0,...
                                'N_TC',TCorig(1:5)','date_range',datenum(Cal.Date.cal_year,1,[1,Cal.calibration_days{Cal.n_inst,1}(1)]));

Forigx=Forig; Fn=Fnew;
figure; set(gcf,'Tag','TEMP_COMP_DATE')
[mn,sn]=grpstats(Forigx(:,[1,end]),{year(Forigx(:,1)),fix(Forigx(:,1))},{'mean','sem'});
[mt,st]=grpstats(Fn(:,[1,end]),{year(Fn(:,1)),fix(Fn(:,1))},{'mean','sem'});
errorbar(mn(:,1),mn(:,2),sn(:,2),'Color','k','Marker','s');
hold on
errorbar(mt(:,1),mt(:,2),st(:,2),'Color','g','Marker','s');
datetick('x','KeepTicks','KeepLimits'); grid on; ylabel('Standard Lamp R6 ratio');
legend('Old temperature coeff','New temperature coeff');
title(['R6 Temperature dependence Brewer#', Cal.brw_str{Cal.n_inst}]);

figure; set(gcf,'Tag','TEMP_COMP_TEMP')
[mn,sn]=grpstats(Forigx(:,[2,end]),Forigx(:,2),{'mean','sem'});
[mt,st]=grpstats(Fn(:,[2,end]),Fn(:,2),{'mean','sem'});
errorbar(mn(:,1),mn(:,2),sn(:,2),'Color','k','Marker','s');
hold on
errorbar(mt(:,1),mt(:,2),st(:,2),'Color','g','Marker','s'); grid;
legend('Old temperature coeff','New temperature coeff');
title(['R6 Temperature dependence Brewer#', Cal.brw_str{Cal.n_inst}]);
ylabel('Standard Lamp R6 ratio'); xlabel('Temperature');

%%
% ix=sort(findobj('tag','TEMP_COEF_DESC'));
% printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'Width',15,'Height',7,'LockAxes',0,'no_export');

% ix=sort(findobj('tag','TEMP_day_new'));
% printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'Width',14,'Height',9,'LockAxes',0,'no_export');

ix=sort(findobj('tag','TEMP_OLD_VS_NEW'));
printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'Width',12.5,'Height',6.5);

ix=sort(findobj('tag','TEMP_COMP_DATE'));
printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'Width',12.5,'Height',6.5);

ix=sort(findobj('tag','TEMP_COMP_TEMP'));
printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'Width',12.5,'Height',6.5);

close all

%% Latex stuff

% Temperature Range
% Para que funcione asignamos la salida Fr en la llamada a la función
% temp_coeff_raw donde se calculen los TC's (en este caso en {})
tmp=Fr(:,2);
latexcmd(fullfile(Cal.file_latex,['cal_tempcoeff_',Cal.brw_str{Cal.n_inst}]),...
                                  '\tempmin',min(tmp),'\tempmax',max(tmp));
clear tmp;
temperature{Cal.n_inst}.sl_raw=sl_raw{Cal.n_inst};
temperature{Cal.n_inst}.NTC=NTC;
temperature{Cal.n_inst}.ajuste=ajuste;
if exist('Args','var')
temperature{Cal.n_inst}.info=Args;
else warning('No se están guardando los inputs de la función!!')
end
save(Cal.file_save,'-APPEND','temperature');

% Tables
tc_table={};
 for t=1:length(NTC)
    tc_table{t}=[round(config_orig(2:6)'*10^4)/10^4                             %'Current'
                       NTC{1}                                                   %'Calculated'
                 round(config_def(2:6)'*10^4)/10^4];                            %'Final'

    if t==1, t=[]; indx=1;  else t=t-1; indx=indx+1;  end
       matrix2latex_ctable(tc_table{indx},...
                     fullfile(Cal.file_latex,['table_TC',num2str(t),'_',Cal.brw_str{Cal.n_inst},'.tex']),...
                    'RowLabels',{'Current','Calculated','Final'},...
                    'ColumnLabels',{'slit\#2','slit\#3','slit\#4','slit\#5','slit\#6'},...
                    'alignment', 'c','resize',0.8,'format','%7.4f','size','footnotesize');
 end

tabla_regress={};
 for tt=1:length(ajuste)

     param=ajuste{tt};
     if isstruct(param)
         param=param.new;
     end
     absc=mmcellstr(sprintf('%g +/- %g |',round(param([1:5 7],[1,3]))'));
     slpe=mmcellstr(sprintf('%3.1f +/- %3.2f |',param([1:5 7],[2,4])'));
     tabla_regress{tt}=cat(2,absc,slpe);

     if tt==1, tt=[]; indx=1;  else tt=tt-1; indx=indx+1;  end
        matrix2latex_ctable(tabla_regress{indx},...
                fullfile(Cal.file_latex,['table_regress',num2str(tt),'_',Cal.brw_str{Cal.n_inst},'.tex']),...
               'RowLabels',{'slit\#2','slit\#3','slit\#4','slit\#5','slit\#6','MS9'},...
               'ColumnLabels',{'0 abscissa +/- standard error','slope +/- standard error'},...
               'alignment', 'c','resize',0.8,'size','footnotesize');
 end

%% Filter attenuation
[ETC_FILTER_CORRECTION,media_fi,fi,fi_avg]=filter_rep(Cal.brw_str{Cal.n_inst},...
                             'date_range',datenum(Cal.Date.cal_year,2,15),...
                             'outlier_flag',1,'plot_flag',0,'config',config_orig(17:22));
                             
filter{Cal.n_inst}.ETC_FILTER_CORRECTION=ETC_FILTER_CORRECTION;
filter{Cal.n_inst}.media_fi=media_fi;
filter{Cal.n_inst}.fi=fi;
filter{Cal.n_inst}.ETC_FILTER_COR=round(ETC_FILTER_CORRECTION(2,:).*(sign(ETC_FILTER_CORRECTION(3,:))==sign(ETC_FILTER_CORRECTION(4,:))));                       

save(Cal.file_save,'-APPEND','filter');

NFI=size(fi,1); 
NFIcamp=length(find(ismember(fi_avg(:,1),datenum(Cal.Date.cal_year,1,Cal.calibration_days{Cal.n_inst,1}))==1));
latexcmd(fullfile(Cal.file_latex,['cal_filter_',Cal.brw_str{Cal.n_inst}]),'\NFI',NFI,'\NFIcamp',NFIcamp);

label_2={'filter #1','filter #2','filter #3','filter #4','filter #5'};
ETC_FILTER_CORR2cell={};
for y=1:5
    ETC_FILTER_CORR2cell{1,y}=round(ETC_FILTER_CORRECTION(1,y)*10)/10;
    ETC_FILTER_CORR2cell{2,y}=round(ETC_FILTER_CORRECTION(2,y)*10)/10;
    ETC_FILTER_CORR2cell{3,y}=sprintf('%c%s %s%c','[',num2str(round(ETC_FILTER_CORRECTION(3,y)*10)/10),num2str(round(ETC_FILTER_CORRECTION(4,y)*10)/10),']');
end
disp(ETC_FILTER_CORR2cell);
matrix2latex_ctable(ETC_FILTER_CORR2cell,fullfile(Cal.file_latex,['table_filter_correction_',Cal.brw_str{Cal.n_inst},'.tex']),...
                     'rowLabels',{'ETC Filt. Corr. (median)','ETC Filt. Corr. (mean)','ETC Filt. Corr. (mean 95\% CI) '},...
                     'columnLabels',{'filter\#1','filter\#2','filter\#3','filter\#4','filter\#5'},...
                     'alignment', 'c','resize',0.8);
   
label_1={'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5','mean'};
label_2={'filter #1','filter #2','filter #3','filter #4','filter #5'};
% disp([num2cell(media_fi);num2cell(fix(mean(media_fi)))]);
matrix2latex_ctable([num2cell(media_fi);num2cell(fix(mean(media_fi)))],fullfile(Cal.file_latex,['table_filter_',Cal.brw_str{Cal.n_inst},'.tex']),...
                     'rowLabels',{'slit\#0','slit\#1','slit\#2','slit\#3','slit\#4','slit\#5','mean'},...
                     'columnLabels',{'filter\#1','filter\#2','filter\#3','filter\#4','filter\#5'},...
                     'alignment', 'c','resize',0.72);
                 
%%
 figure(max(findobj('tag','FI_wavelength')));
 printfiles_report(gcf,Cal.dir_figs,'Width',13.5);
    
 figure(max(findobj('tag','FI_STATS')));
 printfiles_report(gcf,Cal.dir_figs,'Width',13,'Height',16);
       
 ix=sort(findobj('-regexp','Tag','FIOS*\w+'));
 for ff=ix
     printfiles_report(ff',Cal.dir_figs,'Width',17,'Height',9);
 end

close all

%%
makeHtmlTable([fix(media_fi);fix(mean(media_fi))],[],label_1,label_2 );

%%
makeHtmlTable(ETC_FILTER_CORRECTION,[],{'ETC Filt. Corr. (median)','ETC Filt. Corr. (mean)','ETC Filt. Corr. (CI) ','ETC Filt. Corr.(CI)'},label_2 );
