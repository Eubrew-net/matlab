%function [ETC_NEW,o3c]=ETC_calibration(file_setup,summary,instrumento,refernecia,tsync,oscmax,szasync)
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
%
%      -Two point calibration
%
%
%
%
%% TODO -----------> 
%                     SEPARAR LAS FIGURAS DEL PROCESO
%                     Poder elegir los dias



function [ETC_NEW,o3_c,m_netc]=ETC_calibration(file_setup,summary,A,...
    instrumento,referencia,tsync,oscmax,szasync)

% Cargamos la configuracion
eval(file_setup);

% Por si queremos cambiar los valores por defecto
if ~isempty(instrumento) n_inst=instrumento; end
if ~isempty(referencia) n_ref=referencia; end
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
        SZA_SYNC=0.03
end
%

% los dias que se procesan son los cosiderados dias finales
blinddays={};
blinddays{n_ref}=CALC_DAYS;
blinddays{n_inst}=CALC_DAYS;

% Buscamos los datos  comunes
% realizqamos la calibracion con los datos de los sumarios
jday=findm(diaj(diaj(summary{n_ref}(:,1))),blinddays{n_ref},0.5);
ref=summary{n_ref}(jday,:);
 %for i=1:length(brw)
 disp(n_ref);

     %n_inst;
         figure;

         jday=findm(diaj(diaj(summary{n_inst}(:,1))),blinddays{n_inst},0.5);
         inst=summary{n_inst}(jday,:);
         %o3_c=ratio_min(ref,inst,10);
         MIN=60*24;
         n_min=T_SYNC;
         %OSC_MAX=1.5;
         [aa,bb]=findm_min(ref(:,1),inst(:,1),n_min/MIN);
         o3_c=[ref(aa,1),ref(aa,1)-inst(bb,1),ref(aa,2:end),inst(bb,2:end)];
% o3_c simultaneous data;
%    % ozone_r=recalculated; ozone_1:original ; ozone_sl-> recalc+SL
% date,dif_date,
% Ref->3-14
%sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1, ozone_sl sigma_sl
% Inst to calibrate->15-26
%sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1, ozone_sl sigma_sl
% 
         
        % diferencia en angulo zenital en %  
        % este parameetro es determinante sobretodo con tiempos de
        % sincronizacion grandes
         o3_c=o3_c(abs(o3_c(:,16)-o3_c(:,4))./o3_c(:,4)<SZA_SYNC,:);
         
%          ozone_slant_inst=o3_c(:,13).*o3_c(:,16)/1000;
         
         ozone_slant=o3_c(:,13).*o3_c(:,4)/1000; %air mass from reference
         %ozone_slant=o3_c(:,13).*o3_c(:,16)/1000; %air mass from instrument
         ozone_scale=fix(ozone_slant/.1)*.1;
         
% 
%         % airm * ozo *10*A1ins
%         % ETC determination
         o3p=o3_c(:,13).*o3_c(:,4)*10*A.new(n_inst); %airmas from reference
         %o3p=o3_c(:,13).*o3_c(:,16)*10*A(n_inst);
         ms9=o3_c(:,21);
          % ozone slant path range
         j=find(ozone_scale<OSC_MAX(1));


         %% two point calibration
         % Metodo de calibracio clasico
         % TODO -----------> SEPARAR LAS FIGURAS DEL PROCESO
         f=figure;
         set(f,'Tag','CAL_2P')
         plot(ozone_slant*1000,ms9,'k+','MarkerSize',2);
         hold on
         plot(ozone_slant(j)*1000,ms9(j),'bo','MarkerSize',3);
         set(gca,'Xlim',[0,1900])
         [lin{n_inst},hcal{n_inst}]=robust_line;
         title([brw_str(n_inst)]);
         line=hcal{n_inst};
         
         %% one point calibration
         j=find(ozone_scale<OSC_MAX(2));
         % calibracion oficial    
         f=figure;
         set(f,'Tag','CAL_1P')
         plot(ozone_slant,(ms9-o3p),'+','MarkerSize',2);
         hold on;
         y=mean_smooth(ozone_slant,(ms9-o3p),0.12,1);
         hold on;
         plot(ozone_slant(j),(ms9(j)-o3p(j)),'*','MarkerSize',3);
         set(gca,'Xlim',[0.2,1.9]);
         grid on;
         title('ETC determinatio  vs Ozone Slant Path');
         xlabel('Ozone slant path (DU)');
         ylabel('ETC');
         hline(nanmedian(y(:,1)),'r',num2str(nanmedian(y(:,1))));
         
              
                 
         f=figure;
         set(f,'Tag','CAL_2P_HIST')
         hist(ms9(j)-o3p(j));
         vline(fix(nanmedian(y(:,1))),'r');
         ETC_NEW=nanmedian(y(:,1))
         
         
         f=figure;
         set(f,'Tag','CAL_2P_SCHIST')
         ETC_CALC=ms9(j)-o3p(j);
         %ETC_NEW=round(nanmean(ETC_CALC))
         h=scatterhist(ozone_slant(j),(ETC_CALC));
         axes(h(1)); set(h(1),'LineWidth',1);
         hline(ETC_NEW,'r-',num2str(round(ETC_NEW)));
         title([' ETC DETERMINATION from RBCC-E reference'])
         xlabel('ozone slant path','HandleVisibility','On');        
         ylabel('ETC =  MS9 - A1*{O_{3REF}}*M2','HandleVisibility','On'); 

        
        %%evaluation with the new ETC
         o3_new=(ms9-ETC_NEW)./(o3_c(:,16)*10*A.new(n_inst));
         o3_c=[o3_c,o3_new];
         [m,s,n,grpn]=grpstats(o3_c(:,[1,13,25,end]),{diaj(o3_c(:,1))},{'mean','std','numel','gname'});         
         m_netc=round([diaj(m(:,1)),m(:,2),s(:,2),n(:,2),m(:,3),s(:,3),m(:,4),100*(m(:,2)-m(:,3))./m(:,2),100*(m(:,2)-m(:,end))./m(:,2)]*10)/10;         
         %m_etc=[m_netc];
         


%jday=find( diaj(summary{n_ref}(:,1))==251 | diaj(summary{n_ref}(:,1))==253);
%jday=find(  diaj(summary{n_ref}(:,1))>254 & %diaj(summary{n_ref}(:,1))<=260 );
%jday=findm(diaj(diaj(summary{n_ref}(:,1))),blinddays{n_ref},0.5);
%for n_ref=[n_ref]
