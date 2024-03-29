function [NTC,tabla_regress]=temp_coeff_old_vs_new_report(config_file,sl,sl_cr,config,daterange,outlier_flag)
%% SL temperature analysis
%  
% TODO-> funciton
% outputs
% calculation from raw counts. Revisar linea 49
% 
%function [NTC,tabla_regress]=temp_coeff_old_vs_new_report(config_file,sl,sl_cr,config,daterange,outlier_flag)
% confif file-> used for genera setings
% sl-> old sl from readb_ds
% sl-> calculated with new config
% daterange
% filter outlier


if isempty(config_file)
    n_inst=6;
    brw_name{n_inst}='163';
    FINAL_DAYS(1)=0;
else
   eval(config_file);
end
%% OLD and new configuration files
TC=[];A=[];
TC_old=[]; cfg_old=[];cfg=[];
line={};
h=[];
out=[];
%i=n_inst;
%idx_inst=n_inst;

for i=n_inst
    
    a=cell2mat(config{n_inst}');
    % new config
    b=unique(a(1:end-1,2:2:end-1)','rows');
    A(i)=b(8);
    ETC(i)=b(11);
    %cfg(i,1:52)=b;
    TC(i,1:5)=b(2:6);
    
    % old config
    b=unique(a(1:end-2,1:2:end)','rows');
    A_old(i)=b(8);
    ETC_old(i)=b(11);
    %cfg_old(i,1:52)=b;
    TC_old(i,1:5)=b(2:6);
    
end
%Counts and recalculate conts comp%  idx_inst=i;
%   sls=cell2mat(sl_cr{i});
%  Fr_r=ratio2counts(sls);
%  Fr_r(:,1)=sls(:,1);
%  Fr_r(:,2)=sls(:,13);
%  
%  sls=cell2mat(sl{i})
%  Fr=ratio2counts(sls);
%  Fr(:,1)=sls(:,1);
%  Fr(:,2)=sls(:,13);
% figure;plot(Fr(:,1),Fr_r./Fr)
%  
 
%% SL recalculated with  configuration
% Temperature coefficients calculated with the configuration provided
% 


if iscell(sl{n_inst})
  sls=cell2mat(sl{n_inst});
  sls_n=cell2mat(sl_cr{n_inst});
else
    sls=sl{n_inst};
    sls_n=sl_cr{n_inst};
end

if size(sl,2)==1
      sls=cell2mat(sl);
      sls_n=cell2mat(sl_cr);
end


Fr=ratio2counts(sls);
Fr(:,1)=diaj2(sls(:,1));
Fr(:,2)=abs(sls(:,13));


Frn=ratio2counts(sls_n);
Frn(:,1)=diaj2(sls(:,1));
Frn(:,2)=abs(sls(:,13));

% Date filter
if nargin>3 % overwrite setup config
    date_range=daterange;
end

%% control de fechas
if exist('date_range','var') & ~isempty(date_range)
    j=find(sls(:,1)<date_range(1));
    Fr(j,:)=NaN;
    Frn(j,:)=NaN;
    if length(date_range)>1
        j=find(sls(:,1)>date_range(2));
        Fr(j,:)=NaN;
        Frn(j,:)=NaN;
    end
end
Fr_dep=[];
if exist('outlier_flag')
    for ii=0:5
        [a,b,out]=boxparams(Fr(:,3+ii),1.5);
        subplot(3,2,ii+1);
        plot(Fr(:,2),Fr(:,3+ii),'.','MarkerSize',1);
        hold on;
        plot(Fr(out,2),Fr(out,3+ii),'x','MarkerSize',14);
        Fr_dep=Fr(out,:) ;
        Fr(out,1)=NaN;
        Fr(out,3+ii)=NaN;
        Frn(out,1)=NaN;
        Frn(out,3+ii)=NaN;
    end
end
%%
f=figure;
set(f,'Tag','TEMP_COEF_DESC');
orient landscape;
suptitle(brw_name{n_inst})
subplot(2,4,1:2)
ploty(Fr(:,[1,3:end-2]),'.');
hold on;

set(gca,'LineWidth',1);
ylabel('Counts');
xlabel('day');

text(repmat(FINAL_DAYS(1)+.5,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
%legend({'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'},'BestOutSide');
ploty(Frn(:,[1,3:end-2]),'x');


subplot(2,4,3:4);
mmplotyy_temp(Fr(:,1),Fr(:,end),'.',Frn(:,end),'x');
set(gca,'LineWidth',1);
mmplotyy('R6 new');
xlabel('day')
% ylabel('R6');
mmplotyy('shrink');
legend({'R6','R6rc'},'Location','NorthEast','HandleVisibility','Off');
%legend('R6','R5');

subplot(2,4,5:6)
ploty(Fr(:,[2,3:end-2]),'.');
hold on;
ploty(Frn(:,[2,3:end-2]),'x');



set(gca,'LineWidth',1);
text(repmat(min(Fr(:,2))+1.5,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
%legend({'slit #0','slit #2','slit #3','slit #4','slit #5'},'BestOutside');
ylabel('Counts'); xlabel('temperature (�C)');
subplot(2,4,7:8);
mmplotyy_temp(Fr(:,2),Fr(:,end),'.',Frn(:,end),'x');
set(gca,'LineWidth',1);
mmplotyy('R6c');
xlabel('temperature (�C)')
mmplotyy('shrink');
suptitle(brw_name{n_inst})
legend(gca,{'R6','R6c'},'Location','NorthEast','HandleVisibility','Off');

%% OLD 
f=figure;
set(f,'tag','TEMP_global');
orient landscape;
plot(Fr(:,2),Fr(:,3:7),'.');

[a,b]=robust_line;
tc=b(2,:);otc=TC_old(n_inst,:);
if TC(n_inst,1)==0 % si esta normalizada o no
 NTC=-(tc-tc(1))+TC(n_inst,:);
else
 NTC=-tc+TC(n_inst,:)
end

title(num2str([TC_old(n_inst,:);NTC]));
grid;
xlabel('PMT Temperature (C\circ)');
ylabel('counts seconds');

%
%% NEW
f=figure;
set(f,'tag','TEMP_NEW_global');
orient landscape;
plot(Frn(:,2),Frn(:,3:7),'.');

[a,b]=robust_line;
tc=b(2,:);rtc=TC(n_inst,:);
if TC(n_inst,1)==0 % si esta normalizada o no
 NTC_=-(tc-tc(1))+TC(n_inst,:);
else
 NTC_=-tc+TC(n_inst,:)
end

title(num2str([TC(n_inst,:);NTC_]));
grid;
xlabel('PMT Temperature (C\circ)');
ylabel('counts seconds');


sl_temp={...
                'old ',num2str(TC(n_inst,:));...
                'new ',num2str( NTC);...
                'new2',num2str( b(2,:));
                };

suptitle(brw_name{n_inst})
%% REVISAR
O3W=[   0.00   -1.00    0.50    2.20   -1.70];

f=figure;
set(f,'tag','TEMP_OLD_VS_NEW');
FN=Fr;
FN(:,3:7)=Fr(:,3:7)+matmul(repmat(FN(:,2),1,5),+(-otc+rtc));%(NTC-TC(n_inst))

plot(Fr(:,2),Fr(:,3:7)*O3W','x')
hold on;plot(FN(:,2),FN(:,3:7)*O3W','bo')
legend({'R6  TC','R6 TC new'});
[a,r6tc]=rline;
title('R6 ratios, TC vs calculated TC');


%%
%%
f=figure;
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})
c=hsv(fix(length(unique(fix(Fr(~isnan(Fr(:,1)),1))))/3));

hl={};  line={};  stats={};
for ii=0:5
 %[a,b,out]=boxparams(Fr(:,3+ii),2.5);
 %Fr(out,3+ii)=NaN;
 subplot(3,2,ii+1)
 if ii==5 
     ii=ii+1;
 end
 plot(Frn(:,2),Frn(:,3+ii),'x','MarkerSize',1);
 [hl{ii+1,n_inst},line{ii+1,n_inst},stats{ii+1,n_inst}]=report_robust_line;
 hold on
 plot(Frn(out,2),Frn(out,3+ii),'x','MarkerSize',14);
 [h]=gscatter(Frn(:,2),Frn(:,3+ii),fix(Frn(:,1)/10)*10,c,[],10,'off');
 if ii==6
     [h]=gscatter(Frn(:,2),Frn(:,3+ii),fix(Frn(:,1)/10)*10,c,[],10,'on');
     lg=legend('show');
      set(lg,'Location','NorthEast','HandleVisibility','off');
 end
  set(gca,'LineWidth',1);
 %   if ii~=1
%      legend off;
%   end
  if ii==6
     title('MS9 ');       
     xlabel('PMT Temperature (�C)');
  else
     title([' Temperature coeff slit #',num2str(ii+2)]);
  end
 if ii==4
     xlabel('PMT Temperature (�C)');
 end
end
suptitle(brw_name{n_inst})
%% vs lamda
%lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
% figure;plot(lamda_nominal(2:end),aux(2,1:end-1))
%%TEMPT_COEFF----------------------------------------------> FUERA DE LA
%%FUNCION
label={'','0 abcissa +/- standard error','slope +/- standard error'};
error=stats(:,n_inst); coeff=line(:,n_inst);

tabla_regress={{''},{'intercept +/- standard error'},{'slope +/- standard error'}
    {'SLIT #2 '},{sprintf('%g +/- %g',[round(coeff{1}(1)),round(error{1}.se(1))])},{sprintf(' %3.1f +/- %3.1f',[coeff{1}(2),error{1}.se(2)])}
    {'SLIT #3 '},{sprintf('%g +/- %g',[round(coeff{2}(1)),round(error{2}.se(1))])},{sprintf(' %3.1f +/- %3.1f',[coeff{2}(2),error{2}.se(2)])}
    {'SLIT #4 '},{sprintf('%g +/- %g',[round(coeff{3}(1)),round(error{3}.se(1))])},{sprintf(' %3.1f +/- %3.1f',[coeff{3}(2),error{3}.se(2)])}
    {'SLIT #5 '},{sprintf('%g +/- %g',[round(coeff{4}(1)),round(error{4}.se(1))])},{sprintf(' %3.1f +/- %3.1f',[coeff{4}(2),error{4}.se(2)])}
    {'SLIT #6 '},{sprintf('%g +/- %g',[round(coeff{5}(1)),round(error{5}.se(1))])},{sprintf(' %3.1f +/- %3.1f',[coeff{5}(2),error{5}.se(2)])}
    {'MS9 '}    ,{sprintf('%g +/- %g',[round(coeff{7}(1)),round(error{7}.se(1))])},{sprintf(' %3.1f +/- %3.1f',[coeff{7}(2),error{7}.se(2)])}};
% tabla_regress={{''},{'SLIT #2 '},{'SLIT #3 '},{'SLIT #4 '},{'SLIT #5 '},{'SLIT #6 '},{'MS9 '}
%     {'intercept '},{sprintf('%+0.1f +/- %0.2f',coeff{1}(1),error{1}.se(1))},...
%                    {sprintf('%+0.1f +/- %0.2f',coeff{2}(1),error{2}.se(1))},...
%                    {sprintf('%+0.1f +/- %0.2f',coeff{3}(1),error{3}.se(1))},...
%                    {sprintf('%+0.1f +/- %0.2f',coeff{4}(1),error{4}.se(1))},...
%                    {sprintf('%+0.1f +/- %0.2f',coeff{5}(1),error{5}.se(1))},...
%                    {sprintf('%+0.1f +/- %0.2f',coeff{7}(1),error{7}.se(1))} 
%     {'slope '},{sprintf('%+0.1f +/- %0.2f',coeff{1}(2),error{1}.se(2))},...
%                {sprintf('%+0.1f +/- %0.2f',coeff{2}(2),error{2}.se(2))},...
%                {sprintf('%+0.1f +/- %0.2f',coeff{3}(2),error{3}.se(2))},...
%                {sprintf('%+0.1f +/- %0.2f',coeff{4}(2),error{4}.se(2))},...
%                {sprintf('%+0.1f +/- %0.2f',coeff{5}(2),error{5}.se(2))},...
%                {sprintf('%+0.1f +/- %0.2f',coeff{7}(2),error{7}.se(2))}};

