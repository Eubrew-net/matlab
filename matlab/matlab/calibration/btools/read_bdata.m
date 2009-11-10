%ozone->[dsum,ozone_sum,config,ozone_ds,sl,sl_cr,hg,bhg,missing]=read_bdata(brewer)
% lee los ficheros del directorio bfiles
function [ozone,log,missing]=read_bdata(brewer,setup)

eval(setup);
i=brewer;
dsum={};    ozone_sum={};  ozone_ds={}; ozone_raw0={};
config={};  sl={};     sl_cr={};     hg={};     bhg={};
missing=NaN;
ozone=[];
for day=CALC_DAYS
    index_day=day-CALC_DAYS(1)+1;
    bfile_f=sprintf('B%03d%02d.%03d',day,cal_year-2000,brw(i));
    bfile_p='BFILES';
    bfile=fullfile(bfile_p,bfile_f);
    
    if exist(bfile,'file')
       try
        % disp(['loading  ', bfile]);
        % aux_conf={fullfile(bfile_p,brw_config_files{i,1}),fullfile(bfile_p,brw_config_files{i,1})};
        %[ o3,config_,sl_,hg_]=readb_ds_develop(bfile,aux_conf);
        lastwarn('');
        if exist(['scf',brw_str{i}],'var')
          scf=eval(['scf',brw_str{i}]);
          sfc_flag='sfc';
         [ o3,config_,sl_,hg_]=readb_ds_develop(bfile,brw_config_files(i,1:2),scf);
        else
         sfc_flag='  ';
        [o3,config_,sl_,hg_]=readb_ds_develop(bfile,brw_config_files(i,1:2));
         %disp(['OK-> ',brw_name{i}]);
        end
        catch
            err=lasterror;
            log{index_day}={'ERROR',bfile,brw_name{i},err.message,sfc_flag};
            missing(index_day)=1;
            disp(bfile);
            brw_config_files{i,1:2}
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
            log{index_day}={'OK',bfile,brw_name{i},lastwarn,sfc_flag};
        catch
            disp('Error assingnig variables');
            log{index_day}={'ERROR',bfile,brw_name{i},'Variables',sfc_flag};
        end
    else
        %disp(['Missing   ',bfile])
        missing(index_day)=NaN;
        log{index_day}={'ERROR',bfile,brw_name{i},'Not found','   '};
    end
     log{index_day};
end
disp(brw(i));


ozone.dsum=dsum;
ozone.ozone_sum=ozone_sum;
ozone.config=config;
ozone.ozone_ds=ozone_ds;
ozone.hg=hg;
ozone.sl=sl;
ozone.sl_cr=sl_cr;
ozone.hg=hg;
ozone.bhg=bhg;
ozone.raw0=ozone_raw0;
%ozone.raw=ozone_raw;
%ozone.raw_legend=o3.ozone_raw_legend;
