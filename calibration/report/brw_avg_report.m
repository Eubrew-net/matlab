
function [sl_data,dt_data,rs_data,ap_data,hg_data,h2o_data,op_data,OUTliers]=brw_avg_report(brw_str,brw_config_files,varargin)  
% AVG Report files
%   History report for Standard Lamp, Dead Time , Run Stop and Power supply report 
%%MODIFICADO
%   090109 : trycatch update alberto
%   230909 : update to read the files from bfiles/brw
%   240909 : Alberto   añandido flag de depuracion en SL->sl_avg
%            cuando cambia el sl durante la calibracion los toma como outlier.
%   021109 : Juanjo se distingue el flag_outlier segun para que función sea
%            sl_avg, dt_avg, rs_avg o bien ap_avg
%            En todos los casos será 'flag_outlier_??'
%   210410 : Isa, Introducidos HGOAVG
%   220410 : Isa, Introducidos MIOAVG
%   230410 : Isa, Introducidos OPOAVG
%   111110 : Isa, Introducida Matriz Outliers, a partir de los nuevos outputs
%                OutR6F5R5,OutHTLT,OutRS,OutHTSL5V,OutHG,OutMSFW
%                Introducido el OUTput OUTliers
%   150113 : Juanjo, added path_to_file optional argument. Default: current directory
% 
%   TODO: reportar tambien los outlier. 
% 
%   Ejemplo:  brw_avg_report(...,'flag_outlier_sl','flag_outlier_dt');     
                                                                                 
%% Validamos argumentos
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'brw_avg_report';

% Input obligatorio
arg.addRequired('brw_str');
arg.addRequired('brw_config_files');

% Input param - value
arg.addParamValue('path_to_file', '.', @isstr); % por defecto, current directory
arg.addParamValue('outlier_flag',{'','','','','','',''},@(x)(any(strcmp(x,{'sl','dt','rs','ap','hg','h2o','op'})) || isempty(cell2mat(x))));
arg.addParamValue('date_range', [], @(x)isfloat(x)); % por defecto, no control de fechas
arg.addParamValue('SL_REF', NaN, @isfloat); % por defecto no SL_REF
arg.addParamValue('DT_REF', [NaN NaN], @isfloat); % por defecto no SL_REF

% Validamos los argumentos definidos:
try
    arg.parse(brw_str, brw_config_files, varargin{:});
    mmv2struct(arg.Results); Args=arg.Results;
    chk=1;
catch
    errval=lasterror;
    if length(varargin)==6
        date_range=varargin{2};
        SL_REF=varargin{4};
        outlier_flag=varargin{6};
    elseif length(varargin)==4
        date_range=varargin{2};
        SL_REF=varargin{4};
        outlier_flag=0;        % Por defecto no depuracion
    elseif length(varargin)==2
        date_range=varargin{2};
        SL_REF=NaN;
        outlier_flag=0;        % Por defecto no depuracion
    else
        date_range=[];         % Por defecto no control de fechas
        SL_REF=NaN;
        outlier_flag=[];       % Por defecto no depuracion
    end
    chk=0;
end
                                                      
 bfilepath =fullfile(path_to_file,['bdata' brw_str]);
 bfileSpath=fullfile(path_to_file,'bfiles',brw_str);

%% Standard Lamp report
try
    slfile=[bfileSpath,filesep(), 'SLOAVG.' brw_str];
    if exist(slfile,'file')
    else
        slfile=[bfilepath,filesep(), 'SLOAVG.' brw_str];
    end
    if any(strcmp('sl',outlier_flag)==1),
        flag=outlier_flag{strcmp('sl',outlier_flag)};
    else flag='';
    end
    [sl_data,OutR6R5F5]=sl_avg(slfile,date_range,SL_REF,flag);
catch
    disp(['ERROR',slfile]); sl_data=[];
end

%% Dead time report
try
    dtfile=[bfileSpath,filesep(), 'DTOAVG.' brw_str];
    if exist(dtfile,'file')
    else
        dtfile=[bfilepath,filesep(),'DTOAVG.',brw_str];
    end
    if any(strcmp('dt',outlier_flag)==1),
        flag=outlier_flag{strcmp('dt',outlier_flag)};
    else flag='';
    end
    [dt_data,OutHTLT]=dt_avg(dtfile,date_range,DT_REF,flag);
catch
    disp(['ERROR',dtfile]); dt_data=[];
end

%% Run stop report
try
    rsfile=[bfileSpath,filesep(), 'RSOAVG.' brw_str];
    if exist(rsfile,'file')
    else
        rsfile=[bfilepath,filesep(),'RSOAVG.',brw_str];
    end
    if any(strcmp('rs',outlier_flag)==1),
        flag=outlier_flag{strcmp('rs',outlier_flag)};
    else flag='';
    end
    [rs_data,OutRS]=rs_avg(rsfile,date_range,flag);
catch
    disp(['ERROR',rsfile]); rs_data=[]; OutRS=NaN;
end

%% Power supply
try
    apfile=[bfileSpath,filesep(),'APOAVG.',brw_str];
    if exist(apfile,'file')
    else
        apfile=[bfilepath,filesep(),'APOAVG.',brw_str];
    end
    
    if any(strcmp('ap',outlier_flag)==1),
        flag=outlier_flag{strcmp('ap',outlier_flag)};
    else flag='';
    end
    [ap_data,OutHTSL5V]=ap_avg(apfile,date_range,flag);
catch
    disp(['ERROR',apfile]); ap_data=[];
end
%%  HGOAVG
try
    hgfile=[bfileSpath,filesep(),'HGOAVG.',brw_str];
    if exist(hgfile,'file')
    else
        hgfile=[bfilepath,filesep(),'HGOAVG.',brw_str];
    end
    
    if any(strcmp('hg',outlier_flag)==1),
        flag=outlier_flag{strcmp('hg',outlier_flag)};
    else flag='';
    end
    [hg_data,OutHG]=hg_avg(hgfile,'date_range',date_range,'outlier_flag',flag);
catch
    disp(['ERROR',hgfile]); hg_data=[];
end
%%  H2OAVG
try
    h2ofile=[bfileSpath,filesep(),'H2OAVG.',brw_str];
    if exist(h2ofile,'file')
    else
        h2ofile=[bfilepath,filesep(),'H2OAVG.',brw_str];
    end
    if any(strcmp('h2o',outlier_flag)==1),
        flag=outlier_flag{strcmp('h2o',outlier_flag)};
    else flag='';
    end
    [h2o_data,OutMSFW]=h2o_avg(h2ofile,'date_range',date_range,'outlier_flag',flag);
catch
    disp(['ERROR',h2ofile]); h2o_data=[];
end

%%  MIOAVG
% try
%     mifile=[bfileSpath,filesep(),'MIOAVG.',brw_str];
%     if exist(mifile,'file')
%     else
%         mifile=[bfilepath,filesep(),'MIOAVG.',brw_str];
%     end
%     if any(strcmp('mi',outlier_flag)==1),
%         flag=outlier_flag{strcmp('mi',outlier_flag)};
%     else flag='';
%     end
%     [mi_data,OutMSFW]=mi_avg(mifile,'date_range',date_range,'outlier_flag',flag);
% catch
%     disp(['ERROR',mifile]);
% end
%%  OPOAVG
try
    opfile=[bfileSpath,filesep(),'OPAVG.',brw_str];
    if exist(opfile,'file')
    else
        opfile=[bfilepath,filesep(),'OPAVG.',brw_str];
    end
    if any(strcmp('op',outlier_flag)==1),
        flag=outlier_flag{strcmp('op',outlier_flag)};
    else flag='';
    end
    op_data=op_avg(opfile,'date_range',date_range,'outlier_flag',flag);
catch
    disp(['ERROR',opfile]); op_data=[];
end
%% Guardamos outliers
   OUTliers.SL=OutR6R5F5;
   OUTliers.DT=OutHTLT;
   OUTliers.RS=OutRS;
%     [OutR6F5R5 (:,[6:end]) OutRS(:,[6:end]) OutHTSL5V(:,[6:end]) OutHG(:,[6:end]) OutMSFW(:,[6:end])];

%%
if chk
    % Se muestran los argumentos que toman los valores por defecto
    disp('--------- Validation OK --------------')
    disp('List of arguments given default values:')
    if ~numel(arg.UsingDefaults)==0
        for k=1:numel(arg.UsingDefaults)
            field = char(arg.UsingDefaults(k));
            value = arg.Results.(field);
            if isempty(value),   value = '[]';
            elseif iscell(value), value = num2str(cell2mat(value)); end
            disp(sprintf('   ''%s''    defaults to %s', field, value))
        end
    else
        disp('               None                   ')
    end
    disp('--------------------------------------')
else
    disp('NO INPUT VALIDATION!!')
    disp(sprintf('%s',errval.message))
end