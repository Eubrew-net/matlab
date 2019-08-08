%ozone->[dsum,ozone_sum,config,ozone_ds,sl,sl_cr,hg,bhg,missing]=read_bdata(brewer)
% lee los ficheros del directorio bfiles
function [dt,rs,missing]=read_dt_obs(brewer,path_root)


brw=brewer

config={};  dt=[];     rs=[];     
missing=NaN;
dt_=[];
rs_=[];

    bfile_f=sprintf('B*.%03d',brw);
    bfile_p=fullfile(path_root,sprintf('bdata%03d',brw));
    bfile=fullfile(bfile_p,bfile_f);
    s=dir(bfile);
    for ii=1:length(s)
          
        bfile_f=s(ii).name;
        bfile=fullfile(bfile_p,bfile_f);
       
        if exist(bfile,'file')
       try
          disp(['loading  ', bfile]);
          [ dt_,rs_]=readb_dt(bfile);
          
          %disp(['OK-> ',Cal.brw_name{i}]);
        catch
            err=lasterror;
            disp(['ERROR reading  ',bfile,' '])
            disp(err.message)
            missing(ii)=1;
        end
        missing(ii)=0;
        try
            dt=[dt;dt_];       % first calibration     
            rs=[rs;rs_]; %recalculated/second calibration
        catch
            disp('Error assingnig variables');
        end
    else
        disp(['Missing   ',bfile])
        missing(ii)=NaN;
    end
end

