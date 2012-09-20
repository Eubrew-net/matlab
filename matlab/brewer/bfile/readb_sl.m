%function [slavg,sls_,sl_,hg,time_badhg,sl_raw,sls_raw]=readb_sl(bfile,config)
%%  Input :
%    bfile: fichero B, configuracion (ICF en formato ASCII)
%    Config:
%        1 si no le damos configuracion-> la lee del fichero B
%        2 si la configuracion es el nombre del fichero ICF la lee del fichero
%        3 si es una celda de dos configuraciones ingnora la del fichero (ojo revisar)
%        4 si es una variable considera que es una tabla de configuracion
%
%% Output:
%     .raw ; leidas del fichero            
%     .r   ; recalculadas 1 configruacion  : es igual a .raw en el caso 1 o
%                                            si icf=config del fichero 
%     .rc  ; recalculadas 2 configuracion
%
%          slavg: [Date R6 mean, R6 sigma, R5 mean, R5 sigma, N, Temp, Temp sigma]
%          sls  : sumarios [fecha ......
%          sl   :  medias indiv [fecha,temp,..........
% sls
%fecha	x1	x2	x3	x4	M	M	M	DD	AA	SZA	AIRM	TEM	S 	L 	FILTER	R1	R2	R3	R4	R5	R6	INT	INT2	SR1	SR2	SR3	SR4	SR5	SR6	SINT	SINT2
%1	    2	3	4	5	6	7	8	9	10	11	 12	    13	14	15	16	    17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32
%
%R1	R2	R3	R4	R5	R6	INT	INT2
%17	18	19	20	21	22	23	24
%
%SR1	SR2	SR3	SR4	SR5	SR6	SINT SINT2
%25  	26	27	28	29	30	31	 32

% SLAVG R6 SR6 R5 SR5 N TEMP STEMP
% Funcion especializada en leer los datos de sl , basada en readb
% Requiere mmstrtok
%
% Config
% 1 si no le damos configuracion-> la lee del fichero B
% 2 si la configuracion es el nombre del fichero ICF la lee del fichero
% 3 si es una celda de dos configuraciones ingnora la del fichero (ojo revisar)
% 4 si es una variable considera que es una tabla de configuracion
%
% Alberto Redondas 2009
% 
function [slavg,sls_,sl_,hg,time_badhg,sl,sl_raw,sls_raw]=readb_sl(bfile,config_file)

O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    0  -1.00    0.00    0.00    4.20   -3.20];
%WN=[302.1,306.3,310.1,313.5,316.8,320.1];
% MS8 SO2 ms9 o3 en el soft del brewer.
% single ratios used in brewer software
rms4=[0 0 -1  0  0  1  0];
rms5=[0 0  0 -1  0  1  0];
rms6=[0 0  0  0 -1  1  0];
rms7=[0 0  0  0  0 -1  1];
% matriz de ratios
% Ratios=F*W;0.
W=[rms4;rms5;rms6;rms7;SO2W;O3W]';


ds=[];dss=[];
%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(bfile)
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    [p,n,e,v]=fileparts(bfile);
    fileinfo=sscanf([n,e],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1))

    l=mmstrtok(s,char(10));
    jsl=strmatch('sl',l);
    jhg=strmatch('hg',l);
    jhgscan=strmatch('hgscan',l);

    jsum=strmatch('summary',l);
    jco=strmatch('co',l);

    fmtds_old=[' ds %c %d %f %d %d %d %d %d %d %d %d %d rat %d %d %d %d']; %no tiene cuenta slit0 
    fmtds=[' ds %c %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
    fmtsl=[' sl %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f'];
    fmtsl_old=[' sl %c %d %f %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];

    fmt=['ds %*s %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d']; % format of ds Bfile
    fmtsum=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format 
    fmtsum_output=['summary\r%d:%d:%d\r%c%c%c\r%d/\r%d\r%.5f\r%.3f\r%d\r%c%c\r%d\r%d\r%d\r%d\r%d\r%d\r%d\r%.1f\r%.1f\r%d\r%d\r%d\r%d\r%d\r%d\r%.1f\r%.1f']; % output summary format 

    %fmtinst=['inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%d'];
    fmtinst=['inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%*3c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'];
    TCfmt=['inst %f %f %f %f %f '];
    absfmt=['inst %*f %*f %*f %*f %*f %*f %f %f %f '];
    extratfmt=['inst %*f %*f %*f %*f %*f %*f %*f %*f %*f %f %f'];
    dtfmt=['inst %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f'];

    fmtum=['um %d %d %d %*s %f %f %f pr %f %d %f %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
    fmtum_output=['summary\r%d:%d:%d\r%c%c%c\r%f/\r%f\r%f\r%f\r%f\r%c%c\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f']; % output um format 
    %measures=cell('ds','zs','uq','co');
    fmt_icf=[
    'inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%3c',...
    ' %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s'];


    sl=[];
    sls=[];
    nsl=0;
    nsls=0;
    timesls=[];
    timesl=[];
    
    filter=[0,64,128,192,256];
    
    
    
% READ CONFIGURATION
% colunna 1 % Configuracion en el fichero
% columna 2 % configuracion proporcionada
%read header

 % leemos la primera configuracio la del fichero B
 [config,TC,DT,extrat,absx,AT]=readb_config(bfile);
 
if nargin>1 
   
    
  if isnumeric(config_file)  % matriz  de configuraciones
    
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
    
elseif ischar(config_file)  %
    [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file);
    config(:,2)=config_2;
    warning('only one configuratio used');
elseif iscellstr(config_file)
    % ignoramos la configuracion del fichero
    [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file{2});
    config(:,2)=config_2;
    %disp('config 2') %disp(config_file{2})
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
end % if nargin
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

% aï¿½adimos la fecha del fichero al final

if size(config,2)==2
    config=[config;[datefich(1),datefich(1)]];
else
    config=[config;datefich(1)];
end

    
    
    
    
    
    
    
    
    
    buf=l{1}; % get first line, should be version...

    if any(strmatch('version',buf))==1, %then OK
        ind=find(buf==char(13));
        lat=str2num(buf(ind(6):ind(7)));
        long=str2num(buf(ind(7):ind(8)));
        pr=str2num(buf(ind(end-1):end));
    elseif any(strmatch('dh',buf))==1
        disp('old format');
        fmtds=fmtds_old;
        hd=mmstrtok(buf,char(13));
        lat=str2num(hd{6});
        long=str2num(hd{7});
        pr=str2num(hd{end});
    else
        warning('no header information');
    end

    

for i=1:length(jsum)
    
    dsum=sscanf(l{jsum(i)},fmtsum);
    if length(dsum)>12
      tipo=char(dsum(12:13)');
      month=char(dsum(4:7)');
      fecha=datenum(sprintf(' %02d/%s/%02d',dsum(7),month,dsum(8)));
      hora=dsum(1)/24+dsum(2)/24/60+dsum(3)/24/60/60;
      if strmatch('sl',tipo)
        
          nsls=nsls+1;
          jslsum(nsls)=jsum(i);
          sl_idx=find(jsl-jsum(i)<0 & jsl-jsum(i)>=-7);
          jsl(sl_idx);
          if length(sl_idx)==7  % medida completa 7 medidas individuales
            
            timesls=[timesls;[fecha+hora,jsum(i)]];
            sls=[sls,dsum];  
            for ii=1:7  
                ds_=sscanf(l{jsl(sl_idx(ii))},fmtsl);
                if size(ds_,1)==17 % new soft
                    sl=[sl,ds_];  
                    hora=ds_(3)/60/24;
                    timesl=[timesl;[fecha+hora,jsl(sl_idx(ii)),size(sls,2)]];
                else
                    ds_=sscanf(l{jsl(sl_idx(ii))},fmtsl_old);   
                    if size(ds_,1)==16 % old soft
                       ds_=[ds_(1:6);0;ds_(7:end)];
                       sl=[sl,ds_];  
                       hora=ds_(3)/60/24;
                       timesl=[timesl;[fecha+hora,jsl(sl_idx(ii)),size(dss,2)*10+ii]];
                    end
                end
                
            end 
        end
        %disp(jsum(i));
    end
else
  l{jsum(i)}
end
end
% READ HG
% filtro de hg
% format 
  if isempty(jhgscan)
   hg=sscanf(char(l(jhg))','hg %d:%d:%d %f %f %d %f %d ',[8,Inf]);
  else
    jhg=setdiff(jhg,jhgscan);
    hg=sscanf(char(l(jhg))','hg %d:%d:%d %f %f %d %f %d %d ',[9,Inf]);
  end
  if ~isempty(hg)
   time_hg=hg(1,:)*60+hg(2,:)+hg(3,:)/60; %a minutos
   flaghg=abs(hg(5,:)-config(14))<2; % more than 2 steps change
   flag_hg=find(diff(flaghg)==-1);   % 
  %revisar no es el siguiente sino el proximo no negativo
    time_badhg=time_hg([flag_hg;flag_hg+1]');
  % hg a fecha
    hg=hg';
    hgtime=datefich(1)+time_hg(:)/60/24;
    hg=[hgtime,hg(:,[4,5,6,7]),hg(:,5)-config(14)];
  end
  
  
if ~isempty(sls) && ~isempty(timesl) %controla si no hay sl
    hora_sl=sls(1,:)*60+sls(2,:)+sls(3,:)/60;
    sl_temp=sls(11,timesl(:,3))';   
    %idx_sl indice de la medida sl
    idx_sl=fix(timesl(:,3));
    timesl=[timesl,sl_temp]; % temperatura;sls(11);
    
   %FILTRO HG 
    tb_ds=[];    tb_dsum=[];
    for ii=1:size(time_badhg,1)
     tb_dsum=[tb_dsum,find((hora>time_badhg(ii,1)   & hora<time_badhg(ii,2)))];
     tb_ds=[tb_ds,find((sl(3,:)>time_badhg(ii,1) & sl(3,:)<time_badhg(ii,2)))];
    end
     timesl(:,2)=ones(size(timesl(:,2)));
     timesls(:,2)=ones(size(timesls(:,2)));
    if ~isempty(tb_dsum)
       timesl(tb_ds,2)=0;
       timesls(tb_dsum,2)=0;
       warning('bad hg');
    end
     
 
    sl=sl';
    sls=sls';
    
    % sl_raw no recaclulated   
    sl_.raw=[timesl,sl,sls(idx_sl,19:22)]; % añadimos r5 r6 f1 f5 del fichero
    sls_.raw=[timesls,sls];
    
    j_ok=find(timesls(:,2)==1);
    slavg.raw=fix([mean(fix(timesls(j_ok,1))),mean(sls(j_ok,20)),std(sls(j_ok,20)),mean(sls(j_ok,19)),std(sls(j_ok,19)),size(sls,1),mean(sls(j_ok,11)),std(sls(j_ok,11))]);
    %SLAVG R6 SR6 R5 SR5 N TEMP STEMP
    

     %RECALCULATION
     %function DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF)
     % sl -> filtro1 NDfilter time lowslit hislit cy raw0 ....raw6
     % ...ratio1...4
      DS=ds_counts(sl(:,7:13),sl(:,2),sl_temp,sl(:,6),DT(1,:),TC(1,:),AT(1,:));
      ratios=[DS*W,sl(:,9),sl(:,13)];
    
      %% 8240 NEXT:PRINT#4,:MS(10)=F(2):MS(11)=F(6):REM SL needs raw counts
      %% los ratios de fichero
      %MS9=sl(:,15)-0.5*sl(:,16)-1.7*sl(:,17); % o3 double ratio ==MS(9)
      %MS8=sl(:,14)-3.2*sl(:,17); %:REM SO2 ratio MS(8)
      %ratios_orig=[sl(:,14:17),MS8,MS9,sl(:,9),sl(:,13)];
      % figure; plot(100*(ratios_orig-round(ratios))./ratios_orig);
      % legend('ms4','ms5','ms6','ms7','ms8','ms9','w1','w5');
    
       %% esto falla con el brewer 075 revisar -> 
       %Fr=ratio2counts(sls_.raw);
       %m1=grpstats(DS(:,3:7),idx_sl,{'mean'});
       %figure;plot(100*(round(m1)-Fr(:,3:7))./Fr(:,3:7))


       [sls_m,sls_std]=grpstats(ratios,idx_sl,{'mean','std'});
       aux=sls;
       aux(:,15:22)=sls_m;
       aux(:,23:30)=sls_std;
       sls_c=aux;
       % recalculated witht the first configuration
       sls_.c=[timesls,sls];
       sl_.c=[timesl,sl(:,1:6),DS,ratios];
       % sl sl.c(:,13:17)---> cuentas por segundo (DT,Filter and temp corr).
       % sl.raw(:,13:17)-> cuetas brutas
        slavg.c=fix([mean(fix(timesls(j_ok,1))),mean(sls_c(j_ok,20)),std(sls_c(j_ok,20)),mean(sls_c(j_ok,19)),std(sls_c(j_ok,19)),size(sls_c,1),mean(sls_c(j_ok,11)),std(sls_c(j_ok,11))]);
   
  if size(config,2)==2
         DS2=ds_counts(sl(:,7:13),sl(:,2),sl_temp,sl(:,6),DT(2,:),TC(2,:),AT(2,:));
         ratios2=[DS2*W,sl(:,9),sl(:,13)];
         sl_.cr=[timesl,DS2,ratios2];
      %      figure   plot(sls_m./sls(:,15:22))    legend('ms4','ms5','ms6','ms7','ms8','ms9','w1','w5');
     % Sumario
     [sls_m,sls_std]=grpstats(ratios2,idx_sl,{'mean','std'});
        aux=sls;
        aux(:,15:22)=sls_m;
        aux(:,23:30)=sls_std;
        sls_rc=aux;
        sls_.rc=[timesls,aux];
        slavg.rc=fix([mean(fix(timesls(j_ok,1))),mean(sls_rc(j_ok,20)),std(sls_rc(j_ok,20)),mean(sls_rc(j_ok,19)),std(sls_rc(j_ok,19)),size(sls_rc,1),mean(sls_rc(j_ok,11)),std(sls_rc(j_ok,11))]);
   
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
    warning ('Fichero vacio');
    sl=[];sls=[];slsum=[]; sl_raw=[];sls_raw=[];slavg.raw=[];
end




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
   for j=1:7

      if j~=1  
          ii=j;
      else
          ii=8;
      end
      % slit 0 no tiene correccion (no se usa para ozono) 
      F(:,j)=F(:,j)+(TC(ii)*temp)+SAF(j,Filtro)';
  end
end   
    
  F(:,2)=F_dark;
  DS=F; 

 
 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ds
% if strmatch('ds',tipo)
%         ndss=ndss+1;
%         jdssum(ndss)=jsum(i);
%         ds_idx=find(jds-jsum(i)<0 & jds-jsum(i)>=-5);
%         %jds(ds_idx);
%         if length(ds_idx)==5
%           dss=[dss,dsum];  
%           for ii=1:5  
%            ds_=sscanf(l{jds(ds_idx(ii))},fmtds);
%            ds=[ds,ds_];  
%            hora=ds_(3)/60/24;
%            %timeline=[timeline;[fecha+hora,jds(ds_idx(ii)),tipo(1)+tipo(2)/1000]];
%           end 
%         end
%         %disp(jsum(i));
%     end 