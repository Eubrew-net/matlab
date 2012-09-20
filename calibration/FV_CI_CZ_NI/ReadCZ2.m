
function [GRT FH]= ReadCZ2(filename)
% Esta función abre los ficheros CZ, calculando las Cuentas/s a partir de
% las cuentas brutas (expresión que aparece en la página 111 del manual del operador)




%% PASOS PREVIOS.............................................

set(0,'DefaultFigureWindowStyle','docked');
s=fileread(filename);
[mat idx1] = regexp(s, 'CZ scan start time = ', 'match', 'start');
[mat idx2] = regexp(s, 'Dark Count =  ', 'match', 'start');
[mat idx3] = regexp(s, 'Counts/Second', 'match', 'start');
[mat idx4] = regexp(s, 'CZ scan finished at ', 'match', 'start');
[mat idx5] = regexp(s, 'end', 'match', 'start');
[mat idx6] = regexp(s, 'Number of Cycles Used -------------  ', 'match', 'start');
[mat idx7] = regexp(s, 'Internal ', 'match', 'start');
[mat idx8] = regexp(s, 'dh', 'match', 'start');
% Localizamos las palabras/frases de interés.

a= size('CZ scan start time = ',2);
b= size('Dark Count =  ',2);
c= size('Counts/Second ',2);
d= size('CZ scan finished at ',2);
e= size('end',2);
l= size('Number of Cycles Used -------------  ',2);
m= size('Internal ',2);
n= size('standard lamp',2);
% Las medimos, por si lo que se quiere es localizar la parte que va a
% ....continuación.
f=length(idx1);
% Para ver cuantas repeticiones hay.






%% DEFINICIONES...........................................

FH={}; % Para hacerlo dependiente de la variable j.
H={}; % Para hacerlo dependiente de la variable j.
GRT={}; % Para hacerlo dependiente de la variable j.
GR={}; % Para hacerlo dependiente de la variable j.
CS={}; % Para hacerlo dependiente de la variable j.
C={}; % Para hacerlo dependiente de la variable j.
Ciclos={}; % Para hacerlo dependiente de la variable j.
CY={}; % Para hacerlo dependiente de la variable j.
data.Dark_Count={}; % Para hacerlo dependiente de la variable j.
DK={}; % Para hacerlo dependiente de la variable j.
DS=[]; % Para unir todas las horas de inicio
DF=[]; % Para unir todas las horas de fin
DC=[]; % Para unir todas las cuentas
GRTU=[];





%% FECHA............

%Fecha=sscanf(filename,'%*2c%5d%*c%*3d');
Dia= s((idx8(1))+3:(idx8(1))+5);
Mes= s((idx8(1))+6:(idx8(1))+8);
Ano= s((idx8(1))+9:(idx8(1))+10);
format short
Dian= sscanf(Dia,'%d');
Mesn= sscanf(Mes,'%d');
Anon= sscanf(Ano,'%d') +2000;
VFecha = [Anon Mesn Dian];
F =datenum (VFecha);
% Leemos la parte del string donde estan el día, mes y año.
% Los pasamos a número.
% Creamos un vector con ellos.






%% ORDENES..................................................

for   j=1:f;
    data.Started_at =s((idx1(j))+a:(idx1(j))+(a+7));
    data.Finished_at =s((idx4(j))+d:(idx4(j))+(d+7));
    data.Dark_Count{j} =s((idx2(j))+b:(idx2(j))+(b+4));
    DS=[DS;data.Started_at];
    DF=[DF;data.Finished_at];
    DC=[DC;data.Dark_Count{j}];
    % Localizamos datos de interés
    % ....7 es la size de 00:00:00
    % Unimos los datos de horas de comienzo
    % Unimos los datos de horas de fin
    % Unimos los datos de cuentas


    dat{j}=s((idx3(j))+c:(idx4(j))-1);
    DataNum{j}=sscanf(dat{j},'%f%*c%f%*c%d%*c%f%*c%*s');
    h{j}=length(DataNum{j});
    i{j}=h{j}/4;
    reshape(DataNum{j},4,i{j});
    format bank
    DataNumR{j}=ans';
    % Cogemos la parte del archivo que nos interesa (Todo menos la columna de las C/S, xlo del %)
    % ....g es una celda, donde cada puesto corresponde al string
    % ....correspondiente al valor de j.
    % Pasamos el string a números.
    % Vemos cuantos datos contiene
    % Los dividimos entre las 4 columnas, para obtener el número de filas.
    % Reshape para tener cada dato en una fila
    % Transformamos DataNum en una matriz de 4 columnas e i filas.


    DK{j}=sscanf(data.Dark_Count{j} ,'%f');
    Ciclos{j}= s((idx6(j))+l:(idx6(j))+(l+2));
    CY{j}= sscanf(Ciclos{j},'%f');
    IT= 0.1147;
    CS{j}= 2* (DataNumR{j}(:,4)-DK{j})/ (CY{j}*IT);
    % Tenemos el Dark count, pero está como string.
    % Se pasa a valor numérico.
    % Se define el número de ciclos.
    % Se define el tiempo de integración
    % Definimos nuestro valor de C/S (CS{j}) a partir de la expresión
    % ...2x(Fi-Fdk)/CYxIT.

    H{j}=DataNumR{j}(1,1)/(24*60);
    FH{j}=F+H{j};
    % Tenemos un valor de fecha matlab

    GRT{j}= [DataNumR{j} CS{j}];
    GRTU=[GRTU;GRT{j}];
    % GRTU4= [ GRTU(:,2) GRTU(:,3) GRTU(:,4) GRTU(:,5) ];
    % Tenemos nuestra matriz GRT de 5 columnas.
    % Unimos todos los datos generados.
    % Le quitamos la primera columna al dato se salida (tiempo), para que no sea
    % ...engañoso.

end






%% DATOS DE SALIDA.....................................................

Scan_of =s((idx7(j))+m:(idx7(j))+(m+n));
data2.Column1='Scan start time';
data2.Column2='Scan finish time';
data2.Column3='Dark count';

DSC=cellstr(DS);
DFC=cellstr(DF);
DCC=cellstr(DC);
DataSFC=[DSC DFC DCC];
% Obtenemos una columna con f datos en string
% Unimos las columnas, correspondientes a cada j.

data3.Column1='Time (GTM)';
data3.Column2='Wavelength (Ang)';
data3.Column3='Step number';
data3.Column4='Raw Counts';
data3.Column5='Counts/Second';
GRTF4=GRTU;

% Para que sea el dato de salida (lo tenemos dentro del bucle para que funcione)




%% GRAFICOS 2D.....................................................

% set(0,'DefaultFigureWindowStyle','docked');
% % 
% plot(GRTU(:,2),GRTU(:,5),'r.-');
% grid;
% xlabel('Longitud onda (ang)');
% ylabel('Cuentas/Segundo');

% 
% Ploteamos las cuentas por segundo (c5)
% ....frente a la longitud de onda.
% Para las distintas repeticiones.


fid=fclose('all');
end

