%function [sr,si,co]=readb_sl(bfile,config)
%  Input : fichero B, configuracion (ICF en formato ASCII)
%  Output:
%          sr: [ fecha, año, diaj, hh,mm,dd, steps revolution]
%          si  : siting TODO
%          sl  : cell array co todos los comentarios
%
%
%                
% SKAVG R6 SR6 R5 SR5 N TEMP STEMP
% Funcion especializada en leer los datos de sr , basada en readb
% Requiere mmstrtok
% Si se facilita fichero de configuracion lo usa si no lee la configuracion
% de la cabecer
function [sr,si,co]=readb_sr(bfile,config)

sr=[];si=[];
%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(bfile)
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    [PATHSTR,NAME,EXT,VERSN] = fileparts(bfile);
    fileinfo=sscanf([NAME,EXT],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1))

    l=mmstrtok(s,char(10));
    
    %jsum=strmatch('summary',l);
    jco=strmatch('co',l);
    

    if ~isempty(jco)
        co=l(jco);
        jsr_aux=strfind(co,'sr');
        jsr=find(~cellfun('isempty',jsr_aux))
    
                
        if ~isempty(jsr)
           for jj=1:length(jsr) 
            sr_aux=co(jsr(jj));
            lsr=mmstrtok(sr_aux,char(13));
            aux_time=sscanf(lsr{2},'%02d:%02d:%02d');
            aux_sr=sscanf(lsr{3},'sr: Azimuth Steps per revolution measured = %d ')
            aux_sr=[datefich,aux_time',aux_sr];
            sr=[sr;aux_sr];
           end
        end
        
    else
        co=[];
    end
    
    
    