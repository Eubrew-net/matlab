
 function rename_disp(path_a_brewer)
 
% Renombra los ficheros de dispersion del brewer en longitudes de onda crecientes
% 
% lineas  orden    lamp           tom_granar
% 2893.600	1	%	Hg	9
% 2932.630	2	%	In	9
%  ...     ...      ......
% 
% TODO: reescribir el fichero con la longitud de onda correcta ?
% 
% Modificado: 30/11/2009 Juanjo: Corregido el patrón de busqueda de brewer
%                                 
 
origen=pwd; cd (path_a_brewer); 
brew=cell2mat(regexp(path_a_brewer,'(\\\d+)','match'));
s=dir(['W*.',brew(2:end)]);

disp_lines=[
2893.600	1	%	Hg	9
2932.630	2	%	In	9
2967.280	3	%	Hg	10
3018.360	4	%	Zn	1
3035.780	5	%	Zn	2
3039.360	6	%	In	10
3080.822    7   
3133.167	8	%	Cd	4
3133.170    8
3261.055	9	%	Cd	5
3261.050    9
3282.330	10	%	Zn	3
3341.480	11	%	Hg	11
3403.652	12	%	Cd	6
3403.670    12
3499.950	13	%	Cd	7
3499.952	13
3611.630	14	%	Cd	8
3611.510    14
];

for i=1:length(s)

     name_old=sscanf(s(i).name,'W%01d%01d%03d%02d.%03d');

     if length(name_old)<=1
        name_old=sscanf(s(i).name,'%02d%01d%03d%02d.%03d');
     end
     if length(name_old)==4
       name_old=sscanf(s(i).name,'W%01d%01d%03d%02d%*02c.%03d');
       if length(name_old)==4
       name_old=sscanf(s(i).name,'W%01d%01d%03d%02d%*03c.%03d');
       end  
     end
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
         if exist('renamed')~=7 % si no es un directorio lo creamos
            mkdir('renamed')
         end
        [SUCCESS,MESSAGE,MESSAGEID] = copyfile(s(i).name,fullfile('renamed',name_new));
         if SUCCESS~=1
            disp(MESSAGE);
         end
     else
         disp('linea no registrada')
         disp(sprintf('%f',line_no(1)));
         disp(s(i).name)
         plot(line_no(2:2:end),line_no(3:2:end)); title(sprintf('%.5f',line_no(1)));
     end
end
rename(origen)

function rename(dir_cal)
cd ./renamed ; s=dir('W*');
for i=1:length(s)
    % problema con la extension;
   
    [data,c]=sscanf(s(i).name,'W%01d%01d%03d%02d.%03d');
    if c~=5 | isempty(c)
      [data,c]=sscanf(s(i).name,'W%02d%01d%03d%02d.%03d');
    end
    if c==5
        % wv slit day year inst
        ndir=sprintf('%03d_%02d_%03d',data(5:-1:3));
        data(3)=data(3)-1;  ndir_m=sprintf('%03d_%02d_%03d',data(5:-1:3));
        data(3)=data(3)+2;  ndir_p=sprintf('%03d_%02d_%03d',data(5:-1:3));
           
        if exist(ndir_p,'dir')
            movefile(s(i).name,ndir_p);
        elseif exist(ndir_m,'dir');
            movefile(s(i).name,ndir_m);           
        else
            if ~exist(ndir,'dir')
                mkdir(ndir);
            end
            movefile(s(i).name,ndir);
        end  
    else
        disp(s(i).name);
    end
end
cd(dir_cal)
 
