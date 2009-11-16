%ozone->[dsum,ozone_sum,config,ozone_ds,sl,sl_cr,hg,bhg,missing]=read_bdata(brewer)
% lee los ficheros del directorio bfiles
function [ozone]=read_sl_data(brewer,setup)

eval(setup);
i=brewer;
config={};  sl={};     sl_cr={};     hg={};     bhg={};
missing=NaN;
sl=[];

    bfile_f=sprintf('B*.%03d',brw(i));
    bfile_p=sprintf('bdata%03d',brw(i));
    bfile=fullfile(bfile_p,bfile_f);
   
   s=dir(bfile);
   for ii=1:length(s)
    
        bfile_f=s(i).name;
        bfile=fullfile(bfile_p,bfile_f);
   
    
    if exist(bfile,'file')
       try
         disp(['loading  ', bfile]);
        % aux_conf={fullfile(bfile_p,brw_config_files{i,1}),fullfile(bfile_p,brw_config_files{i,1})};
        %[ o3,config_,sl_,hg_]=readb_ds_develop(bfile,aux_conf);
        [ o3,config_,sl_,hg_]=readb_sl_dev(bfile,brw_config_files(i,1:2));
        disp(['OK-> ',brw_name{i}]);
        catch
            err=lasterror;
            disp(['ERROR reading  ',bfile,' ',brw_name{i}])
            disp(err.message)
            missing(i,day)=1;
        end
        missing(i,day)=0;
        try
            sl=[sl;sl_.sls_c];       % first calibration     
            sl_cr=[sl_cr;sl_.sls_cr]; %recalculated/second calibration
            hg=[hg;hg_.hg];
            bhg=[bhg;hg_.time_badhg];
        catch
            disp('Error assingnig variables');
        end
    else
        disp(['Missing   ',bfile])
        missing(i,day-day0)=NaN;
    end
end
disp(brw(i));


ozone.sl=sl;
ozone.sl_cr=sl_cr;
ozone.hg=hg;
ozone.bhg=bhg;
ozone.config=config;