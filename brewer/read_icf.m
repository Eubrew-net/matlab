function [config,TC,DT,extrat,absx,AT,legend]=read_icf(file,datefich,show)
%function [config,TC,DT,extrat,absx,AT,leg]=read_icf(file,datefich,show);
%
% config 1:52 with values of icf file:
% 1  'Release date         ' 17 'ND filter 0      ' 35 'O3 FW #3 Offset   '
% 2  'o3 Temp coef 1       ' 18 'ND filter 1      ' 36 'NO2 absn Coeff    '
% 3  'o3 Temp coef 2       ' 19 'ND filter 2      ' 37 'NO2 ds etc        '
% 4  'o3 Temp coef 3       ' 20 'ND filter 3      ' 38 'NO2 zs etc        '
% 5  'o3 Temp coef 4       ' 21 'ND filter 4      ' 39 'NO2 Mic #1 Offset '
% 6  'o3 Temp coef 5       ' 22 'ND filter 5      ' 40 'NO2 FW #3 Offset  '
% 7  'Micrometer steps/deg ' 23 'Zenith steps/rev ' 41 'NO2/O3 Mode Change'
% 8  'O3 on O3 Ratio       ' 24 'Brewer Type      ' 42 'Grating Slope     '
% 9  'SO2 on SO2 Ratio     ' 25 'COM Port #       ' 43 'Grating Intercept '
% 10 'O3 on SO2 Ratio      ' 26 'o3 Temp coef hg  ' 44 'Micrometer Zero   '
% 11 'ETC on O3 Ratio      ' 27 'n2 Temp coef hg  ' 45 'Iris Open Steps   '
% 12 'ETC on SO2 Ratio     ' 28 'n2 Temp coef 1   ' 46 'Buffer Delay (s)  '
% 13 'Dead time (sec)      ' 29 'n2 Temp coef 2   ' 47 'NO2 FW#1 Pos      '
% 14 'WL cal step number   ' 30 'n2 Temp coef 3   ' 48 'O3 FW#1 Pos       '
% 15 'Slitmask motor delay ' 31 'n2 Temp coef 4   ' 49 'FW#2 Pos          '
% 16 'Umkehr Offset        ' 32 'n2 Temp coef 5   ' 50 'uv FW#2 Pos       '
%                            33 'O3 Mic #1 Offset ' 51 'Zenith Offset     '
%                            34 'Mic #2 Offset    ' 52 'Zenith UVB Positio'
%
% example pretty print
% cfg=read_icf('icf28006.196');
% xlswrite([cellstr(leg),num2cell(cfg)])
if nargin==1
    datefich=now;
    show=0;
elseif nargin==2
    show=0;
end

[fpath,ffile,fext]=fileparts(file);

if ~strcmpi(fext,'.cfg')
    
lines=fileread(file);
fmt_icf=[
'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%3c',...
' %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s'];
config=sscanf(lines',fmt_icf);
type=char(config(23:25)');
fecha=char(config(54:end)');

if strcmp(type,'iii') config(23)=3; 
elseif strmatch('ii',type) config(23)=2; 
elseif strcmp(type,'v') config(23)=5;    
elseif strcmp(type,'iv') config(23)=4; 
else config(23)=0;
end



%date 
config(54:end)=[];
%model erase
config(24:25)=[];
if isempty(fecha)
  [pat,name,ext,ve]=fileparts(file); 
  fileinfo=sscanf([name,ext],'%*3c%03d%02d.%03d');
  datefich=datejul(fileinfo(2),fileinfo(1));
  fecha=datefich(1)
  config(53)=fecha;
else   
try
  fecha=datenum(fecha);
catch
  [pat,name,ext,ve]=fileparts(file); 
  fileinfo=sscanf([name,ext],'%*3c%03d%02d.%03d');
  %fileinfo=sscanf(file,'%*3c%03d%02d.%03d');
  datefich=datejul(fileinfo(2),fileinfo(1));
  datestr(datefich(1))
  fecha=datefich(1);
  %config(53)=fecha;
end 
end
config=[fecha;config];
else
 configfile=load(file); 
 cal_idx=max(find(configfile(1,:)<=datefich(1))); % calibracion mas proxima por debajo
 config=configfile(:,cal_idx);
 datestr(configfile(1,cal_idx))
end

    if ~isnan(config(2:6))
        TC=config(2:6); end
    if ~isnan(config(13))
        DT=config(13);  end 
    if ~isnan(config(11:12))  
        extrat=config(11:12); end %    B1=extrat(1);B2=extrat(2); 
    if ~isnan(config(8:10)) 
        absx=config(8:10);    end % A1=absx(1);A2=absx(2);A3=absx(3); 
    if ~isnan(config(17:22)) 
        AT=config(17:22);     end % atenuacion
     
    TC=[TC;config(26)]; 
if length(config)~=52
    config(52)=NaN;
    % 
end


legend=[
'Release date         '
'o3 Temp coef 1       '
'o3 Temp coef 2       '
'o3 Temp coef 3       '
'o3 Temp coef 4       '
'o3 Temp coef 5       '
'Micrometer steps/deg '
'O3 on O3 Ratio       '
'SO2 on SO2 Ratio     '
'O3 on SO2 Ratio      '
'ETC on O3 Ratio      '
'ETC on SO2 Ratio     '
'Dead time (sec)      '
'WL cal step number   '
'Slitmask motor delay '
'Umkehr Offset        '
'ND filter 0          '
'ND filter 1          '
'ND filter 2          '
'ND filter 3          '
'ND filter 4          '
'ND filter 5          '
'Zenith steps/rev     '
'Brewer Type          '
'COM Port #           '
'o3 Temp coef hg      '
'n2 Temp coef hg      '
'n2 Temp coef 1       '
'n2 Temp coef 2       '
'n2 Temp coef 3       '
'n2 Temp coef 4       '
'n2 Temp coef 5       '
'O3 Mic #1 Offset     '
'Mic #2 Offset        '
'O3 FW #3 Offset      '
'NO2 absn Coeff       '
'NO2 ds etc           '
'NO2 zs etc           '
'NO2 Mic #1 Offset    '
'NO2 FW #3 Offset     '
'NO2/O3 Mode Change   '
'Grating Slope        '
'Grating Intercept    '
'Micrometer Zero      '
'Iris Open Steps      '
'Buffer Delay (s)     '
'NO2 FW#1 Pos         '
'O3 FW#1 Pos          '
'FW#2 Pos             '
'uv FW#2 Pos          '
'Zenith Offset        '
'Zenith UVB Position  '

];

if show==1
    xlswrite_([cellstr(legend),num2cell(config)])
end
% 5399 :
% 5400 REM read ic file
% 5402 REM  I=0 reads all
% 5404 REM  I=1 reads all except dsp/zs values
% 5410 ON ERROR GOTO 5000
% 5412 CLOSE 8:OPEN DD$+NO$+"\"+ICF$+"."+NO$ FOR INPUT AS 8
% 5414 ON ERROR GOTO 3100
% 5420 REM get O3 TC's
% 5422 FOR J=2 TO 6:INPUT#8,TC(J):NEXT
% 5424 TC(0)=TC(2)-TC(5)-3.2*(TC(5)-TC(6)):TQ(0)=TC(0)
% 5426 TC(1)=TC(3)-TC(5)-.5*(TC(4)-TC(5))-1.7*(TC(5)-TC(6)):TQ(1)=TC(1)
% 5430 REM get other values
% 5432 INPUT#8,PC,A1,A2,A3,B1,B2,T1,MC$,DL$,UO$
% 5434 FOR J=0 TO 5:INPUT#8,AF(J):NEXT
% 5436 INPUT#8,ER$,TYP$,CP$
% 5437 N9$="6":SE$=":":IF TYP$="mkiii" AND Q14%=1 THEN N9$="9":SE$="&"
% 5438 OF%=148-VAL(MC$):M8$=MC$:ER%=VAL(ER$):CP%=VAL(CP$)
% 5440 AD=1019:IF CP%=2 THEN AD=AD-256
% 5442 CP$=RIGHT$(STR$(CP%),1):REM must be 1 char
% 5450 REM get other TC's
% 5452 INPUT#8,TC(7),NTC(7)
% 5454 FOR J=2 TO 6:INPUT#8,NTC(J):NEXT
% 5456 NTC(0)=NTC(2)-NTC(5)-3.2*(NTC(5)-NTC(6)):NTQ(0)=NTC(0)
% 5458 NTC(1)=.1*NTC(2)-.59*NTC(3)+.11*NTC(4)+1.2*NTC(5)-.82*NTC(6):NTQ(1)=NTC(1)
% 5460 REM get rest
% 5462 INPUT#8,MZ%,MY%,MX%,NA1,NB1,NB2,NMZ%,NMX%,SWITCH%,GS,GI
% 5464 INPUT#8,ZERO,IRIS,DELAY,NOFW1,OZFW1,POFW2,UF$,ZO%
% 5466 INPUT#8,ZU%:IF ZU%<999 THEN ZU%=ER%*3/4
% 5470 REM get DSP/ZE coeffs
% 5472 IF I<>0 THEN 5484
% 5474 CLOSE 8:OPEN DD$+NO$+"\"+DCF$+"."+NO$ FOR INPUT AS 8
% 5476 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,DC(I,J):DC(0,J)=DC(6,J):NEXT:NEXT
% 5478 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,NDC(I,J):NDC(0,J)=NDC(6,J):NEXT:NEXT
% 5480 CLOSE 8:OPEN DD$+NO$+"\"+ZSF$+"."+NO$ FOR INPUT AS 8
% 5482 FOR I=1 TO 9:INPUT#8,ZSC(I):NEXT
%
    
    
% 
% 
% 
% l=mmstrtok(lines,char(10));
% type=l{23}
% date=l{52}
% l([23,52])=[];
% config=sscanf(char(l)','%f');
% config=[datenum(date),config'];
% 
%     if ~isnan(config(2:6)) 
%         TC=config(2:6); end
%     if ~isnan(config(13))
%         DT=config(13);  end 
%     if ~isnan(config(11:12))  
%         extrat=config(11:12); end %    B1=extrat(1);B2=extrat(2); 
%     if ~isnan(config(8:10)) 
%         absx=config(8:10);    end % A1=absx(1);A2=absx(2);A3=absx(3); 
%     if ~isnan(config(17:22)) 
%         AT=config(17:22);     end % atenuacion
%     if ~isnan(config(14)) 
%         O3CSTEP=config(14);     end % CAL STEP
% 
%        DIOD=sscanf(char(l(6))','%f');
% o3calstep=sscanf(char(l(12))','%f');
% slitmaskconstant=sscanf(char(l(14))','%f');
% data.umkehrpos=buf(15);
% BREWER.NDtrans=buf(16:21)';  % nd0 to nd5
% BREWER.zenithspr=buf(22);
% BREWER.comport=sprintf('COM%d',buf(23));
% BREWER.o3tempcoeff=[buf(24) BREWER.o3tempcoeff];
% data.mic1diodeoffset=buf(31);
% data.o3fw3pos=buf(33);
% BREWER.uvzero=buf(42);
% data.irisspr=buf(43);
% data.o3fw1pos=buf(46);
% data.uvfw2pos=buf(48);
% data.zenithlamppos=buf(49);
% 
