%function [irx,lamp,di]=loadlamp(name)
% Carga una lampara generica brewer
function [irx,lamp,di]=loadlamp(name)
 %name=sprintf('LAMP%3d.OLD',lamp)
 [fid,m]=fopen(name);
 if fid>0 
    s=fgets(fid); lamp=sscanf(upper(s),'LAMP%d')
    s=fgets(fid); di =str2num(s);  
    irx=fscanf(fid,'%f',[2,Inf])';
    fclose(fid);
 else 
    irx=[];
    warning([name,' no encontrado']);
 end   
