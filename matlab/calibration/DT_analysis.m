function DT_analysis(Cal,ozone_raw0,config,varargin)
%function DT_analysis(Cal,ozone_raw0,config,varargin)
% En principio pensada para chequear efecto del DT sobre la calibración,
% ahora permite comparar calibraciones:
% config son tres columnas: 1ª configuracion, 2ª configuracion y Bfiles header
% Se comparan la 2ª (matriz de calibración) con la 1ª (configuración de prueba)
% 
% Tres gráficos:
%  (optional) Raw counts vs Time, grouped by filtes, for every day processed
%  1) Signal-to-Noise ratio vs. Airmass, grouped by filters, for four ozone canals
%  2) Signal-to-Noise ratio vs. Time for SL MS9, grouped by filters
%  3) Ozone relative differences of both calibrations. Referenced always to
%     final config. (2ª). NO SE ESTÁN DESCARTANDO SD>2.5
% 
% INPUTS:
%   Mandatory
%       - Cal, ozone_raw0, config 
% 
%   Optional:
%       - date_select: un date_range, pero en dia juliano. Se usan sólo los
%                      días especificados !!
%       - DTv         : Vector de dos elementos. Valores de DT a comparar.
%                      Si no especificamos nada, se comparan las dos calibraciones
%                     (config1 y config2), si lo pasamos como argumento, entonces se
%                      compara la misma calibración (ver n_config) con los 2 DT's
%       - plot_flag  : 0 | 1 Ploteo de dias individuales (raw counts vs time, grouped by filters) 
%       - n_config   : 1 | 2 check DT on first | second config. 
%                      It is not relevant, just to show constant we want
% 
% Ejemplo: DT_analysis(Cal,ozone_raw0,config,'date_select',[200,230,250],'DTv',[30 35],'n_config',1); 
% 
% TODO: Filtrar outliers

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='DT_function';

arg.addRequired('Cal', @isstruct);
arg.addRequired('ozone_raw0', @iscell);
arg.addRequired('config', @iscell);

arg.StructExpand = false;
arg.addParamValue('date_select', [], @isfloat); % por defecto: no control de fechas. Dia Juliano!!
arg.addParamValue('DTv', [], @isfloat); % por defecto: [DT1, DT2] from config
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1)); % por defecto, no individual plots
arg.addParamValue('n_config', 2, @(x)(x==1 || x==2)); % por defecto: segunda configuración to check DT 

try
  arg.parse(Cal, ozone_raw0, config, varargin{:});
  mmv2struct(arg.Results); Args=arg.Results;
  chk=1;
catch
  errval=lasterror;  chk=0;
end

lectures_legend={'date';'flg';'nds';'tmp';'fl1';'fl2';'tim';'m2 ';'m3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
                                                            'F4 ';'F5 ';'F6 ';'r1 ';'r2 ';'r3 ';'r4 ';'r5 ';'r6 '};
O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
IT=0.1147;

raw=ozone_raw0{Cal.n_inst}; myfunc=@(x)diaj(x(1,1));
fech=cell2mat(cellfun(myfunc,raw, 'UniformOutput', false)');
if ~isempty(date_select)
    [c, ia] = intersect(fech,date_select);    
    raw=raw(ia);
end

cfg=config{Cal.n_inst}{end}(:,1:2);% Usamos configuración final, 2
TC1=cfg(2:7,1); DT1=cfg(13,1); extrat1=cfg(11,1); absx1=cfg(8,1); AT1=cfg(17:22,1);
TC2=cfg(2:7,2); DT2=cfg(13,2); extrat2=cfg(11,2); absx2=cfg(8,2); AT2=cfg(17:22,2);

if isempty(DTv)
   DTv=[DT1,DT2]; 
else
   DTv=DTv.*10^-9;
   if n_config==2
      TC1=TC2; extrat1=extrat2; absx1=absx2; AT1=AT2;
   else
      TC2=TC1; extrat2=extrat1; absx2=absx1; AT2=AT1;
   end
end

%% Raw counts
if plot_flag
    for days=1:length(raw)
        data=[];
        % leemos datos        
        data=raw{days}; data=data(data(:,2)>0,:);% hg filter
        % ploteamos raw counts vs time
        figure; set(gcf,'Tag',sprintf('raw_counts_%03d',diaj(data(1,1))));
        gscatter(data(:,7)/60,data(:,15),data(:,6),'','*',5,'on','Hour','Raw  Counts'); 
        set(gca,'Xlim',[6 18],'Yscale','Log'); grid; box on;
        title(sprintf('%s: Raw Counts Grouped by Filter, Day %03d ',Cal.brw_name{Cal.n_inst},diaj(data(1,1))));        
    end
end

%% DT on counts
%     counts_=[]; cps_=[]; cps_dark=[];
%     for days=1:length(raw)
%         data=[];
%         % leemos datos        
%         data=raw{days}; data=data(data(:,2)>0,:);% hg filter
%         [data_,data_std,data_N]=grpstats(data,fix(data(:,3)/10),{'mean','std','numel'});
%         idx=data_N(:,1)<5; 
%         data_(idx,:)=[]; data_std(idx,:)=[]; data_N(idx,:)=[];% Eliminamos <5 medidas individuales
%         % Asignamos raw counts
%         counts=data_(:,11:17); dark=data_(:,12); cy=data_(:,10);
%         counts(counts<=0)=2; counts(counts>1E7)=1E7;
%         if plot_flag
%            figure;
%            gscatter(data(:,7)/60,data(:,15),data(:,6),'','*',5,'on','Hour','Raw  Counts'); 
%            set(gca,'Ygrid','On','Xlim',[6 18],'Yscale','Log');
%            box on;
%            title(sprintf('%s: Raw Counts Grouped by Filter, Day %03d ',Cal.brw_name{Cal.n_inst},diaj(data(1,1))));        
%         end
%         % cps = counts/second
%         cps=2*matdiv(matadd(counts,-dark),cy.*IT);
%         cps_d=2*matdiv(dark,cy.*IT);
%       
%         % dead time correction F=F0*e^(-DT*F0) Nos interesa F0 (true count rate)
%         % y tenemos F. Hacemos F0 = F*e^(DT*F0) 
%         F=cps; CNT=[];
%         for dt_indx=1:length(DTv)
%             DT_=DTv(dt_indx); 
%             for j=1:9 % iteramos 9 veces (en primera aproximación F=F0)      
%                 if j==1, F0=counts; end
%                 for slit=1:7 % las 7 wl's 
%                     F0(:,slit)=(F(:,slit).*exp(F0(:,slit)*DT_)); 
%                 end   
%             end
%            F_dt=round(log10(F0)*10^4);% aritmetica entera
%            CNT(:,:,dt_indx)=[data_(:,1),F_dt,data_(:,8),data_(:,6),data_(:,7)];
%         end   
%         counts_=[counts_;CNT]; 
%         cps_=[cps_;cps]; cps_dark=[cps_dark;cps_d];
%     end
%     
%% counts/second DT corrected. Relativ. Diff DT_nom+10 - DT_nom
%     dt_nom=find(DTv==DT2);
%     if length(dt_nom)==1
%        figure;
%        rel_diff=(counts_(:,5:8,1)-counts_(:,5:8,dt_nom))*100./counts_(:,5:8,dt_nom);
%        [h,x,bt]=gplotmatrix(counts_(:,9,dt_nom),rel_diff,counts_(:,end-1,dt_nom),'','*',5,'on','hist','Airmass',lectures_legend(14:17));    
%        set(x,'YLim',[min(min(rel_diff)) max(max(rel_diff))],'Ygrid','On','Xlim',[.9 8],'Yscale','Log');
%        set(get(bt,'Title'),'String',...
%                         sprintf('%s: CPS (dt corrected) \n Rel. diff. DT=%e - DT=%e',Cal.brw_name{Cal.n_inst},DTv(1),DTv(2)));        
%     else
%        disp('Checking same DT for both configs'); 
%     end
    
%% Signal-to-noise ratio 
% % SNR = (cpsT -cpsD)  / sqrt( cpsT/T +cpsD/T)
% % SNR =2 *(NT-ND) / sqrt( NT/T +ND/T)
        % cps_all= counts/second 
  raw_=cell2mat(raw);
  cps_all=2*matdiv(matadd(raw_(:,11:17),-raw_(:,12)),raw_(:,10).*IT);
  cps_all_d=2*matdiv(raw_(:,12),raw_(:,10).*IT);

  delta_T=2*raw_(:,10)*IT;
  SNR=matadd(cps_all,-cps_all_d)./sqrt(matadd(matdiv(cps_all,delta_T), matdiv(cps_all_d,delta_T)));

  figure;
  [h,x,bt]=gplotmatrix(raw_(:,7)/60,SNR(:,4:7),raw_(:,6),'','',10,'on','hist','Airmass',lectures_legend(14:17));
  set(x,'YGrid','on'); % ,'XLim',[1 3.5]
  set(get(bt,'Title'),'String',[Cal.brw_name(Cal.n_inst),' Signal - to - Noise Ratio']);
  
  figure; 
  chck=SNR*O3W';
  gscatter(raw_(:,7)/60,chck,raw_(:,6),'','',7,'on','Time',' Signal-to-Noise Ratio');
  title(sprintf('%s: SL MS9',Cal.brw_name{Cal.n_inst}));
  set(gca,'YLim',[100 3000],'XLim',[6 18]); grid; box on;
  
%% DT on OZONE     
% coeficientes de temperatura
   TC_1=[NaN,NaN,TC1'];
   TC_1(1)=TC_1(3)-TC_1(6)-3.2*(TC_1(6)-TC_1(7));
   TC_1(2)=TC_1(5)-TC_1(6)-.5*(TC_1(5)-TC_1(6))-1.7*(TC_1(6)-TC_1(7));
   TC_1=TC_1;

   TC_2=[NaN,NaN,TC2'];
   TC_2(1)=TC_2(3)-TC_2(6)-3.2*(TC_2(6)-TC_2(7));
   TC_2(2)=TC_2(5)-TC_2(6)-.5*(TC_2(5)-TC_2(6))-1.7*(TC_2(6)-TC_2(7));
   TC_2=TC_2;

   ozono_1=[]; ozono_std1=[]; ozono_2=[]; ozono_std2=[];
   for days=1:length(raw)
       ozo_rc=[]; ozo_rc_std=[];
       data=raw{days}; data=data(data(:,2)>0,:);
       
       % DT, TC and AF corrected
       DS1=ds_counts(data(:,11:17),data(:,6),data(:,4),data(:,10),DTv(1),TC_1,AT1);
       DS2=ds_counts(data(:,11:17),data(:,6),data(:,4),data(:,10),DTv(2),TC_2,AT2);
       ds_1=DS1;  ds_2=DS2;

       % raleyght corrected
       BE=[0,0,4870,4620,4410,4220,4040];
       for j=1:7
           ds_1(:,j)=ds_1(:,j)+BE(j)*data(:,9);         
           ds_2(:,j)=ds_2(:,j)+BE(j)*data(:,9);         
       end    
       DS1=ds_1; DS2=ds_2;

       % ozone     
       ms5_1=DS1(:,6)-DS1(:,4);  ms6_1=DS1(:,6)-DS1(:,5);  ms7_1=DS1(:,7)-DS1(:,6);
       ms9_1=ms5_1-0.5*ms6_1-1.7*ms7_1;     % o3 double ratio MS(9)

       ms5_2=DS2(:,6)-DS2(:,4);  ms6_2=DS2(:,6)-DS2(:,5);  ms7_2=DS2(:,7)-DS2(:,6);
       ms9_2=ms5_2-0.5*ms6_2-1.7*ms7_2;     % o3 double ratio MS(9)

       ozone1=(ms9_1-extrat1(1))./(10*absx1(1)*data(:,8));
       ozone2=(ms9_2-extrat2(1))./(10*absx2(1)*data(:,8));
           
       idx_ds=fix(data(:,3)/10);
       [ozo_rc1,ozo_rc1_std]=grpstats([data(:,1),ozone1,data(:,6),data(:,8)],idx_ds,{'mean','std'});
       [ozo_rc2,ozo_rc2_std]=grpstats([data(:,1),ozone2,data(:,6),data(:,8)],idx_ds,{'mean','std'});
      
       ozono_1=[ozono_1;ozo_rc1]; ozono_2=[ozono_2;ozo_rc2];
       ozono_std1=[ozono_std1;ozo_rc1_std]; ozono_std2=[ozono_std2;ozo_rc2_std];
   end       

%% Plot DT on ozone
%   idx=ozono_std1(:,2)<=2.5;% eliminamos ozono malo
  ozono_1=ozono_1(:,:);  ozono_2=ozono_2(:,:); 
  ozono_std1=ozono_std1(:,:);
   
  figure; set(gcf,'Tag','DT_comp')
  x=gscatter(ozono_2(:,2).*ozono_2(:,4),(ozono_1(:,2)-ozono_2(:,2))*100./ozono_2(:,2),ozono_2(:,3),'','',7,'on','OSC','Ozone Relative Diff. (%)');
  set(gca,'XLim',[200 1800]);
  grid; box on; h=hline(0,'k-');set(h,'LineWidth',2);
  title(sprintf('%s: Ozone Config 1 vs Config 2 \n CONFIG 1: ETC=%d, A=%6.4f, DT=%3.1e; CONFIG 2: ETC=%d, A=%6.4f, DT=%3.1e',...
                 Cal.brw_name{Cal.n_inst},extrat1(1),absx1(1),DTv(1),extrat2(1),absx2(1),DTv(2)));  
  
             
             
             
function DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF,SAF)
  
%AF en columna
AF=AF(:);

% REM calc corr F's
% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
% 8350 REM correct VA for dark/dead time
% 8355 VA=(VA-F(1))*2/CY/IT:IF VA>1E+07 THEN VA=1E+07
% 8360 IF VA<2 THEN VA=2
% 8365 F1=VA:FOR J=0 TO 8:VA=F1*EXP(VA*T1):NEXT
% 8370 RETURN

%correccion por dark  
  F_dark=F(:,2);
  F(:,2)=NaN*F_dark;
  % otra constante
  IT=0.1147;
  for j=1:7
    F(:,j) = 2*(F(:,j)-F_dark)./CY/IT;
  end
  F(F<=0)=2;
  F(F>1E07)=1E07;

  % dead time correction
  F0=F;% asumimos F0=F para la primera iteración
  for j=1:9     
     for i=1:7  
        F0(:,i)=(F(:,i).*exp(F0(:,i)*DT)); 
     end
  end
  F=round(log10(F0)*10^4);  %aritmetica entera
  
% REM calc corr F's
% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
% 8315   F(I)=LOG(VA)/CO*P4%:J=I:IF J=0 THEN J=7
% 8320   IF MDD$="o3" THEN X=TC(J) ELSE X=NTC(J)
% 8325   F(I)=F(I)+X*TE%+AF(AF%)
% 8335 NEXT:RETURN

  Filtro=(Filtro/64)+1;
%
if nargin==7 % standard configuration
  for j=1:7

      if j~=1  
          ii=j;
      else
          ii=8;
      end
      % slit 0 no tiene correccion (no se usa para ozono) 
      F(:,j)=F(:,j)+(TC(ii)*temp)+AF(Filtro);
  end
else % spectral configuration
    SAF=[SAF(:,1),NaN*SAF(:,1),SAF(:,2:end),SAF(:,1)];

   for j=1:7

      if j~=1  
          ii=j;
      else
          ii=8;
      end
      % slit 0 no tiene correccion (no se usa para ozono) 
      F(:,j)=F(:,j)+(TC(ii)*temp)+SAF(Filtro,j);
  end
end   
    
  F(:,2)=F_dark;
  DS=F; 
