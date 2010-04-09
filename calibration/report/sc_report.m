
%   INPUTS:
% -------- Necesarios --------
% - brw_str, string con el nombre de brewer
% - brw_config, configuracion que se le pasa (la nueva)
% 
% -------- Opcionales ---------
% - date_range
% - CSN_orig
% - OSC, mu*O3(DU) climatologico
% - control_flag
% 
% Estructura:  arguin.date_range
%                   arguin.CSN_orig
%                   arguin.OSC
%                   arguin.control_flag
% 
% MODIFICADO: 
% HECHO ref_iau introducir el ozone slant path climatologico  en brewer_setup
% HECHO  introducir le date range
% 
% Juanjo 05/11/2009: Se modifican los Tag de los ploteos de SC individuales con vistas a 
%                              incluirlos en Appendix?
% 
% Juanjo 09/04/2010: Se cambia la forma de especificar los input a la
%                             funcion. Ahora se le pasan todos como
%                             estructura
%                             
% Juanjo 09/04/2010: Ahora el CSN_orig se coge de la configuracion inicial (config_orig).               
%                             Se le pasa como argumento desde el
%                             cal_report_###
%                             

% change-> no eliminar los datos filtrados. Marcar el filtro que los
% invalida.

function [step_cal,sc_avg,sc_raw]=sc_report(brw_str,brw_config,arguin)

mmv2struct(arguin)

sc_avg={};
sc_raw={};
disp(brw_str)    
try
% Para el B156, B040, leer solo a partir del dia 100->
% sc_avg: hora_ini, hora_fin, indx, min_step, max_step, paso, 
%              temp, mu, filter, cal_stepmax, O3, cal_stepmin, SO2, step_before, 
%              fit_stepmax, fit_O3, norm_res, coeff_pol_(3), hg_flag, hg_start, hg_end,
  if isempty(brw_config)
    [sc_avg,sc_raw]=readb_scl(['.',filesep(),'bdata',brw_str,filesep(),'B*.',brw_str]);
  else    
   % del fichero de configuracion CSN_orig=   
  [sc_avg,sc_raw]=readb_scl(['.',filesep(),'bdata',brw_str,filesep(),'B*.',brw_str],brw_config);
  end
catch
   l=lasterror;
   disp(['Error: ',l.message])
end

if isempty(OSC)
    OSC=680;
end
ref_iau=OSC;

if isempty(sc_avg) 
    step_cal=[NaN,NaN,NaN];
    return
end

%% Date filter
if  ~isempty(date_range)
       sc_avg(sc_avg(:,1)<date_range(1),:)=NaN;
       sc_raw(sc_raw(:,1)<date_range(1),:)=NaN;
       if length(date_range)>1
           sc_avg(sc_avg(:,1)>date_range(2),:)=NaN;
           sc_raw(sc_raw(:,1)>date_range(2),:)=NaN;
       end
end


%% Depuracion
if control_flag==1
a=sc_avg;
b=sc_raw;
brw_name=brw_str;


if ~ (isempty(a) || isempty(b) )

   % filtro NaN
   %  if i~=2
        a(any(isnan(a')),:)=[];    
            % Filtro Steps to far
        jnan=find(abs(a(:,15)-a(:,14))>40);
        
        for ii=1:length(jnan)
            %try
             J=find(fix(b(:,1))==fix(a(jnan(ii),1)) & fix(b(:,2)/100)==a(jnan(ii),3) );
             b(J,:)=[];
            %catch
            % disp('WARNING revisar');
            % revisado
            %end
        end
         a(jnan,:)=[];
        %ozono fuera de rango
        j=find(b(:,18)>550 | b(:,18)<100);
        b(j,:)=[];
        j=find(a(:,11)>550 | a(:,16)<10);
        a(j,:)=[];
        

        %normr residual remove
        f_start1=figure;
        set(gcf,'tag','SC_Control_1');
        subplot(2,1,1);
        if size(unique(fix(a(:,17)/10)*10))==1;
           plot(a(:,10),a(:,8).*a(:,11),'o');
          %legend(num2str(fix(a(1,17)/10)*10));
        else
           gscatter(a(:,10),a(:,8).*a(:,11),fix(a(:,17)/10)*10)
        end
        ylabel('ozone slant path')
        title('Residual plot')
        subplot(2,1,2);
        if ~all(isnan(a(:,21)))
            gscatter(a(:,10),a(:,8).*a(:,11),fix(a(:,21)*2)/2)
        end
        title('HG step plot');
        ylabel('ozone slant path')
        suptitle({'SC control plot',brw_str});
        l=findobj(gcf,'Tag','legend');
        set(l,'Location', 'EastOutside' )

        % figure
        figure
        set(gcf,'tag','SC_Control_3');
        subplot(2,1,1)
        if size(unique(fix( (a(:,2)-a(:,23))*60*24)),1)==1;
           plot(a(:,10),a(:,8).*a(:,11),'o');
           legend(num2str(unique(fix( (a(:,2)-a(:,23))*60*24))));
        else

        gscatter(a(:,10),a(:,8).*a(:,11),fix( (a(:,2)-a(:,23))*60*24));
        end
        title('HG time (minutes) plot');
        ylabel('ozone slant path')
       %figure
        subplot(2,1,2)
        if size(unique(diaj(a(:,1))),1)==1;
           plot(a(:,10),a(:,8).*a(:,11),'.');
           legend(num2str(diaj(a(1,1))));
        else
        h=gscatter(a(:,10),a(:,11).*a(:,8),diaj(a(:,1)));
        end
        title('SC plot by day');        
        ylabel('ozone slant path')        
        l=findobj(gcf,'Tag','legend');        
        set(l,'Location', 'EastOutside' )        
        suptitle({'SC control plot',brw_str});
        
        
        %% filter #0 removal
%          jzero=find(~a(:,9));
%          a(jzero,:)=[];
%          jzero=find(~b(:,6));
%          b(jzero,:)=[];
% 

        % residual remove
        j=find(abs(a(:,17)>=25));
        for ii=1:length(j)
            J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
            b(J,:)=[];
        end
        a(j,:)=[];
 
       % bad hg remove
        if isempty(a) 
            return; 
        end
            j=find(abs(a(:,21))>1.1 | isnan(a(:,21)));
        for ii=1:length(j)
            J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
            b(J,:)=[];
        end
            a(j,:)=[];
            
        % AIRM
        j=find(abs(a(:,8)>=5.0));
        for ii=1:length(j)
            J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
            b(J,:)=[];
        end
        a(j,:)=[];


     %end
end
else
  a=sc_avg;
  b=sc_raw;
  disp('Warning no valid SC');
   % residual remove
   j=find(abs(a(:,17)>=25));
      for ii=1:length(j)
         J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
         b(J,:)=[];
      end
   a(j,:)=[];
  
end




% 3D plot
% %% 3D
% f=figure;
% set(f,'tag','SC 3D');
% scatter3(b(:,3),b(:,8),b(:,18),3,diaj(b(:,1)))
% xlabel('step');ylabel('airm');zlabel('ozone');
% title(' Sun scan measrementes');
% suptitle(brw_str);
%% SC

% sun scan control plot 2
h=figure;
set(h,'tag','SC_CONTROL');
subplot(2,2,1);
plot(a(:,1),a(:,21),'.');% xlabel('step');ylabel('airm');zlabel('ozone');
title('hg step difference');
datetick('x',6,'keepticks','keeplimits')
subplot(2,2,2);
plot(a(:,1),24*60*(a(:,23)-a(:,2)),'o');
title('hg time difference');
datetick('x',6,'keepticks','keeplimits')
subplot(2,2,3);
plot(a(:,1),a(:,17),'s')
title('norm residuals');
datetick('x',6,'keepticks','keeplimits')
subplot(2,2,4);
plot(a(:,1),a(:,[10,15]),'*')
title('max o3 fit o3');
datetick('x',6,'keepticks','keeplimits')

suptitle(brw_str);

% Plot of selected sun_scan

dias=unique(diaj(b(~isnan(b(:,1)),1)));
if length(dias)>10
    % last ten
    dias=dias(end-10:end);
end
    for jj=1:length(dias)  
    scavg=a(diaj(a(:,1))==dias(jj),:);
    scraw=b(diaj(b(:,1))==dias(jj),:);
    medida=fix(scraw(:,2)/100);
    if ~isempty(scraw )
        for ii=1:size(scavg,1),
            h=figure;
            set(h,'tag',sprintf('%s%i%c%i','SC_INDIVIDUAL',jj,'_',ii)); 

            sc_=scraw(medida==scavg(ii,3),:);
            sca=scavg(ii,:);
            %subplot(3,2,mod(i,6)+1);
            polyplot2(sc_(:,3),sc_(:,18));
            % polyplot2(sc_(:,3),sc_(:,18).*sc_(:,8));

            title({' ',' ',...
                sprintf(' airm=%.2f  filter=%d ozone=%.1f  step=%.0f \\Delta hg step=%.1f ',sca(1,[8,9,11,10,21])),...
                ['y=',poly2str(round(sca(18:20)*100)/100,'x'),'',sprintf(' normr=%.1f',sca(1,17))]},'FontSize',9);
            sup=suptitle([brw_str ,'  DiaJ=',num2str(dias(jj)),' ' ,datestr(sca(1,1))]); set(sup,'FontSize',10)
            xlabel('step');  ylabel('ozone');
            set(gca,'LineWidth',1);
        end
      end
    end
set(h,'Tag','SC_INDIVIDUAL'); 
    
%figure;
%plot(a(:,10),a(:,8).*a(:,11),'.',a(:,15),a(:,16).*a(:,8),'+')
%rline


%%
figure
% IF no debug
a(isnan(a(:,10)),:)=[];
[p,s]=polyfit(a(:,10),a(:,8).*a(:,11),1);
%x=unique(fix(a(:,10)))

% hg correction
a(isnan(a(:,21)),21)=0;
x=a(:,10)-a(:,21)/2;
X=x;
y=polyval(p,x);
try  %fails with only one
 xlims=[invpred(x,y,2000);invpred(x,y,300)];
 x=sort([x;xlims]);
catch
    x=sort(x);
    xlims=[300,1800];
end
[y,delta]=polyconf(p,x,s);

figure
gscatter(X,a(:,8).*a(:,11),{month(a(:,1)),year(a(:,1))});



f_end=figure; set(f_end,'Tag','Final_SC_Calculation');
h0=plot(X,a(:,8).*a(:,11),'s'); set(gca,'LineWidth',1);
hold on;
hconf=confplot(x,y,delta); set(hconf(1),'Marker','none')
ylim([300,1400]); xlim(xlims);
hold on;
h1=plot(X,a(:,8).*a(:,11),'o');
try
step_cal=invpred(x,y,ref_iau);
catch
    step_cal=NaN;
end
[y1,delta1]=polyconf(p,step_cal,s);
try   step0=invpred(x,y,ref_iau+delta1);catch step0=NaN; end
try    step1=invpred(x,y,ref_iau-delta1);catch step1=NaN; end

hl=hline([ref_iau,ref_iau+delta1,ref_iau-delta1],{'b-','r:','r:'},{'','',''}); 
vl=vline(([step0,step_cal,step1]),{'r:','b-','r:'},{'','',''}); 
try
title(sprintf('Ozone slant path =%.0f   Calc Step = %.1f [%.1f,%.1f] \n   Calibration Step from config file %s = %.0f ',...
               ref_iau,step_cal,step0,step1,brw_config(end-11:end),CSN_orig));
catch
    title('OSC no config file');
end
% sup=suptitle(brw_str); pos=get(sup,'Position');
% set(sup,'Position',[pos(1)+.02,pos(2)+.02,1]);
ylabel('Ozone slant Path'); xlabel(' Calc Step number');
orient('portrait');  

step_cal=[step_cal,step0,step1];    sc_avg=a;
 
