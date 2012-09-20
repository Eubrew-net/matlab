function irx=loadirx(lamp)

if nargin==0
    [name,path]=uigetfile('*.ir*');
    od=pwd;
    cd(path)
else    
    if isstr(lamp)
        name=sprintf('f:\\red_brewer\\calibraciones\\irrfiles\\certificados\\LAMP%03s.irr',lamp)  
    else
        name=sprintf('f:\\red_brewer\\calibraciones\\irrfiles\\certificados\\LAMP%03d.irr',lamp)
    end
end
 [fid,m]=fopen(name);
 if fid>0 
    fgets(fid)
    fgets(fid)
    irx=fscanf(fid,'%f',[2,Inf])';
    fclose(fid);
 else 
    irx=[];
    warning([name,' no encontrado']);
 end   

 
 if nargin==0
    cd(od)
end    
