function [ozone,log,missing]=read_bdata(brewer,setup,spectral_setup)

% lee los ficheros del directorio bfiles
% 
% INPUT: 
% - brw_id
% - setup. De aquí toma configuración y dates
% - spectral_setup ??
% 
% OUTPUT:
% - ozone
% - log
% - missing (NaN para ficheros ausentes, 0 para OK, 1 para error)
% 
% MODIFICADO:
% Juanjo (05/2011): modificado para considerar en primer lugar ficheros 
%                   depurados, Bdddyy_dep.###
%                   Si no existe B_dep, entonces será Bdddyy.###, como
%                   habitualmente

b_idx=brewer;
if isstruct(setup)
   mmv2struct(setup); 
   mmv2struct(setup.Date); 
else
  try
    load(setup);
  catch
    eval(setup);
  end
end

if nargin==2
    spectral_setup=[];
else
    eval(['scf',brw_str{b_idx},'=spectral_setup']);
end

dsum={};    ozone_sum={};  ozone_ds={}; ozone_raw0={};
ozone_raw={}; ozone_ratios={};
config={};  sl={};     sl_cr={};     hg={};     bhg={};
missing=NaN;
ozone=[];

bfile_p='BFILES'; 
for day=CALC_DAYS
    bfile_f=[]; o3=[];config_=[];sl_=[];hg_=[];
    if day<0
      index_day=abs(day-CALC_DAYS(1))+1;
      bfile_f=sprintf('B%03d%02d.%03d',365+day,cal_year-2001,brw(b_idx));  
      bfile_f=fullfile('..',num2str(cal_year-1),bfile_p,bfile_f);
    else
      index_day=day-CALC_DAYS(1)+1;
      bfile_f=sprintf('B%03d%02d.%03d',day,cal_year-2000,brw(b_idx));  
      bfile_f=fullfile(bfile_p,bfile_f);
    end

    [path nam ext]=fileparts(bfile_f);
    if exist(fullfile(path,[nam,'_dep',ext]))
       bfile=fullfile(path,[nam,'_dep',ext]); 
    elseif exist(bfile_f)
       bfile=bfile_f;
    else
       disp(['Missing   ',bfile_f]);
       missing(index_day)=NaN;
       log{index_day}={'ERROR',bfile_f,brw_name{b_idx},'Not found','   '};
       continue
    end

    try
      lastwarn('');
      if exist(['scf',brw_str{b_idx}],'var')
         scf=eval(['scf',brw_str{b_idx}]);  sfc_flag='sfc';
         [ o3,config_,sl_,hg_]=readb_ds_develop(bfile,brw_config_files(b_idx,1:2),scf);
      else
         sfc_flag='  ';
         [o3,config_,sl_,hg_]=readb_ds_develop(bfile,brw_config_files(b_idx,1:2));
         log{index_day}={'OK',bfile,brw_name{b_idx},lastwarn,sfc_flag}; missing(index_day)=0;
         disp(['OK-> ',bfile,' ',brw_name{b_idx},' ozone obs day ',num2str(unique(diaj(o3.ozone_ds(:,1)))')]);
      end
    catch
      err=lasterror;
      log{index_day}={'ERROR',bfile_f,brw_name{b_idx},err.message,sfc_flag};
      missing(index_day)=1;
      disp(['ERROR ',bfile,' ',brw_config_files{b_idx,1},' ',brw_config_files{b_idx,2}]);
    end
        
    try
      dsum=[dsum;o3.dsum];
      ozone_sum=[ozone_sum;o3.ozone_s];
      config=[config;config_];
      ozone_ds=[ozone_ds;o3.ozone_ds];
      ozone_raw0=[ozone_raw0;o3.ds_raw0];
      ozone_raw=[ozone_raw;o3.ozone_raw];
      sl=[sl;sl_.sls_c];        % first calibration (or bfile)
      sl_cr=[sl_cr;sl_.sls_cr]; % recalculated/second calibration
      hg=[hg;hg_.hg];
      bhg=[bhg;hg_.time_badhg];
      if ~isempty(o3.ds_raw0)
          ozone_ratios=[ozone_ratios;[o3.ds_raw0,o3.ozone_ds(:,[9:14,16:21])]];
      end
   %  leyendas
      ozone.ds_legend=o3.ozone_ds_legend;
   %  sumarios y medidas tal y como estan en el fichero
      ozone.dsum_legend=o3.dsum_legend;
      ozone.raw0_legend=o3.ds_raw0_legend;
   %  recalculadas
      ozone.ds_legend=o3.ozone_ds_legend;
      ozone.s_legend=o3.ozone_s_legend;         
    catch
      disp('Error assigning variables');
      log{index_day}={'ERROR',bfile,brw_name{b_idx},'Variables',sfc_flag};
    end
end
disp(brw(b_idx));

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
ozone.raw=ozone_raw;
ozone.ratios=ozone_ratios;
