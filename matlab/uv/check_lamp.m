function check_lamp(date,nbrw)

% Análisis de parámetros de calibración de lámpara:
% Se requiere directorio en QLraw### de la forma ###_yy_ddd con  info
% conocida: ficheros B, D, voltaje y QL, al menos.
%  INPUT:
%        - date, formato dddyy, correspondiente a la calibración 
%        - brewerid, entero
% 
% TODO: no puedo acabar, de modo que no garantizo que la función sea a
% prueba de fallos:
%       - hay que implementar manejo de errores

close all;
set(0,'DefaultFigureWindowStyle','Docked');

path_root=fullfile(cell2mat(regexpi(pwd,'^[A-Z]:', 'match')),'UV'); 
path(genpath(fullfile(path_root,'matlab_uv')),path);

dat=brewer_date(date); nbrw=nbrw;
chk_dirs=sprintf('%03d_%02d_%03d',nbrw,dat(2)-2000,dat(end));
path_to_raw=fullfile(path_root,'Lamps',strcat('QLraw',num2str(nbrw)),chk_dirs);

assignin('base', 'dat', dat); assignin('base', 'nbrw', nbrw); 
assignin('base', 'path_root', path_root); assignin('base', 'path_to_raw', path_to_raw);

ops.outputDir=path_to_raw; ops.showCode=false; publish('lamps_analysis',ops); 
cd(fullfile(path_root,'matlab_uv'));
