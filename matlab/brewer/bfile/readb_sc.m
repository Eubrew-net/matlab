function [sc,sc_raw,co,o3]=readb_sc(bfile,config_file,varargin)
%function [sc,sc_meas,co]=readb_sc(bfile,config_file)
%  Input : fichero B, configuracion (ICF en formato ASCII)
%  Output:
%          sc: [ fecha, año, diaj, hh,mm,dd, steps revolution]
%          sc_d  : siting TODO
%          co  : cell array co todos los comentarios
%
%
%                
% SKAVG R6 SR6 R5 SR5 N TEMP STEMP
% Funcion especializada en leer los datos de sc , basada en readb
% Requiere:
%        mmstrtok
% Si se facilita fichero de configuracion lo usa si no lee la configuracion
% de la cabecer
% Alberto Redondas 2005
% revisar linea 77
% 
%  MODIFICADO:  
%  Juanjo 08/02/2012: Añadido condicional para evitar problemas cuando se detiene el sc
%                    (HOME key pressed) -> líneas 120:122
%  Alberto 2014: Suppresed correctes

sc=[];
fmtsc=' sc %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f';
fmt_head=' version=%f dh %f %f %f %s %f %f %f pr %f';

config=readb_config(bfile);

if  nargin>1 && ischar(config_file)
    [config_,TC_,DT_,extrat_,absx_,AT_]=read_icf(config_file);
    config(:,2)=config_;

end

try
    s=fileread(bfile);
    [PATHSTR,NAME,EXT] = fileparts(bfile);
    fileinfo=sscanf([NAME,EXT],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    l=mmstrtok(s,char(10));

    jco=strmatch('co',l); 
    %jsc=strmatch('sc',l);
    jsc=find(strncmp(l,'sc',2));
    if isempty(jsc) || isempty(jco)
       o3.sc_avg=[];      o3.sc_raw=[];
       sc=[];    sc_raw=[];    co='No SC';
%        fprintf('%s: No SC''s\n',bfile);
       return
    end
    jhg=strmatch('hg',l);
    jhgscan=strmatch('hgscan',l);
    jloc=strmatch('version',l);

    % Read the head
    if isunix
       c=(strrep(strtrim(mmcellstr(l{jloc(1)},char(13))),' ','_')); 
       %c=mmstrtok(strrep(l{jloc(1)},char(13),','),','); 
       loc=c{6};
       c([1:2,6,10])=[];
       c=cellfun(@str2num,c);
       c=[NaN;c];
       %c=textscan(strrep(strrep(strtrim(l{jloc(1)}),' ','_'),char(13),' '),fmt_head);
    elseif ispc
       c=textscan(l{jloc(1)},fmt_head,'delimiter',char(10));
       loc=c{5};
       c(5)=[];
       c=cell2num(c);
    end
    
    datebfile=datenum(c(4)+2000,c(3),c(2));
    if datebfile~=datefich(1)
        disp('warning Date error in file');
        datevec(datebfile-datefich(1))
    end
    lat=c(5);
    long=c(6);
    pr=c(8);

% READ HG
% filtro de hg
if ~isempty(jhg)
  hg=readb_hg_measures(l,jhgscan,jhg)';
else
  hg=NaN*ones(1,9)';
end


    time_hg=sort(hg(1,:)*60+hg(2,:)+hg(3,:)/60); %a minutos. Lo de sort es un APAÑO
    flaghg=abs(hg(5,:)-config(14))<2; % more than 2 steps change
    if size(hg,2)>1
        flag_hg=find(diff(flaghg)==-1);   %

        if flaghg(1)==0
            flag_hg=[1,flag_hg];
        end
        %revisar no es el siguiente sino el proximo no negativo
        % almacenar la constante en el fichero.

        time_badhg=time_hg([flag_hg;flag_hg+1]');
        time_badhg=[0,time_hg(1);time_badhg];
    else
        time_badhg=[0,0];
    end
    hgscan_date=datefich(1)+time_hg/60/24;
    jaux=find(diff(hgscan_date)<0);
    hgscan_date(jaux+1:end)=hgscan_date(jaux+1:end)+1;
    hg_data.hg=[hgscan_date;hg;flaghg]';
    hg_data.hg_legend={'fecha'	'hora'	'min'	'seg'	'coef' 	'step'...
        'step_int'	'int'	'temp'	'steps_chg'	'flag'...
        };
    hg_data.time_badhg=time_badhg/60/24+datefich(1);

    if ~isempty(jco)
        co=l(jco);
        jsc_aux=strfind(co,'sc:');
        jsc=find(~cellfun('isempty',jsc_aux)); 
        co_aux=find(~cellfun('isempty',strfind(co,'sc: Suppressed'))); 
        co_aux=find(~cellfun('isempty',strfind(co,'sc: Suppressed')));
        [a b]=intersect(jsc,co_aux); 
        jsc(b)=[];
        c=find(cellfun(@(x) ~isempty(strfind(x,'Running')),co(jsc)));
        jsc(c)=[];
        
        sc=[];
        sc_raw=[];
        o3.co=co;
        if ~isempty(jsc)
            idx=1;
            for jj=1:2:length(jsc)
                sc_aux=co(jsc(jj));
                if ~isempty(strfind(cell2str(sc_aux),'HOME key'))
                    continue
                end
                lsc=mmstrtok(sc_aux,char(13));
                aux_time_start=sscanf(lsc{2},'%02d:%02d:%02d');
                aux_start=sscanf(lsc{3},'sc: start %d %d %d %d %d %d ');
                %14015 B$="start"+" "+str$(w1)+str$(w2)+str$(dw)+" "+da$+" "+mo$+" "+ye$: gosub 3050
                if ~isempty(varargin)
                    date_range=varargin{1};
                    if datenum([datefich(2),1,datefich(3),aux_time_start'])<date_range(1)
                       continue
                    elseif length(date_range)>1
                        if datenum([datefich(2),1,datefich(3),aux_time_start'])>date_range(2)                            
                           continue                       
                        end
                    end
                end
                if jj==length(jsc)
                    return; 
                end
                sc_aux=co(jsc(jj+1));
                lsc=mmstrtok(sc_aux,char(13));
                aux_time_end=sscanf(lsc{2},'%02d:%02d:%02d');
                aux_end=sscanf(lsc{3},'sc: end %f %f %f %f %f %f %f %f %d ');
                if size(aux_end,1)~=8
                    for ii=size(aux_end,1)+1:8
                        aux_end(ii)=NaN;
                    end
                end
                
                
                %40020 REM  VAR1$: Temp       VAR5$: O3
                %40030 REM  VAR2$: Mu         VAR6$: Min step
                %40040 REM  VAR3$: Filter     VAR7$: SO2
                %40050 REM  VAR4$: Max step   VAR8$: Micrometer step before measured

                %aux_sc=[datefich(1),aux_time_start',aux_start',aux_end'];


                time_start=datefich(1)+aux_time_start(1)/24+aux_time_start(2)/60/24+aux_time_start(3)/60/60/24;
                time_end=datefich(1)+aux_time_end(1)/24+aux_time_end(2)/60/24+aux_time_end(3)/60/60/24;
               try
                aux_sc=[time_start,time_end,(jj+1)/2,aux_start(1:3)',aux_end'];
               catch
                 aux_sc=NaN*ones(1,14);
               end
               if length(aux_sc)<14 
                   aux_sc=NaN*ones(1,14);
                   return 
               end
               
                ini_med=jco(jsc(jj));
                fin_med=jco(jsc(jj+1));
                [sc_meas,sc_c]=sscanf(char(l{ini_med+1:fin_med-1})',fmtsc,[17,Inf]);
                
               if sc_c
                sc_meas=sc_meas';
                time_meas=datefich(1)+sc_meas(:,3)/60/24;
                n=size(sc_meas,1);
                % indice+ n_sc +scan
                jj=100*(jj+1)/2+(1:n);

                sc_temp=repmat(aux_sc(7),n,1);
                %sc_airm=repmat(aux_sc(:,12),n,1);
                [szasc,m2sc,m3sc]=brewersza(sc_meas(:,3),fileinfo(2),fileinfo(3),lat,long);
                step=aux_start(1):aux_start(3):aux_start(2);
                step=[step,aux_start(2):-aux_start(3):aux_start(1)];
                
                %sustituimos slit 0 slit end por las masas opticas
                sc_meas(:,4)=m2sc;
                sc_meas(:,5)=m3sc*pr/1013;
                % size step == n
                if size(step,2)~=size(jj,2)
                  step=step(1:size(jj,2));  
                  %return; % medida incompleta
                end
                 sc_aux=[time_meas,jj',step',sc_temp,sc_meas];
                
                [ozo_sc,so2_sc,ratios]=ds_ozone(ds_raw2counts(sc_aux,config(:,1)),config(:,1));
                % sustituimos los ratios  
                sc_aux(:,18)=ozo_sc;
                sc_aux(:,19)=so2_sc;
                if size(config,2)==2
                    [ozo_sc,so2_sc]=ds_ozone(ds_raw2counts(sc_aux,config(:,2)),config(:,2));
                    sc_aux(:,20)=ozo_sc;
                    sc_aux(:,21)=so2_sc;
                end
                sc_aux=[sc_aux,ratios(:,5:6)];


                % ajuste del sc
                % polyfit2 alsor return the vertice coordinates of the parabola
                [p,s,v]=polyfit2(sc_aux(:,3),ozo_sc); %step vs ozone

                %HG
                hgscan=hg_data.hg;
                %j=find(hgscan(:,1)<time_start);
                %k=max(j);
                j=find(hgscan(:,1)<time_start,1,'last');
                hg_start=hgscan(j,:);
                %j=find(hgscan(:,1)>time_end);
                %k=min(j);
                %hg_end=hgscan(min(j),:);
                j=find(hgscan(:,1)>time_end,1,'first');
                hg_end=hgscan(j,:);

                %añadir al avg---> completar
                if ~isempty(hg_end) & ~isempty(hg_start)
                    sc_flag=hg_end(6)-hg_start(6);
                else
                    sc_flag=NaN;
                    if isempty(hg_end) hg_end=NaN; end
                    if isempty(hg_start) hg_start=NaN; end
                    
                end

                aux_sc=[aux_sc,v,s.normr,p,sc_flag,hg_start(1),hg_end(1)];
                if aux_sc(:,8)==-999
                    [szasc,m2sc]=brewersza(nanmean(aux_sc(1:2)),fileinfo(2),fileinfo(3),lat,long);
                    aux_sc(:,[8 10 11])=[m2sc v(1) v(2)];
                end
                sc=[sc;aux_sc];
                sc_raw=[sc_raw;sc_aux];

               else % error measure.
                  disp( char(l{ini_med+1:fin_med-1})' )
               end

            end



            o3.sc_avg=sc;
                            % 7    8        9        10      11         12        13      14
            o3.sc_avg_legend={ 'time_start' 'time_end' 'jj' 'st0'  'stend'  'inc'...
                'temp' 'airm'  'filt'  'o3step'  'o3max'  'so2step'  'so2max' 'calc_step'...
                'o3stepc' 'o3max' 'normr' 'a'  'b'  'c' 'hg_chg' 'hg_start' 'hg_end'};
                 % 15          16    17     18   19   20    21         22       23
            o3.sc_raw=sc_raw;
            o3.sc_raw_legend={'date';'flg';'jj';'tmp';'fl1';'fl2';'tim';...
                'm2 ';'m3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
                'F4 ';'F5 ';'F6 ';'o3 ';'so2 ';'o3c ';'so2c ';'Ms9';'Ms10'};

        else
            o3.sc_avg=[];
            o3.sc_raw=[];
        end
    else
        o3.co=[];
    end
catch
    sc=[];
    sc_raw=[];
    co=lasterror;
    disp(co.message)
    disp(bfile);
    %disp(jsc);
    rethrow(lasterror);
end

function [P,s,v]=polyfit2(x,y)
[p,s,mu]=polyfit(x,y,2);
% denormalizamos
P(1)=p(1)/mu(2)^2;
P(2)=p(2)/mu(2)-2*p(1)*mu(1)/mu(2)^2;
P(3)=p(1)*mu(1)^2/mu(2)^2+p(3)-mu(1)*p(2)/mu(2);
v=[-P(2)/2/P(1),polyval(P,-P(2)/2/P(1))];


%[p,s,mu]=polyfit(x,y,2);
%v=[round(-p(2)/2/p(1)),polyval(p,round(-p(2)/2/p(1)))];



%     if ~isempty(jco)
%         co=l(jco);
%         jsr_aux=strfind(co,'sc:');
%         jsr=find(~cellfun('isempty',jsr_aux))
%     
%                 
%         if ~isempty(jsr)
%            for jj=1:2:length(jsr) 
%    
%             sr_aux=co(jsr(jj));
%             lsr=mmstrtok(sr_aux,char(13));
%             aux_time=sscanf(lsr{2},'%02d:%02d:%02d');
%             aux_start=sscanf(lsr{3},'sc: start %d %d %d %d %d %d ');
% 
%             sr_aux=co(jsr(jj+1));
%             lsr=mmstrtok(sr_aux,char(13))
%             aux_time=sscanf(lsr{2},'%02d:%02d:%02d');
%             aux_end=sscanf(lsr{3},'sc: end %f %f %f %f %f %f %f %f %d ');
%             aux_sr=[datefich(1),aux_time',aux_start',aux_end'];
%             sc=[sc;aux_sr];
%             ini_med=jco(jsr(jj));
%             fin_med=jco(jsr(jj+1));
%             sc_meas=sscanf(char(l{ini_med+1:fin_med-1})',fmtsc,[17,Inf])';
%             time_meas=datefich(1)+sc_meas(:,3)/60/24;
%             n=size(sc_meas,1);
%             jj=100*(jj+1)/2+(1:n);
%             sc_temp=repmat(aux_sr(11),n,1);
%             sc_airm=repmat(aux_sr(:,12),n,1);
%             
%             step=aux_start(1):aux_start(3):aux_start(2);
%             step=[step,aux_start(2):-aux_start(3):aux_start(1)];
%             sc_meas(:,4)=sc_airm;            
%             sc_raw=[sc_raw;[time_meas,jj',step',sc_temp,sc_meas]];
%             
%             sc_raw_legend={'date';'flg';'nds';'tmp';'fl1';'fl2';'tim';...
%               'm2 ';'m3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
%               'F4 ';'F5 ';'F6 ';'r1 ';'r2 ';'r3 ';'r4 '};
%             
%             
%            end
%            
%            
%         end
%         
%     else
%         co=[];
%     end
%     
%     
    