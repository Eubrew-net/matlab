%%  AVG Report files
%   History report for Standard Lamp, Dead Time , Run Stop and Power supply report 
%   090109: trycatch update alberto
%   230909 : update to read the files from bfiles/brw
%   240909 : alberto   añandido flag de depuracion en SL->sl_avg
%            cuando cambia el sl durante la calibracion los toma como outlier.
%   021109 : Juanjo se distingue el flag_outlier segun para que función sea
%            sl_avg, dt_avg, rs_avg o bien ap_avg
%            En todos los casos será 'flag_outlier_??'
% 
%   TODO: reportar tambien los outlier. 
% 
%   Ejemplo:  brw_avg_report(...,'flag_outlier_sl','flag_outlier_dt');     

function [sl_data,dt_data,rs_data,ap_data]=brw_avg_report(brw_str,date_range,brw_config_files,SL_REF,...
                                                          varargin)    
   
%% Configuration file used on the report
disp(brw_str)

sl_data=[];dt_data=[];rs_data=[];ap_data=[];
  [config,TC,DT,ETC,A1,AT,leg]=read_icf(brw_config_files); 
  bfilepath=['.',filesep(),'bdata' brw_str];
  bfileSpath=['.',filesep(),'bfiles',filesep(),brw_str];
  %makeHtmlTable(config,'',leg)
  
%% Standard Lamp report
try
   slfile=[bfileSpath,filesep(), 'SLOAVG.' brw_str];
   if exist(slfile,'file') 
   else 
     slfile=[bfilepath,filesep(), 'SLOAVG.' brw_str];
   end

   if any(strcmp(varargin,'flag_outlier_sl')),  flag_outlier_sl=1;
   else flag_outlier_sl=0;
   end

   sl_data=sl_avg(slfile,date_range,SL_REF,flag_outlier_sl);
catch
    disp(['ERROR',slfile]);
end
   %snapnow;

%% Dead time report
try 
   dtfile=[bfileSpath,filesep(), 'DTOAVG.' brw_str];
   if exist(dtfile,'file') 
   else 
     dtfile=[bfilepath,filesep(),'DTOAVG.',brw_str];
   end

   if any(strcmp(varargin,'flag_outlier_dt')),  flag_outlier_dt=1;
   else flag_outlier_dt=0;
   end

   dt_data=dt_avg(dtfile,date_range,DT,flag_outlier_dt);
catch
    disp(['ERROR',dtfile]);
    
end
%    snapnow;

%% Run stop report
try
    rsfile=[bfileSpath,filesep(), 'RSOAVG.' brw_str];
    if exist(rsfile,'file') 
        rsfile=[bfileSpath,filesep(),'RSOAVG.',brw_str];
    else 
     rsfile=[bfilepath,filesep(),'RSOAVG.',brw_str];
    end

    if any(strcmp(varargin,'flag_outlier_rs')),  flag_outlier_rs=1;
    else flag_outlier_rs=0;
    end

    rs_data=rs_avg(rsfile,date_range,flag_outlier_rs);
catch
    disp(['ERROR',rsfile]);
end
%    snapnow;
   
%%  Power supply
try
   apfile=[bfilepath,filesep(),'APOAVG.',brw_str];
   
   if any(strcmp(varargin,'flag_outlier_ap')),  flag_outlier_ap=1;
   else flag_outlier_ap=0;
   end

   ap_data=ap_avg(apfile,date_range,flag_outlier_ap);
catch
    disp(['ERROR',apfile]);
end
%    snapnow;
