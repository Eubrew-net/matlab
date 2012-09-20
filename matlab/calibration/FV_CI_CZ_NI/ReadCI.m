
function [DataNumRFH TNumTotal Error]= ReadCI(filename)

% lectura de ficheros CI's
% 
% INPUT: path a fichero
% 
% OUTPUT:
%  - DataNumRFH, tantas celdas como CI's en el fichero, 'Fecha Matlab','Wl (Ang)','Step nº','Raw Counts','Counts/Second'
%  - TNumTotal, emperatura (in volts). Matriz con tantos elementos commo CI's 
%  - Error, celda con informe de lectura
% 
% MODIFICACIONES:
% 
% 22/07/2010 Isabel Modificado para que busque idx1 para otros Brewers
% 23/07/2010 Isabel Modificado para que como salida tome el error cometido
%                   (si se encuentra en un lugar diferente, o pasa algo)

%% Diferentes Brewers
legend={'Fecha Matlab','Wavelength (Ang)','Step number','Raw Counts','Counts/Second'};
s=fileread(filename);
[pat nam ext]=fileparts(filename);
date=sscanf(nam,'%*2c%3d%2d'); 
F=datejuli(2000+date(2),date(1));

% Localizamos las palabras/frases de interés.
[darks end_dk] = regexpi(s, '\<dark\s*\w*\s*=\s*\d?[.]?\d*\>', 'match','end');% para CI y CZ
 ends          = regexp(s, 'end', 'start');
 pr            = regexp(s, 'pr', 'start');

%% leemos datos
DarkCount=NaN*ones(1,length(darks));
TNumTotal=NaN*ones(1,length(darks));
for j=1:length(darks);
    try        
      DarkCount(j)=sscanf(darks{j},'%*s%*s%f');
        
      d{j}=s(end_dk(j)+1:ends(j)-1);
      DataNum=sscanf(d{j},'%f%*c%d%*c%d%*c%f%*c%f');
      DataNumR{j}=reshape(DataNum,5,length(DataNum)/5)';
      DataNumRFH{j}=[F+DataNumR{j}(:,1)/(24*60) DataNumR{j}(:,2:5)];
        
      % TEMPERATURA. Una por scan
      TNumTotal(j)=str2num(s((pr(j))-5:(pr(j))-2));
        
    catch
      err=lasterror;
      Error{j}={'Error',[nam,ext],err.message};
      disp(['ERROR ',[nam,ext],' ',err.message]);
    end
    Error{j}={'Ok',[nam,ext]};
end

%% GRAFICOS 2D (cuentas por segundo frente a la longitud de onda)
%     plot(DataNumRFHTotalF(:,2),DataNumRFHTotalF(:,5),'r.-');
%     xlabel('Longitud onda (ang)');
%     ylabel('Cuentas/Segundo');
%     title(filename); grid;
