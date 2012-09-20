
%function irx=loadirr(lamp,pathirr)
% retorna la calibracion pasando el numero de lampara como argumento 
% pathirr: directorio en el que se encuentran los ficheros de irradiancia
% absoluta

function irx=loadirr_PLC(lamp,pathirr)
if isnumeric(lamp)
 name=sprintf('LAMP%03d.irr',lamp);
else
 name=lamp;
end
 [fid,m]=fopen(fullfile(pathirr,name));
 if fid>0 
    fgets(fid)
    fgets(fid)
    irx=fscanf(fid,'%f',[2,Inf])';
    fclose(fid);
    lamda=2865:5:3635;
     if size(irx(:,1))== size(lamda)
       y=iterp1(irx(:,1),irx(:,2),lamda,pchip);
       figure;plot(irx(:,1),irx(:,2),'r',lamda,y,'*-k');
       irx=[lamda,y];
     end
 else 
    irx=[];
    warning([name,' no encontrado']);
 end   
