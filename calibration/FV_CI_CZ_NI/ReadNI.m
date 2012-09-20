
function [DataNumRFHCS TNumTotal]= ReadNI(filename)
% Esta función abre los ficheros NI y los lee.
% Tenemos "x" matrices de 11 columnas y "x" datos de T .
% Nos devuelve tantos DataNumRFH y TNumTotal como repeticiones hayan.

data3.Column1='F+H Matlab';
data3.Column2='Wavelength (Ang)';
data3.Column3='Step number';
data3.Column4='CS SMPosition 0';
data3.Column5='CS SMPosition 1';
data3.Column6='CS SMPosition 2';
data3.Column7='CS SMPosition 3';
data3.Column8='CS SMPosition 4';
data3.Column9='CS SMPosition 5';
data3.Column10='CS SMPosition 6';
data3.Column11='CS SMPosition 7';





%% ....PASOS PREVIOS.............................................

s=fileread(filename);
[mat idx1] = regexp(s, 'NI scan start time = ', 'match', 'start');
[mat idx2] = regexp(s, 'Dark Count =', 'match', 'start');
[mat idx3] = regexp(s, 'pos 0=>7', 'match', 'start');
[mat idx4] = regexp(s, 'NI scan finished at ', 'match', 'start');
[mat idx5] = regexp(s, 'end', 'match', 'start');
[mat idx6] = regexp(s, 'dh', 'match', 'start');
[mat idx7] = regexp(s, 'Number of Cycles Used -------------  ', 'match', 'start');
[mat idx8] = regexp(s, 'pr', 'match', 'start');
% Localizamos las palabras/frases de interés.

a= size('NI scan start time =',2);
b= size('Dark Count =',2);
c= size('pos 0=>7',2);
e= size('NI scan finished at ',2);
g= size('dh 02 03 08 Izana  28.3081  16.4992  ',2);
l= size('Number of Cycles Used -------------  ',2);
% Las medimos, por si lo que se quiere es localizar la parte que va a
% ....continuación.

f=length(idx1);
% Para ver cuantas repeticiones hay.




%% ....DEFINICIONES...........................................

DarkCount={};
DataNum={};% Para hacerlo dependiente de la variable j.
DataNumR={};
DataNumRFH={};
T={};
TNum={};
RCSMP7={};
Comprobacion={};
Ciclos={}; % Para hacerlo dependiente de la variable j.
CY={}; % Para hacerlo dependiente de la variable j.
CS={};
DataNumRFHCS={};
Error={};
ErrorP={};

DataNumRFHCSTotalC=[]; %Para unir todas las DataNumRFH {j} en columnas
DataNumRFHCSTotalF=[]; %Para unir todas las DataNumRFH {j} en filas
DarkCountT=[]; % Para unir todas las cuentas
TNumTotal=[]; % Para unir todas las temperaturas
ErrorPT=[];




%% ....FECHA.....................................

Dia= s((idx6(1))+3:(idx6(1))+5);
Mes= s((idx6(1))+6:(idx6(1))+8);
Ano= s((idx6(1))+9:(idx6(1))+10);
format short
Dian= sscanf(Dia,'%d');
Mesn= sscanf(Mes,'%d');
Anon= sscanf(Ano,'%d') +2000;
VFecha = [Anon Mesn Dian];
F= datenum (VFecha);
% Leemos la parte del string donde estan el día, mes y año.
% Los pasamos a número.
% Creamos un vector con ellos.
% Lo convertimos en número matlab.





%% ...ORDENES..................................................

%...MATRIZ DataNumR{j}...................................................
for   j=1:f;
    DarkCount{j} = s((idx2(j))+b:(idx2(j))+(b+6));
    DarkCountT=[DarkCountT;DarkCount{j}];
    % Localizamos datos de interés
    % Unimos los datos de cuentas

    d{j}=s((idx3(j))+(c+4):(idx4(j))-1);
    DataNum{j}=sscanf(d{j},'%f%*c%f%*c%d%*c%f%*c%f%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d');
    h{j}=length(DataNum{j});
    i{j}=h{j}/13;
    reshape(DataNum{j},13,i{j});
    format bank
    DataNumR{j}=ans';
    % Cogemos la parte del archivo que nos interesa.
    % ....data es una celda, donde cada puesto corresponde al string
    % ....correspondiente al valor de j.
    % Pasamos el string a números.
    % Vemos cuantos datos contiene
    % Los dividimos entre las 5 columnas, para obtener el número de filas.
    % Reshape para tener cada dato en una fila
    % Transformamos DataNum en una matriz de 13 columnas e i filas.



    %...FECHA-HORA/UNIÓN CON MATRIZ DataNumR{j}...................................
    H{j}=DataNumR{j}(:,1)/(24*60);
    FH{j}=F+H{j};
    DataNumRFH{j}=[FH{j} DataNumR{j}(:,2) DataNumR{j}(:,3) DataNumR{j}(:,4) DataNumR{j}(:,5) DataNumR{j}(:,6) DataNumR{j}(:,7) DataNumR{j}(:,8) DataNumR{j}(:,9) DataNumR{j}(:,10) DataNumR{j}(:,11) DataNumR{j}(:,12) DataNumR{j}(:,13)];
    % Tenemos un valor de hora matlab
    % Creamos nuestra columna Fecha+Hora
    % Creamos nuestra salida de datos (matriz 13 columnas, en la que la primera,
    %...que era hora GMT ahora es FH)

    data3.Column1='F+H Matlab';
    data3.Column2='Wavelength (Ang)';
    data3.Column3='Step number';
    data3.Column4='Raw Counts SMP2';
    data3.Column5='Counts/Second SMP2';
    data3.Column6='RC SMPosition 0';
    data3.Column7='RC SMPosition 1';
    data3.Column8='RC SMPosition 2';
    data3.Column9='RC SMPosition 3';
    data3.Column10='RC SMPosition 4';
    data3.Column11='RC SMPosition 5';
    data3.Column12='RC SMPosition 6';
    data3.Column13='RC SMPosition 7';


    
    
    %...TEMPERATURA...................................................
  %  T{j}= s((idx6(j))+g:(idx3(j))+(7+g));
   % TNum{j}= sscanf(T{j},'%8f');
   % TNumTotal=[TNumTotal TNum{j}];
        T{j}= s((idx8(j))-10:(idx8(j))-1);
        TNum{j}= sscanf(T{j},'%8f');
        TNumTotal=[TNumTotal TNum{j}(end,:)];
    % Localizamos datos de interés.
    % Los pasamos a número.
    % Los unimos , tenemos una fila de temperaturas. Cada T asociada a
    % ...una repetición j.



    %...CUENTAS/SEGUNDO...................................................

    for ii=6:13
        DK{j}=sscanf(DarkCount{j},'%f');
        Ciclos{j}= s((idx7(j))+l:(idx7(j))+(l+2));
        CY{j}= sscanf(Ciclos{j},'%f');
        IT= 0.1147;
        CS{ii}= 2*(DataNumR{j}(:,ii)-DK{j})/(CY{j}*IT);
        % Tenemos el Dark count, pero está como string.
        % Se pasa a valor numérico.
        % Se define el número de ciclos.
        % Se define el tiempo de integración
        % Definimos nuestro valor de C/S (CS{j}) a partir de la expresión
        % ...2x(Fi-Fdk)/CYxIT.
    end

    DataNumRFHCS{j}=[FH{j} DataNumR{j}(:,2) DataNumR{j}(:,3)  CS{6} CS{7} CS{8} CS{9} CS{10} CS{11} CS{12} CS{13}];
    %Redefinimos nuestra matriz sustituyendo las cuentas Brutas por
    %...Cuentas por segundo.

    data3.Column1='F+H Matlab';
    data3.Column2='Wavelength (Ang)';
    data3.Column3='Step number';
    data3.Column4='CS SMPosition 0';
    data3.Column5='CS SMPosition 1';
    data3.Column6='CS SMPosition 2';
    data3.Column7='CS SMPosition 3';
    data3.Column8='CS SMPosition 4';
    data3.Column9='CS SMPosition 5';
    data3.Column10='CS SMPosition 6';
    data3.Column11='CS SMPosition 7';



    %...RC SMP7= RC SMP3 + RC SMP5.......................................

    RCSMP7{j}= DataNumRFHCS{j}(:,7) + DataNumRFHCS{j}(:,9);
    Error{j}=  DataNumRFHCS{j}(:,11) - RCSMP7{j} ;
    ErrorP{j}=(Error{j}./ DataNumRFHCS{j}(:,11))*100;
    Comprobacion{j}= [ DataNumRFHCS{j}(:,2)  DataNumRFHCS{j}(:,11) RCSMP7{j}  ErrorP{j}];








    %...UNIÓN DataNumRFH{j} CON DataNumRFH{j}...................................................
    %     DataNumRFHCSTotalC=[DataNumRFHCSTotalC DataNumRFHCS{j}];
    % Unimos todos los datos por columnas, así la longitud de onda es la
    % ...misma,lo que cambia es la columna tiempo.
    DataNumRFHCSTotalF=[DataNumRFHCSTotalF;DataNumRFHCS{j}];
    % Lo hacemos por filas también, para que sea más cómodo a la hora de
    % ...la representación gráfica.

%     ErrorPT=[ErrorPT ErrorP{j}];
    % Unimos los errores por columnas, para poderlos representar frente a
    % ...la longitud de onda.
end







%% ...DATOS DE SALIDA.....................................................

data2.Column='Dark ';
DarkCountCell=cellstr(DarkCount);
% Obtenemos una columna con f datos en string

    data3.Column1='F+H Matlab';
    data3.Column2='Wavelength (Ang)';
    data3.Column3='Step number';
    data3.Column4='CS SMPosition 0';
    data3.Column5='CS SMPosition 1';
    data3.Column6='CS SMPosition 2';
    data3.Column7='CS SMPosition 3';
    data3.Column8='CS SMPosition 4';
    data3.Column9='CS SMPosition 5';
    data3.Column10='CS SMPosition 6';
    data3.Column11='CS SMPosition 7';

%DataNumRFH{j}
%TNumTotal




%...GRAFICOS 2D.....................................................

%      set(0,'DefaultFigureWindowStyle','docked');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,6),'r*');
%      xlabel('Longitud onda (ang)');
%      ylabel('CS SMP');
%      grid;
%      title(filename) ;
%      hold on
%
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,7),'g*');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,8),'b*');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,9),'c*');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,10),'m*');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,11),'y*');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,12),'k*');
%      plot(DataNumRFHCSTotalF(:,2),DataNumRFHCSTotalF(:,13),'rv');
%      legend('SMP_0','SMP_1','SMP_2','SMP_3','SMP_4','SMP_5','SMP_6','SMP_7',2);
%      hold off


%..ErrorP....................................................

%      figure
%      plot(DataNumRFHCS{1}(:,2),ErrorPT,'rv');
%      xlabel('Longitud onda (ang)');
%      ylabel('Error %');
%      grid;
%      title(filename);


% Ploteamos las cuentas por segundo (c5)
% ....frente a la longitud de onda para las diferentes slit positions.






