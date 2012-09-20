%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% calc_med_irr
%
% Programa para calcular las medias de los ficheros de irradiancia absoluta
% de las lámparas
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','MATLAB:gui:latexsup:BadTeXString');

% Variables a modificar en el programa:
dirin=fullfile(pwd,'certificados\12411_200W\');  %directorio en el que estan los ficheros a usar
dirout=fullfile(pwd,'certificados\12411_200W\');  %directorio donde se llevan los resultados
nlamp='039';    %string con el número de la lámpara a la que se le calcula el fichero de irradiancia absoluta

% se cargan los ficheros
fichs=dir(fullfile(dirin,['LAMP',nlamp,'_*.irr']));
nfichs=length(fichs);
nomfich={};
for i=1:nfichs
    fid1=fopen(fullfile(dirin,fichs(i).name),'r');
    s1=fgets(fid1);
    s2=fgets(fid1);
    irr{i}=(fscanf(fid1,'%d %f\r\n',[2,inf]))';
    fclose(fid1);
    nomfich{i}=fichs(i).name;
end

% se calcula la media, partiendo del hecho de que todos los ficheros están
% calculados para las mismas longitudes de onda
lamb=irr{1}(:,1);
irrs=irr{1}(:,2);
for i=2:nfichs
    irrs=[irrs,irr{i}(:,2)];
end
irrm=mean(irrs,2);

% se imprime el fichero de irradiancia absoluto calculado
fid2=fopen(fullfile(dirout,['LAMP',nlamp,'.irr']),'w');
fprintf(fid2,'%s',s1);
fprintf(fid2,'%s',s2);
fprintf(fid2,'%4d  %8.4f\r\n',[lamb,irrm]');
fclose(fid2);

% se representa el fichero de irradiancia absoluto calculado
f1=figure;
plot(lamb,irrm);
grid;
xlabel('wavelength (A)'); ylabel('irr');
title(['Lamp ',nlamp,': Irr file']);

% se representa el ratio entre la media calculada y los ficheros de
% irradiancia individuales
rats=[];
for i=1:nfichs
    r{i}=(irr{i}(:,2)-irrm)*100./irrm;
    rats=[rats,r{i}];
end
f2=figure;
plot(lamb,rats,'x');
grid;
xlabel('wavelength (A)'); ylabel('ratio');
title(['Lamp ',nlamp,': Ratio Irr Files vs Irr Mean']);
legend(nomfich,'Location','North'); set(gca,'YLim',[-1 1]);