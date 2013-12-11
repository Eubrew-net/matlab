
function o3=readb_ds_develop_dz(bfile,config_file,spectral_config)

ds=[]; dss=[]; dz=[]; dzs=[]; timedz=[]; timedzsum=[]; 

%formats for reading the bfile
fmtdz=' dz %c %d %f %d %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f';
fmtsum='summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'; % summary format
 
%leemos el fichero en memoria
s=fileread(bfile);

%leemos la fecha del fichero
[path,name,ext]=fileparts(bfile);
fileinfo=sscanf([name,ext],'%c%03d%02d.%03d');
datefich=datejul(fileinfo(3),fileinfo(2));
datestr(datefich(1));

l=mmstrtok(s,char(10));

jsum=strmatch('summary',l);
jhg=strmatch('hg',l);
jhgscan=strmatch('hgscan',l);
jdz=strmatch('dz',l);

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

% leemos la configuracion
if nargin==1
    [config,TC,DT,extrat,absx,AT]=process_config(bfile);
else    
    [config,TC,DT,extrat,absx,AT]=process_config(bfile,config_file);
end

% READ HG: filtro de hg. 
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
        hg(1:idx_old,1:end-1)=cell2mat(textscan(char(l(jhg(jhg_old)))','hg %f:%f:%f %f %f %f %f %f',...
                            'delimiter',char(13),'multipleDelimsAsOne',1));
        jhg=setdiff(jhg(1+idx_old:end),jhgscan); % after hgscan follows hg
     else
        jhg=setdiff(jhg,jhgscan); % after hgscan follows hg
     end
   try  
        %do not work on new versions of matlab ¿?
        hg(length(jhg_old)+1:end,:)=cell2mat(textscan(char(l(jhg))','hg %f:%f:%f %f %f %f %f %f %f',...
                            'delimiter',char(13),'multipleDelimsAsOne',1));   
   catch
        %hgs2=strrep(l(jhg),[char(13),char(13)],char(10)); 
        haux=strrep(l(jhg),char(13),' ');
        haux=sscanf(char(haux)','hg %f:%f:%f %f %f %f %f %f %f\n ',[9,Inf]);
        %haux=reshape(haux,9,[])';
        hg(length(jhg_old)+1:end,:)=haux';
   end
   hg=hg';
  end
  
  time_hg=hg(1,:)*60+hg(2,:)+hg(3,:)/60; %a minutos. Lo de sort es un APAÑO
  flaghg=abs(hg(5,:)-config(14))<2; % more than 2 steps change
  if size(hg,2)>1
        flag_hg=find(diff(flaghg)==-1);   %
       
        if isempty(flag_hg)
            time_badhg=[0,0];
        else
            if flaghg(1)==0    % revisa
                flag_hg=[1,flag_hg];
            end
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
      'step_int'	'int'	'temp'	'steps_chg'	'flag'...
};

  hg_data.time_badhg=time_badhg/60/24+datefich(1);
  ndss=0;  nsls=0;  ndzs=0;
  for i=1:length(jsum)
      dsum=sscanf(l{jsum(i)},fmtsum);
      type=char(dsum(12:13)');
      month=char(dsum(4:7)');
      fecha=datenum(sprintf(' %02d/%s/%02d',dsum(7),month,dsum(8)));
      hora=dsum(1)/24+dsum(2)/24/60+dsum(3)/24/60/60;
      if strmatch('dz',type)
          ndzs=ndzs+1;
          dz_idx=find(jdz-jsum(i)<0 & jdz-jsum(i)>=-4);
          jdzsum(ndzs)=jsum(i);
          if length(dz_idx)==4
              %timedssum fecha,indice
              timedzsum=[timedzsum;[fecha+hora,jsum(i)]];
              dzs=[dzs,dsum];
              for ii=1:4
                  ds_=NaN*ones(18,1); 
                  ds_aux=sscanf(l{jdz(dz_idx(ii))},fmtdz);
                  if size(ds_aux,1)==18
                     ds_=ds_aux; 
                  else
                     ds_(1:14)=sscanf(l{jdz(dz_idx(ii))},' dz %c %d %f %d %d %d %d %d %d %d %d %d %d %d');                  
                  end
                  dz=[dz,ds_];
                  hora=ds_(3)/60/24;
                  timedz=[timedz;[fecha+hora,jdz(dz_idx(ii)),size(dzs,2)*10+ii]];
              end
          end
      else
      end
  end
  
% ---------------------- Start DZ output ------------------------------------
if ~isempty(dzs)
    % Time calculation: hora a formato matlab -> sumarios
    hora=dzs(1,:)*60+dzs(2,:)+dzs(3,:)/60;

    % idx_dz indice de la medida dz
    idx_dz=fix(timedz(:,3)/10);
    % asignamos la temperatura al ds tomada del sumario
    dz_temp=dzs(11,idx_dz)';
    %filter check
    if any(dzs(14,idx_dz)-(dz(2,:)/64))
       % to chek that the filter are 0 64....
       unique(ds(2,:))
       unique(dss(14,:))
       disp('error in filter check');
       
       ds(2,:)=64*dss(14,idx_ds);
    end       
    
    % calculo de los angulos zenitales y masa optica sumarios
    [szadzs,m2dzs,m3dzs]=brewersza(hora',fileinfo(2),fileinfo(3),lat,long);
    [sza,saz,tst_dz,snoon,sunrise,sunset]=sun_pos(timedzsum(:,1),lat,-long);
    timedzs=cat(2,timedzsum,[szadzs,m2dzs,m3dzs,sza,saz,tst_dz,snoon,sunrise,sunset]);

    % calculos se sza y masa op medidas individuales
    [szadz,m2dz,m3dz]=brewersza(dz(3,:)',fileinfo(2),fileinfo(3),lat,long);
    [sza,saz,tst_dz,snoon,sunrise,sunset]=sun_pos(timedz(:,1),lat,-long);
    timedz=[timedz,[szadz,m2dz,m3dz,sza,saz,tst_dz,snoon,sunrise,sunset]];

    %HGFILTER
    % -> falla si no hay ningun hg->
    tb_dz=[];    tb_dzsum=[];
    for ii=1:size(time_badhg,1)
     tb_dzsum=[tb_dzsum,find((hora>time_badhg(ii,1)   & hora<time_badhg(ii,2)))];
     tb_dz=[tb_dz,find((dz(3,:)>time_badhg(ii,1) & dz(3,:)<time_badhg(ii,2)))];
    end
    % flag hg utilizamos el numero de linea (ï¿½?)
    timedz(:,2)=ones(size(timedz(:,2)));
    timedzs(:,2)=ones(size(timedzs(:,2)));
    if ~isempty(tb_dzsum)
       timedz(tb_dz,2)=0;
       timedzs(tb_dzsum,2)=0;
    end
    dz=dz'; dzs=dzs';

    %%  salidas raw DS      
      o3.dzsum=[timedzs(:,1:2),timedzs(:,8)/60,timedzs(:,4),...
        dzs(:,9:11),dzs(:,[14,22,30,21,29]),dzs(:,[15,23,16,24,17,25,18,26,19,27,20,28])];
      o3.dzsum_legend={'date';'hgflag';'hora ';'??';'ang2';'airm';'temp';'filt';'ozo ';'std_ozo';'so2 ';'std_so2';...
        'ms4 ';'std_ms4';'ms5 ';'std_ms5';'ms6 ';'std_ms6';'ms7 ';'std_ms7';'ms8 ';'std_ms8';'ms9 ';'std_ms9'};

     %sustituimos s0 s1 de la medida por m2 m3
     dz(:,4:5)=[m2dz,m3dz*pr/1013];
     dz(:,3)=tst_dz;
     MS9=dz(:,15)-0.5*dz(:,16)-1.7*dz(:,17); % o3 double ratio ==MS(9)
     MS8=dz(:,14)-3.2*dz(:,17);              %:REM SO2 ratio MS(8)       
          
     o3.dz_raw0=[timedz(:,1:3),dz_temp,dz,MS8,MS9];
     o3.dz_raw0_legend={'date';'hgflag';'ndz';'tmp';'fl1';'fl2';'tim';'m2 ';'m3*pressure corr';'cy ';...
                        'F0 ';'F1 ';'F2 ';'F3 ';'F4 ';'F5 ';'F6 '; 'F7 ';'r1 ';'r2 ';'r3 ';'r4 ';'MS8 ';'MS9 '};    

    %% dz re-calculation: Pendiente. ¿Vale la pena? Por ahora sólo interesan las cuentas brutas (o3.dz_raw0 y )

else
    disp('Fichero vacio? (no dz measurements)');
    o3.dzsum=[]; o3.dzsum_legend=[];
    o3.dz_raw0=[]; o3.dz_raw0_legend=[];
end
% ---------------------- End DZ output ------------------------------------
