%%  AVG Report files
%   History report for Standard Lamp, Dead Time , Run Stop and Power supply report 
%   090109: trycatch update alberto
%   230909 : update to read the files from bfiles/brw
%   240909 : alberto   añandido flag de depuracion en SL->sl_avg
%           cuando cambia el sl durante la calibracion los toma como outlier.
%          TODO: reportar tambien los outlier,cambiar el resto dt_avg rs_avg     
%       

function [sl_data,dt_data,rs_data,ap_data]=brw_avg_report(brw_str,date_range,brw_config_files,SL_REF,flag_outlier)    
   
%% Configuration file used on the report
disp(brw_str)

sl_data=[];dt_data=[];rs_data=[];ap_data=[];
  [config,TC,DT,ETC,A1,AT,leg]=read_icf(brw_config_files); 
  bfilepath=['.',filesep(),'bdata' brw_str];
  bfileSpath=['.',filesep(),'bfiles',filesep(),brw_str];
  %makeHtmlTable(config,'',leg)
  
if nargin<=4
    flag_outlier=0;
end
%% Standard Lamp report
try
   slfile=[bfileSpath,filesep(), 'SLOAVG.' brw_str];
   if exist(slfile,'file') 
   else 
     slfile=[bfilepath,filesep(), 'SLOAVG.' brw_str];
   end
   sl_data=sl_avg(slfile,date_range,SL_REF,flag_outlier);  
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
   dt_data=dt_avg(dtfile,date_range,DT);
   snapnow;
catch
    disp(['ERROR',dtfile]);
    
end
%% Run stop report
try
    rsfile=[bfileSpath,filesep(), 'RSOAVG.' brw_str];
    if exist(rsfile,'file') 
        rsfile=[bfileSpath,filesep(),'RSOAVG.',brw_str];
    else 
     rsfile=[bfilepath,filesep(),'RSOAVG.',brw_str];
    end
   rs_data=rs_avg(rsfile,date_range);
   snapnow;
catch
    disp(['ERROR',rsfile]);
end

   
   
   
%%  Power supply
try
   apfile=[bfilepath,filesep(),'APOAVG.',brw_str];
   ap_data=ap_avg(apfile,date_range);
   snapnow;
catch
    disp(['ERROR',apfile]);
end
