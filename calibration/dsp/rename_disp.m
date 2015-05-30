
 function rename_disp(path_a_brewer)
 
% Renombra los ficheros de dispersion W en longitudes de onda crecientes 
% (ver abajo, linea 32), moviéndolos al directorio renamed creado 
% dentro del señalado por path_a_brewer.
% 
% path_a_brewer será el patrón de búsqueda, INCLUIDO el path al directorio
% donde están los ficheros W. 
%  
%       Ejemplo:  rename_disp('.\bdata205\205\W*.205')
% 
% En el caso de estar trabajando en el propio directorio donde están los W,
% habrá que escribir, por ejemplo, '.\W*.205'
%
% 
% lineas  orden    lamp           tom_granar
% 2893.600	1	%	Hg	9
% 2932.630	2	%	In	9
%  ...     ...      ......
% 
% TODO: reescribir el fichero con la longitud de onda correcta ?
%      ¿longitud de onda 3080.822?
% 
% Modificado: 30/11/2009 Juanjo: Corregido el patrón de busqueda de brewer
%             05/03/2010 Juanjo: Se redefine el patrón de búsqueda (ver arriba).
%                        Se añade información a la variable disp_lines, 
%                        segun "Investigation of the wavelength accuracy of
%                        Brewer spectrophotometers", J. Gröbner. Slits
%                        tomadas de A. Redondas. Se modifican líneas 113 a
%                        121. Ahora, para dia ddd, se crea el
%                        directorio ###_yy_ddd+1 donde se llevaran los
%                        ficheros correspondientes a ddd, ddd+1 y ddd+2. Se
%                        garantiza así el buen funcionamiento de dsp_report
%                        (ver linea 10, day=day-1:day+1;). Testado con
%                        brewer #201 y #205
 
origen=pwd;
[pathstr,name,ext]=fileparts(path_a_brewer); 
if isempty(pathstr)
    pathstr='.';
end
cd(pathstr);
s=dir(cat(2,name,ext));

disp_lines=[
% wl(A)     Line no.    Lamp type    Line no.       Slits
%        (rename_disp)           (Brewer Softw)       
2893.600    1    %          Hg          9             0-1
2932.630    2    %          In          9             
2967.280    3    %          Hg          10            0-3
3018.360    4    %          Zn          1             0-5
3035.780    5    %          Zn          2             0-5
3039.360    6    %          In          10            
3080.822    7    %          ??                        
3133.167    8    %          Cd          4             0-5
3133.170    8    %          Cd??                      
3261.055    9    %          Cd          5             3-5
3261.050    9    %          Cd??                      
3282.330    10   %          Zn          3             1-5
3341.480    11   %          Hg          11            0-5
3403.652    12   %          Cd          6             0-5
3403.670    12   %          Cd??                      
3499.950    13   %          Cd          7             1-5
3499.952    13   %          Cd??                      
3611.630    14   %          Cd(multip)  8             5-5
3611.510    14   %          Cd??                      
];
tic
for i=1:length(s)
     name_old=sscanf(upper(s(i).name),'W%01d%01d%03d%02d.%03d');

     if length(name_old)<=1
        name_old=sscanf(s(i).name,'%02d%01d%03d%02d.%03d');
     end
     if length(name_old)==4
       name_old=sscanf(upper(s(i).name),'W%01d%01d%03d%02d%*02c.%03d');
       if length(name_old)==4
       name_old=sscanf(upper(s(i).name),'W%01d%01d%03d%02d%*03c.%03d');
       end  
     end
    try 
     line=fileread(s(i).name);
     line_no=sscanf(line,'%f');

     j=find(disp_lines(:,1)==line_no(1));
     if ~isempty(j)
         j=disp_lines(j,2);% orden asignado a la long. de onda
         name_old(1)=j;% cambiamos línea por orden asignado

         if j<=9
           name_new=sprintf('W%01d%01d%03d%02d.%03d',name_old);
         else
           name_new=sprintf('W%02d%01d%03d%02d.%03d',name_old);
         end

         disp(name_new)
         if exist('renamed','dir')~=7 % si no es un directorio lo creamos
            mkdir('renamed')
         end
        [SUCCESS,MESSAGE] = copyfile(s(i).name,fullfile('renamed',name_new));
         if SUCCESS~=1
            disp(MESSAGE);
         end
      else
         disp(sprintf('%s: %f, %s','linea no registrada',line_no(1),s(i).name));
         plot(line_no(2:2:end),line_no(3:2:end)); title(sprintf('%.5f',line_no(1)));
     end
    catch
        warning(s(i).name);
    end
    
end
toc
rename(origen)

function rename(dir_cal)
%mkdir renamed
cd ./renamed ;
s=dir('W*');
tic
for i=1:length(s)
    % problema con la extension;
   
    [data,c]=sscanf(s(i).name,'W%01d%01d%03d%02d.%03d');
    if c~=5 || isempty(c)
      [data,c]=sscanf(s(i).name,'W%02d%01d%03d%02d.%03d');
    end
    if c==5
        % wv slit day year inst
        ndir=sprintf('%03d_%02d_%03d',[data(5:-1:4);data(3)+1]);
        ndir_m=sprintf('%03d_%02d_%03d',[data(5:-1:4);data(3)]);   
        ndir_mm=sprintf('%03d_%02d_%03d',[data(5:-1:4);data(3)-1]);  
           
    if ~exist(ndir,'dir') && ~exist(ndir_m,'dir') && ~exist(ndir_mm,'dir')
        mkdir(ndir);
    end

        if exist(ndir,'dir')
            movefile(s(i).name,ndir);
        elseif exist(ndir_m,'dir');
            movefile(s(i).name,ndir_m);           
        elseif exist(ndir_mm,'dir')
            movefile(s(i).name,ndir_mm);
        end  
    else
        disp(s(i).name);
    end
end
toc
fclose all; cd(dir_cal)
 
