function [dt,rs]=readb_dt(bfile,config)
%  Input : fichero B, configuracion (ICF en formato ASCII)
%  Output:
%          dt: [ fecha, año, diaj, hh,mm,dd, steps revolution]
%          rs  : siting TODO
%          co  : cell array co todos los comentarios
%  DT
%   1	2	3	4	5	6	7	8	9	10	 11
% Fecha	mm  mm	mm	dd	yy	hh	min	seg	Temp FW#2 (high -> 0)		
% 
%  12  13  14  15  16  17                    18  		
% F(3) DT1 DT2 DT3 DT4 DT5                   FW#2 (low -> 1)					
% 
%  19  20  21  22  23  24  25  26  27  28  29
% F(3) DT1 DT2 DT3 DT4 DT5 DT6 DT7 DT8 DT9 DT10
%
%  30       31     32	   33
% avg_high  std	 avg_low  std
%
% RS
% fecha	temp	R0	R1	R2	R3	R4	R5	R6	R7	
%   1	2	    3	4	5	6	7	8	9	10		
% S0	S1	S2	S3	S4	S5	S6	S7			
% 11	12	13	14	15	16	17	18
% RS0	RS1	RS2	RS3	RS4	RS5	RS6	RS7
% 19	20	21	22	23	24	25	26
% RR0	RR1	RR2	RR3	RR4	RR5	RR6
% 27	28	29	30	31	32	33 
%RRS0	RRS1	RRS2	RRS3	RRS4	RRS5	RRS6
% 34	35	    36	    37	    38	    39	    40
% Funcion especializada en leer los datos de sr , basada en readb
% Requiere mmstrtok
% TODO: Si se facilita fichero de configuracion lo usa si no lee la configuracion
% de la cabecer
% Alberto Redondas 2005

dt=[]; rs=[];
fmtdt='dto3  %c%c%c %f/ %f %d:%d:%d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f  ';
fmtrs='rso3  %c%c%c %f/ %f %d:%d:%d ';

%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(['Error',bfile]);
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    [PATHSTR,NAME,EXT,VERSN] = fileparts(bfile);
    fileinfo=sscanf([NAME,EXT],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
%     datestr(datefich(1));

    l=mmstrtok(s,char(10));
    
    %jsum=strmatch('summary',l);
    jdt=strmatch('dto3',l);
    jrs=strmatch('rso3',l);
    
    

    if ~isempty(jdt)
        dt_str=l(jdt);
        for i=1:length(jdt)
           dt_=sscanf(l{jdt(i)},fmtdt);
           month=char(dt_(1:3)');
           fecha=datenum(sprintf(' %02d/%s/%02d',dt_(4),month,dt_(5)));
           hora=dt_(6)/24+dt_(7)/24/60+dt_(8)/24/60/60;  
           dt=[dt;[fecha+hora,dt_']];           
        end         
    else
        dt=[];
    end
    
    if ~isempty(jrs)
        rs_str=l(jrs);
        for i=1:length(jrs)
           [rs_,caux]=sscanf(l{jrs(i)},fmtrs);
           month=char(rs_(1:3)');
           fecha=datenum(sprintf(' %02d/%s/%02d',rs_(4),month,rs_(5)));
           hora=rs_(6)/24+rs_(7)/24/60+rs_(8)/24/60/60;  
           rs_=str2num(l{jrs(i)}(26:end));
           try
           rs=[rs;[fecha+hora,rs_']];
           catch
            disp(rs_)
           end
        end         
    else
        rs=[];
    end
%    
%     if ~isempty(dt)
%         %subplot(2,1,1)
%         errorbar([dt(:,1),dt(:,1)],dt(:,[30,32]),dt(:,[31,33]),'o');
%         datetick('keeplimits');grid
%     end
%     if ~isempty(dt)
%         %subplot(2,1,2)
%         plot(rs(:,1),rs(:,19:26));
%         datetick;
%         set(gca,'Ylim',[0.991,1.001]);
%         hline([0.997,1.003])
%         grid
%     end
%    