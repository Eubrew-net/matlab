function [step_cal,sc_avg,sc_raw,Args]=sc_report(brw_str,brw_config,varargin)
%   INPUTS:
% -------- Necesarios --------
% - brw_str, string con el nombre de brewer
% - brw_config, configuracion que se le pasa (la nueva)
% 
% -------- Opcionales ---------
% - date_range. Por defecto [] (no control de fechas)
% - CSN_orig. Por defecto NaN
% - OSC, mu*O3(DU) climatologico. Por defecto 680
% - control_flag. Por defecto 0 (no control de outliers)
% 
%  MODIFICADO: 
% HECHO ref_iau introducir el ozone slant path climatologico  en brewer_setup
% HECHO  introducir le date range
% 
% Juanjo 05/11/2009: Se modifican los Tag de los ploteos de SC individuales con vistas a 
%                    incluirlos en Appendix?
% 
% Juanjo 09/04/2010: Se cambia la forma de especificar los input a la
%                    funcion. Uso de inputparser
%                    Ahora el CSN_orig se coge de la configuracion inicial (config_orig).                        
%                    (Se le pasa como argumento desde el cal_report_###)
%                                                
% Juanjo 30/10/2010: Se retoma versión anterior, fusionando novedades de Alberto (sc_data como input opcional)
%                    Se añade como argumento opcional residual_limit (por defecto 25) (línea )
%                    sc_data (se le pasan los datos, opcional, línea 90)
%                    hg_time (por defecto no depuración, <0, línea 274). Util por ejemplo para el #064
%                    Se reorganiza residual remove (se mantiene = filosofía, aunque ahora hg_limit = parametro, línea 193)
%                    Se reorganiza bad HG remove (se mantiene = filosofía, limite = 1.15)
%                    Se añade plot en AIRMASS filter (temporal)
%                    Añadido flag de ploteo individual (one_flag). Por defecto ploteo
% 
%                    También output Args, con la configuración de entrada (línea 48)
% 
% Juanjo 03/11/2011:  Se añade input opcional 'data_path'. Por defecto bdata###
% 
% Ejemplo:
% [cal_step{1},sc_avg{1},sc_raw{1},Args{1}]=sc_report_mio(Cal.brw_str{Cal.n_inst},Cal.brw_config_files{Cal.n_inst,2},... 
%                      'CSN_orig',config_orig(14),'OSC',Station.OSC,...
%                      'date_range',[datenum(Cal.Date.cal_year-1,1,1),datenum(Cal.Date.cal_year-1,12,1)],...
%                      'control_flag',1,...
%                      'residual_limit',20,'hg_time',10,'one_flag',0);
% 
% TODO:
% change-> no eliminar los datos filtrados. Marcar el filtro que los invalida.


%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='sc_report';

arg.addRequired('brw_str', @ischar);
arg.addRequired('brw_config',@ischar);

arg.StructExpand = false;
arg.addParamValue('sc_data',[],@isstruct); % por defecto
arg.addParamValue('data_path', '', @ischar); % por defecto: bdata###
arg.addParamValue('date_range', [], @isfloat); % por defecto: no control de fechas
arg.addParamValue('CSN_orig', NaN, @isfloat); % por defecto: NaN
arg.addParamValue('OSC', 680, @isfloat); % por defecto: 680
arg.addParamValue('control_flag', 0, @(x)(x==1 || x==0)); % por defecto: no outlier control
arg.addParamValue('residual_limit', 25, @(x)(x>1 || x<100)); % por defecto 25
arg.addParamValue('one_flag', 1, @(x)(x==1 || x==0)); % por defecto: ploteo de SC's escogidos
arg.addParamValue('hg_time', [], @isfloat); % por defecto: no depuración
arg.addParamValue('cor_hg', [], @isfloat); % hg step correction is added to the calc_step
try
  arg.parse(brw_str, brw_config, varargin{:});
  mmv2struct(arg.Results); Args=arg.Results;
  chk=1;

catch
  errval=lasterror;
  if length(varargin)==8
      date_range=varargin{2};
      CSN_orig=varargin{4};
      OSC=varargin{6};
      outlier_flag=varargin{8};
  elseif length(varargin)==6
      date_range=varargin{2};
      CSN_orig=varargin{4};
      OSC=varargin{6};
      outlier_flag=0;
  elseif  length(varargin)==4
      date_range=varargin{2};
      CSN_orig=varargin{4};
      OSC=680;
      outlier_flag=0;
  elseif length(varargin)==2
      date_range=varargin{2};
      CSN_orig=NaN;
      OSC=680;
      outlier_flag=0;
  else
      date_range=[];
      CSN_orig=NaN;
      OSC=680;
      outlier_flag=0;
  end
  chk=0;
end

%%
disp(brw_str)    
sc_avg={}; sc_raw={};
ref_iau=OSC;
if isempty(sc_data)
    if isempty(data_path)
       data_path=['.',filesep(),'bdata',brw_str,filesep(),'B*.',brw_str];
    else
       data_path=fullfile(data_path,['B*.',brw_str]);
    end
    
    try
        % Para el B156, B040, leer solo a partir del dia 100->
        % sc_avg: hora_ini, hora_fin, indx, min_step, max_step, paso,
        %              temp, mu, filter, cal_stepmax, O3, cal_stepmin, SO2, step_before,
        %              fit_stepmax, fit_O3, norm_res, coeff_pol_(3), hg_flag, hg_start, hg_end,
        if isempty(brw_config)
            [sc_avg,sc_raw]=readb_scl(data_path,...
                                       'date_range',date_range);
        else
            % del fichero de configuracion CSN_orig=
            [sc_avg,sc_raw]=readb_scl(data_path,...
                                       'config',brw_config,'date_range',date_range);
        end
    catch
        l=lasterror;
        disp(['Error: ',l.message])
    end
else
    sc_avg=sc_data.sc_avg;
    sc_raw=sc_data.sc_raw;
end

if isempty(sc_avg) 
    step_cal=[NaN,NaN,NaN,NaN,NaN];
    return
end

%sale si no hay datos
if all(isnan(sc_avg(:,1))) %isempty(sc_avg) 
    step_cal=[NaN,NaN,NaN,NaN,NaN];
    return
end

%% Depuracion
if control_flag==1
a=sc_avg;
b=sc_raw;
brw_name=brw_str;

if ~ (isempty(a) || isempty(b) )
   % filtro NaN
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

   % Ozono fuera de rango        
        b(b(:,18)>550 | b(:,18)<100,:)=[];
        a(a(:,11)>550 | a(:,16)<10,:)=[];
        
   % normr residual remove
   j=find(abs(a(:,17)>=residual_limit));
   for ii=1:length(j)
       J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
       b(J,:)=[];
   end
   f_start1=figure;
   set(gcf,'tag','SC_Control_1');
   subplot(2,1,1);
   if size(unique(fix(a(:,17)/10)*10))==1;
      plot(a(:,10),a(:,8).*a(:,11),'o');
      hold on; plot(a(j,10),a(j,8).*a(j,11),'kx','MarkerSize',10);
      %legend(num2str(fix(a(1,17)/10)*10));
   else
      gscatter(a(:,10),a(:,8).*a(:,11),fix(a(:,17)/5)*5+2.5); box on; % grupos de 5, para afinar (estaba en grupos de 10)
      set(findobj(gcf,'Tag','legend'),'Location','EastOutside');
      hold on; plot(a(j,10),a(j,8).*a(j,11),'kx','MarkerSize',10); grid
   end
   ylabel('ozone slant path')
   title(sprintf('Norm of Residuals (legend means: group = value +/- 2.5). Residual Limit = %4.1f',residual_limit));
   a(j,:)=[];
        
   % bad hg remove
    if isempty(a) 
       step_cal=[NaN,NaN,NaN,NaN,NaN];
       return; 
    end
    hg_limit=1.25;
    j=find(abs(a(:,21))>hg_limit | isnan(a(:,21)));
    for ii=1:length(j)
        J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
        b(J,:)=[];
    end        
    subplot(2,1,2);
    if ~all(isnan(a(:,21)))
        gscatter(a(:,10),a(:,8).*a(:,11),fix(abs(a(:,21))*2)/2+0.25); box on;
        set(findobj(gcf,'Tag','legend'),'Location','EastOutside');
        hold on; plot(a(j,10),a(j,8).*a(j,11),'kx','MarkerSize',10); grid
    end
    title(sprintf('Bad Hg remove (legend means: group = value +/- 0.25). Hg Limit = %4.2f',hg_limit));
    ylabel('ozone slant path');
    a(j,:)=[];
            
   % AIRM
   j=find(abs(a(:,8)>=6.0));
   for ii=1:length(j)
      J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
      b(J,:)=[];
   end
   figure;   plot(a(:,8).*a(:,11),a(:,8),'o','MarkerSize',7)
   hold on; plot(a(j,8).*a(j,11),a(j,8),'x','MarkerSize',10); 
   ylabel('Airmass'); xlabel('OSC'); grid
   a(j,:)=[];


        figure
        set(gcf,'tag','SC_Control_3');
        subplot(2,1,1)
        if size(unique(fix( (a(:,2)-a(:,23))*60*24)),1)==1;
           plot(a(:,10),a(:,8).*a(:,11),'o');
           legend(num2str(unique(fix( (a(:,2)-a(:,23))*60*24))));
        else
        gscatter(a(:,10),a(:,8).*a(:,11),round((a(:,2)-a(:,23))*60*24)); box on;
        set(findobj(gcf,'Tag','legend'),'Location','EastOutside');
        end
        title('Time since last Hg (minutes)');
        ylabel('ozone slant path')
        subplot(2,1,2)
        if size(unique(diaj(a(:,1))),1)==1;
           plot(a(:,10),a(:,8).*a(:,11),'.');
           legend(num2str(diaj(a(1,1))),'Location','EastOutside');
        else
        gscatter(a(:,10),a(:,11).*a(:,8),diaj(a(:,1))); box on;
        set(findobj(gcf,'Tag','legend'),'Location','EastOutside');
        end
        title('SC plot by day');        
        ylabel('ozone slant path')        
end
else
  a=sc_avg;
  b=sc_raw;
  disp('Warning no valid SC');
  j=find(abs(a(:,17)>=residual_limit));
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
    if ~isempty(hg_time)
       j=find(abs(24*60*(a(:,23)-a(:,2)))>abs(hg_time));
%     for ii=1:length(j)
%         J=find(fix(b(:,1))==fix(a(j(ii),1)) & fix(b(:,2)/100)==a(j(ii),3) );
%         b(J,:)=[];
%     end        
%     title(sprintf('Bad Hg remove (legend means: group = value +/- 0.25). Hg Limit = %4.2f',hg_limit));
       hold on; plot(a(j,1),24*60*(a(j,23)-a(j,2)),'kx','MarkerSize',10);
       a(j,:)=[];
    end
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
if one_flag
   dias=unique(diaj(b(~isnan(b(:,1)),1)));
   if length(dias)>5
      % last ten
      dias_=dias(end-5:end);
   else
      dias_=dias;
   end
   for jj=1:length(dias_)  
      scavg_=a(diaj(a(:,1))==dias_(jj),:);
      scraw_=b(diaj(b(:,1))==dias_(jj),:);
      medida=fix(scraw_(:,2)/100);
      if ~isempty(scraw_)
          for ii=1:size(scavg_,1),
              h=figure;
              set(h,'tag',sprintf('%s%i%c%i','SC_INDIVIDUAL',jj,'_',ii)); 
              sc_=scraw_(medida==scavg_(ii,3),:);
              sca=scavg_(ii,:);
              %subplot(3,2,mod(i,6)+1);
              [P,s,v]=polyplot2(sc_(:,3),sc_(:,20));
%               hold on; [P,s,v]=polyplot2(sc_(:,3),sc_(:,20));
              % polyplot2(sc_(:,3),sc_(:,18).*sc_(:,8));
% esto se refiere al calculo hecho              
              title(sprintf('Brewer#%s, ddd=%d (%s)\n airm=%.2f  filter=%d ozone=%.1f  step=%.1f \\Delta hg step=%.1f ',...
                              brw_str,dias(jj),datestr(sca(1,1)),sca(1,[8,9]),v(2),v(1),sca(1,21)));
% esto se refiere al brewer              
%               title(sprintf(' airm=%.2f  filter=%d ozone=%.1f  step=%.1f \\Delta hg step=%.1f ',sca(1,[8,9,11,10,21])));
%              ,['y=',poly2str(round(sca(18:20)*100)/100,'x'),'',sprintf(' normr=%.1f',sca(1,17))]},'FontSize',9);
              xlabel('step');  ylabel('ozone');
              set(gca,'LineWidth',1);
%                  ['y=',poly2str(round(sca(18:20)*100)/100,'x'),'',sprintf(' normr=%.1f',sca(1,17))]},'FontSize',9);  
          end
     end
   end
set(h,'Tag','SC_INDIVIDUAL');     
end
%figure;
%plot(a(:,10),a(:,8).*a(:,11),'.',a(:,15),a(:,16).*a(:,8),'+')
%rline

%%
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
ylim([300 1700]); xlim(xlims);
hold on;
h1=plot(X,a(:,8).*a(:,11),'o');
try
step_cal=invpred(x,y,ref_iau);
catch
    step_cal=NaN;
end
[y1,delta1]=polyconf(p,step_cal,s);
try   
    step0=invpred(x,y,ref_iau+delta1);
catch
    step0=NaN;
end
try    
    step1=invpred(x,y,ref_iau-delta1);
catch
    step1=NaN;
end

hl=hline([ref_iau,ref_iau+delta1,ref_iau-delta1],{'b-','r:','r:'},{'','',''}); 
vl=vline(([step0,step_cal,step1]),{'r:','b-','r:'},{'','',''}); 
try
title(sprintf('OSC clim. =%.0f   Calc Step = %.1f [%.1f,%.1f] \n   Calibration Step from config file %s = %.0f ',...
               ref_iau,step_cal,step0,step1,brw_config(end-11:end),CSN_orig));
catch
    title('OSC no config file');
end
% sup=suptitle(brw_str); pos=get(sup,'Position');
% set(sup,'Position',[pos(1)+.02,pos(2)+.02,1]);
ylabel('Ozone slant Path'); xlabel(' Calc Step number');
orient('portrait');  

% date, csn cal, CI-, CI+, csn cfg
step_cal=[mean(unique(sc_raw(:,1))),step_cal,step0,step1,CSN_orig];    sc_avg=a;

if chk
    % Se muestran los argumentos que toman los valores por defecto
  disp('--------- Validation OK --------------') 
  disp('List of arguments given default values:') 
  if ~numel(arg.UsingDefaults)==0
     for k=1:numel(arg.UsingDefaults)
        field = char(arg.UsingDefaults(k));
        value = arg.Results.(field);
        if isempty(value),   value = '[]';   
        elseif isfloat(value), value = num2str(value); end
        disp(sprintf('   ''%s''    defaults to %s', field, value))
     end
  else
     disp('               None                   ')
  end
  disp('--------------------------------------') 
else
     disp('NO INPUT VALIDATION!!')
     disp(sprintf('%s',errval.message))
end