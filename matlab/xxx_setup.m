%% BREWER CALIBRATION
%% SETUP
% Definimos la variable de configuracion por defecto para todos los brewer
%Cal.Station % parametros de la estacion
%Cal.FCal    % parametros de ficheros
%Cal.Date    % parametros de fecha
%Cal.        % parametros que afectan a la calibrabicon ver detalles
%% General
Cal.path_root=pwd;
Cal.file_save='arosa_2008.mat';
Cal.campaign='Arosa (Switzerland), 20 -- 30 July, 2010';


%% Station 
Station.OSC=680;
Station.name='AROSA';
Station.lat=[];
Station.long=[];
Station.meanozo=[];

Cal.Station=Station;


%%  configuration  date---> Default values
day0=202; dayend=212;

Date.cal_year=2008;
Date.cal_month=07;
Date.day0=day0;
Date.dayend=dayend;
Date.CALC_DAYS=day0:dayend;
Date.BLIND_DAYS=day0:dayend;
Date.FINAL_DAYS=day0:dayend;

Date.N_Period=NaN;
Date.Period_start=NaN;
Date.Period.end=NaN;

Cal.Date=Date;

%% NUEVA DEFINICON POR INSTRUMENTO en minusculas
Cal.calibration_days={
[204:209],[204:209],[	204:209]
[203:212],[204:206],[	206:212]
[205:210],[205:207],[	205:207]
[203:212],[208:212],[	203:205,208:212]
[204:212],[204:206],[   208:212]
[204:209],[204:209],[	204:209]
[204:212],[204:212],[	204:212]
};

Cal.blind_days=Cal.calibration_days(:,2);
Cal.final_days=Cal.calibration_days(:,3);

% para un instrumento dado Cal.blind_days{n_inst}






%% CALIBRATION INFO
Cal.Tsync=7.5;
Cal.brw=[017,040,064,072,156,163,185];
Cal.brw_name={'IOS#017','ARO#040','POL#064','ARO#072','ARO#156','WRC#163','IZO#185'};
Cal.brw_str=mmcellstr(sprintf('%03d|',Cal.brw));
Cal.brwM=[2,2,2,2,3,3,3];
Cal.brw_name2={'IOS MKII','ARO MKII','POL MKII','ARO MKII','ARO MKIII',...
           'WRC MKIII','IZO MKIII'};

Cal.brewer_ref=[1,7]; % can be several []       
Cal.n_ref=[1,7];
Cal.no_maint=[1,6,7];

 brw_config_files={
    'icf20408.017','icf20508.017','2090','2100';
    'icf20507.040','icf20708.040','1730','1717';
    'icf13507.064','icf20508.064','1675','1670';
    'icf20507.072','icf20508.072','1930','1920';
    'icf19806.156','icf20508.156','0430','0435';
    'icf20708.163','icf20508.163','0200','0188';
    'icf25905.185','icf25905.185','0312','0312';
    };

%% Calibration instrument
% Brewer configuration files
  


Cal.n_brw=length(Cal.brw);

pa=repmat(cellstr([Cal.path_root,filesep(),'bfiles']),Cal.n_brw,2);
pa=cellfun(@fullfile,pa,[mmcellstr(sprintf('%03d|',Cal.brw)),mmcellstr(sprintf('%03d|',Cal.brw))],'UniformOutput',0);
brw_config_files(:,1:2)=cellfun(@fullfile,pa,brw_config_files(:,1:2),'UniformOutput',0);
if isunix
 brw_config_files=strrep(brw_config_files,'\',filesep());
 brw_config_files=cellfun(@upper,brw_config_files,'UniformOutput',0);
end

SL_OLD_REF=str2num(cat(1,brw_config_files{:,3}));
SL_NEW_REF=str2num(cat(1,brw_config_files{:,4}));
brw_config_files_old=brw_config_files(:,1);
brw_config_files_new=brw_config_files(:,2);



Cal.brw_config_files=brw_config_files;
Cal.brw_config_files_old=brw_config_files_old;
Cal.brw_config_files_new=brw_config_files_new;
Cal.SL_OLD_REF=str2num(cat(1,brw_config_files{:,3}));
Cal.SL_NEW_REF=str2num(cat(1,brw_config_files{:,4}));

%% Finalcalibration
Cal.FCal.ICF_FILE_INI='ICFXXXYY';
Cal.FCal.ICF_FILE_FIN='ICFXXXYY';
Cal.FCal.DCFFILE='DCFXXXYY';
Cal.FCal.LFFILE='LFXXXYY';

%% Latex directories

%pa=repmat(cellstr([Cal.path_root,filesep(),'latex']),n_brw,1);
%pa=cellfun(@fullfile,pa,mmcellstr(sprintf('%03d|',Cal.brw)),'UniformOutput',0);
%Cal.dir_latex
%cellfun(@mkdir,pa)
%Cal.dir_figs=cellfun(@fullfile,pa,mmcellstr(sprintf('%03d_figures|',Cal.brw)),'UniformOutput',0);
%cellfun(@mkdir,Cal.Dir_figs)