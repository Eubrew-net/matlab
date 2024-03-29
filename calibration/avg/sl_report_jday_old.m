%function [sl_s,slavg,oulier,R6]=sl_report(idx_inst,sl,brw_name,fplot)
%
% sl_s-> summary: daily median  oulier removed and interpolated values of mising days
%      ->time and (median,std ) of 'R6','R5','T','F1','F5';
% slavg ->time and (median,std ) of 'R6','R5','T','F1','F5';
% outlier-> 3 sigma oulier removed
% R6: R6 outlier removed individual measurements
%
%  se llama desde ozone report

function [sl_s,slavg,oulier,R6]=sl_report(idx_inst,sl,brw_name,date_range,fplot)

% leemos las medidas individuales 
sls=cell2mat(sl{idx_inst});
% para corregir defecto puntual en #191
sls(:,13)=abs(sls(:,13));

if exist('date_range') && ~isempty(date_range)
    j=find(sls(:,1)<date_range(1));
    sls(j,:)=NaN;
    if length(date_range)>1
        j=find(sls(:,1)>date_range(2));
        sls(j,:)=NaN;
    end
end

%jok hg before and after
jok=find(sls(:,2)==1);
if isempty(jok)
    disp('Warning no SL ok');
    jok=ones(size(sls(:,2)));
end
% oulier % remove 3 sigma outlier

 [ax,bx,cx,dx]=outliers_bp(sls(:,22),3);
 %if idx_inst~=4 %%%%%%%%%%%%%%%%%%%%%%%%%% �?
   sls(dx,[22,21,13,23,24])=NaN;
 %end
try
  oulier{1,1}=datestr(sls(dx,1));
catch
  oulier{1,1}=sls(dx,1);
end
  oulier{1,2}=sls(dx,:);
  R6=sls(jok,[1,22,13]);


% Recalculated statistics counts
cname={'R6','R5','T','F1','F5'};
ncols=[22,21,13,23,24];

try
    [m,s]=grpstats(sls(jok,[1,22,21,13,23,24]),diaj(sls(jok,1)),{@median,'std'});
catch

    [m,s]=grpstats(sls(jok,[1,22,21,13,23,24]),diaj(sls(jok,1)),{'mean','std'});
    for i=1:5
        med=grpstats(sls(jok,ncols(i)),diaj(sls(jok,1)),{@median});
        m(:,i+1)=med;
    end

end

slavg=orgavg([m,s]); %time and (mean,std ) of 'R6','R5','T','F1','F5';
slavg(:,2)=[];

% sl_s contiene los valores suavizados (media m�vil de 7 d�as). Entonces,
% �por que el if?. Aunque tengamos menos de 5 d�as podemos seguir
% calculando valores suavizados. Por eso he comentado (si no, cuando size(slavg,1)<5 entonces no tendr�amos una media
% m�vil, sino que seguiriamos teniando las medias diarias, slavg. Adem�s, con sl_s(:,1)=sl_s(:,1)+.5; los dos ploteos, 
% aunque id�nticos, salen desfasados en medio d�a)
% Los valores suavizados se calculan, por ejemplo para una ventana de 5,
% seg�n
% 
% yy(1) = y(1)
% yy(2) = (y(1) + y(2) + y(3))/3
% yy(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5
% yy(4) = (y(2) + y(3) + y(4) + y(5) + y(6))/5
% ...
% 
% o sea, a partir de una vecindad del punto considerado. Entonces, �por qu�
% N_dat=15 por defecto? Si interesa una media m�vil a 7 d�as, creo que
% ser�a mejor N_dat=7 (tres pa`lante y trs pa�tr�s)

% if size(slavg,1)>5 
  sl_s=interp_sm(slavg,7);
% else
%   sl_s=slavg;
% end
% sl_s(:,1)=sl_s(:,1)+.5;% ??????? Esto da problemas. Por ejemplo con el 064 CALC_DAYS es 203:209, 
                       % y con esto sale 203:210 

%% PLOT
if nargin==5
   if fplot==1
    cname={'R6','F1','F5','T'};
    ncols=[22,23,24,13];
    figure;
    for i=1:4
        subplot(2,2,i)
        boxplot(sls(:,ncols(i)),diaj(sls(:,1)));
        title([cname{i},' ',brw_name{idx_inst}]);

    end
    %sls_(:,1)=diaj2(sls(:,1));
    
    f=figure;
    set(f,'tag','SL_R6_report');
    slaux=sl_s;
    slaux(:,1)=diaj2(slaux(:,1)); 
    p1=errorbard(slaux(:,1:3),'s');
    %set(p1(1),'Linewidth',3);
    hold on
    %p2=stairs(diaj(slavg(:,1)),slavg(:,2),'o-','LineWidth',2);
    p2=plot(diaj(slavg(:,1)),slavg(:,2),'o-','LineWidth',1);
    p3=plot(diaj2(sls(:,1)),sls(:,22),'.');
    legend([p1(1),p2,p3],'R6 smooth 7','R6 daily mean ','R6 measures','Location','Best');
    title(['Standard Lamp R6   ',brw_name{idx_inst}]);
    %datetick('x','mm/dd','keeplimits','keepticks');
    %suptitle('SAUNA 2    -Sodankyla 2007-');
    grid;
    xlabel('Date')
    ylabel('SL R6  ratios');
    
    %%
    f=figure;
    set(f,'tag','SL_R5_report');
    p1=errorbard(slaux(:,[1,4,5]),'s');
    %set(p1(1),'Linewidth',2);
    hold on
    p2=plot(diaj(slavg(:,1)),slavg(:,4),'o-','LineWidth',1);
    p3=plot(diaj2(sls(:,1)),sls(:,21),'.:');
    legend([p1(1),p2,p3],'R5 smooth 7','R5 daily mean ','R5 measures','Location','Best');
    title(['Standard Lamp R5   ',brw_name{idx_inst}]);
    %datetick('x','mm/dd','keeplimits','keepticks');
    %suptitle('SAUNA 2    -Sodankyla 2007-');
    grid;
    xlabel('Date')
    ylabel('SL R5  ratios');

    % INT
    f=figure;
    set(f,'tag','SL_I5_report');
    p1=errorbard(slaux(:,[1,8:9]),'s');
    %set(p1(1),'Linewidth',3);
    hold on
    p2=plot(diaj(slaux(:,1))+.5,slaux(:,8),'o-','LineWidth',1);
    p3=plot(diaj2(sls(:,1)),sls(:,23),'.','Markersize',15);
    %legend([p1(1),p2,p3],'I_5 smooth 7','I_5 daily mean ','I_5 meas');
    legend([p1(1),p2,p3],'I_5 smooth 7','I_5 daily mean ','I_5 meas','Location','Best');
    title(['Standard Lamp I_5   ',brw_name{idx_inst}]);
    %datetick('x','mm/dd','keeplimits','keepticks');
    %suptitle('SAUNA 2    -Sodankyla 2007-');
    grid;
    xlabel('Date')
    ylabel('SL I_5  ratios');
    set(gca,'LineWidth',1,'XTick',diaj(slavg(:,1)))%,'XTickLabel',diaj(slavg(:,1))

    % INT
    f=figure;
    set(f,'tag','SL_TEMP_report');
    %suptitle('SAUNA 2    -Sodankyla 2007-');
    title(['Standard Lamp R6 vs temperature   ',brw_name{idx_inst}]);
    set(f,'tag','SL_TEMP_report');
    gscatter(sls(:,13),sls(:,22),5*fix(diaj(sls(:,1))/5));
    title(['Standard Lamp R6 vs temperature   ',brw_name{idx_inst}]);

    grid;
    xlabel('PMT Temperature (C\circ)');
    ylabel('SL R6 ratios');
   end

end


%function rdata=orgavg(data)
% reorganiza las matrices (media_1,media_2,media_3..media_n, ...
% sigma_1,sigma_2,sigma_3....sigma_n.) a
% media1, sigma1 , media2 sigma2
function rdata=orgavg(data)
idx=1:size(data,2)/2;
idx=sort([idx,idx]);
idx(2:2:end)=idx(2:2:end)+size(data,2)/2;
rdata=data(:,idx);


% function data=interp_smooth(data_avg)
% funcion que interpola la serie previamente suavizada
% utilizada para rellenar huecos los valores de standard lamp.


function data=interp_sm(data_avg,N_dat)
if nargin==1
   N_dat=15; %suavizado
end
%if nargin==1
   x0=min(fix(data_avg(:,1)));
   x1=max(fix(data_avg(:,1)));
   x=x0:x1;


   %la interpolacion no permite nan
   % el suavizado si �?
   j=find(isnan(data_avg(:,1)));
   if ~isempty(j)
     data_avg(j,:)=[];
   % rellenamos con  la mediana
     for ii=2:size(data_avg,2)
     data_avg(isnan(data_avg(:,ii)),ii)=nanmedian(data_avg(:,ii));
     end
   end

  %suavizado
  aux=repmat(data_avg(:,1),1,size(data_avg(:,2:end),2));
  for i=1:size(data_avg,2)-1;
  data_avg(:,i+1)=smooth(data_avg(:,1),data_avg(:,i+1),N_dat,'rlowess');
  end
  data=data_avg;
%     data=interp1(data_avg(:,1),data_avg(:,2:end),x,'pchip');
%     data=[x',data];
