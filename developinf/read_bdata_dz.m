function dz=read_bdata_dz(brewer,setup,fpath,spectral_setup)
 
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

if nargin<4
    spectral_setup=[];
else
    eval(['scf',brw_str{b_idx},'=spectral_setup']);
end

dzsum={}; dz_raw0={};
if nargin<=2
    bfile_p='BFILES'; fpath='';
else
    bfile_p=fpath;
end

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
%        index_day=day-CALC_DAYS(1)+1;
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
       log{index_day}={'ERROR',bfile_f,brw_name{b_idx},'Not found','   ','  ','  '};
       continue
    end

    try
      lastwarn('');
      if exist(['scf',brw_str{b_idx}],'var')
         scf=eval(['scf',brw_str{b_idx}]);  
         sfc_flag='sfc';
         dz=readb_ds_develop(bfile,brw_config_files(b_idx,1:2),scf);
      else
         sfc_flag='  ';
         [a b c]=fileparts(brw_config_files{b_idx,2});
        if ~isempty(strcat(b,c))
         dz_=readb_ds_develop_dz(bfile,brw_config_files(b_idx,1:2));
        else
         dz_=readb_ds_develop_dz(bfile,brw_config_files{b_idx,1});
        end
      end
      if isempty(dz_.dzsum)
         disp(bfile);  continue; 
      else
         disp(['OK-> ',bfile,' ',brw_name{b_idx},' ozone obs day ',num2str(unique(diaj(dz_.dzsum(:,1)))')]);
      end
    catch
      disp(['ERROR ',bfile,' ',brw_config_files{b_idx,1},' ',brw_config_files{b_idx,2}]);
    end  
    
    try
       dzsum=[dzsum;dz_.dzsum]; dz.dzsum=dzsum;
       dz_raw0=[dz_raw0;dz_.dz_raw0]; dz.dz_raw0=dz_raw0;
    catch
       disp('Error assigning variables');
    end

end
      

