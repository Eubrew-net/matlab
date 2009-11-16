%% SL temperature analysis
%  
% TODO-> funciton


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
 
%% SL recalculated with new configuration
% Temperature coefficients calculated with the new configuration
% 

sls=cell2mat(sl_cr{n_inst});
Fr=ratio2counts(sls);
Fr(:,1)=diaj2(sls(:,1));
Fr(:,2)=sls(:,13);
% Date filter
%j=find(Fr(:,1)<datenum(2008,11,13) | Fr(:,1)>datenum(2008,11,17));
%Fr(j,:)=NaN;


f=figure
set(f,'Tag','TEMP_COEF_DESC');
orient landscape;
subplot(2,4,1:2)
ploty(Fr(:,[1,3:end-2]),'.');
title('Counts');
legend({'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'});
%datetick;
subplot(2,4,3)
ploty(Fr(:,[1,end-1]),'.')
title('R5');
%datetick;
subplot(2,4,4)

ploty(Fr(:,[1,end]),'.');
title('R6');
%datetick;


subplot(2,4,5:6)
ploty(Fr(:,[2,3:end-2]),'.');
title('raw counts vs temperature');
legend({'slit #0','slit #2','slit #3','slit #4','slit #5'});
xlabel('temperature C�')
subplot(2,4,7)
ploty(Fr(:,[2,end-1]),'.');
title('R5');
xlabel('temperature C�')
subplot(2,4,8)

ploty(Fr(:,[2,end]),'.')
title('R6');
xlabel('temperature C�')



f=figure
set(f,'Tag','TEMP_COEF_DEPURATION');
orient landscape;
Fr_dep=[];


% for ii=0:5
%  [a,b,out]=boxparams(Fr(:,3+ii),1.5);
%  subplot(3,2,ii+1);
%  plot(sls(:,13),Fr(:,3+ii),'.','MarkerSize',1);
%  hold on;
%  plot(sls(out,13),Fr(out,3+ii),'x','MarkerSize',14);
%  Fr_dep=Fr(out,:) ;
%  Fr(out,1)=NaN;
%  Fr(out,3+ii)=NaN;
%  
%end
%%
f=figure;
set(f,'tag','TEMP_global');
orient landscape;
plot(sls(:,13),Fr(:,3:7),'.');
[a,b]=robust_line;
tc=b(2,:);
NTC=-(tc-tc(1))+TC(n_inst,:);
title(num2str([TC(n_inst,:);NTC]));
grid;
xlabel('PMT Temperature (�C)');
ylabel('counts seconds');

sl_temp={...
                'old ',num2str(TC(n_inst,:));...
                'new ',num2str( NTC);...
                'new2',num2str( b(2,:));
                };

%%
f=figure;
set(f,'tag','TEMP_day');
orient landscape;
c=hsv(fix(size(sls,1)/10));
for ii=0:5
 %[a,b,out]=boxparams(Fr(:,3+ii),2.5);
 %Fr(out,3+ii)=NaN;
 subplot(3,2,ii+1)

 if ii==5
     title(' MS9');ii=ii+1;
     
     
 else
    title([' Temperature coeff slit',num2str(ii)]);
  end
 plot(sls(:,13),Fr(:,3+ii),'x','MarkerSize',1);
 [h(n_inst),line{n_inst}]=robust_line;
 hold on
 plot(sls(out,13),Fr(out,3+ii),'x','MarkerSize',14);

 h=gscatter(sls(:,13),Fr(:,3+ii),fix(diaj(sls(:,1))/1)*1,c);

 xlabel('PMT Temperature (C\circ)');
 
if ii~=1
    legend off;
end
end

%% Second set
%

sls=cell2mat(sl{n_inst});
Fr=ratio2counts(sls);
Fr(:,1)=sls(:,1);
Fr(:,2)=sls(:,13);

%j=find(Fr(:,1)<datenum(2008,11,13))
%j=find(Fr(:,1)<datenum(2008,11,13) | Fr(:,1)>datenum(2008,11,18));
%Fr(j,3:end)=NaN;

%Fr(j,:)=NaN;
figure
subplot(2,3,1)
ploty(Fr(:,[1,3:end-2]))
datetick;
subplot(2,3,2)
ploty(Fr(:,[1,end-1]))
datetick;
subplot(2,3,3)
ploty(Fr(:,[1,end]))
datetick;


subplot(2,3,4)
ploty(Fr(:,[2,3:end-2]))
subplot(2,3,5)
ploty(Fr(:,[2,end-1]))

subplot(2,3,6)
ploty(Fr(:,[2,end]))



%%
f=figure;
set(f,'tag','TEMP_global_2');
plot(sls(:,13),Fr(:,3:7),'.');
[a,b]=robust_line;
tc=b(2,:);
NTC=-(tc-tc(1))+TC_old(n_inst,:);
title(num2str([TC_old(n_inst,:);NTC]))
grid;
xlabel('PMT Temperature (C\circ)');
ylabel('counts seconds');

sl_temp={...
                'old ',num2str(TC_old(n_inst,:));...
                'new ',num2str( NTC);...
                'new2',num2str( b(2,:));
                };

%%
f=figure;
set(f,'tag','TEMP_day_2');
c=hsv(size(find(~isnan(Fr(:,1))),1)/2);
line={};
for ii=0:5
  %[a,b,out]=boxparams(Fr(:,2+ii),2.5);
  %Fr(out,3+ii)=NaN;
   subplot(3,2,ii+1)

 plot(sls(:,13),Fr(:,3+ii),'x','MarkerSize',1);
 [h(ii+1),line{ii+1}]=robust_line;
 hold on
 %plot(sls(out,13),Fr(out,3+ii),'x','MarkerSize',14);

 h=gscatter(sls(:,13),Fr(:,3+ii),fix(diaj(Fr(:,1))),c);

 xlabel('PMT Temperature (�C)');
 if ii==5
     title(' MS9');ii=ii+1;
 else
    title([' Temperature coeff slit',num2str(ii)]);
  end
if ii~=1
    legend off;
end
end

%% vs lamda
%lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];
% figure;plot(lamda_nominal(2:end),aux(2,1:end-1))

