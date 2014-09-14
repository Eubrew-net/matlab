% options_pub.outputDir=fullfile(pwd,'latex','xxx','html'); options_pub.showCode=true;
% publish(fullfile(pwd,'cal_report_xxxb.m'),options_pub);

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
catch exception
      fprintf('Error: %s\n Initializing data for Brewer %s\n',exception.message,Cal.brw_name{Cal.n_inst});
      save(Cal.file_save);
end

%% configuration files
close all
[config_def,TCdef,DTdef,ETCdef,A1def,ATdef]=read_icf(Cal.brw_config_files{Cal.n_inst,2});
[config_orig,TCorig,DTorig,ETCorig,A1orig,ATorig]=read_icf(Cal.brw_config_files{Cal.n_inst,1});

Station.OSC=680;
Station.name='';
Station.lat=67;
Station.long=50;
Station.meanozo=350;

cal_step={}; sc_avg={}; sc_raw={}; Args={};

%% Sun_scan: Before Campaign
close all
[cal_step{1},sc_avg{1},sc_raw{1},Args{1}]=sc_report(Cal.brw_str{Cal.n_inst},Cal.brw_config_files{Cal.n_inst,1},...
                     'date_range',datenum(Cal.Date.cal_year,1,[1 159]),...
                     'CSN_orig',config_orig(14),'OSC',Station.OSC,...
                     'control_flag',1,'residual_limit',35,...
                     'hg_time',15,'one_flag',0);

%% Sun_scan: Campaign
[cal_step{2},sc_avg{2},sc_raw{2},Args{2}]=sc_report(Cal.brw_str{Cal.n_inst},Cal.brw_config_files{Cal.n_inst,2},...
                     'date_range',datenum(Cal.Date.cal_year,1,Cal.calibration_days{Cal.n_inst,1}([1 end])),...
                     'CSN_orig',config_def(14),'OSC',Station.OSC,...
                     'control_flag',1,'residual_limit',15,...
                     'hg_time',5,'one_flag',1);

%%
ix=sort(findobj('tag','SC_INDIVIDUAL')); figure(ix); set(get(gca,'title'),'FontSize',8);
printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'FontSize',.9,'Width',8.5,'Height',7);

ix=sort(findobj('tag','Final_SC_Calculation'));
if length(ix)>1
    Width=8; Height=6;
    for i=1:length(ix), figure(ix(i)); set(get(gca,'title'),'FontSize',8); end
else
    Width=13; Height=8;
end
printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix,'Width',Width,'Height',Height);

close all

%% Definicion de variables: SC
if length(cal_step)>1
   d_p=[length(cal_step)-1 length(cal_step)];   tags={'','new'};
else
   d_p=1;   tags={'new'};
end

idx=1; cal_step_error={};
for t=d_p % Siempre el penúltimo y último procesados (si hay más de uno)
     cal_step_error{t}=round(mean([abs(cal_step{t}(1)-cal_step{t}(2)),abs(cal_step{t}(3)-cal_step{t}(1))]));
     latexcmd(fullfile(Cal.file_latex,['cal_wavelengthSC',tags{idx},'_',Cal.brw_str{Cal.n_inst}]),...
                                      ['\numSC',tags{idx}],size(sc_avg{t},1),...
                                      ['\CALCSTEP',tags{idx}],round(cal_step{t}(1)),...
                                      ['\calsteperror',tags{idx}],cal_step_error{t});
     idx=idx+1;
end
sunscan{Cal.n_inst}.cal_step=cal_step;
sunscan{Cal.n_inst}.cal_step_error=cal_step_error;
sunscan{Cal.n_inst}.sc_avg=sc_avg; sunscan{Cal.n_inst}.sc_raw=sc_raw;
sunscan{Cal.n_inst}.info=Args;
save(Cal.file_save,'-APPEND','sunscan');

%% dsp calibration
res={}; detail={}; DSP_QUAD={}; QUAD_SUM={}; QUAD_DETAIL={};
CUBIC_SUM={}; CUBIC_DETAIL={}; salida={}; CSN_icf={};

l=dir(fullfile('DSP',[Cal.brw_str{Cal.n_inst},'*']));
ldsp=cellstr(cat(1,l.name));

for jj=1:length(ldsp)  %% ojo solo funciona si config es igual para todos
    %%
%    if jj==length(ldsp),confign=2; else confign=1; end
    try
      [res{jj},detail{jj},DSP_QUAD{jj},QUAD_SUM{jj},QUAD_DETAIL{jj},...
       CUBIC_SUM{jj},CUBIC_DETAIL{jj},salida{jj},CSN_icf{jj},...
       ]=dspreport(Cal,'dsp_dir',fullfile('DSP',ldsp{jj}),'config_n',1);%
    catch
       warning(sprintf('Error en %s. DSP: %s',Cal.brw_name{Cal.n_inst},ldsp{jj}));
       res{jj}=NaN*ones(9,7,2); detail{jj}=NaN*ones(6,6,9,2); QUAD_DETAIL{jj}=NaN;
    end
end
% Para salvar los datos de cada brewer
dates=sscanf(cell2str(cat(2,ldsp')),'%03d_%03d_%03d,',[3,Inf]);
dates=datejul(dates(2:3,:)');dates=dates(:,1);
dsp_summary{Cal.n_inst}.info=cellstr(datestr(dates))';
dsp_summary{Cal.n_inst}.res=res;
dsp_summary{Cal.n_inst}.detail=detail;
dsp_summary{Cal.n_inst}.salida=salida;

save(Cal.file_save,'-APPEND','dsp_summary');

%%
ix=sort(findobj('tag','DSP_QUAD_RES'));
printfiles_report(ix',Cal.dir_figs,'aux_pattern',ix);

close all

%% Tabla - resumen con resultados DSP y Umkehr
 QUAD_SUM_table={}; rows={}; tabla_QuadSum={}; format short g;
 if config_orig(14)~=config_def(14)
    idx=1:length(res)+1; idx(end-1)=0; idx(end)=length(res);
    for t=[1:length(res)-1,length(res)+1]
        tabla_QuadSum{t}=num2cell(round(res{idx(t)}(end-1,:,1)*10^4)/10^4);
    end
    tabla_QuadSum{length(res)}=num2cell(round(res{length(res)}(res{length(res)}(:,1,1)==config_orig(14),:,1)*10^4)/10^4);
    Q_SUM_table_RowLabels={'Current',dsp_summary{Cal.n_inst}.info{:},dsp_summary{Cal.n_inst}.info{end},'Final'};
 else
    for t=1:length(res)
        tabla_QuadSum{t}=num2cell(round(res{t}(end-1,:,1)*10^4)/10^4);
    end
    Q_SUM_table_RowLabels={'Current',dsp_summary{Cal.n_inst}.info{:},'Final'};
 end

 tabla_QuadSum_str=cat(1,tabla_QuadSum{:});

 data_ini=cellfun(@(x) (round(x(:,1)*10^4))/10^4,{config_orig(8),config_orig(9),config_orig(10)},'UniformOutput',false);
 data_fin=cellfun(@(x) (round(x(:,1)*10^4))/10^4,{config_def(8),config_def(9),config_def(10)},'UniformOutput',false);
 QUAD_SUM_table=[{config_orig(14),data_ini{:}}   % Current
                 tabla_QuadSum_str(:,[1 2 4 5])  % Calculated
                 {config_def(14),data_fin{:}}];  % Final
 disp([Q_SUM_table_RowLabels',QUAD_SUM_table]);

label_1={'slit\#0','slit\#1','slit\#2','slit\#3','slit\#4','slit\#5'};
UMK_TABLE={};
 for um=1:length(res)
    steps_umk=res{um}(end-1:end,1,1);

    UMK_TABLE{um}=[];
    for iumk=1:2
      label_2={sprintf('step= %d ',fix(steps_umk(iumk)));'WL(A)';'Res(A)';'O3abs(1/cm)';'Ray abs(1/cm)'};
      if iumk==2, dumk=0; else dumk=iumk; end

      data=[label_2,[label_1;num2cell([round(detail{um}(1,:,end-dumk,1));detail{um}(2:4,:,end-dumk,1)])]];
      UMK_TABLE{um}=[UMK_TABLE{um};data];
    end
 end

%% Tablas y ficheros de definiciones latex
 indx=1;
for t=1:length(res)
    if t==1 indx=[]; else indx=t-1; end
% Se mantienen todas las tablas detalladas (tantas como test's analizados: 0, 1, 2, ...), por si se requieren en el futuro
    matrix2latex_QDETAIL(QUAD_DETAIL{t},...
                      fullfile(Cal.file_latex,['table_QDETAIL',num2str(indx),'_',Cal.brw_str{Cal.n_inst},'.tex']),...
                      'alignment','c','resize',0.9,'size','footnotesize');
% Idem para umkehr
     matrix2latex_ctable(UMK_TABLE{t},...
                      fullfile(Cal.file_latex,['table_UMK',num2str(indx),'_',Cal.brw_str{Cal.n_inst},'.tex']),...
                      'alignment','c','resize',0.9,'size','footnotesize');
end
% Una unica tabla - resumen
matrix2latex_ctable(QUAD_SUM_table,fullfile(Cal.file_latex,['table_dsp','_',Cal.brw_str{Cal.n_inst},'.tex']),...
            'Columnlabels',{'Calc-step', 'O3abs coeff.', 'SO2abs coeff.', 'O3/SO2'},...
            'RowLabels', Q_SUM_table_RowLabels,'alignment', 'c',...
            'resize',0.8,'format',{'%d','%6.4f','%6.4f','%6.4f'},'size','footnotesize');

% Definicion de variables
if length(res)>1
   d_p=[length(res)-1 length(res)];   tags={'','new'};
else
   d_p=1;   tags={'new'};
end

idx=1;
for t=d_p % Siempre el penúltimo y último procesados (si hay más de uno)
               % Solo vale para dos test's !!
     latexcmd(fullfile(Cal.file_latex,['cal_wavelengthDSP',tags{idx},'_',Cal.brw_str{Cal.n_inst}]),...
                                      ['\Auno',tags{idx}],round(res{t}(end-1,2,1)*10000)/10000,...% O3
                                      ['\Ados',tags{idx}],round(res{t}(end-1,4,1)*10000)/10000,...% ratio? MAL
                                      ['\Atres',tags{idx}],round(res{t}(end-1,5,1)*10000)/10000,...% SO2
                                      ['\UMKoffset',tags{idx}],fix(res{t}(end,1)));
     idx=idx+1;
 end

%% Eto para escribir resultados a hoja excel.
%  for dsps=1:length(ldsp)
%      legend1={'step',sprintf('ICF (%d, %d)',CSN_icf{dsps}(1),CSN_icf{dsps}(3)),'abs step','A1 Q','A1 S'};
%       dsp_table=NaN*ones(9,size(legend1,2));
%       dsp_table(:,1:5)=[res{dsps}(:,1,1),NaN*ones(9,1),res{dsps}(:,1,1)+salida{dsps}{1}.cal_ozonepos,...
%                         res{dsps}(:,2,1)*10000,res{dsps}(:,2,2)*10000];
%       dsp_table(end-1,2)=CSN_icf{dsps}(2)*10000;
%
%       aux=round(dsp_table); aux(:,[2 4 5])=aux(:,[2 4 5])/10000;
%       aux=[legend1;num2cell(aux)];
%       cell2str(aux,'\t')
%       xlswrite('./DSP/dsp_todo.xls',ldsp(dsps),Cal.brw_name{Cal.n_inst},['A',num2str(1+(dsps-1)*11)]);
%       xlswrite('./DSP/dsp_todo.xls',aux,Cal.brw_name{Cal.n_inst},['B',num2str(1+(dsps-1)*11)]);
%  end
%       xlswrite('./DSP/dsp_IZO2.xls',[Q_SUM_table_RowLabels',QUAD_SUM_table],[Cal.brw_name{Cal.n_inst},'_sum']);
%
