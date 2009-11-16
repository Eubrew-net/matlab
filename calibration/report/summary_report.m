function [A,summary,ozone_day_sum]=summary_report(file_save)
load(file_save) 

% SL report
% close all;
f0=figure;
sl_s={};
slf={};
R6_={};
close all;
for ii=1:length(brw)
    try
    if ii==n_inst 
      [slf{ii},sl_s{ii},sl_out{ii},R6_{ii}]=sl_report_jday(ii,sl_cr,brw_name,[],1);
    else
      [slf{ii},sl_s{ii},sl_out{ii},R6_{ii}]=sl_report_jday(ii,sl_cr,brw_name,[],0);
    end
    catch
     aux=lasterror;aux.message  
      disp(brw_str(ii)) 
    end
%     if i~=4
%      printfiles(f1,gcf,['SL_2007_']);
%     end
end


% aï¿½adimos el sl
% save(file_save)

% READ Configurati
% READ Configuration
% configuration for FINAL days
% load(file_save)
% eval(file_setup)

[A,ETC,SL_B,cfg,icf_brw]=read_cal_config(config,file_setup,sl_s);

tabla_sl=printmatrix([brw;ETC.old;ETC.new;A.old;A.new;SL_OLD_REF';SL_NEW_REF';fix(SL_B)']',4);
cell2csv('tabla_config.csv',tabla_sl',';');

% makeHtmlTable(round(10000*[brw;ETC.old;ETC.new;A.old;A.new;SL_OLD_REF';SL_NEW_REF';fix(SL_B)']')/10000);

% DATA RECALCULATION for summaries  and individual observations
cal=cell(1,n_brw);
summary=cal;
summary_old=cal; 
for i=1:length(brw)
    [cal{i},summary{i},summary_old{i}]=summary_reprocess(file_setup,i,ozone_ds,ozone_sum,A,sl_s,1);
end

% SUMMARY
blinddays={};
for i=1:length(brw)
  blinddays{i}=CALC_DAYS;
end;

jday=findm(diaj(diaj(summary{n_ref}(:,1))),blinddays{n_ref},0.5);
ref=summary{n_ref}(jday,:);
jday=findm(diaj(diaj(summary{n_inst}(:,1))),blinddays{n_inst},0.5);
inst=summary{n_inst}(jday,:);

[aa,bb]=findm_min(ref(:,1),inst(:,1),TIME_SYNC);
o3_c=[ref(aa,1),ref(aa,1)-inst(bb,1),ref(aa,2:end),inst(bb,2:end)];
         
[m,s,n,grpn]=grpstats(o3_c(:,[1,13,25,end]),{diaj(o3_c(:,1))},{'mean','std','numel','gname'});         
ozone_day_sum=round([diaj(m(:,1)),m(:,2),s(:,2),n(:,2),m(:,3),s(:,3),100*(m(:,3)-m(:,2))./m(:,2)]*10)/10;    

%
% makeHtmlTable(ozone_day_sum,[],cellstr(datestr(ozone_day_sum(:,1)+datenum(cal_year,1,0))),...
%     {'Day',['O3 #',brw_str{n_ref}],'O3 std','N obs',['O3 #',brw_str{n_inst}],'O3 std',[' % ',brw_str{n_ref},'-',brw_str{n_inst},'/',brw_str{n_ref}]})
%


% save(file_save);
% PLOT

c=jet(length(brw)+2);       
f=figure; 
set(f,'Tag','_GlobalPlot_');
h=plot(1);
MK=set(plot(1),'Marker');
for i=length(MK):length(brw)
   MK{i}='.';
end
MK{n_inst}='o';
MK{n_ref}='*';



%MK{n_inst}='+';
MK{n_inst}='o';
MK{n_ref}='*';

clf
hold on;
for i=1:length(brw)
   %h(i)=ploty(cal{i}(:,[1,6]),'.');
   %set(h(i),'color',c(i,:));
   k(i)=ploty(summary{i}(:,[1,end-1]),'*');
   if i==n_inst
       k(length(brw)+1)=ploty(summary_old{i}(:,[1,end-1]),'bs');
       %k(length(brw)+2)=ploty(summary_old{i}(:,[1,7]),'c.');
   end
   %k2(i)=ploty(summary{i}(:,[1,4]),':.');
   set(k(i),'color',c(i,:),'Marker',MK{i});
   %set(k2(i),'color',c(i,:),'Marker',MK{i});
   if mod(i,2)==1 
       set(k(i),'MarkerFaceColor',c(i,:))
   end
end  
set(gca,'LineWidth',1);
title([' RBCC-E Izaña Atmospheric Observatory',num2str(cal_year)])
legend(k,[brw_name,([brw_name{n_inst},'_s_l'])],'Location','Best');
datetick('keepticks');
xlabel('Date'); ylabel('Dobson Units');
grid; box on;
orient('portrait');  Options=printfiles; applytofig(gcf,Options);
set(findobj(gcf,'Tag','legend'),'FontSize',9)
set(gcf, 'units', 'centimeters', 'pos', [0 0 16 10]);


% %% Final status day 246-248
% 
% 
% for dj=CALC_DAYS
%     
%  c=(hot(length(brw)+2));       
%     f=figure; 
%     set(f,'Tag','_DayPlot_');
%  
%     h=plot(1);
%     clf
%     hold on;
%     for i=1:length(brw)
%         
%        k(i)=ploty(summary{i}(:,[1,end-1]),'.');
%        set(k(i),'color',c(i,:),'Marker',MK{i});
%        if i==3
%         set(k(i),'color',[1,0,0],'Marker','d','LineWidth',2);
%        end
%      if i==n_inst
%        set(k(i),'color',[0,0,0],'Marker','o','LineWidth',2);
%        k(length(brw)+1)=ploty(summary_old{i}(:,[1,end-1]),'bs');
%        %k(length(brw)+2)=ploty(summary_old{i}(:,[1,7]),'c.');
%      end
% 
% %        if mod(i,2)==1 
% %            set(k(i),'MarkerFaceColor',c(i,:))
% %        end
%     end
%     suptitle('RBCC-E ')
%     axis([datenum(cal_year,1,1)+dj-1+.25,datenum(cal_year,1,1)+dj-.20,280,400])
%     %legend(k,brw_name,-1);
%     legend(k,[brw_name,([brw_name{n_inst},'_s_l'])]);
%     set(f,'Tag',['__DayPlot__',datestr(datenum(cal_year,1,1)+dj)]);
%     datetick('keeplimits');
%     box on
%     grid
%     ylabel('Dobson Units')
%     title(datestr(datenum(cal_year,1,1)+dj-1));
%     xlabel('Hour (GMT)')
%     
%    
% end
% 
% 
% 
% 
% INITIAL CALIBRATION
% Reference Brewer #185
% days 254-255
% reference


