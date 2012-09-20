function irx=loadirr_PLC(lamp,pathirr)

% retorna el fichero de calibracion 
% 
% INPUT: 
%   - lamp: numero de lampara
%   - pathirr: directorio en el que se encuentran los ficheros de 
%              irradiancia absoluta 
% 
% OUTPUT:
%   - irx: fichero de irradiancia absoluta

if isnumeric(lamp)
 name=sprintf('LAMP%03d.irr',lamp);
else
 name=lamp;
end
 [fid,m]=fopen(fullfile(pathirr,name));
 if fid>0 
    fgets(fid);
    fgets(fid);
    irx=fscanf(fid,'%f',[2,Inf])';
    fclose(fid);
    lamda=2865:5:3635;
     if size(irx(:,1),1)~=length(lamda)
       disp('Interpolamos a 5 A');
       y=interp1(irx(:,1),irx(:,2),lamda,'pchip');
       figure;plot(irx(:,1),irx(:,2),'r',lamda,y,'*-k');
       title(name);
       irx=[lamda',y'];
     end
 else 
    irx=[];
    warning([name,' no encontrado']);
 end   
