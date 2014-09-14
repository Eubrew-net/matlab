%% BREWER CALIBRATION

%% General
% Habrá que modificar a mano el directorio final: CODE, Are2011, SDK11 ...
if ispc
 Cal.path_root=fullfile(cell2mat(regexpi(pwd,'^[A-Z]:', 'match')),'CODE','campaigns','aro2012');
else
 Cal.path_root=fullfile('~',cell2mat(regexpi(pwd,'^[A-Z]:', 'match')),'CODE','campaigns','aro2012');
end
path(genpath(fullfile(Cal.path_root,'matlab')),path);
Cal.file_save='aro_2012.mat';
Cal.campaign='Arosa, Switzerland, 16 -- 27 July, 2012';


%% Station 
Station.OSC=680;
Station.name='AROSA';
Station.lat=[];
Station.long=[];
Station.meanozo=[];

Cal.Station=Station;

%% Finalcalibration
Cal.FCal.ICF_FILE_INI='ICFXXXYY';
Cal.FCal.ICF_FILE_FIN='ICFXXXYY';
Cal.FCal.DCFFILE='DCFXXXYY';
Cal.FCal.LFFILE='LFXXXYY';

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
% cal-days blind-days final-days
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
Cal.no_maint=[1 1 0 1 1 1 1];

%% CALIBRATION INFO
Cal.Tsync=3.5;
Cal.brw=[017,040,064,072,156,163,185]; Cal.n_brw=length(Cal.brw);
Cal.brwM=[2,2,2,2,3,3,3];
Cal.brw_name={'IOS#017','ARO#040','POL#064','ARO#072','ARO#156','WRC#163','IZO#185'};
Cal.brw_name2={'IOS MKII','ARO MKII','POL MKII','ARO MKII','ARO MKIII',...
               'WRC MKIII','IZO MKIII'};
Cal.brw_str=mmcellstr(sprintf('%03d|',Cal.brw));

Cal.brewer_ref=[1,7]; % can be several []       
Cal.n_ref=[1,7];

Cal.sl_c_blind=[0, 0, 0, 0, 0, 0, 0];
Cal.sl_c      =[0, 0, 0, 0, 0, 0, 0];

% Brewer configuration files
% for inst=[2 5 6 7 8 9]
%    [icf_n,icf_text,icf_raw]=xlsread(fullfile(Cal.path_root,'bfiles',Cal.brw_str{inst},['icf',Cal.brw_str{inst},'.xls']),...
%                                    ['icf.',Cal.brw_str{inst}],'','basic');
%    cfg=icf_n(2:end-1,3:end); save('config.cfg', 'cfg', '-ASCII','-double');
%    tmp_file=sprintf('config%s.cfg',Cal.brw_str{inst});
%    copyfile('config.cfg',fullfile(pwd,'bfiles',Cal.brw_str{inst},tmp_file));
%    delete('config.cfg');
%end

 brw_config_files={
    'icf20408.017','icf20508.017','2090','2100';
    'icf20507.040','icf20708.040','1730','1717';
    'icf13507.064','icf20508.064','1675','1670';
    'icf20507.072','icf20508.072','1930','1920';
    'icf19806.156','icf20508.156','0430','0435';
    'icf20708.163','icf20508.163','0200','0188';
    'icf25905.185','icf25905.185','0312','0312';
    };

Cal.ETC_C={
          [0,0,0,0,0,0]         %017
          [0,0,0,0,0,0]         %040
          [0,0,0,18,-50,0]      %066 final guest
          [0,0,0,0,25,0]        %067
          [0,0,0,0,0,0]         %072
          [0,0,0,0,0,0]         %156
          [0,0,0,0,0,0]         %158
          };

%% Brewer configuration files. Eventos e Incidencias
icf_op=cell(1,length(Cal.n_brw));  %old, operative
icf_a=cell(1,length(Cal.n_brw));   %new, alternative

events_n=cell(1,length(Cal.n_brw)); events_raw=cell(1,length(Cal.n_brw));
events_text=cell(1,length(Cal.n_brw)); incidences_text=cell(1,length(Cal.n_brw));
warning('off', 'MATLAB:xlsread:Mode');
for iz=1:Cal.n_brw
 try   
    if iz==find(Cal.brw==185) %reference
       icf_op{iz}=xlsread(fullfile(Cal.path_root,'configs',['icf',Cal.brw_str{iz},'.xls']),...
                         ['icf.',Cal.brw_str{iz}],'','basic');      
       icf_a{iz}=xlsread(fullfile(Cal.path_root,'configs',['icf',Cal.brw_str{iz},'.xls']),...
                         ['icf_a.',Cal.brw_str{iz}],'','basic');                     
       [events_n{iz},events_text{iz},events_raw{iz}]=xlsread(fullfile(Cal.path_root,'configs',['icf',Cal.brw_str{iz},'.xls']),...
                                                             ['Eventos.',Cal.brw_str{iz}],'','basic');
       [inc_n{iz},incidences_text{iz},incidences_raw{iz}]=xlsread(fullfile(Cal.path_root,'configs',['icf',Cal.brw_str{iz},'.xls']),...
                                                             ['Incidencias.',Cal.brw_str{iz}],'','basic');
    else % not reference. Go to bfiles
      if exist(fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},['icf',Cal.brw_str{iz},'.xls']),'file')
         icf_op{iz}=xlsread(fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},['icf',Cal.brw_str{iz},'.xls']),...
                           ['icf.',Cal.brw_str{iz}],'','basic');
         [events_n{iz},events_text{iz},events_raw{iz}]=xlsread(fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},['icf',Cal.brw_str{iz},'.xls']),...
                                                               ['Eventos.',Cal.brw_str{iz}],'','basic');
%          icf_a{iz}=xlsread(fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},['icf',Cal.brw_str{iz},'.xls']),...
%                            ['icf_a.',Cal.brw_str{iz}],'','basic');                               
         [inc_n{iz},incidences_text{iz}]=xlsread(fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},['icf',Cal.brw_str{iz},'.xls']),...
                                                 ['Incidencias.',Cal.brw_str{iz}],'','basic');         
      else
          continue
      end
    end   
    
    if size(icf_op{iz},1)==54  % ??
       cfg=icf_op{iz}(2:end-1,3:end); 
       save('config.cfg', 'cfg', '-ASCII','-double');
    else
       cfg=icf_op{iz}(1:end-1,3:end); 
       save('config.cfg', 'cfg', '-ASCII','-double');
    end
    tmp_file=sprintf('config%s.cfg',Cal.brw_str{iz});       
    copyfile('config.cfg',fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},tmp_file));
    delete('config.cfg');
  
  if iz==find(Cal.brw==185) %reference  
     if size(icf_a{iz},1)==54 %??
        cfg=icf_a{iz}(2:end-1,3:end);
        save('config_a.cfg', 'cfg', '-ASCII','-double');
     else
        cfg=icf_a{iz}(1:end-1,3:end);
        save('config_a.cfg', 'cfg', '-ASCII','-double');
     end             
     tmp_file=sprintf('config%s_a.cfg',Cal.brw_str{iz});
     copyfile('config_a.cfg',fullfile(Cal.path_root,'bfiles',Cal.brw_str{iz},tmp_file));
     delete('config_a.cfg');
   end
 
  catch exception
        fprintf('%s Brewer%s\n',exception.message,Cal.brw_name{iz}); 
        icf_op{iz}=[]; icf_a{iz}=[]; events_n{iz}=[]; events_raw{iz}=[];
        events_text{iz}=[]; incidences_text{iz}=[];
  end
  Cal.events{iz}=events_n{iz}(:,2:end);
  Cal.events_n{iz}=events_n{iz};
  Cal.events_text{iz}=events_text{iz};
  Cal.events_raw{iz}=events_raw{iz};
  Cal.incidences_text{iz}=incidences_text{iz};
end

%% Calibration instrument
% Brewer configuration files  
pa=repmat(cellstr([Cal.path_root,filesep(),'bfiles']),Cal.n_brw,2);
pa=cellfun(@fullfile,pa,[mmcellstr(sprintf('%03d|',Cal.brw)),mmcellstr(sprintf('%03d|',Cal.brw))],'UniformOutput',0);
brw_config_files(:,1:2)=cellfun(@fullfile,pa,brw_config_files(:,1:2),'UniformOutput',0);
if isunix
   brw_config_files=strrep(brw_config_files,'\',filesep());
   brw_config_files=cellfun(@upper,brw_config_files,'UniformOutput',0);
end
Cal.brw_config_files=brw_config_files;
Cal.brw_config_files_old=brw_config_files(:,1);
Cal.brw_config_files_new=brw_config_files(:,2);
Cal.SL_OLD_REF=cellfun(@(x) str2double(x), brw_config_files(:,3));
Cal.SL_NEW_REF=cellfun(@(x) str2double(x), brw_config_files(:,4));


%% Latex directories

%pa=repmat(cellstr([Cal.path_root,filesep(),'latex']),n_brw,1);
%pa=cellfun(@fullfile,pa,mmcellstr(sprintf('%03d|',Cal.brw)),'UniformOutput',0);
%Cal.dir_latex
%cellfun(@mkdir,pa)
%Cal.dir_figs=cellfun(@fullfile,pa,mmcellstr(sprintf('%03d_figures|',Cal.brw)),'UniformOutput',0);
%cellfun(@mkdir,Cal.Dir_figs)