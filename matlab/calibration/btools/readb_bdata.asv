%ozone->[dsum,ozone_sum,config,ozone_ds,sl,sl_cr,hg,bhg,missing]=read_bdata(brewer)
% lee los ficheros del directorio bfiles
function [ozone,log,missing]=readb_bdata(brewer,path,brw_config_files)


i=brewer;

dsum={};    ozone_sum={};  ozone_ds={}; ozone_raw0={};
config={};  sl={};     sl_cr={};     hg={};     bhg={};
missing=NaN;
ozone=[];
%[path,name,ext]=fileparts(path);
sname=dir(path);

for ii=1:length(sname)
    [path,name,ext]=fileparts(sname(ii).name);
    fileinfo=sscanf([name,ext],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1))
    day=fileinfo(3);
   
    index_day=ii;   
    %bfile_f=sprintf('B%03d%02d.%03d',day,file_info,brw(i));
    bfile_f=sname(ii).name;
    bfile_p='bdata163';
    bfile=fullfile(bfile_p,bfile_f);
    
    if exist(bfile,'file')
       try
        % disp(['loading  ', bfile]);
        % aux_conf={fullfile(bfile_p,brw_config_files{i,1}),fullfile(bfile_p,brw_config_files{i,1})};
        %[ o3,config_,sl_,hg_]=readb_ds_develop(bfile,aux_conf);
        lastwarn('');
        [ o3,config_,sl_,hg_]=readb_ds_develop(bfile,brw_config_files(i,1:2));
        %disp(['OK-> ',brw_name{i}]);
        catch
            err=lasterror;
            log{index_day}={'ERROR',bfile,ext,err.message};
            missing(index_day)=1;
        end
        
        try
            dsum=[dsum;o3.dsum];
            ozone_sum=[ozone_sum;o3.ozone_s];
            config=[config;config_];
            ozone_ds=[ozone_ds;o3.ozone_ds];
            ozone_raw0=[ozone_raw0;o3.ds_raw0];
            sl=[sl;sl_.sls_c];       % first calibration     
            sl_cr=[sl_cr;sl_.sls_cr]; %recalculated/second calibration
            hg=[hg;hg_.hg];
            bhg=[bhg;hg_.time_badhg];
            
            missing(index_day)=0;
            log{index_day}={'OK',bfile,ext,lastwarn};
        catch
            disp('Error assingnig variables');
            log{index_day}={'ERROR',bfile,ext,'Variables'};
        end
    else
        %disp(['Missing   ',bfile])
        missing(index_day)=NaN;
        log{index_day}={'ERROR',bfile,ext,'Not found'};
    end
end
disp(ext);


ozone.dsum=dsum;
ozone.ozone_sum=ozone_sum;
ozone.config=config;
ozone.ozone_ds=ozone_ds;
ozone.hg=hg;
ozone.sl=sl;
ozone.sl_cr=sl_cr;
ozone.hg=hg;
ozone.bhg=bhg;
ozone.raw=ozone_raw0;
