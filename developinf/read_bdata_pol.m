function [ozone,log,missing]=read_bdata_pol(brewer,setup,fpath,spectral_setup,location)

% lee los ficheros del directorio bfiles

b_idx=brewer;  fprintf('\n\rBrewer: %s\n\r',setup.brw_name{b_idx});
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

if nargin<5
    location=[];
end

if nargin<4 
    spectral_setup=[];
else
    eval(['scf',brw_str{b_idx},'=spectral_setup']);
end

dsum={}; dksum={}; ozone_raw0={}; ozone_raw0_dk={};
ozone_sum={}; ozone_dksum={}; ozone_ds={}; ozone_dk={};
ozone_raw={};  ozone_raw_dk={};
ozone_ratios={};

config={};  sl={};     sl_cr={};     hg={};     bhg={};
missing=NaN;

ozone_dzsum={};
ozone_dzraw0={};

ozone=[];

if nargin<=2
    bfile_p='BFILES'; fpath='';
else
    bfile_p=fpath;
end
%default
if isempty(fpath) bfile_p='BFILES'; end 

index_day=1;
for dd=CALC_DAYS
    bfile_f=[]; o3=[];config_=[];sl_=[];hg_=[];
       
    if dd>366  % matlab date 
        yr=year(dd); day=diaj(dd); 
    elseif dd<0
       yr=abs(floor(dd/365)); day=dd;
    else
       yr=cal_year; day=dd;
    end       
    if day<0
       if isempty(fpath)
          bfile_path=fullfile(setup.path_root,'..',sprintf('20%02d',cal_year-2001),bfile_p);
          bfile_f=sprintf('B%03d%02d.%s',365+day,cal_year-2001,brw_str{b_idx});  
       else
          bfile_path=fullfile(bfile_p,num2str(cal_year-yr),'BFILES');
          bfile_f=sprintf('B%03d%02d.%s',365*yr+day,(cal_year-yr)-2000,brw_str{b_idx});  
       end
       index_day=abs(day-CALC_DAYS(1))+1;    
       bfile_f=fullfile(bfile_path,bfile_f);
       if ~exist(bfile_f)
          bfile_f=sprintf('B%03d%02d.%03d',365+day,cal_year-2001,brw(b_idx));  
          bfile_f=fullfile(bfile_path,'..',strcat('bdata',brw_str{b_idx}),num2str(cal_year-1),bfile_f);    
       end
    else
       if dd>366 % fecha matlab
          path_root=fullfile(setup.path_root,'..',sprintf('%04d',yr));
       else
          path_root=setup.path_root;           
       end
       if isempty(fpath)
          bfile_path=fullfile(path_root,bfile_p);
       else
          if yr~=cal_year 
           bfile_path=fullfile([bfile_p,brw_str{b_idx}],num2str(yr));
          else 
           bfile_path=fullfile([bfile_p,brw_str{b_idx}]);
          end
       end
       bfile_f=sprintf('B%03d%02d.%03d',day,yr-2000,brw(b_idx));  
       bfile_f=fullfile(bfile_path,bfile_f);
    end

    [path nam ext]=fileparts(bfile_f);
    if exist(fullfile(path,[nam,'_dep',ext]))
       bfile=fullfile(path,[nam,'_dep',ext]); 
    elseif exist(bfile_f)
       bfile=bfile_f;
    else
       disp(['Missing   ',bfile_f]);
       missing(index_day)=NaN;
       log{index_day}={'ERROR',bfile_f,brw_name{b_idx},'Not found','   ','  ','',''};
       continue
    end

    try
      lastwarn('');
      if exist(['scf',brw_str{b_idx}],'var')
         scf=eval(['scf',brw_str{b_idx}]);  
         sfc_flag='sfc';
         [ o3,config_,hg_,loc_]=readb_ds_develop_pol(bfile,brw_config_files(b_idx,1:2),scf);
         if ~isempty(o3.ozone_ds)
            disp(['OK-> ',bfile,' ',brw_name{b_idx},' ozone obs day ',num2str(unique(diaj(o3.ozone_ds(:,1)))')]);
         else
            disp(['OK-> ',bfile,' ',brw_name{b_idx},' No ozone for day ',num2str(unique(diaj(sl_.sl_cr(:,1)))')]);
         end
      else
         sfc_flag='  ';
         [a b c]=fileparts(brw_config_files{b_idx,2});
        if ~isempty(strcat(b,c))
         [o3,config_,hg_,loc_]=readb_ds_develop_pol(bfile,brw_config_files(b_idx,1:2));
         if ~isempty(o3.ozone_ds)
            disp(['OK-> ',bfile,' ',brw_name{b_idx},' ozone obs day ',num2str(unique(diaj(o3.ozone_ds(:,1)))')]);
         else
            disp(['OK-> ',bfile,' ',brw_name{b_idx},' No ozone for day ',num2str(unique(diaj(sl_.sl_cr(:,1)))')]);
         end
        else
         [o3,config_,hg_,loc_]=readb_ds_develop_pol(bfile,brw_config_files{b_idx,1});
         if ~isempty(o3.ozone_ds)
            disp(['OK-> ',bfile,' ',brw_name{b_idx},' ozone obs day ',num2str(unique(diaj(o3.ozone_ds(:,1)))')]);
         else
            disp(['OK-> ',bfile,' ',brw_name{b_idx},' No ozone for day ',num2str(unique(diaj(sl_.sl_cr(:,1)))')]);
         end
        end
      end
    catch
      err=lasterror;
      log{index_day}={'ERROR',bfile_f,brw_name{b_idx},err.message,sfc_flag,'  ','  '};
      missing(index_day)=1;
      disp(['ERROR ',bfile,' ',brw_config_files{b_idx,1},' ',brw_config_files{b_idx,2}]);
    end
        
    try
        
    if isempty(location) || ~isempty(strmatch(lower(location),lower(strtrim(loc_.str))))
      dsum=[dsum;o3.dsum]; dksum=[dksum;o3.dksum];
      ozone_raw0=[ozone_raw0;o3.ds_raw0]; ozone_raw0_dk=[ozone_raw0_dk;o3.dk_raw0];
      ozone_sum=[ozone_sum;o3.ozone_s];   ozone_dksum=[ozone_dksum;o3.ozone_dks];
      ozone_ds=[ozone_ds;o3.ozone_ds];    ozone_dk=[ozone_dk;o3.ozone_dk];
      ozone_raw=[ozone_raw;o3.ozone_raw]; ozone_raw_dk=[ozone_raw_dk;o3.ozone_raw_dk];
            
      config=[config;config_];
      hg=[hg;hg_.hg];
      if ~isempty(o3.ds_raw0)
          ozone_ratios=[ozone_ratios;[o3.ds_raw0,o3.ozone_ds(:,[9:14,16:21])]];
      end
      missing(index_day)=0;
      log{index_day}={'OK ',location,bfile,brw_name{b_idx},lastwarn,sfc_flag,datestr(config_(1,1)),datestr(config_(1,2))};
   %  leyendas
      ozone.ds_legend=o3.ozone_ds_legend;
   %  sumarios y medidas tal y como estan en el fichero
      ozone.dsum_legend=o3.dsum_legend;
      ozone.raw0_legend=o3.ds_raw0_legend;
   %  recalculadas
      ozone.ds_legend=o3.ozone_ds_legend;
      ozone.s_legend=o3.ozone_s_legend;  
    else
      disp(sprintf('%s (%s) Not in location %s',bfile,location ,strtrim(loc_.str)));
      disp(loc_)  
      disp('Error assigning variables');
      log{index_day}={'ERROR',location,bfile,brw_name{b_idx},'Variables',sfc_flag,' ',''};
    end

    catch
      disp('Error assigning variables');
      log{index_day}={'ERROR',location,bfile,brw_name{b_idx},'Variables',sfc_flag,' ',''};
    end
    index_day= index_day+1;
end

ozone.dsum=dsum;
ozone.raw0=ozone_raw0;
ozone.ozone_sum=ozone_sum;
ozone.ozone_dksum=ozone_dksum;
ozone.ozone_ds=ozone_ds;
ozone.ozone_dk=ozone_dk;
ozone.raw=ozone_raw;
ozone.raw_dk=ozone_raw_dk;
ozone.config=config;
ozone.hg=hg;

