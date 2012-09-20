function [sl_raw,TC]=readb_sl(bfile)
%function [sl_raw,TC]=readb_sl(bfile)
%  Input :
%    bfile: fichero B
% output sl_raw, TC
% SL_RAW (32 columns)
%  1     	2	3	4	    5	    6	    7	8	 9	    10	
%  fexha	hg	idx	temp	filter1	filter2	min	sli0 slit1	cy	
%raw couts
%   11	12	13	14	15	16  17	
%   rL0	rL1	rL2	rL3	rL4	rL5	rL6
%counts/second calculated with TC=0
% cL0	cL1	cL2	cL3	cL4	cL5	cL6	
% 18	19	20	21	22	23	24	
% single ratios and F1 F5 from file (calculated with TC of the file)
% ms4	ms5	ms6	ms7	ms8	ms9	R1	R5
% 25	26	27	28	29	30	31	32
% Requiere mmstrtok
%
% Alberto Redondas 2010
% 


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
    [p,n,e]=fileparts(bfile);
    fileinfo=sscanf([n,e],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1));

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
    
    
    
% leemos la configuracion;
[config,TC,DT,extrat,absx,AT]=process_config(bfile);
 
      
        
    
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
    
    F_=sl(:,7:13); % asilamos las cuetas
    %DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF,SAF)
    F=ds_counts(F_,sl(:,2),sl_temp,sl(:,6),DT(1,:),zeros(size(TC(1,:))),AT(1,:)); % correccion 0 de temperatura
    
    
    sl_raw.sl=[timesl,sl(:,1:13),F,sl(:,14:end),sls(idx_sl,19:22)]; % añadimos r5 r6 f1 f5 del sumario
    sl_raw.sls=[timesls,sls];
   
    
%     %comprobacion
%     DS=ds_counts(F_,sl(:,2),sl_temp,sl(:,6),DT(1,:),TC(1,:),AT(1,:)); % correccion  de temperatura
%     ms4=DS(:,6)-DS(:,3);
%     ms5=DS(:,6)-DS(:,4);
%     ms6=DS(:,6)-DS(:,5);
%     ms7=DS(:,7)-DS(:,6);
%     ms9=ms5-0.5*ms6-1.7*ms7;     % o3 double ratio ==MS(9)
%     ms8=ms4-3.2*ms7;
%     ratios=[ms4,ms5,ms6,ms7,ms8,ms9];
%     ratios_fich=[sl(:,14:end),sls(idx_sl,19:20)];
%     plot((ratios_fich-ratios)./ratios)
%     legend('ms4','ms5','ms6','ms7','ms8','ms9')
%     %deben conicidir con las del fichero
    
    % hg ok
    j_ok=find(timesls(:,2)==1);
    sl_raw.sls_dep=fix([mean(fix(timesls(j_ok,1))),mean(sls(j_ok,20)),std(sls(j_ok,20)),mean(sls(j_ok,19)),std(sls(j_ok,19)),...
                        length(j_ok),mean(sls(j_ok,11)),std(sls(j_ok,11))]); % size(sls,1)
    %SLAVG R6 SR6 R5 SR5 N TEMP STEMP                                       
    %                       
    
    sl_raw.sl_legend ={'fexha' 'hg' 'idx'	'temp'...
                       'filter1','filter2','min','sli0','slit1','cy'...
                       'raw L0'	'rL1'	'rL2'	'rL3'	'rL4'	'rL5'	'rL6'...  
                       'counts/second TC=0 cL0'	'cL1'	'cL2'	'cL3'	'cL4'	'cL5'	'cL6'...
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
%   for j=1:9
     for i=1:7  
        F(:,i)=(F0(:,i).*exp(F(:,i)*DT)); 
     end
%   end
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