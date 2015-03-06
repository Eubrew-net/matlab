function [o3,config,hg_data,loc]=readb_ds_develop_pol(bfile,config_file,spectral_config)

ds=[]; dss=[]; timeds=[]; timedsum =[];
dk=[]; dks=[]; timedk=[]; timedksum=[];

%formats for reading the bfile
fmtds =' ds %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f';
fmtdk =' dk %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f';
fmtsum='summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'; % summary format

% Weight definition for the seven slits
% slit 0 used for hg calibration slit 1-> dark
O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    0  -1.00    0.00    0.00    4.20   -3.20];
WN=[302.1,306.3,310.1,313.5,316.8,320.1];

%leemos el fichero en memoria
s=fileread(bfile);

%leemos la fecha del fichero
[path,name,ext]=fileparts(bfile);

fileinfo=sscanf([name,ext],'%c%03d%02d.%03d');
datefich=datejul(fileinfo(3),fileinfo(2));
datestr(datefich(1));% Flag de fecha

l=mmstrtok(s,char(10));

jds=strmatch('ds',l);
jdk=strmatch('dk',l);
jsum=strmatch('summary',l);
jco=strmatch('co',l);
jhg=strmatch('hg',l);
jhgscan=strmatch('hgscan',l);

% READ CONFIGURATION
% colunna 1 % Configuracion en el fichero
% columna 2 % configuracion proporcionada

buf=l{1}; % get first line, should be version...
if any(strmatch('version',buf))==1, %then OK
    ind=find(buf==char(13));
    lat=str2num(buf(ind(6):ind(7)));
    long=str2num(buf(ind(7):ind(8)));
    pr=str2num(buf(ind(end-1):end));
    if isempty(pr)
       id_pr=findstr(buf,'pr');
       pr= str2num(buf(id_pr+3:end));
    end
    loc.lat=lat;
    loc.long=long;
    loc.pr=pr;
    loc.str=buf(ind(5):ind(6));
    
else
    disp('No header');
    loc.lat=NaN;
    loc.long=NaN;
    loc.pr=NaN;
    loc.str='';
end

% leemos la configuracion arreglar los parametros de entrada
% argumentos de entrada
if nargin==1
    [config,TC,DT,extrat,absx,AT]=process_config(bfile);
else    
    [config,TC,DT,extrat,absx,AT]=process_config(bfile,config_file);
end

%% READ HG: filtro de hg
  if isempty(jhgscan) % Con la version antigua nunca se escribe la diferencia de pasos??
     % Se asume como maximo 9 campos (version nueva)
     hg=NaN*ones(length(jhg),9);
     if ~isempty(jhg)
         try
            hg(:,1:end-1)=cell2mat(cellfun(@(x) cell2mat(textscan(strrep(x,char(13),' '),'hg %f:%f:%f %f %f %f %f %f',...
                                'delimiter',char(13),'multipleDelimsAsOne',1)),cellstr(char(l(jhg))),...
                                'UniformOutput' ,0)); 
         catch
             haux=strrep(l(jhg),char(13),' ');
             haux=sscanf(char(haux)','hg %f:%f:%f %f %f %f %f %f\n ',[8,Inf]);
             hg(:,1:end-1)=haux';
         end        
         hg=hg';
     else
         hg=NaN*ones(2,9)';
     end
  else
     % This only accounts for changing to new sofware after the old one
     hg=NaN*ones(length(setdiff(jhg,jhgscan)),9);
     jhg_old=find(jhg<jhgscan(1)); % these are the old ones
     if ~isempty(jhg_old)
        idx_old=length(jhg_old);
       try 
        hg(1:idx_old,1:end-1)=cell2mat(textscan(char(l(jhg(jhg_old)))','hg %f:%f:%f %f %f %f %f %f',...
                            'delimiter',char(13),'multipleDelimsAsOne',1));
       catch
           haux=strrep(l(jhg(jhg_old)),char(13),' ');
           haux=sscanf(char(haux)','hg %f:%f:%f %f %f %f %f %f  \n ',[8,Inf]);
          %haux=reshape(haux,9,[])';
          hg(1:idx_old,1:end-1)=haux';
       end
                        
        jhg=setdiff(jhg(1+idx_old:end),jhgscan); % after hgscan follows hg
     else
        jhg=setdiff(jhg,jhgscan); % after hgscan follows hg
     end
     
   try  
        %do not work on new versions of matlab ??
        hg(length(jhg_old)+1:end,:)=cell2mat(textscan(char(l(jhg))','hg %f:%f:%f %f %f %f %f %f %f',...
                            'delimiter',char(13),'multipleDelimsAsOne',1));   
   catch
        %hgs2=strrep(l(jhg),[char(13),char(13)],char(10)); 
        haux=strrep(l(jhg),char(13),' ');
        haux=sscanf(char(haux)','hg %f:%f:%f %f %f %f %f %f %f\n ',[9,Inf]);
        %haux=reshape(haux,9,[])';
        try
         hg(length(jhg_old)+1:end,:)=haux';
        catch
         hg(1:size(haux',1),:)=haux';
        end         
   end
   hg=hg';
  end
  
%  aux_date=datevec(datefich(1)); aux_date=repmat(aux_date(1:3),size(hg(1:3,:)',1),2); aux_date(:,4:6)=hg(1:3,:)';
%  aux_date=datenum(aux_date); aux=NaN*ones(size(hg,1)+1,size(hg,2)); aux(1,:)=aux_date;
%  ix_bad=diff(time_hg); hg(ix_bad<0,:)=[]; time_hg=hg(1,:)*60+hg(2,:)+hg(3,:)/60;
  time_hg=hg(1,:)*60+hg(2,:)+hg(3,:)/60; %a minutos. Lo de sort es un APA?O
  flaghg=abs(hg(5,:)-config(14))<2; % more than 2 steps change
  if size(hg,2)>1
        flag_hg=find(diff(flaghg)==-1);      
        if isempty(flag_hg)
           time_badhg=[0,0];
        else
           if flaghg(1)==0 % revisa
              flag_hg=[1,flag_hg];
           end 
           %revisar no es el siguiente sino el proximo no negativo
           % almacenar la constante en el fichero.
           time_badhg=time_hg([flag_hg;flag_hg+1]');
           time_badhg=[time_hg(1),time_hg(1);time_badhg];
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
                     'step_int'	'int'	'temp'	'steps_chg'	'flag'};
  hg_data.time_badhg=time_badhg/60/24+datefich(1);

%%
  ndss=0;  ndsk=0;
  for i=1:length(jsum)
      dsum=sscanf(l{jsum(i)},fmtsum);
      type=char(dsum(12:13)');
      month=char(dsum(4:7)');
      fecha=datenum(sprintf(' %02d/%s/%02d',dsum(7),month,dsum(8)));
      hora=dsum(1)/24+dsum(2)/24/60+dsum(3)/24/60/60;
      if strmatch('ds',type)
          ndss=ndss+1;
          ds_idx=find(jds-jsum(i)<0 & jds-jsum(i)>=-5);
          if length(ds_idx)==5
              %timedssum fecha,indice
              timedsum=[timedsum;[fecha+hora,jsum(i)]];
              dss=[dss,dsum];
              for ii=1:5
                  ds_=sscanf(l{jds(ds_idx(ii))},fmtds);
                  if size(ds_,1)==17
                      ds=[ds,ds_];
                      hora=ds_(3)/60/24;
                      %time ds
                      %timeds=fecha matlab,linea del fichero,n???de
                      %sumario +temperatura
                      timeds=[timeds;[fecha+hora,jds(ds_idx(ii)),size(dss,2)*10+ii]];
                  end
              end
          end
      elseif strmatch('dk',type) 
          ndsk=ndsk+1;
          dk_idx=find(jdk-jsum(i)<0 & jdk-jsum(i)>=-5);
          if length(ds_idx)==5
              %timedssum fecha,indice
              timedksum=[timedksum;[fecha+hora,jsum(i)]];
              dks=[dks,dsum];
              for ii=1:5
                  dk_=sscanf(l{jdk(dk_idx(ii))},fmtdk);
                  if size(dk_,1)==17
                      dk=[dk,dk_];
                      hora=dk_(3)/60/24;
                      %time ds
                      %timeds=fecha matlab,linea del fichero,n???de
                      %sumario +temperatura
                      timedk=[timedk;[fecha+hora,jds(dk_idx(ii)),size(dks,2)*10+ii]];
                  end
              end
          end
      end
  end

%% DS  
if ~isempty(dss)
    % Time calculation
    % hora a formato matlab ->sumarios
    hora=dss(1,:)*60+dss(2,:)+dss(3,:)/60;

    %idx_ds indice de la medida ds
    idx_ds=fix(timeds(:,3)/10);
    %TEMPERATURA % asignamos la temperatura al ds tomada del sumario
    ds_temp=dss(11,idx_ds)';
    %filter check
     if any(dss(14,idx_ds)-(ds(2,:)/64))
       % to chek that the filter are 0 64....
       unique(ds(2,:))
       unique(dss(14,:))
       disp('error in filter check');
       
       ds(2,:)=64*dss(14,idx_ds);
     end
         
    % calculo de los angulos zenitales y masa optica sumarios
    [szadss,m2dss,m3dss]=brewersza(hora',fileinfo(2),fileinfo(3),lat,long);
    [sza,saz,tst_ds,snoon,sunrise,sunset]=sun_pos(timedsum(:,1),lat,-long);
    timedss=[timedsum,[szadss,m2dss,m3dss,sza,saz,tst_ds,snoon,sunrise,sunset]];

    % calculos se sza y masa op medidas individuales
    [szads,m2ds,m3ds]=brewersza(ds(3,:)',fileinfo(2),fileinfo(3),lat,long);
    [sza,saz,tst_ds,snoon,sunrise,sunset]=sun_pos(timeds(:,1),lat,-long);
    timeds=[timeds,[szads,m2ds,m3ds,sza,saz,tst_ds,snoon,sunrise,sunset]];

    % HGFILTER (falla si no hay ningun hg)
    tb_ds=[];    tb_dsum=[];
    for ii=1:size(time_badhg,1)
        tb_dsum=[tb_dsum,find((hora>time_badhg(ii,1)   & hora<time_badhg(ii,2)))];
        tb_ds  =[tb_ds,find((ds(3,:)>time_badhg(ii,1)  & ds(3,:)<time_badhg(ii,2)))];
    end
    % flag hg utilizamos el numero de linea
    timeds(:,2)=ones(size(timeds(:,2)));
    timedss(:,2)=ones(size(timedss(:,2)));
    if ~isempty(tb_dsum)
       timedss(tb_dsum,2)=0;
       timeds(tb_ds,2)=0;
    end
    ds=ds';dss=dss';

%%  salidas raw DS    
      o3.dsum=[timedss(:,1:2),timedss(:,8)/60,timedss(:,4),...
        dss(:,9:11),dss(:,[14,22,30,21,29]),dss(:,[15,23,16,24,17,25,18,26,19,27,20,28])];
      o3.dsum_legend={'date';'hgflag';'tst ';'aimass';'sza';'airm';'temp';...
                      'filt';'ozo ';'sozo';'so2 ';'sso2';...
                      'ms4 ';'sms4';'ms5 ';'sms5';'ms6 ';'sms6';'ms7 ';'sms7';...
                      'ms8 ';'sms8';'ms9 ';'sms9'}; % xlswrite(dsum,'',dss_legend);

     %sustituimos [slit_ini, slit_end] de la medida por m2 m3
     ds(:,4:5)=[timeds(:,5),timeds(:,6)*pr/1013];% m2ds, m3ds
     %sustituimos tiempo de la medida por true-solar-time
     ds(:,3)=timeds(:,9);% tst_ds
     
     MS9=ds(:,15)-0.5*ds(:,16)-1.7*ds(:,17); % o3 double ratio ==MS(9)
     MS8=ds(:,14)-3.2*ds(:,17);              % SO2 double ratio ==MS(8)            
     
     o3.ds_raw0=[timeds(:,1:3),ds_temp,ds,MS8,MS9];
     o3.ds_raw0_legend={'date';'hgflg';'nds';'tmp';'fl1';'fl2';'tim';'m2 ';...
                        'm3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
                        'F4 ';'F5 ';'F6 ';'ms4 ';'ms5 ';'ms6 ';'ms7 ';'MS8 ';'MS9 '};    

%% ds re-calculation
    % Convert to count-rates / Dead Time - Temperature - Filter - correction
    %IF Q14%=0 THEN TE%=-33.27+VAL(TE$)*18.64:IF Q10%=0 THEN TE%=-30+VAL(TE$)*16+.5

     Fr=ds(:,7:13); % asimilamos las cuentas brutas (en todos los canales) del fichero B
     if nargin <3 || isempty(spectral_config)% first config 
        F=ds_counts(Fr,ds(:,2),ds_temp,ds(:,6),DT(1,:),TC(1,:),AT(1,:));
     else
        F=ds_counts(Fr,ds(:,2),ds_temp,ds(:,6),DT(1,:),TC(1,:),AT(1,:),spectral_config);
     end
     
     DS_=F;  % DS_ counts raleyght uncorrected
     DS=rayleigth_cor(DS_,pr,m3ds);

     [ozone,so2,ratios]=ozone_cal(DS,m2ds,config(:,1));
     [ozo_rc,ozo_rc_std]=grpstats(ozone,idx_ds,{'mean','std'});

    if size(config,2)>1 % segunda configuracion
       Fr=ds(:,7:13); % asimilamos las cuentas brutas (en todos los canales) del fichero B      
       if nargin <3 || isempty(spectral_config) 
          F2=ds_counts(Fr,ds(:,2),ds_temp,ds(:,6),DT(2,:),TC(2,:),AT(2,:)');
       else
          F2=ds_counts(Fr,ds(:,2),ds_temp,ds(:,6),DT(2,:),TC(2,:),AT(2,:),spectral_config);
       end
        
       DS_2=F2;  % DS_ counts raleyght uncorrected
       DS2=rayleigth_cor(DS_2,pr,m3ds);
       [ozone2,so22,ratios2]=ozone_cal(DS2,m2ds,config(:,2));
       [ozo_c,ozo_std]=grpstats(ozone2,idx_ds,{'mean','std'});

       % All individual measurements, recalculated
       o3.ozone_ds=[timeds(:,1:5),ds_temp,ds(:,2),ozone,ratios,ozone2,ratios2];
       o3.ozone_ds_legend={'date'  'hg_flag' 'nds'   'sza'   'airm'  'temp'  'flt'...
                           'o3_o'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'...% ratios (Rayleight corrected !!)
                           'o3_n'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'}; % ratios (Rayleight corrected !!)
       
       % Summaries, recalculated  
       o3.ozone_s=[timedss(:,1:4),dss(:,[11,14]),ozo_rc,ozo_rc_std,ozo_c,ozo_std];
       o3.ozone_s_legend={'date '     'hg_flag '    'sza '       'airm '   'temp ' 'flt ' ...
                          'o3_first ' 'std_first '	'o3_second ' 'std_second '};

       % Raw counts & count-rates recalculated (DT, Temp &  Filt. corrected). Rayleight uncorrected !!
       o3.ozone_raw=[timeds(:,1:9),ds(:,2),ds_temp,ds(:,7:13),F,F2];
       o3.ozone_raw_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'  'flt'  'temp'...
                            'OS0'  'OS1'	'OS2'	'OS3'	'OS4'	'OS5'	'OS6'	...  % cuentas brutas
                            'iS0'  'iS1'	'iS2'	'iS3'	'iS4'	'iS5'	'iS6'	...  % count-rates recalculadas 1 (Rayleight uncorrected !!)
                            'fs0'	'fs1'	'fs2'	'fs3'	'fs4'	'fs5'	'fs6'	...  % count-rates recalculadas 2 (Rayleight uncorrected !!)
                            };
    else
       % All individual measurements, recalculated
       o3.ozone_ds=[timeds(:,1:5),ds_temp,ds(:,2),ozone,ratios,NaN*ozone,NaN*ratios];
       o3.ozone_ds_legend={'date'  'hg_flag' 'nds'   'sza'   'airm'  'temp'  'flt'...
                           'o3_o'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'...% ratios (Rayleight corrected !!)
                           'o3_n'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'}; % ratios (Rayleight corrected !!)

       % Summaries, recalculated  
       o3.ozone_s=[timedss(:,1:4),dss(:,[11,14,22,30]),ozo_rc,ozo_rc_std];
       o3.ozone_s_legend={'fecha '    'hgflag ' 'sza '       'airm ' 'tmp ' 'flt ' ...
                          'o3_bfile ' 'std '    'ozo_first ' 'std_first '};
                
       % Raw counts & count-rates recalculated (DT, Temp &  Filt. corrected). Rayleight uncorrected !!
       o3.ozone_raw=[timeds(:,1:9),ds(:,2),ds_temp,ds(:,7:13),F,F];
       o3.ozone_raw_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'  'flt'  'temp'...
                            'OS0'  'OS1'	'OS2'	'OS3'	'OS4'	'OS5'	'OS6'	...  % cuentas brutas
                            'iS0'  'iS1'	'iS2'	'iS3'	'iS4'	'iS5'	'iS6'	...  % count-rates recalculadas 1 (Rayleight uncorrected !!)
                            'fs0'	'fs1'	'fs2'	'fs3'	'fs4'	'fs5'	'fs6'	...  % count-rates recalculadas 2 (Rayleight uncorrected !!)
                            };
    end

else
    warning('Fichero vacio ? no ozone measurements');
    o3.dsum=[]; o3.ozone_s=[]; o3.ozone_ds=[]; o3.ds_raw0=[]; o3.dss=[];
    o3.timeds=[]; o3.timedss=[]; o3.ozone_raw=[];
    o3.ozone_ds_legend=[];o3.dsum_legend=[];
    o3.ds_raw0_legend=[];o3.ozone_ds_legend=[];
    o3.ozone_s_legend=[];
end


%% DK  
if ~isempty(dks)
    % Time calculation
    % hora a formato matlab ->sumarios
    hora=dks(1,:)*60+dks(2,:)+dks(3,:)/60;

    %idx_ds indice de la medida ds
    idx_dk=fix(timedk(:,3)/10);
    %TEMPERATURA % asignamos la temperatura al ds tomada del sumario
    dk_temp=dks(11,idx_dk)';
    %filter check
     if any(dks(14,idx_dk)-(dk(2,:)/64))
       % to chek that the filter are 0 64....
       unique(dk(2,:))
       unique(dks(14,:))
       disp('error in filter check');
       
       dk(2,:)=64*dks(14,idx_dk);
     end
         
    % calculo de los angulos zenitales y masa optica sumarios
    [szadss,m2dss,m3dss]=brewersza(hora',fileinfo(2),fileinfo(3),lat,long);
    [sza,saz,tst_ds,snoon,sunrise,sunset]=sun_pos(timedksum(:,1),lat,-long);
    timedks=[timedksum,[szadss,m2dss,m3dss,sza,saz,tst_ds,snoon,sunrise,sunset]];

    % calculos se sza y masa op medidas individuales
    [szads,m2ds,m3ds]=brewersza(dk(3,:)',fileinfo(2),fileinfo(3),lat,long);
    [sza,saz,tst_ds,snoon,sunrise,sunset]=sun_pos(timedk(:,1),lat,-long);
    timedk=[timedk,[szads,m2ds,m3ds,sza,saz,tst_ds,snoon,sunrise,sunset]];

    % HGFILTER (falla si no hay ningun hg)
    tb_dk=[];    tb_dksum=[];
    for ii=1:size(time_badhg,1)
        tb_dksum=[tb_dksum,find((hora>time_badhg(ii,1)   & hora<time_badhg(ii,2)))];
        tb_dk  =[tb_dk,find((dk(3,:)>time_badhg(ii,1)  & dk(3,:)<time_badhg(ii,2)))];
    end
    % flag hg utilizamos el numero de linea
    timedk(:,2)=ones(size(timedk(:,2)));
    timedks(:,2)=ones(size(timedks(:,2)));
    if ~isempty(tb_dksum)
       timedks(tb_dksum,2)=0;
       timedk(tb_dk,2)=0;
    end
    dk=dk';dks=dks';

%%  salidas raw DS    
      o3.dksum=[timedks(:,1:2),timedks(:,8)/60,timedks(:,4),...
        dks(:,9:11),dks(:,[14,22,30,21,29]),dks(:,[15,23,16,24,17,25,18,26,19,27,20,28])];
      o3.dksum_legend={'date';'hgflag';'tst ';'aimass';'sza';'airm';'temp';...
                      'filt';'ozo ';'sozo';'so2 ';'sso2';...
                      'ms4 ';'sms4';'ms5 ';'sms5';'ms6 ';'sms6';'ms7 ';'sms7';...
                      'ms8 ';'sms8';'ms9 ';'sms9'}; 

     %sustituimos [slit_ini, slit_end] de la medida por m2 m3
     dk(:,4:5)=[timedk(:,5),timedk(:,6)*pr/1013];% m2ds, m3ds
     %sustituimos tiempo de la medida por true-solar-time
     dk(:,3)=timedk(:,9);% tst_ds
     
     MS9=dk(:,15)-0.5*dk(:,16)-1.7*dk(:,17); % o3 double ratio ==MS(9)
     MS8=dk(:,14)-3.2*dk(:,17);              % SO2 double ratio ==MS(8)            
     
     o3.dk_raw0=[timedk(:,1:3),dk_temp,dk,MS8,MS9];
     o3.dk_raw0_legend={'date';'hgflg';'nds';'tmp';'fl1';'fl2';'tim';'m2 ';...
                        'm3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
                        'F4 ';'F5 ';'F6 ';'ms4 ';'ms5 ';'ms6 ';'ms7 ';'MS8 ';'MS9 '};    

%% ds re-calculation
    % Convert to count-rates / Dead Time - Temperature - Filter - correction
    %IF Q14%=0 THEN TE%=-33.27+VAL(TE$)*18.64:IF Q10%=0 THEN TE%=-30+VAL(TE$)*16+.5

     Fr=dk(:,7:13); % asimilamos las cuentas brutas (en todos los canales) del fichero B
     if nargin <3 || isempty(spectral_config)% first config 
        F=ds_counts(Fr,dk(:,2),dk_temp,dk(:,6),DT(1,:),TC(1,:),AT(1,:));
     else
        F=ds_counts(Fr,dk(:,2),dk_temp,dk(:,6),DT(1,:),TC(1,:),AT(1,:),spectral_config);
     end
     
     DK_=F;  % DS_ counts raleyght uncorrected
     DK=rayleigth_cor(DK_,pr,m3ds);

     [ozone,so2,ratios]=ozone_cal(DK,m2ds,config(:,1));
     [ozo_rc,ozo_rc_std]=grpstats(ozone,idx_dk,{'mean','std'});

    if size(config,2)>1 % segunda configuracion
       Fr=dk(:,7:13); % asimilamos las cuentas brutas (en todos los canales) del fichero B      
       if nargin <3 || isempty(spectral_config) 
          F2=ds_counts(Fr,dk(:,2),dk_temp,dk(:,6),DT(2,:),TC(2,:),AT(2,:)');
       else
          F2=ds_counts(Fr,dk(:,2),dk_temp,dk(:,6),DT(2,:),TC(2,:),AT(2,:),spectral_config);
       end
        
       DK_2=F2;  % DS_ counts raleyght uncorrected
       DK2=rayleigth_cor(DK_2,pr,m3ds);
       [ozone2,so22,ratios2]=ozone_cal(DK2,m2ds,config(:,2));
       [ozo_c,ozo_std]=grpstats(ozone2,idx_dk,{'mean','std'});

       % All individual measurements, recalculated
       o3.ozone_dk=[timedk(:,1:5),dk_temp,dk(:,2),ozone,ratios,ozone2,ratios2];
       o3.ozone_dk_legend={'date'  'hg_flag' 'nds'   'sza'   'airm'  'temp'  'flt'...
                           'o3_o'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'...% ratios (Rayleight corrected !!)
                           'o3_n'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'}; % ratios (Rayleight corrected !!)
       
       % Summaries, recalculated  
       o3.ozone_dks=[timedks(:,1:4),dks(:,[11,14]),ozo_rc,ozo_rc_std,ozo_c,ozo_std];
       o3.ozone_dks_legend={'date '     'hg_flag '    'sza '       'airm '   'temp ' 'flt ' ...
                          'o3_first ' 'std_first '	'o3_second ' 'std_second '};

       % Raw counts & count-rates recalculated (DT, Temp &  Filt. corrected). Rayleight uncorrected !!
       o3.ozone_raw_dk=[timedk(:,1:9),dk(:,2),dk_temp,dk(:,7:13),F,F2];
       o3.ozone_raw_dk_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'  'flt'  'temp'...
                            'OS0'  'OS1'	'OS2'	'OS3'	'OS4'	'OS5'	'OS6'	...  % cuentas brutas
                            'iS0'  'iS1'	'iS2'	'iS3'	'iS4'	'iS5'	'iS6'	...  % count-rates recalculadas 1 (Rayleight uncorrected !!)
                            'fs0'	'fs1'	'fs2'	'fs3'	'fs4'	'fs5'	'fs6'	...  % count-rates recalculadas 2 (Rayleight uncorrected !!)
                            };
    else
       % All individual measurements, recalculated
       o3.ozone_dk=[timedk(:,1:5),dk_temp,dk(:,2),ozone,ratios,NaN*ozone,NaN*ratios];
       o3.ozone_dk_legend={'date'  'hg_flag' 'nds'   'sza'   'airm'  'temp'  'flt'...
                           'o3_o'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'...% ratios (Rayleight corrected !!)
                           'o3_n'  'ms4'     'ms5'   'ms6'   'ms7'   'ms8'   'ms9'}; % ratios (Rayleight corrected !!)

       % Summaries, recalculated  
       o3.ozone_dks=[timedks(:,1:4),dks(:,[11,14,22,30]),ozo_rc,ozo_rc_std];
       o3.ozone_dks_legend={'fecha '    'hgflag ' 'sza '       'airm ' 'tmp ' 'flt ' ...
                          'o3_bfile ' 'std '    'ozo_first ' 'std_first '};
                
       % Raw counts & count-rates recalculated (DT, Temp &  Filt. corrected). Rayleight uncorrected !!
       o3.ozone_raw_dk=[timedk(:,1:9),dk(:,2),dk_temp,dk(:,7:13),F,F];
       o3.ozone_raw_dk_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'  'flt'  'temp'...
                            'OS0'  'OS1'	'OS2'	'OS3'	'OS4'	'OS5'	'OS6'	...  % cuentas brutas
                            'iS0'  'iS1'	'iS2'	'iS3'	'iS4'	'iS5'	'iS6'	...  % count-rates recalculadas 1 (Rayleight uncorrected !!)
                            'fs0'	'fs1'	'fs2'	'fs3'	'fs4'	'fs5'	'fs6'	...  % count-rates recalculadas 2 (Rayleight uncorrected !!)
                            };
    end

else
    warning('Fichero vacio ? no ozone measurements');
    o3.dsum=[]; o3.ozone_s=[]; o3.ozone_ds=[]; o3.ds_raw0=[]; o3.dss=[];
    o3.timeds=[]; o3.timedss=[]; o3.ozone_raw=[];
    o3.ozone_ds_legend=[];o3.dsum_legend=[];
    o3.ds_raw0_legend=[];o3.ozone_ds_legend=[];
    o3.ozone_s_legend=[];
end



%% %%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

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
    so2=(ms8-B2)./(A2*A3*m2)-ozone/A2; %revisar
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

function DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF,SAF)

% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
%
% 8350 REM correct VA for dark/dead time
% 8355 VA=(VA-F(1))*2/CY/IT:IF VA>1E+07 THEN VA=1E+07
% 8360 IF VA<2 THEN VA=2
% 8365 F1=VA:FOR J=0 TO 8:VA=F1*EXP(VA*T1):NEXT
% 8370 RETURN
  
  % Convert to count-rates
  F_dark=F(:,2);  F(:,2)=NaN*F_dark;
  % IT=interval-scaling factor
  IT=0.1147;
  for j=1:7
    F(:,j) = 2*(F(:,j)-F_dark)./CY/IT; 
  end
  F(F<=0)=2;
  F(F>1E07)=1E07;

  % Dead Time correction
  F0=F;
  for j=1:9
     for i=1:7  
        F(:,i)=(F0(:,i).*exp(F(:,i)*DT)); 
     end
  end
  F=round(log10(F)*10^4);  %aritmetica entera
  
% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
% 8315   F(I)=LOG(VA)/CO*P4%:J=I:IF J=0 THEN J=7
% 8320   IF MDD$="o3" THEN X=TC(J) ELSE X=NTC(J)
% 8325   F(I)=F(I)+X*TE%+AF(AF%)
% 8335 NEXT:RETURN

  % AF en columna
  AF=AF(:);
  Filtro=(Filtro/64)+1;

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

function DS=raw2counts(F,Filtro,temp,CY,DT,TC,AF,SAF)

%function DS=raw2counts(F,Filtro,temp,CY,DT,TC,AF,SAF)
%SAF=lineas Filtro, columnas slits
  
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
  F= 2*matdiv(matadd(F,-F_dark),CY)/IT;
  F(F<=0)=2;
  F(F>1E07)=1E07;

  % dead time correction
  F0=F;
  for j=1:9
    F=F0.*exp(F*DT);   
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
TC(1)=TC(8);
TC=TC(1:7);
TCorr=temp*TC;  
if nargin==7 % standard configuration  
    F=TCorr+ matadd(F,AF(Filtro));
 else % spectral configuration
   SAFx=[SAF(Filtro,1),NaN*SAF(Filtro,1),SAF(Filtro,2:end)];
   F=F+TCorr+SAFx;
end    
F(:,2)=F_dark;
DS=F; 

function RC=rayleigth_cor(F,P,M3,BE)

% function RC=rayleigth_cor(F,P,M3,BE)
% Rayleight correction
% Si se proporcionan coeficientes se calculan si no se usa el standard
%
% FROM INIT.RTN 
% 12060 FOR I=2 TO 6:READ BE(I):NEXT:REM  read Rayleigh coeffs
% 12070 DATA 4870,4620,4410,4220,4040
%
% F(I)=F(I)+BE(I)*M3*PZ%/1013:REM rayleigh
% 
% TODO: Vectorizado
% w=[0.00  0.00   0.00   -1.00    0.50    2.20   -1.70];
% 
% RC=matmul(m3ds,R)*pr/1013*w'
% R coef raleight
% w weithgth

  if nargin==3 % si no usa la estandard
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
  % 1??? Rayleight correction
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


