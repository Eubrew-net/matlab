%**************************************************************************

%Programa que calcula la media entre los ficheros QLs elegidos, entre
%fechas concretas, para el cálculo de la respuesta a aplicar al equipo.

%**************************************************************************

clear all

%Variables a modificar en el programa:
dirin='E:\red_brewer\uvbrewer185\resp2005\QL_1000W';  %directorio en el que estan los ficheros QL a usar
dirout='E:\red_brewer\uvbrewer185\resp2005\Resp_Final';  %directorio donde se llevan los resultados
nbr='185'  %numero del Brewer en estudio
fech1='11/05/05';   %fecha inicial en formato dd/mm/yy;
fech2='23/09/05';   %fecha final en formato dd/mm/yy;
fechmal1='30/09/05';    %fecha que no debe ser cogida, en formato dd/mm/yy;
per='1';    %número del período en estudio para salvar las gráficas
fichsal='uvr26605M'; %nombre del fichero en el que se salva la respuesta final
mapacolor=['-xr';'-xb';'-xg';'-xk';'-or';'-ob';'-og';'-ok';'-*r';'-*b';'-*g';'-*k'];

%Se determinan los ficheros a usar para cacular la respuesta
listaresp=dir(fullfile(dirin,strcat('QL*.',nbr)));
nfich=length(listaresp);

%Se leen todos los ficheros QL
dirnow=pwd;
cd(dirin);
for i=1:nfich
    [ql_avg{i},ql_dat{i}]=load_ql_red(listaresp(i).name);
end
cd(dirnow);

close all

%Se crea la matriz que contiene los valores de los ql para cada fecha
for i=1:nfich
    ql_d{i}=[ql_avg{i}.date,ql_avg{i}.qlc'];
end

%Se determinan los valores de los QLs entre las fechas en las que se quiere
%calcular la respuesta
fechini=datenum(fech1,'dd/mm/yy');
fechfin=datenum(fech2,'dd/mm/yy');
fechno1=datenum(fechmal1,'dd/mm/yy');

for i=1:nfich
    [ival{i},jval{i},val{i}]=find(fix(ql_d{i}(:,1))>=fechini & fix(ql_d{i}(:,1))<=fechfin & fix(ql_d{i}(:,1))~=fechno1);
end

%Se calculan los valores medios y la desviación estándar para cada lámpara en la fecha en estudio
ref=0;
for i=1:nfich
    if ~isempty(ival{i})    %para eliminar los que estén vacíos
        ql_mean{i-ref}=([ql_avg{i}.lamda;mean(ql_d{i}(ival{i},2:end),1)])';
        ql_dev{i-ref}=([ql_avg{i}.lamda;std(ql_d{i}(ival{i},2:end),0,1)])';
        ql_pct{i-ref}=[ql_avg{i}.lamda',100*ql_dev{i}(:,2)./ql_mean{i}(:,2)];
        puntop=findstr(listaresp(i).name,'.');
        nlamp{i-ref}=listaresp(i).name(puntop-4:puntop-1);
    else
        ref=ref+1;
    end
end
nfich=nfich-ref;

for i=1:nfich
    %Se representan gráficamente la media de cada lámpara con su desviación
    figure;
    ax=errorbar(ql_mean{i}(:,1),ql_mean{i}(:,2),ql_dev{i}(:,2),'o');
    xlabel('Wavelength (A)')
    ylabel('Resp (counts/W*m^2)')
    title(['Brewer ',nbr,': Lamp ',nlamp{i},' mean response (',fech1,' to ',fech2,')'])
    grid
    figure;
    h=plotyy(ql_mean{i}(:,1),ql_mean{i}(:,2),ql_mean{i}(:,1),ql_dev{i}(:,2));
    title(['Brewer ',nbr,': Lamp ',nlamp{i},' mean response (',fech1,' to ',fech2,')'])
    xlabel('Wavelength (A)');
    set(get(h(1),'Ylabel'),'String','Resp (counts/W*m^2)');
    set(get(h(2),'Ylabel'),'String','Standard Deviation (counts/W*m^2)');
    grid;
    figure;
    plot(ql_pct{i}(:,1),ql_pct{i}(:,2));
    xlabel('Wavelength (A)')
    ylabel('Standard Deviation (pct)')
    title(['Brewer ',nbr,': Lamp ',nlamp{i},' standard deviation (',fech1,' to ',fech2,')'])
    grid
end

%Se representan gráficamente todas las medias de cada lámpara:
figure;
%set(gcf,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1],'DefaultAxesLineStyleOrder','x-|o-|*-')
for i=1:nfich
    plot(ql_mean{i}(:,1),ql_mean{i}(:,2),mapacolor(i,:));
    hold on;
end
xlabel('Wavelength (A)');
ylabel('Resp (counts/W*m^2)');
title(['Brewer ',nbr,': Mean responses (',fech1,' to ',fech2,')']);
grid;
legend(nlamp,'Location','NorthEastOutside');
hold off;

%Se determinan las longitudes de onda comunes a todas las lámparas
lamb=ql_mean{1}(:,1);
for i=2:nfich
    [lamb,l1,l2]=intersect(lamb,ql_mean{i}(:,1));
end
meantot=[];
for i=1:nfich
    [lamb,l1,l2]=intersect(lamb,ql_mean{i}(:,1));
    meantot=[meantot,ql_mean{i}(l1,2)];
end

%Se calcula el valor de la respuesta final usando todas las lámparas:
ql_meant=[lamb,mean(meantot,2)];
ql_devt=[lamb,std(meantot,0,2)];
ql_pctt=[lamb,100*ql_devt(:,2)./ql_meant(:,2)];

%Se representan gráficamente la respuesta final con su desviación
figure;
ax=errorbar(ql_meant(:,1),ql_meant(:,2),ql_devt(:,2),'o');
xlabel('Wavelength (A)')
ylabel('Resp (counts/W*m^2)')
title(['Brewer ',nbr,': Mean response (',fech1,' to ',fech2,')'])
grid
figure;
h=plotyy(ql_meant(:,1),ql_meant(:,2),ql_meant(:,1),ql_devt(:,2));
title(['Brewer ',nbr,': Mean response (',fech1,' to ',fech2,')'])
xlabel('Wavelength (A)');
set(get(h(1),'Ylabel'),'String','Resp (counts/W*m^2)');
set(get(h(2),'Ylabel'),'String','Standard Deviation (counts/W*m^2)');
grid;
nfig=figure;
plot(ql_pctt(:,1),ql_pctt(:,2));
xlabel('Wavelength (A)');
ylabel('Standard Deviation (pct)');
title(['Brewer ',nbr,': Standard deviation (',fech1,' to ',fech2,')'])
grid;

%Se lleva a un fichero el valor de la respuesta promedio de las lámparas de
%1000 W:
save(fullfile(dirout,strcat(fichsal,'.',nbr)),'ql_meant','-ascii');

%Se guardan las gráficas en formato PostScript:
nomcom1=['MediasQL1000Br',nbr,'p',per];
print(1,'-dpsc',fullfile(dirout,nomcom1));
for i=2:nfig
    print(i,'-dpsc',fullfile(dirout,nomcom1),'-append');
end

%Se salvan las figuras creadas:
nomcom2=[nomcom1,'_'];
for i=1:nfig
    saveas(i,fullfile(dirout,[nomcom2,num2str(i),'.fig']));
end

%Se salvan las variables creadas:
save(fullfile(dirout,nomcom1));

close all

disp('fin de la ejecución de calc_med_lamps')



