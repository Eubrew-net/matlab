function [NTC,tabla_regress,Fr]=temp_coeff_report(config_file,sl,config,varargin)

% SL temperature analysis
%  
% TODO
% cambiar la fecha para contemplar mas de un a�o
% outputs
% calculation from raw counts. Revisar linea 49
%
% Alberto 09/2009
% Modificado el plot para elegir el numero de dias a plotear
%  ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
%  nrep=ceil(ndays/20);
%  c=hsv(ceil(ndays/nrep));
%  
% Juanjo 10/11/2009: Redefino los inputs de la funci�n. Tres son
%        obligatorios; config_file, sl y config. Otros tres opcionales;
%        - 'daterange' -> array de uno o dos elementos (fecha matlab)
%        - 'outlier_flag' -> 1=depuraci�n, 0=no depuraci�n
% 
% Ejemplo:
% [NTC,tabla_regress]=temp_coeff_report(config_temp,sl_cr,config,'daterange',...
%                                       datenum(cal_year,cal_month-10,1),...
%                                       'outlier_flag',1);
% 

ok_vargs = {'date_range','outlier_flag'};

    for j=1:2:(length(varargin)-1)
        pname = varargin{j};
        pval = varargin{j+1};
        k = strmatch(pname, ok_vargs);
        if isempty(k)
            disp(sprintf('%s %s','Error temp_coeff_report: Unknown parameter name ', pname));
        elseif length(k)>1
            disp(sprintf('%s %s','Error temp_coeff_report: Ambiguous parameter name ', pname));
        else
            switch(k)
                case 1  % daterange
                     date_range = pval;
                case 2  % color
                     outlier_flag = pval;
            end            
        end
    end              

if isstruct(config_file)
     n_inst=config_file.n_inst;
     brw_name{n_inst}=config_file.brw_name;
     FINAL_DAYS(1)=config_file.final_days;
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
    %falla si solo hay 1
    if size(a,2)>2
    b=unique(a(1:end-1,2:2:end)','rows');
    else
    b=unique(a(1:end-1,2)','rows');
    end
    A(i)=b(8);
    ETC(i)=b(11);
    %cfg(i,1:52)=b;
    TC(i,1:5)=b(2:6);
    
    % old config
    b=unique(a(1:end-1,1:2:end-1)','rows');
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
if isfloat(sl)
   Fr=ratio2counts_avg(sl);
   sls=sl;
elseif iscell(sl)
       if iscell(sl{n_inst})
          sls=cell2mat(sl{n_inst});
          Fr=ratio2counts(sls);
          Fr(:,1)=diaj2(sls(:,1)); %fecha
          Fr(:,2)=abs(sls(:,13));
         %Fr(:,10)=sls(:,1); %fecha 
       else
          sls=sl{n_inst};
          Fr=ratio2counts(sls);
          Fr(:,1)=diaj2(sls(:,1)); %fecha
          Fr(:,2)=abs(sls(:,13));
       end
elseif isstruct(sl)
    sls=cat(1,sl.c);
    Fr=ratio2counts(sls);    
    Fr(:,1)=diaj2(sls(:,1)); %fecha
    Fr(:,2)=abs(sls(:,13));
end
%Fr=ratio2counts(sls);

%% control de fechas
if exist('date_range','var')
    j=find(sls(:,1)<(date_range(1)));
    Fr(j,:)=NaN;
    if length(date_range)>1
        j=find(sls(:,1)>(date_range(2)));
        Fr(j,:)=NaN;
    end
end


%% Depuraci�n de Outliers
%only for julian
%  j=find(Fr(:,2)>25);
%  Fr(j,:)=NaN;
 


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

%% time dependence removed

x=[Fr(:,1),ones(size(Fr(:,1)))];
y=Fr(:,3:7);
Fx=Fr;
%dt=NaN*zeros(5,1);
%st=NaN*zeros(5,2);
for i=1:5
    bx=regress(y(:,i),x); %dependencia del tiempo
    Fx(:,i+2)=Fr(:,i+2)-(bx(1)*x(:,1)+bx(2))+nanmean(Fr(:,i+2));
end
O3W=[     0.00   -1.00    0.50    2.20   -1.70];
SO2W=[    -1.00    0.00    0.00    4.20   -3.20];

Fx(:,end-1)=Fr(:,3:7)*SO2W';
Fx(:,end)=Fr(:,3:7)*O3W';


%%
f=figure;
set(f,'Tag','TEMP_COEF_DESC');
orient landscape;
suptitle(brw_name{n_inst})
subplot(2,4,1:2)
ploty(Fr(:,[1,3:end-2]),'.');
set(gca,'LineWidth',1);
ylabel('Counts');
xlabel('day');
text(repmat(min(Fr(:,1))+.1,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
%legend({'slit #0','slit #1','slit #2','slit #3','slit #4','slit #5'},'BestOutSide');
% hold on; % informativo pero queda feo, estudiar
% plot2(Fr(:,1),Fr(:,2),'p');
% ylabel('Temperature C�');
subplot(2,4,3:4);
mmplotyy_temp(Fr(:,1),Fr(:,end),'.',Fr(:,end-1),'x');
set(gca,'LineWidth',1);
mmplotyy('R5');
xlabel('day')
% ylabel('R6');
mmplotyy('shrink');
legend({'R6','R5'},'Location','NorthEast','HandleVisibility','Off');
%legend('R6','R5');

subplot(2,4,5:6)
ploty(Fr(:,[2,3:end-2]),'.');
set(gca,'LineWidth',1);
text(repmat(min(Fr(:,2))+1.5,5,1),nanmean(Fr(:,3:end-2)),...
            {'\itslit #2','\itslit #3','\itslit #4','\itslit #5','\itslit #6'});
%legend({'slit #0','slit #2','slit #3','slit #4','slit #5'},'BestOutside');
ylabel('Counts'); xlabel('temperature (�C)');
subplot(2,4,7:8);
mmplotyy_temp(Fr(:,2),Fr(:,end),'.',Fr(:,end-1),'x');
set(gca,'LineWidth',1);
mmplotyy('R5');
xlabel('temperature (�C)')
mmplotyy('shrink');
suptitle(brw_name{n_inst})
legend(gca,{'R6','R5'},'Location','NorthEast','HandleVisibility','Off');

%% cambio % respecto al valor medio
figure; 
subplot(2,2,1)
plot(Fr(:,2),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
ylabel(' ratio to mean (%) SL counts/seconds');xlabel('Temperature');
legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','North','Orientation','Horizontal');



subplot(2,2,2)
plot(Fr(:,1),100*matdiv(matadd(Fr(:,3:end-2),-nanmean(Fr(:,3:end-2))),nanmean(Fr(:,3:end-2))),'.');
ylabel(' ratio to mean (%) SL counts/seconds');xlabel('Time');
legend({'sl#0','sl#2','sl#3','sl#4','sl#5'},'Location','South','Orientation','Horizontal');

subplot(2,2,3)
plot(Fr(:,1),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
ylabel(' %ratio to mean SL ratios');xlabel('Time');
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');

subplot(2,2,4)
plot(Fr(:,2),100*matdiv(matadd(Fr(:,end-1:end),-nanmean(Fr(:,end-1:end))),nanmean(Fr(:,end-1:end))),'.');
ylabel(' %ratio to mean SL ratios');xlabel('Temperature');
legend({'R6','R5'},'Location','Best','HandleVisibility','Off');


%%
f=figure;
set(f,'tag','TEMP_global');
orient landscape;
plot(Fr(:,2),Fr(:,3:7),'.');

[a,b]=robust_line;
tc=b(2,:);otc=TC(n_inst,:);
if TC(n_inst,1)==0 % si esta normalizada o no
 NTC=-(tc-tc(1))+otc;
else
 NTC=-tc+otc;
end

title(num2str([TC(n_inst,:);NTC]));
grid;
xlabel('PMT Temperature (C\circ)');
ylabel('counts seconds');
suptitle(brw_name{n_inst})


%% REVISAR
O3W=[   0.00   -1.00    0.50    2.20   -1.70];

f=figure;
set(f,'tag','TEMP_OLD_VS_NEW');
FN=Fr;
FN(:,3:7)=Fr(:,3:7)+matmul(repmat(FN(:,2),1,5),(NTC)-otc);
plot(Fr(:,2),Fr(:,3:7)*O3W','rx')
hold on;plot(FN(:,2),FN(:,3:7)*O3W','bo')
legend({'R6  TC','R6 TC new'});
[a,r6tc]=rline;
title('R6 ratios, TC vs calculated TC');


%%
f=figure;
set(f,'tag','TEMP_day');
orient tall;
suptitle(brw_name{n_inst})


hl={};  line={};  stats={};

ndays=length(unique(fix(Fr(~isnan(Fr(:,1)),1))));
nrep=ceil(ndays/20);
%c=hsv(fix(length(unique(fix(Fr(~isnan(Fr(:,1)),1))))/3));
c=hsv(ceil(ndays/nrep));
for ii=0:5
 %[a,b,out]=boxparams(Fr(:,3+ii),2.5);
 %Fr(out,3+ii)=NaN;
 subplot(3,2,ii+1)
 if ii==5 
     ii=ii+1;
 end
 plot(Fr(:,2),Fr(:,3+ii),'x','MarkerSize',1);
 [hl{ii+1,n_inst},line{ii+1,n_inst},stats{ii+1,n_inst}]=report_robust_line;
 hold on
 
 plot(Fr(out,2),Fr(out,3+ii),'x','MarkerSize',14);
 [h]=gscatter(Fr(:,2),Fr(:,3+ii),fix(Fr(:,1)/nrep)*nrep,c,[],10);

% Si queremos la legenda en todos los subplots
% lg=legend('show');
% set(lg,'Location','NorthEast','HandleVisibility','off');

% Si solo queremos la legenda en uno de los 6 subplots
 legend('hide');
 if ii==2
 lg=legend('show');
 set(lg,'Location','NorthEast','HandleVisibility','off');
 end
 set(gca,'LineWidth',1);
  if ii==6
     title('MS9 ');       
     xlabel('PMT Temperature (�C)');
  else
     title(['slit #',num2str(ii+2)]);
  end
 if ii==4
     xlabel('PMT Temperature (�C)');
 end
end
suptitle(sprintf('%s: %s',brw_name{n_inst},'Temperature coeff.'));
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

