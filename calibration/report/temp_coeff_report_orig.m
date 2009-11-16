%% SL temperature analysis
%  
% TODO-> funciton
% outputs
% calculation from raw counts.
function [NTC]=temp_coeff_report(config_file,sl,config,daterange,outlier_flag)
eval(config_file);
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
else
    sls=sl{n_inst};
end
Fr=ratio2counts(sls);

Fr(:,1)=diaj2(sls(:,1));
Fr(:,2)=abs(sls(:,13));
% Date filter
if nargin>3 % overwrite setup config
    date_range=daterange;
end

if exist('date_range') & ~isempty(date_range)
    j=find(sls(:,1)<date_range(1));
    Fr(j,:)=NaN;
    if length(date_range)>1
        j=find(sls(:,1)>date_range(2));
        Fr(j,:)=NaN;
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
    end
end



f=figure;
set(f,'Tag','TEMP_COEF_DESC');
orient landscape;
suptitle(brw_name{n_inst})
subplot(2,4,1:2)
ploty(Fr(:,[1,3:end-2]),'.');
title('Counts');
legend({'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'},'BestOutSide');

subplot(2,4,3:4);
mmplotyy(Fr(:,1),Fr(:,end),'.',Fr(:,end-1),'x');
mmplotyy('R5');
xlabel('day')
ylabel('R6');
mmplotyy('shrink');
legend('R6','R5');

subplot(2,4,5:6)
ploty(Fr(:,[2,3:end-2]),'.');
title('raw counts vs temperature');
legend({'slit #0','slit #2','slit #3','slit #4','slit #5'},'BestOutside');
xlabel('temperature C�')
subplot(2,4,7:8);
mmplotyy(Fr(:,2),Fr(:,end),'.',Fr(:,end-1),'x');
mmplotyy('R5');
xlabel('temperature C�')
ylabel('R6');

mmplotyy('shrink');

suptitle(brw_name{n_inst})
legend('R6','R5');
%f=figure;
%set(f,'Tag','TEMP_COEF_DEPURATION');
%orient landscape;
%%
f=figure;
set(f,'tag','TEMP_global');
orient landscape;
plot(Fr(:,2),Fr(:,3:7),'.');
[a,b]=robust_line;
tc=b(2,:);
NTC=-(tc-tc(1))+TC(n_inst,:);
title(num2str([TC(n_inst,:);NTC]));
grid;
xlabel('PMT Temperature (C\circ)');
ylabel('counts seconds');

sl_temp={...
                'old ',num2str(TC(n_inst,:));...
                'new ',num2str( NTC);...
                'new2',num2str( b(2,:));
                };

suptitle(brw_name{n_inst})
%%
O3W=[   0.00   -1.00    0.50    2.20   -1.70];

f=figure;
set(f,'tag','TEMP_OLD_VS_NEW');
FN=Fr;
FN(:,3:7)=Fr(:,3:7)+matmul(repmat(FN(:,2),1,5),(NTC-TC(n_inst)));

plot(Fr(:,2),Fr(:,3:7)*O3W','x')
hold on;plot(FN(:,2),FN(:,3:7)*O3W','bo')
legend({'R6  TC','R6 TC new'});
[a,r6tc]=robust_line;
title('R6 ratios, TC vs calculated TC');



%%
f=figure;
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})
c=hsv(fix(length(unique(fix(Fr(~isnan(Fr(:,1)),1))))/3));


for ii=0:5
 %[a,b,out]=boxparams(Fr(:,3+ii),2.5);
 %Fr(out,3+ii)=NaN;
 subplot(3,2,ii+1)

 if ii==5
     title(' MS9');ii=ii+1;  
 else
    title([' Temperature coeff slit',num2str(ii)]);
  end
 plot(Fr(:,2),Fr(:,3+ii),'x','MarkerSize',1);
 [h(n_inst),line{n_inst}]=robust_line;
 hold on
 plot(Fr(out,2),Fr(out,3+ii),'x','MarkerSize',14);
 h=gscatter(Fr(:,2),Fr(:,3+ii),fix(Fr(:,1)/5)*5,c);
 xlabel('PMT Temperature (C\circ)');
  if ii~=1
    legend off;
  end
end
suptitle(brw_name{n_inst})
%% vs lamda
%lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
% figure;plot(lamda_nominal(2:end),aux(2,1:end-1))

