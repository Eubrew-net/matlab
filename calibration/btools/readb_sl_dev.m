
function [sl_data,hg_data,config]=readb_sl_dev(bfile,config_file)
% Config
% 1 si no le damos configuracion-> la lee del fichero B
% 2 si la configuracion es el nombre del fichero ICF la lee del fichero
% 2a si tiene dos configuraciones ingnora la del fichero
% 3 si es una variable considera que es una tabla de configuracion
%
%
% output
%  o3 structure;
%
dsum=[];ds=[];dss=[];timeds=[];timedss=[];ds_l=[];ds_aod=[];
ds=[];dss=[];ndss=0;timedsum=[];timeds=[];
sl=[];sls=[];nsl=0;nsls=0;timesls=[];timesl=[];
TC=[];config=[];
config_2=[];
TC_2=[];
DT_2=[];
extrat_2=[];absx_2=[];AT_2=[];

%formats for reading the bfile
fmtds=[' ds %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f'];
fmtsc=[' sc %c %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];

fmt=['ds %*s %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d']; % format of ds Bfile
fmtsum=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format
fmtsum_output=['summary\r%d:%d:%d\r%c%c%c\r%d/\r%d\r%.5f\r%.3f\r%d\r%c%c\r%d\r%d\r%d\r%d\r%d\r%d\r%d\r%.1f\r%.1f\r%d\r%d\r%d\r%d\r%d\r%d\r%.1f\r%.1f']; % output summary format
fmtinst=['inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%*3c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'];
TCfmt=['inst %f %f %f %f %f '];
absfmt=['inst %*f %*f %*f %*f %*f %*f %f %f %f '];
extratfmt=['inst %*f %*f %*f %*f %*f %*f %*f %*f %*f %f %f'];
dtfmt=['inst %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f'];
fmtum=['um %d %d %d %*s %f %f %f pr %f %d %f %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
fmtum_output=['summary\r%d:%d:%d\r%c%c%c\r%f/\r%f\r%f\r%f\r%f\r%c%c\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f']; % output um format
fmt_icf=[
'inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%3c',...
' %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s'];
fmtsl=[' sl %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f'];
fmtsl_old=[' sl %c %d %f %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];

%Filter definition
filter=[0,64,128,192,256];

% Weight definition for the seven slits
% slit 0 used for hg calibration slit 1-> dark
O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    0  -1.00    0.00    0.00    4.20   -3.20];
WN=[302.1,306.3,310.1,313.5,316.8,320.1];
% MS8 SO2 ms9 o3 en el soft del brewer.
% single ratios used in brewer software
rms4=[0 0 -1  0  0  1  0];
rms5=[0 0  0 -1  0  1  0];
rms6=[0 0  0  0 -1  1  0];
rms7=[0 0  0  0  0 -1  1];
% matriz de ratios
% Ratios=F*W;0.
W=[rms4;rms5;rms6;rms7;SO2W;O3W]';

%leemos el fichero en memoria

s=fileread(bfile);
%leemos la fecha del fichero
[path,name,ext]=fileparts(bfile);

fileinfo=sscanf([name,ext],'%c%03d%02d.%03d');
datefich=datejul(fileinfo(3),fileinfo(2));
datestr(datefich(1))
% Flag de fecha

l=mmstrtok(s,char(10));

jds=strmatch('ds',l);
jsum=strmatch('summary',l);
jco=strmatch('co',l);
jum=strmatch('um',l);
jhg=strmatch('hg',l);
jhgscan=strmatch('hgscan',l);
jsl=strmatch('sl',l);


jsc=strmatch('sc',l);

%measures=cell('ds','zs','uq','co');




% READ CONFIGURATION
% colunna 1 % Configuracion en el fichero
% columna 2 % configuracion proporcionada
%read header

buf=l{1}; % get first line, should be version...
if any(strmatch('version',buf))==1, %then OK
    ind=find(buf==char(13));
    lat=str2num(buf(ind(6):ind(7)));
    long=str2num(buf(ind(7):ind(8)));
    pr=str2num(buf(ind(end-1):end));
end
% primera configuracio la del fichero B
[config,TC,DT,extrat,absx,AT]=readb_config(bfile);


% Lecura de la segunda configuracion
if nargin>1 & isnumeric(config_file)  % matriz  de configuraciones
    %
    cal_idx=max(find(config_file(1,:)<=datefich(1))); % calibracion mas proxima
    datestr(config_file(1,cal_idx) )

    if ~isnan(config_file(2:6,cal_idx))
        TC_=config_file(2:6,cal_idx); end
    if ~isnan(config_file(13,cal_idx))
        DT_=config_file(13,cal_idx);  end
    if ~isnan(config_file(11:12,cal_idx))
        extrat_=config_file(11:12,cal_idx); end %    B1=extrat(1);B2=extrat(2);
    if ~isnan(config_file(8:10,cal_idx))
        absx_=config_file(8:10,cal_idx);    end % A1=absx(1);A2=absx(2);A3=absx(3);
    if ~isnan(config_file(17:22,cal_idx))
        AT_=config_file(17:22,cal_idx);     end % atenuacion
    % revisar
%     config_file(8:10,2)=absx;
%     config_file(11:12,2)=extrat;
%     config_file(2:6,2)=TC;
%    config_file(17:22,2)=inst(16:21); % atenuation filters

    config(:,2)=config_file(:,cal_idx); %quitamos la fecha
    TC_=[TC(:)',config_file(26,cal_idx)]'; % temperature coef for lamda1
elseif  nargin>1 && ischar(config_file)
        [config_,TC_,DT_,extrat_,absx_,AT_]=read_icf(config_file);
        config(:,2)=config_;
elseif nargin>1 && iscellstr(config_file)
    % ignoramos la configuracion del fichero
    [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file{2});
    config(:,2)=config_2;
    %disp('config 2')
    %disp(config_file{2})
    try
        [config_,TC_,DT_,extrat_,absx_,AT_]=read_icf(config_file{1});
        config(:,1)=config_;
    catch
        disp('cofiguracion del fichero');
    end
else
    if nargin~=1
        disp('ERROR de configuracion');
    end
end
% 5420 REM get O3 TC's
% 5422 FOR J=2 TO 6:INPUT#8,TC(J):NEXT
% 5424 TC(0)=TC(2)-TC(5)-3.2*(TC(5)-TC(6)):TQ(0)=TC(0)
% 5426 TC(1)=TC(3)-TC(5)-.5*(TC(4)-TC(5))-1.7*(TC(5)-TC(6)):
% cambiamos los indices.
if isempty(TC)
    % error en leer la configuracion del fichero
    TC=TC_';
    AT=AT_;
    DT=DT_;
    config(:,1)=config(:,2)
end
TC=[NaN,NaN,TC];
TC(1)=TC(3)-TC(6)-3.2*(TC(6)-TC(7));
TC(2)=TC(5)-TC(6)-.5*(TC(5)-TC(6))-1.7*(TC(6)-TC(7));
% segunda configuracion
if size(config,2)==2
  if isempty(TC_2)
    TC_=[NaN,NaN,TC_(1:6)'];
    TC_(1)=TC_(3)-TC_(6)-3.2*(TC_(6)-TC_(7));
    TC_(2)=TC_(5)-TC_(6)-.5*(TC_(5)-TC_(6))-1.7*(TC_(6)-TC_(7));
    TC=[TC;TC_];
    DT=[DT;DT_];
    AT=[AT,AT_]';
  else  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REPROGRAMAR ESTA CHAPUZA
    TC_=[NaN,NaN,TC_2(1:6)'];
    TC_(1)=TC_(3)-TC_(6)-3.2*(TC_(6)-TC_(7));
    TC_(2)=TC_(5)-TC_(6)-.5*(TC_(5)-TC_(6))-1.7*(TC_(6)-TC_(7));
    TC=[TC;TC_];
    DT=[DT;DT_2];
    AT=[AT,AT_2]';
  end
else
    AT=AT(:)';% AT en fila
end

% a�adimos la fecha del fichero al final

if size(config,2)==2
    config=[config;[datefich(1),datefich(1)]];
else
    config=[config;datefich(1)];
end




% READ HG
% filtro de hg
  if isempty(jhgscan)
   %hg=sscanf(char(l(jhg))','hg %d:%d:%d %f %f %d %f %d ',[8,Inf]);
   hg=cell2mat(textscan(char(l(jhg))','hg %f:%f:%f %f %f %f %f %f ',...
       'delimiter',char(13),'multipleDelimsAsOne',1));
   hg=hg';
   hg=[hg;nan*hg(1,:)];
  else
    jhg=setdiff(jhg,jhgscan);
    hg=sscanf(char(l(jhg))','hg %d:%d:%d %f %f %d %f %d %d ',[9,Inf]);
    hg=[hg;nan*hg(1,:)];
  end
  time_hg=hg(1,:)*60+hg(2,:)+hg(3,:)/60; %a minutos
  flaghg=abs(hg(5,:)-config(14))<2; % more than 2 steps change
  %  flag_hg=find(diff(flaghg)==-1);   %
  if size(hg,2)>1
        flag_hg=find(diff(flaghg)==-1);   %

       
        if isempty(flag_hg)
            time_badhg=[0,0];
        else
            if flaghg(1)==0    % revisa
                flag_hg=[1,flag_hg];
            end
        
             %revisar no es el siguiente sino el proximo no negativo
            % almacenar la constante en el fichero.

            time_badhg=time_hg([flag_hg;flag_hg+1]');
            time_badhg=[0,time_hg(1);time_badhg];
        end
    else
        time_badhg=[0,0];
  end

   hgscan_date=datefich(1)+time_hg/60/24;
   jaux=find(diff(hgscan_date)<0);
   if ~isempty(jaux)
       if time_hg(jaux)>21*60
           hgscan_date(jaux+1:end)=hgscan_date(jaux+1:end)+1;
       else
           disp('hg fecha');
       end
   end
  hg_data.hg=[hgscan_date;hg;flaghg]';
  hg_data.hg_legend={'fecha'	'hora'	'min'	'seg'	'coef' 	'step'...
      'step_int'	'int'	'temp'	'steps_chg'	'flag'...
};


    hg_data.time_badhg=time_badhg/60/24+datefich(1);

    
  %%%  
  nsls=0;
  for i=1:length(jsum)
      dsum=sscanf(l{jsum(i)},fmtsum);
      type=char(dsum(12:13)');
      month=char(dsum(4:7)');
      fecha=datenum(sprintf(' %02d/%s/%02d',dsum(7),month,dsum(8)));
      hora=dsum(1)/24+dsum(2)/24/60+dsum(3)/24/60/60;
      if strmatch('sl',type)% if ds
          nsls=nsls+1;
          %jslsum(nsls)=jsum(i);
          sl_idx=find(jsl-jsum(i)<0 & jsl-jsum(i)>=-7);
          %jsl(sl_idx);
          if length(sl_idx)==7  % medida completa 7 medidas individuales
              timesls=[timesls;[fecha+hora,jsum(i)]];
              sls=[sls,dsum];
              for ii=1:7
                  ds_=sscanf(l{jsl(sl_idx(ii))},fmtsl);
                  if size(ds_,1)==17 % new soft
                      sl=[sl,ds_];
                      hora=ds_(3)/60/24;
                      timesl=[timesl;[fecha+hora,jsl(sl_idx(ii)),size(sls,2)*10+ii]];
                  else
                      ds_=sscanf(l{jsl(sl_idx(ii))},fmtsl_old);
                      if size(ds_,1)==16 % old soft
                          ds_=[ds_(1:6);0;ds_(7:end)];
                          sl=[sl,ds_];
                          hora=ds_(3)/60/24;
                          timesl=[timesl;[fecha+hora,jsl(sl_idx(ii)),size(sls,2)*10+ii]];
                      end
                  end
              end
          end
       end
  end
    

if ~isempty(sls)
% SLS hora a formato matlab ->sumarios
    hora_sl=sls(1,:)*60+sls(2,:)+sls(3,:)/60;

    %idx_sl indice de la medida sl
    idx_sl=fix(timesl(:,3)/10);
    %TEMPERATURA% asignamos la temperatura al sl del sumario
    sl_temp=sls(11,idx_sl)';

    timesl=[timesl,sl_temp]; % temperatura;sls(11);

    %filtro HG para medidas SL
    tb_ds=[];    tb_dsum=[];
    for ii=1:size(time_badhg,1)

     tb_dsum=[tb_dsum,find((hora_sl>time_badhg(ii,1)   & hora_sl<time_badhg(ii,2)))];
     tb_ds=[tb_ds,find((sl(3,:)>time_badhg(ii,1) & sl(3,:)<time_badhg(ii,2)))];
    end
    timesl(:,2)=ones(size(timesl(:,2)));
    timesls(:,2)=ones(size(timesls(:,2)));
    if ~isempty(tb_dsum)
          timesl(tb_ds,2)=0;
          timesls(tb_dsum,2)=0;
          warning('sl bad hg');
    end

%
%     timesl(:,2)=zeros(size(timesl(:,2)));
%     timesls(:,2)=zeros(size(timesls(:,2)));
%     if ~isempty(tb_dsum)
%           timesl(~tb_ds,2)=0;
%           timesl(~tb_dsum,2)=0;
%           warning('sl bad hg');
%     end


    sl=sl';sl_raw=sl;
    sls=sls';sls_raw=sls;
    %RAW valores del fichero
    sl_data.sls_raw=[timesls,sls_raw];
    sl_data.sl_raw=[timesl,sl_raw];
    %RECALCULATION


    %function DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF)
    % sl -> filtro1 NDfilter time lowslit hislit cy raw0 ....raw6
    % ...ratio1...4
    DS=ds_counts(sl(:,7:13),sl(:,2),sl_temp,sl(:,6),DT(1,:),TC(1,:),AT(1,:));
    ratios=[DS*W,sl(:,9),sl(:,13)];
%% 8240 NEXT:PRINT#4,:MS(10)=F(2):MS(11)=F(6):REM SL needs raw counts


%     figure; %     plot(100*(ratios_orig-round(ratios))./ratios_orig);
% legend('ms4','ms5','ms6','ms7','ms8','ms9','w1','w5');
%     figure;      plot1(ratios_orig./ratios,'.');     plot2(sl_temp);
%     Fr=ratio2counts(sl_data.sls_raw);
%     Se puede evaluar fuera.
%      figure;plot(timesl(:,1),DS(:,3:7),sl_data.sls_raw(:,1),Fr(:,3:7))
%      m1=grpstats(DS(:,3:7),idx_sl,{'mean'});
%      figure;plot(100*(round(m1)-Fr(:,3:7))./Fr(:,3:7))

% cuentas recalculadas con las ctes del fichero/config1

     [sls_m,sls_std]=grpstats(ratios,idx_sl,{'mean','std'});
     sls(:,15:22)=sls_m;
     sls(:,23:30)=sls_std;
     sl_data.sls_c=[timesls,sls];
     sl_data.sl_c=[timesl,DS,ratios];
     % time cuentas/sec ratios

   if size(config,2)==2
      DS2=ds_counts(sl(:,7:13),sl(:,2),sl_temp,sl(:,6),DT(2,:),TC(2,:),AT(2,:));
      ratios2=[DS2*W,sl(:,9),sl(:,13)];
      sl_data.sl_cr=[timesl,DS2,ratios2];
      %      figure   plot(sls_m./sls(:,15:22))    legend('ms4','ms5','ms6','ms7','ms8','ms9','w1','w5');
     % Sumario
     [sls_m,sls_std]=grpstats(ratios2,idx_sl,{'mean','std'});
     sls(:,15:22)=sls_m;
     sls(:,23:30)=sls_std;
     sl_data.sls_cr=[timesls,sls];
   end


     sl_data.sls_legend={...
         %1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32
        'fecha'	'hg'	'h'	'm'	's'	'm'	'm'	'm'	'n' 'nm'	'sza'	'airm'	'temp'...
        ' s'	'l	' 'fil'	'Ms4'	'Ms5'	'Ms6'	'Ms7'	'Ms8'	'Ms9'	'Ms10'	'Ms11'...
        'sms4'	'sms5' 'sms6'	'sms7'	'sms8'	'sms9'	'sms10'	'sms11'...
        };
     sl_data.sl_legend ={'fexha' 'hg' 'idx'	'temp'...
                        'L0'	'L1'	'L2'	'L3'	'L4'	'L5'	'L6'...
                        'ms4'	'ms5'	'ms6'	'ms7'	'ms8'	'ms9'	'R1'	'R5'};






else
    sl_data.sls=[];
    sl_data.sl=[];
    sl_data.slraw=[];
    sl_data.sls_c=[];
    sl_data.sl_c=[];
    sl_data.sls_cr=[];
    sl_data.sl_cr=[];

end



function [flag,time]=hg_filter(dsvar,hg_time)
% dsvar-> temperature first column
% hgtime-> time interval of wrong hg step change >2
% flag 1 ok, zero bad hg
% time since last hg ok
    
     flag=dsvar(:,1)*NaN;
     for ii=1:size(time_badhg,1)
        flag=[tb_dsum,find((dsvar(:,1)>time_badhg(ii,1)   & dsvar(:,1)<time_badhg(ii,2)))];
     end
    





function [ozone,so2,ratios]=ozone_cal(DS,m2,config)
% 8700 REM -8799 calculate ratios
% 8705 IF MDD$="n2" THEN 8730
% FOR I=4 TO 6:MS(I)=F(5)-F(I-2):NEXT:
% 						MS(7)=F(6)-F(5):REM single ratios
% 8715   MS(8)=MS(4)-3.2*MS(7):REM SO2 ratio
% 8720   MS(9)=MS(5)-.5*MS(6)-1.7*MS(7):REM O3 ratio

    ms4=DS(:,6)-DS(:,3);
    ms5=DS(:,6)-DS(:,4);
    ms6=DS(:,6)-DS(:,5);
    ms7=DS(:,7)-DS(:,6);
    ms9=ms5-0.5*ms6-1.7*ms7;     % o3 double ratio ==MS(9)
    ms8=ms4-3.2*ms7;             %:REM SO2 ratio MS(8)
    
    B1=config(11);B2=config(12);
    A1=config(8);A2=config(9);A3=config(10);  
    ozone=(ms9-B1)./(10*A1*m2);
    so2=(ms8-B2)./(A2*A3*m2)-ozone/A2;
    ratios=[ms4,ms5,ms6,ms7,ms8,ms9];
    
    
    
function ratios=calc_ratios(F)
        
% Weight definition for the seven slits
% slit 0 used for hg calibration slit 1-> dark
O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    0  -1.00    0.00    0.00    4.20   -3.20];
% MS8 SO2 ms9 o3 en el soft del brewer.
% single ratios used in brewer software
rms4=[0 0 -1  0  0  1  0];
rms5=[0 0  0 -1  0  1  0];
rms6=[0 0  0  0 -1  1  0];
rms7=[0 0  0  0  0 -1  1];


        
        
    
function F=ratio2counts(sls)
    % Del programa de analisis de SL.
    % entramos con los sumarios
    % SLSUMARY-> 
    MS=sls(:,17:24); %el uno es el MS4-> restar 3
    %  ratios=[ms4,ms5,ms6,ms7,ms8,ms9,sl(:,9),sl(:,13)];
    %           1   2   3   4   5   6   F(3)     F(7)
    % F 1->7
    %   S0 DARK S1 S2   S3  S4  S5  
    % F   1  2   3  4    5   6   7  8  9
    % f   0  1   2  3    4   5   6 
    
    F(:,3)=log(MS(:,7))*1E4/log(10); % deshacemos la escala
    % MS7 son la cuentas de la slit 1->f(2)
    F(:,6)=MS(:,1)+F(:,3); % f5= ms4 - f2
    F(:,4)=F(:,6)-MS(:,2); % f3=f5-MS5
    F(:,5)=F(:,6)-MS(:,3); % f4=f5-ms6
    F(:,7)=F(:,6)+MS(:,4); % f6=f5+ms7
    F(:,8)=MS(:,5);      % ms(8)   
    F(:,9)=MS(:,6);      % ms(9)    
    % F(7) tiene que ser igual a MS8 !!
    %F8c=log(MS(:,8))*1E4/log(10);
    %figure;plot(100*(F(:,7)-F8c)./F(:,7));



% 
function DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF)
  
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
  F0=F;
  for j=1:9
     for i=1:7  
        F(:,i)=(F0(:,i).*exp(F(:,i)*DT)); 
     end
  end
  F=round(log10(F)*10^4);  %aritmetica entera
  
% REM calc corr F's
% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
% 8315   F(I)=LOG(VA)/CO*P4%:J=I:IF J=0 THEN J=7
% 8320   IF MDD$="o3" THEN X=TC(J) ELSE X=NTC(J)
% 8325   F(I)=F(I)+X*TE%+AF(AF%)
% 8335 NEXT:RETURN

  Filtro=(Filtro/64)+1;
  %
  for j=1:7

      if j~=1  
          ii=j;
      else
          ii=8;
      end
      % slit 0 no tiene correccion (no se usa para ozono) 
      F(:,j)=F(:,j)+(TC(ii)*temp)+AF(Filtro);
  end
  F(:,2)=F_dark;
  DS=F; 

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %function RC=rayleigth_cor(F,P,M3,BE)
  %Rayleight correction
  % Si se proporcionan coeficientes se calculan si no se usa el standard
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function RC=rayleigth_cor(F,P,M3,BE)
   % F(I)=F(I)+BE(I)*M3*PZ%/1013:REM rayleigh

      
      if nargin==3 % si no usa la estandard
        % FROM INIT.RTN 
        %12060 FOR I=2 TO 6:READ BE(I):NEXT:REM  read Rayleigh coeffs
        %12070 DATA 4870,4620,4410,4220,4040

      BE=[0,0,4870,4620,4410,4220,4040];
      end
    % BE=[5327    0 5096    4835    4610    4408    4217];
    for j=1:7
        F(:,j)=F(:,j)+BE(j)*M3*P/1013;         
    end    
  RC=F;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % function ozone_cal_raw=(DS,m2,P,M3,BE)
  % ozone calculation from counts/seconds
  % input data
  %  DS counts/second
  %  
  % 1� Rayleight correction
  %  Si se proporcionan coeficientes se calculan si no se usa el standard
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  function [ozone,so2,ratios]=ozone_cal_raw(DS,m2,P,M3,config)
 
    DS=rayleigth_cor(F2,pr,m3ds);  
      
    ms4=DS(:,6)-DS(:,3);
    ms5=DS(:,6)-DS(:,4);
    ms6=DS(:,6)-DS(:,5);
    ms7=DS(:,7)-DS(:,6);
    ms9=ms5-0.5*ms6-1.7*ms7;     % o3 double ratio ==MS(9)
    ms8=ms4-3.2*ms7;             %:REM SO2 ratio MS(8)
    
        
    B1=config(11);B2=config(12);
    A1=config(8);A2=config(9);A3=config(10);  
    ozone=(ms9-B1)./(10*A1*m2);
    so2=(ms8-B2)./(A2*A3*m2)-ozone/A2;
    ratios=[DS,ms4,ms5,ms6,ms7,ms8,ms9];

function [p,s,v]=polyfit2(x,y)
[p1,s,m]=polyfit(x,y,2);
%desacemos el cambio
p(1)=p1(1)/m(2)^2;
p(2)=p1(2)/m(2)-2*p1(1)*m(1)/m(2)^2;
p(3)=p1(1)*(m(1)/m(2))^2-p1(2)*(m(1)/m(2))+p1(3);
v=[round(-p(2)/2/p(1)),polyval(p,round(-p(2)/2/p(1)))];


