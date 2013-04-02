function [ETC,o3_c,m_netc]=ETC_calibration_C(file_setup,summary,A,instrumento,referencia,tsync,oscmax,szasync,C_DAYS)
%function [ETC_NEW,o3c,m_netc]=ETC_calibration_C(file_setup,summary,instrumento,refernecia,tsync,oscmax,szasync,C_DAYS)
%% Calibration
%% Parametros de configuracion de momeno harcoded
% alberto: introducido oscmax para 2p y 1p calibration
%INPUT
% T_SYNC          tiempo de medidas simultaneas
% OSC_MAX=[2p,1p] Ozone slant path maximo para obtener la calibracion
%                 for 2 point calibration and 1 point calibration 
%                 en cm   
%                 default 2
%                 017 0.7 
%                 185 2.5  
% SZA_SYNC=0.03    Diferencia en tanto por 1 del SZA entre la
%                 referencia y el instrumento a calibrar
%                 en % es menos estricta en altos angulos zenitales
%                 default 3% (0.03)      
%OUTPUT
%  ETC_NEW : calculo de la nueva etc
%  o3_c    : datos simultaneos de salida
%  o3_m    : promedios diarios con la nueva etc
%
%ETC_NEW estructura con dos elementos
%           elemento 1: Calculos con masa optica menor que OSC_MAX
%           elemento 2: Calculos con "TODAS" las masas opticas
%
% ETC_NEW:           
%    .NEW: ETC por el metodo de 1P
%    .NEW ERR: Errror standard de la ETC  sigma/sqrt(Ndat) 
%    .TP   :2x2  Etc y A1 por el metodo 2P (filas) columnas (osc, todas)
%    .TP_STATS: estructura de estandisctac de la regresion.
% 
% o3_c: datos simultaneos usados en el calculo
% Columnas  1  y 2
% date,dif_date,
% Ref->3-14
%  sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1, ozone_sl sigma_sl
% Inst to calibrate->15-26
%  sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1, ozone_sl sigma_sl
% Columnas 27 y 28
% ozono_r2,flag_OSC
% donde:
%       ozone_r=recalculated; ozone_1:original ; ozone_sl-> recalc+SL
%       ozono_r2, recalculado con la nueva ETC
%       flag_osc; Flag 1/0 si verifica OSC<OSC_MAX(2)
%
% m_etc: Promedios diarios
%       % fecha,o3ref,std,n,o3_orig,std,o3_new,std,o3_recal,std
%       % 1 date 2,3-> ref  4-Ndata, 
%       % 5,6 orig config
%       % 7,8 new config
%       % 9,10 with new etc 
%         %  mostof the cases  5,6 == 9,10 
%
% Process: 
%  O3 from reference is taken from o3_c(:,13) recalculated+sl
%  MS9 for instrument is o3_c(:,21)
%
% TODO -----------> 
%                     SEPARAR LAS FIGURAS DEL PROCESO
%                     Poder elegir los dias
%
% MODIFICATIOS:
% 01/10/2011 (Juanjo): Redefino m_netc. Además del campo 10 de inst (campo 23  de o3_c), 
%                      uso el campo 6 (campo 19 de o3_c) (línea 325). Necesario para tablas correctas 
%
%function [ETC,o3_c,m_netc,cal_data]=ETC_calibration(file_setup,summary,A,...
%    instrumento,referencia,tsync,oscmax,szasync,C_DAYS)

% Cargamos la configuracion
if isstruct(file_setup)
    TIME_SYNC=file_setup.Tsync;
    %FINAL_DAYS=Cal.Date.FINAL_DAYS;
    CALC_DAYS=file_setup.Date.FINAL_DAYS;
else
    eval(file_setup);
end

% Por si queremos cambiar los valores por defecto
if ~isempty(instrumento) n_inst=instrumento; else n_inst=file_setup.n_inst; end
if ~isempty(referencia) n_ref=referencia; else n_ref=file_setup.n_ref(1);end
if ~isempty(tsync)      
    T_SYNC=tsync;
else
    T_SYNC=TIME_SYNC;
end
if ~isempty(oscmax)
        if length(oscmax)==1;
            OSC_MAX=[oscmax,oscmax];
        else
            OSC_MAX=oscmax;
        end
        
else
        OSC_MAX=[2,2];
end

if ~isempty(szasync)
        SZA_SYNC=szasync;
else
        SZA_SYNC=0.03;
end

blinddays={};

if ~isempty(C_DAYS)
        blinddays{n_ref}=C_DAYS;
        blinddays{n_inst}=C_DAYS;
else
        blinddays{n_ref}=CALC_DAYS;
        blinddays{n_inst}=CALC_DAYS;
end

%

% los dias que se procesan son los cosiderados dias finales

% Buscamos los datos  comunes
% realizqamos la calibracion con los datos de los sumarios
jday=findm(diaj(summary{n_ref}(:,1)),blinddays{n_ref},0.5);
ref=summary{n_ref}(jday,:);
 %for i=1:length(brw)
 disp(n_ref);

     %n_inst;
         jday=findm(diaj(summary{n_inst}(:,1)),blinddays{n_inst},0.5);
         inst=summary{n_inst}(jday,:);
         %o3_c=ratio_min(ref,inst,10);
         MIN=60*24;
         n_min=T_SYNC;
         %OSC_MAX=1.5;
         [aa,bb]=findm_min(ref(:,1),inst(:,1),n_min/MIN);
         o3_c=[ref(aa,1),ref(aa,1)-inst(bb,1),ref(aa,2:end),inst(bb,2:end)];
         
         
 % o3_c simultaneous data;
%  ozone_r=recalculated; ozone_1:original ; ozone_sl-> recalc+SL
%    date,dif_date,
% Ref->3-14
% sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1, ozone_sl sigma_sl
%  3   4      5    6       7      8       9   10    11     12       13         14 
% Inst to calibrate->15-26
% sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1, ozone_sl sigma_sl
% 15   16    17   18     19        19    20   21                   
         
     
% eliminanos los nan (filtros no contemplados)
         o3_c=o3_c(~isnan(o3_c(:,21)),:);
% diferencia en angulo zenital en %  
        % este parameetro es determinante sobretodo con tiempos de
        % sincronizacion grandes
        o3_c=o3_c(abs(o3_c(:,16)-o3_c(:,4))./o3_c(:,4)<SZA_SYNC,:);
         
         
         ms9c=o3_c(:,21);   % filter corr. 
         ms9=o3_c(:,21);    % no filter corr.(Cuidado!! Hasta que no se adopte filter_corr siempre)
         o3ref=o3_c(:,7);   % usually not SL corrected: o3_c(:,7), SL corrected o3_c(:,13)
         m_inst=o3_c(:,16); % ozone airmass from inst.
         m_ref =o3_c(:,4);  % ozone airmass from ref.
           
%        
         ozone_slant=o3ref.*m_ref/1000;  % ozone and airmass from reference
%         ozone_slant=o3_c(:,11).*o3_c(:,16)/1000; %air mass from instrument
       %ozone scale, group ozone slant values in 0.05 intervals  
          ozone_scale=fix(ozone_slant/.05)*.05;
         
% 
%         % airm * ozo *10*A1ins
%         % ETC determination
         o3p=o3ref.*o3_c(:,4)*10*A; %airmas from reference
         
         o3p=o3ref.*m_inst.*A*10;
% must be the same
%         o3p_2=o3ref.*m_ref.*A*10;

         
          % ozone slant path range
         if OSC_MAX(1)>0 
            j=find(ozone_scale<OSC_MAX(1));
         else
            j=find(ozone_scale>abs(OSC_MAX(1)));
         end
          

         %% two point calibration
         % Metodo de calibracio clasico
         % TODO -----------> SEPARAR LAS FIGURAS DEL PROCESO
         f=figure;
         set(f,'Tag','CAL_2P')
         s1=subplot(3,1,1:2); j_nan=isnan(ozone_slant);
         plot(ozone_slant(~j_nan)*1000,ms9(~j_nan),'k+','MarkerSize',6);
         [lin_all,hcal_all,stats_all]=robust_line; set(lin_all,'LineWidth',2);
         set(findobj(get(gca,'Children'),'Type','text'),'Position',[ozone_slant(1)*1000+1, min(ms9)])
         set(findobj(get(gca,'Children'),'Type','line'),'HandleVisibility','Off');
         hold on
         try
          plot(ozone_slant(j)*1000,ms9(j),'ro','MarkerSize',4);
          [lin_parc,hcal_parc,stats_parc]=robust_line;
          set(gca,'Xlim',[0,1900],'XTickLabel',[]); set(lin_parc,'LineStyle','-.');
          legend('off'); 
         catch
          legend('no data');
          stats_parc.resid=NaN*ozone_slant;
          msg=lasterror;disp(msg.message)
         end
         try
            title(sprintf('%s calibrated to %s. Airmass range: [%3.1f - %3.1f]. Ozone range: [%d - %d]',...
                           file_setup.brw_str{instrumento},file_setup.brw_str{referencia},...
                           min(m_ref(j)),max(m_ref(j)),min(fix(o3ref(j))),max(fix(o3ref(j)))));
         catch exception
            fprintf('Error: %s, brewer %s\n',exception.message,file_setup.brw_str{instrumento}); 
            title('XXX');
         end
%          line=hcal{n_inst};
         aux=stats_all.resid;         aux2=stats_parc.resid;
         s2=subplot(3,1,3);
         plot(ozone_slant(~j_nan)*1000,aux,'k+','MarkerSize',6);
         hold on; plot(ozone_slant(j)*1000,aux2,'ro','MarkerSize',4);
         linkprop([s1,s2],'XLim');
%          plot(ozone_slant(~isnan(ms9(j)))*1000,aux,'k.',ozone_slant(~isnan(ms9))*1000,aux2,'rx');
%          plot(ozone_slant(ms9(j))*1000,aux,'k.',ozone_slant(ms9)*1000,aux2,'rx');
         hline([0,-50,50],'k-');
         
         
         [ETC(2).TP(1,:),ETC(2).TP_STATS] = robustfit(ozone_slant,ms9);
         try
          [ETC(1).TP(1,:),ETC(1).TP_STATS] = robustfit(ozone_slant(j),ms9(j));
         catch
           ETC(1).TP(1,:)=NaN*ETC(2).TP(1,:);
           ETC(1).TP_STATS=NaN*ETC(1).TP_STATS;
         end
         %% SALIDA
         %ETC.TP=(line);
         %ETC.TP_STATS=stats{n_inst};
         
         
         %%two point by filter
         try
          figure;
          gscatter(ozone_slant(j),o3_c(j,21),o3_c(j,18));
          hold on; plot(ozone_slant(j),o3_c(j,21),'kx'); [rk,l,lstats]=robust_line; l=round(l); l(2,:)=l(2,:)./10000;
          title(num2str(l)); ylabel('MS9  corrected'); legend(num2str((unique(o3_c(j,18)))))
          
          figure; gscatter(ozone_slant(j),o3_c(j,22),o3_c(j,18));
          hold on; plot(ozone_slant(j),o3_c(j,22),'kx'); [rk,l1,l1stats]=robust_line;
          title(num2str(round(l1)));  ylabel('MS9 un corrected');
                   
         catch
             msg=lasterror;  
               disp(msg.message)
             if length(j)>2
              figure;plot(ozone_slant(j),o3_c(j,21),'kx');[rk,l,lstats]=robust_line;title(num2str(round(l)));
              ylabel('MS9  corrected');legend(num2str((unique(o3_c(j,18)))))
           
              figure;plot(ozone_slant(j),o3_c(j,22),'kx');[rk,l1,l1stats]=robust_line;title(num2str(round(l1)))        
               ylabel('MS9 un corrected')
               
             end
         end
         % two point 1/airmass regression
         figure;
         plot(1000./(m_inst.*o3ref),1000*ms9c./(m_inst.*o3ref),'x');
         y=ms9c./m_ref; x=[o3ref,1./m_ref];
        [b1,bi1,res,resi,st]=regress(y,x);
        gscatter(1./(o3ref.*m_inst),res,o3_c(:,18)) 
%          %% depurar
%          try
%             filter=unique(o3_c(j,18));dummy_var=[];
%               for i=1:length(filter),   dummy_var(j,i)=(o3_c(j,18)==filter(i)); end
%               [a,b,c,d]=regress(o3_c(j,22),[ozone_slant(j),dummy_var(j),ones(size(ozone_slant(j)))]);
%               sum(dummy_var)
%              disp(fix([a,b])); 
%           %regresion by filter
%               [a,b,c,d]=regress(o3_c(j,22),[ozone_slant(j),dummy_var(j)]);
%               sum(dummy_var)
%               disp(fix([a,b]));
%          catch
%              warning('Filter Regression');
%          end
%          % standard regression
%             [a,b,c,d]=regress(o3_c(j,22),[ozone_slant(j),ones(size(ozone_slant(j)))]);
%             disp(fix([a,b]));
%          
        
         
         %% one point calibration    todo el rango
         if OSC_MAX(2)>0
            j=find(ozone_scale<OSC_MAX(2));
         else
            j=find(ozone_scale>abs(OSC_MAX(2)));
         end
         f=figure; set(f,'Tag','CAL_1P')
         plot(ozone_slant,(ms9-o3p),'+','MarkerSize',2);
         hold on;
         y=mean_smooth(ozone_slant,(ms9-o3p),0.12,1);
         hold on;
         plot(ozone_slant(j),(ms9(j)-o3p(j)),'*','MarkerSize',5);
         set(gca,'Xlim',[0.2,1.9]); grid;
         title(sprintf('ETC determinatio  vs Ozone Slant Path \r\n %s vs. %s',file_setup.brw_name{instrumento},file_setup.brw_name{referencia}));
         xlabel('Ozone slant path (DU)');         ylabel('ETC');
         hline(nanmedian(y(j,1)),'r',num2str(nanmedian(y(j,1))));
         hline(nanmedian(y(:,1)),'b',num2str(nanmedian(y(:,1))));
         
         %% ETC temperatura
         figure
         [mt,st,nd,nam]=grpstats((ms9-o3p),o3_c(:,17),0.5);
         plot(cellfun(@str2num,nam),mt,'x');
         rline
         %% todo el rango
         ETC_NEW_=nanmedian(y(:,1));
         ETC_NEW_ERR_=nanstd(y(:,1))/sqrt(length(y(:,1)));
         
         ETC(2).NEW=ETC_NEW_;
         ETC(2).NEW_ERR=ETC_NEW_ERR_;
                         
              
         %% one point calibration  solo el rango seleccionado               
         ETC_CALC=ms9(j)-o3p(j);
         ETC_NEW=nanmedian(ETC_CALC);    ETC_NEW_ERR=nanmedian(abs(ETC_CALC-nanmedian(ETC_CALC)));
%        ETC_NEW_ERR=nanstd(ETC_CALC)/sqrt(length(ETC_CALC));
         ETC(1).NEW=ETC_NEW;         ETC(1).NEW_ERR=ETC_NEW_ERR;
             
         %% Histograma
         f=figure;  set(f,'Tag','CAL_2P_HIST')
         hist(ETC_CALC);
         vline_v(round(nanmedian(ETC_CALC)),'r-',sprintf('Median: %6.1f',round(nanmedian(ETC_CALC))));
         vline_v(round(nanmean(ETC_CALC))  ,'b-',sprintf('Mean: %6.1f',round(nanmean(ETC_CALC))));
                          
         %% ploteo bonito
         f=figure;    set(f,'Tag','CAL_2P_SCHIST')
         h=scatterhist(ozone_slant(j),ETC_CALC);
         axes(h(1)); set(h(1),'LineWidth',1);
         hline(ETC_NEW,'b-',sprintf('%d \\pm %d',round(ETC(1).NEW),round(ETC(1).NEW_ERR)));
%          hline(nanmean(ETC_CALC),'b-',num2str(fix(nanmean(ETC_CALC))));
         title(sprintf('%s ETC Transfer from RBCC-E reference %s',file_setup.brw_name{instrumento},file_setup.brw_name{referencia}))
         xlabel('ozone slant path','HandleVisibility','On');        
         ylabel('ETC =  MS9 - A1*{O_{3REF}}*M2','HandleVisibility','On'); 

        
        %% evaluation with the new ETC
         o3_new=(ms9-ETC_NEW)./(o3_c(:,16)*10*A);
         o3_c=[o3_c,o3_new];
         
%   1-> date 
%   2-> ref + SL correct
%   3-> inst: si summary     -> O3_recalculado sin SL. 
%             si summary_old -> O3 original sin SL) 
%   4-> inst: si summary     -> O3 recalculado + SL correct 
%             si summary_old -> O3 original + SL correct)  
%   5-> inst  O3 recalculado con nueva ETC (ver ariba, líneas 287-8)  
         [m,s,n,grpn]=grpstats(o3_c(:,[1,13,19,23,25,end]),{diaj(o3_c(:,1))},{'mean','std','numel','gname'});         
         m_netc=round([m(:,1),m(:,2),s(:,2),n(:,2),...%ref + sl
                       m(:,3),s(:,3),...% campo 6 de inst
                       m(:,4),s(:,4),...% campo 10 de inst
                       m(:,5),s(:,5),...% campo 12 de inst
                       m(:,6),s(:,6)]*10)/10;% o3 recalculated with new ETC                  
         o3_c=[o3_c,ozone_scale<OSC_MAX(2)];


%jday=find( diaj(summary{n_ref}(:,1))==251 | diaj(summary{n_ref}(:,1))==253);
%jday=find(  diaj(summary{n_ref}(:,1))>254 & %diaj(summary{n_ref}(:,1))<=260 );
%jday=findm(diaj(diaj(summary{n_ref}(:,1))),blinddays{n_ref},0.5);
%for n_ref=[n_ref]
