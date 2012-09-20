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

function [ETC,o3_c,m_netc]=ETC_calibration(file_setup,summary,A,...
    instrumento,referencia,tsync,oscmax,szasync,C_DAYS)

% Cargamos la configuracion
if isstruct(file_setup)
    TIME_SYNC=file_setup.Tsync;
    %FINAL_DAYS=Cal.Date.FINAL_DAYS;
    CALC_DAYS=file_setup.Date.FINAL_DAYS;
else
    eval(file_setup);
end


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
l={};ram=[];rpm=[];
figure
%%for jj=1:length(blinddays{n_ref})
l{jj}=[];  
baux=NaN*ones(3,2);
rg=[NaN,NaN];
%jday=findm(diaj(summary{n_inst}(:,1)),blinddays{n_inst}(jj),0.5);
jday=findm(diaj(summary{n_ref}(:,1)),240,0.5);
ref=summary{n_ref}(jday,:);
% buscamos el minimo airmass
[a,b]=min(ref(:,2));
ref_am=ref(1:b,:);
ref_pm=ref(b:end,:);
% rango de masas opticas 1.2 - 4
ref_am=ref_am(ref_am(:,3)>1.2 &  ref_am(:,3)<4.5,:);
ref_pm=ref_pm(ref_pm(:,3)>1.2 &  ref_pm(:,3)<4.5,:);
%


if length(ref_am)>1
[beta,i,r,rint,p] = linregress(ref_am(:,8),ref_am(:,3),0.05);
baux(:,1)=[beta;p(1)];
rg(1)=std(ref_am(:,6));
if rg(1)<1 & p(1)>0.9999 
 gscatter(ref_am(:,3),ref_am(:,8),ref_am(:,5));
 plot(ref_am(:,3),ref_am(:,8),'-')
 ram=[ram;ref_am];
 hold on;
end
end
if length(ref_pm)>1
[beta,i,r,rint,p] = linregress(ref_pm(:,8),ref_pm(:,3),0.05);
baux(:,2)=[beta;p(1)];
rg(2)=std(ref_pm(:,6));
if rg(1)<1 & p(1)>0.9999 
 hp(jj)=plot(ref_pm(:,3),ref_pm(:,8),'b*');
 rpm=[rpm;ref_pm];
 hold on;
end

end

l{jj}=[blinddays{n_ref}(jj),blinddays{n_ref}(jj)+0.5;baux;...
    size(ref_am,1),size(ref_pm,1);rg];
%end

lgl=cell2mat(l);
am=(lgl(1,:)==fix(lgl(1,:)));
figure
boxplot(lgl(3,:),{fix(lgl(6,:)),am})



% Buscamos los datos  comunes
% realizqamos la calibracion con los datos de los sumarios
jday=findm(diaj(summary{n_ref}(:,1)),blinddays{n_ref},0.5);
ref=summary{n_ref}(jday,:);
 %for i=1:length(brw)
 disp(n_ref);

     %n_inst;
         figure;

         jday=findm(diaj(summary{n_inst}(:,1)),blinddays{n_inst},0.5);
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
         o3p=o3_c(:,13).*o3_c(:,4)*10*A; %airmas from reference
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
         set(gca,'Xlim',[0,1900]);
         [lin{n_inst},hcal{n_inst},stats{n_inst}]=robust_line;
         try
            title([brw_str(n_inst)]);
         catch
            title('XXX');
         end
         line=hcal{n_inst};
         
         [ETC(2).TP(1,:),ETC(2).TP_STATS] = robustfit(ozone_slant,ms9);
         [ETC(1).TP(1,:),ETC(1).TP_STATS] = robustfit(ozone_slant(j),ms9(j));
         %% SALIDA
         %ETC.TP=(line);
         %ETC.TP_STATS=stats{n_inst};
         
         
         %%two point by filter
         try
          figure;gscatter(ozone_slant(j),o3_c(j,21),o3_c(j,18));hold on;plot(ozone_slant(j),o3_c(j,21),'kx');[rk,l,lstats]=robust_line;title(num2str(round(l)));
          ylabel('MS9  corrected');legend(num2str((unique(o3_c(j,18)))))
          
          figure;gscatter(ozone_slant(j),o3_c(j,22),o3_c(j,18));hold on;plot(ozone_slant(j),o3_c(j,22),'kx');[rk,l1,l1stats]=robust_line;title(num2str(round(l1)))        
          ylabel('MS9 un corrected')
                   
         catch
           msg=lasterror;  
           disp(msg.message)
         end
         
         
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
         j=find(ozone_scale<OSC_MAX(2));
      
         f=figure;
         set(f,'Tag','CAL_1P')
         plot(ozone_slant,(ms9-o3p),'+','MarkerSize',2);
         hold on;
         y=mean_smooth(ozone_slant,(ms9-o3p),0.12,1);
         hold on;
         plot(ozone_slant(j),(ms9(j)-o3p(j)),'*','MarkerSize',5);
         set(gca,'Xlim',[0.2,1.9]);
         grid on;
         title('ETC determinatio  vs Ozone Slant Path');
         xlabel('Ozone slant path (DU)');
         ylabel('ETC');
         hline(nanmedian(y(:,1)),'r',num2str(nanmedian(y(:,1))));
         
         % todo el rango
         ETC_NEW_=nanmedian(y(:,1))
         ETC_NEW_ERR_=nanstd(y(:,1))/sqrt(length(y(:,1)));
         
         ETC(2).NEW=ETC_NEW_;
         ETC(2).NEW_ERR=ETC_NEW_ERR_;
         
         
         
              
         %% one point calibration  solo el rango seleccionado
                
         f=figure;
         set(f,'Tag','CAL_2P_HIST')
         hist(ms9(j)-o3p(j));
         vline(fix(nanmedian(y(j,1))),'r');
         ETC_NEW=nanmedian(y(j,1))
         ETC_NEW_ERR=nanstd(y(j,1))/sqrt(length(y(j,1)));
         
         ETC(1).NEW=ETC_NEW;
         ETC(1).NEW_ERR=ETC_NEW_ERR;
         
         
         %% ploteo bonito
         f=figure;
         set(f,'Tag','CAL_2P_SCHIST')
         ETC_CALC=ms9(j)-o3p(j);
         h=scatterhist(ozone_slant(j),(ETC_CALC));
         axes(h(1)); set(h(1),'LineWidth',1);
         hline(ETC_NEW,'r-',num2str(fix(ETC_NEW)));
         title([' ETC DETERMINATION from RBCC-E reference'])
         xlabel('ozone slant path','HandleVisibility','On');        
         ylabel('ETC =  MS9 - A1*{O_{3REF}}*M2','HandleVisibility','On'); 

        
        %%evaluation with the new ETC
         o3_new=(ms9-ETC_NEW)./(o3_c(:,16)*10*A);
         o3_c=[o3_c,o3_new];
         
         % 1 date 2-> ref 3 inst original 4 inst new config  5 inst recal  
         %  mostof the cases  4==5 
         [m,s,n,grpn]=grpstats(o3_c(:,[1,13,23,25,end]),{diaj(o3_c(:,1))},{'mean','std','numel','gname'});         
         m_netc=round([(m(:,1)),m(:,2),s(:,2),n(:,2),m(:,3),s(:,3),m(:,4),s(:,4),m(:,5),s(:,5)]*10)/10;         
         %m_etc=[m_netc];
         
         o3_c=[o3_c,ozone_scale<OSC_MAX(2)];


%jday=find( diaj(summary{n_ref}(:,1))==251 | diaj(summary{n_ref}(:,1))==253);
%jday=find(  diaj(summary{n_ref}(:,1))>254 & %diaj(summary{n_ref}(:,1))<=260 );
%jday=findm(diaj(diaj(summary{n_ref}(:,1))),blinddays{n_ref},0.5);
%for n_ref=[n_ref]
