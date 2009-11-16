%% final calibration 
% Reference Brewer #185
% days 254-255
% reference

blinddays={};
for i=1:length(brw)
  blinddays{i}=FINAL_DAYS;
end;
 
 x{n_inst}=[]; 
 ox{n_inst}=[];
 osc_smooth{n_inst}=[];
 osc_smooth{n_inst}=[]; 
 jday=findm((diaj(summary{n_inst}(:,1))),blinddays{n_inst},0.5);
 inst=summary{n_inst}(jday,:);
 jday=findm((diaj(summary{n_ref}(:,1))),blinddays{n_ref},0.5);
 ref=summary{n_ref}(jday,:);
     % summary datos para la calibracion;
     % ozone_r=recalculated; ozone_1:original ; ozone_sl-> recalc+SL
     % date,sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1
     % ozone_sl sigma_sl
   try
    % fecha, ozono, sza,    
    [x{n_inst},r,rp,ra,dat,ox{n_inst},osc_smooth{n_inst}]=ratio_min_ozone(inst(:,[1,12,3,2,4,5]),ref(:,[1,10,3,2,4,5]),TIME_SYNC,brw_str{n_inst},brw_str{n_ref});
    ox{n_inst}(1,1)=brw(n_inst); 
    rx{n_inst}=ratio_min(inst(:,[1,6]),ref(:,[1,6]),TIME_SYNC,...
        brw_str{n_inst},brw_str{n_ref});
    
    catch
      disp(lasterror);
    end
 
[ETC_NEW,o3c,m_etc]=ETC_calibration(file_setup,summary,A,n_inst,[],[],[],[])

% %
% M=cell(size(m_etc));
% M(:,1)=cellstr(datestr(m_etc(:,1)+datenum(cal_year,1,0)));
% makeHtmlTable(m_etc,[],M(:,1),{'JDay',['O3 #',brw_str{n_ref}],...
%               'O3 std','N obs',['O3 #',brw_str{n_inst}],'O3 std','O3new',...
%               [' % ',brw_str{n_ref},'-',brw_str{n_inst},'/',brw_str{n_ref}],'%new'});


%
         
% % %%       
% % %%print
% % fend=figure;
% % try
% %     snapnow;
% % catch
% %     disp('report');
% % end
% % printfiles_fast(f0,fend,[brw_str{n_inst},'_figures_cal']);


% % %% detailed comparison
% % %save detailed_comparison o3_c
% % %load detailed_comparison
% % head='Date_matlab date_dif sza_R airm_R temp_R filter_R O3_R sO3_R ms9 sm9 O3_R_o SO3_R_o O3_R_sl sO3_R_sl I_sza I_airm I_temp I_filter O3_I sO3_I ms9_I sm9_I O3_I_o sO3_I_o O3_I_sl sO3_I_sl';
% % [o3,i,j]=unique(o3_c(:,1));
% % label_detailed=mmcellstr(strtrim(strrep(head,' ','|')));
% % columns_detailed_report=[1:8,21,19,23];
% % aux=[cellstr(datestr(o3_c(i,1))),num2cell(o3_c(i,columns_detailed_report))];
% % xlswrite_(aux,'',['Date';label_detailed(columns_detailed_report)],'detailed_report.xls');
% % 
% % % configration files
% % head2=[cellstr(leg),num2cell(config_def),num2cell(config_orig),num2cell(config_ref)]';
% % head2{2}='Final ICF';
% % head2{3}='Original ICF';
% % head2{4}='Reference ICF';
% % xlswrite('detailed_report.xls',head2,2);
% % % 'Date, Diff(min), REF

%close all;
         
%                
% 
%          try
%              [m,s,n,name,v,ci]=grpstats(ms9-o3p,ozone_scale,{'mean','std','numel','gname','var','meanci'});
%              x=unique(ozone_scale);
%              errorbar(x,m,x-s,x+s);
%              [r,gof,c]=fit(x,m,'power2','StartPoint',[line(1),1,line(2)],'Robust','on');
%              if gof.rsquare>0.75
%                plot(r,'r.');
%                R=coeffvalues(r);
%                hline(R(3),'r',num2str(R(3)));
%                hline(r(0.68),'k',num2str(fix(r(0.68))));
%                hline(median(m),'g',num2str(median(m)));
%                
%                vline(0.68,'k',num2str(0.68));
%                
%                title({formula(r),num2str(coeffvalues(r))});
%              else
%                hline(median(m),'r',num2str(median(m)));
%                 
%              end
%          catch
%              disp('line');
%          end
%          suptitle(brw_str(i));
%end
  
 
