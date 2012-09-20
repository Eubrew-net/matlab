
function [MAXIMOSH]=ReadFV(filename,fplot)
% Esta función abre los ficheros FV,los lee y devuelve los datos de las
% partes zenital y azimutal por sepadaro, con sus correspondientes
% gráficos.

% OJO con la fecha, fila 65 y 204, cambiar año!!!!!!!!!!!!!!!!!!!!!!!!

% 25/07/2010 Isabel Mejorado. Cambiada la forma en la que separa la parte
%                   azimutal de la zenital, para que abarque Brewers que usan un número
%                   distinto de pasos en el barrido (lineas 116,etc...)
%                   try en la 68 por si solo tiene un scan.

if nargin==1 fplot=0; end



%% ...PASOS PREVIOS.............................................

set(0,'DefaultFigureWindowStyle','docked');
s=fileread(filename);
[mat idx1] = regexp(s, 'Field', 'match', 'start');
[mat idx2] = regexp(s, 'at', 'match', 'start');
[mat idx3] = regexp(s, 'filter', 'match', 'start');
[mat idx4] = regexp(s, 'CY', 'match', 'start');
[mat idx5] = regexp(s, 'SL', 'match', 'start');
l=length(idx1);
%Para ver cuantas repeticiones hay.
size('Field of view Scan started at 08:48:44filter: 0CY 5SL  5 ',2);
% size es 57 =ans.
% OJO!! Al cortar y pegar la parte de texto de la cual
% queremos saber la talla, tener en cuenta que si subimos el texto para
% volverlo morado 3 espacios, tenemos que separarlo los mismos espacios.
b=size(s,2);
% Tenemos el tamaño total del fichero





%% ...DEFINICIONES...........................................

d={};
de={};
Rj=[]; %Para dejar constancia de las j
HH=[]; %Para dejar constancia de las horas
HG=[]; %Para dejar constancia de las horas para las gráficas
TGaz=[]; %Para dejar constancia de la media angulo azimutal
TGze=[]; %Para dejar constancia de la media angulo zenital.
RDFaz=[]; %Para unir parte az
RDFze=[]; %Para unir parte ze
Rjhmtaz=[]; %Para unir hora az
Rjhmtze=[]; %Para unir hora ze
RMazaz =[]; %Para unir las filas del Maz
RMazze =[]; %Para unir las filas del Mze
RPMaz =[]; %Para unir las filas del paso máximo
RPMze =[]; %Para unir las filas del paso máximo
RAPMaz =[]; % Para unir los ángulos del paso máximo
RAPMze =[]; % Para unir los ángulos del paso máximo





%% ...ORDENES..................................................


for   j=1:l-1;
    
    Rj=[Rj;j]; [a b]=fileparts(filename);
    jul=sscanf(b,'%*c%*c%3d%2d%*c%*3d');
    juliano=datenum(2010,1,1)+(jul(1,1))-1;
    h=s((idx2(j))+3:(idx2(j))+10);
    hh=datenum(h)-734139;
    jh=juliano+hh;
    % Nos devuelve una columna de l-1 filas con las j.
    % Leemos el nombre del archivo para tener el dia juliano.
    % Leemos la hora (tenemos un string)
    % Restamos datenum(2010,01,01), xk sale xdefecto
    % Unimos la hora y el día en un solo número.
    
    H=sscanf(h,'%2d%*c%2d%*c%*2d');
    HR= reshape(H,1,2);
    HG=[HG;h];
    HH=[HH;HR];
    HHG=cellstr(HG);
    % Pasamos la hora a número (tenemos 1fila 2columnas;hora y min).
    % Reshape para tener 1fila 2columnas.
    % Unimos las horas de las distintas j como string, para titulo graficos.
    % Unimos las horas de las distintas j como números, para datos finales.
    % Tenemos la hora pero como string, para poderla poner en las gráficas.
    
    data.Field_of_view='Scan';
    data.Started_at =jh;
    data.Filter= s((idx3(j))+8:(idx3(j))+8);
    data.CY=s((idx4(j))+3:(idx4(j))+3);
    data.SL=s((idx5(j))+4:(idx5(j))+4);
    % Leemos los datos correspondientes a cada j.
    % Donde "s" es el sitio de donde le decimos que lea desde x hasta y
    % (x:y). S es un string.
    
    d{j}=s((idx1(j))+57:(idx1(j+1))-1);
    format short g;
    D{j}=sscanf(d{j},'%f%*c%f%*c%f%*c%f%*c%f');
    f{j}=length(D{j});
    g{j}=f{j}/5;
    reshape(D{j},5,g{j});
    DF{j}=ans';
    % Cogemos la parte que nos interesa (es un string)
    % Lo pasamos a números.
    % Vemos el tamaño.
    % Vemos el número de filas (tamaño entre 5).
    % Reshape para forma final.
    % Traspuesta (5columnas, g filas).
    
    nf=find (DF{j}(:,1)==0);
    DF{j}(nf,:)=[];
    DFaz{j}=DF{j};
    c3DFaz{j}=DFaz{j}(:,3);
    Gaz{j}= mean (c3DFaz{j});
    TGaz=[TGaz;Gaz{j}];
    % ....Separamos parte azimutal.
    % Eliminamos las filas de la parte zenital.
    % Renombramos.
    % ....38 filas totales para cada DF
    % ....Los pasos azimutales siempre van entre -160 a 160 (17 filas) y son
    % ....los primeros 17 valores no nulos para cada DF.
    % ....Tendré tantos DFaz como valores de l-1.
    % ....Hacemos la media del ángulo azimutal para cada DF, para poder poner
    % ....el dato en el título del gráfico.
    % Seleccionamos la columna correspondiente (3)
    % Buscamos su traspuesta .
    % Le calculamos la media de los valores.
    
    DF{j}=ans';
    nf=find (DF{j}(:,2)==0);
    DF{j}(nf,:)=[];
    DFze{j}=DF{j};
    c4DFze{j}=DFze{j}(:,4);
    Gze{j}=mean (c4DFze{j});
    TGze=[TGze;Gze{j}];
    % ....Separamos parte zenital.
    % Eliminamos las filas de la parte azimutal.
    % Renombramos.
    % ....38 filas totales para cada DF
    % ....Los pasos zenitales siempre van desde -40 a 40 (21 filas) y son los
    % ....últimos valores para cada DF
    % ....Tendré tantos DFze como valores de l-1.
    % ....Hacemos la media del ángulo zenital para cada DF, para poder poner
    % ....el dato en el título del gráfico.
    % Seleccionamos la columna correspondiente (4)
    % Buscamos su traspuesta .
    % Le calculamos la media de los valores.
    
    naz= size(DFaz{j},1);
    nez= size(DFze{j},1);
    jhmaz=linspace(jh,jh,naz);
    jhmze=linspace(jh,jh,nez);
    jhmtaz=jhmaz';
    jhmtze=jhmze';
    % Creamos un vector de 17/21 elementos, donde el primer y el último
    % ....elemento son jh
    % Calculamos la traspuesta para tenerlo como columna.
    
    RDFaz=[RDFaz;DFaz{j}];
    RDFze=[RDFze;DFze{j}];
    Rjhmtaz=[Rjhmtaz;jhmtaz];
    Rjhmtze=[Rjhmtze;jhmtze];
    Datosaz=[Rjhmtaz RDFaz];
    Datosze=[Rjhmtze RDFze];
    % Unimos los datos de  todas las j (filas bajo filas).
    % Unimos las horas de las j (filas bajo filas)
    % Unimos columnas de datos con horas (columna al lado de columna)
    
    
    
    
    %%...MAXIMOS A PARTIR DE LOS DATOS NUMÉRICOS BRUTOS...................
    
    [Maz,az]=max(DFaz{j}(:,5));
    [Mze,ze]=max(DFze{j}(:,5));
    PMaz=DFaz{j}(az,1);
    PMze=DFze{j}(ze,2);
    APMaz=DFaz{j}(az,3);
    APMze=DFze{j}(ze,4);
    % Hallamos el máximo de intensidad para cada DFaz y DFze y la fila en la que
    % ....está, para ver si corresponde al 0,0. "az/ze" es la posicion del elemento de
    % ....mayor intensidad.
    % Vemos cual es el paso que corresponde al máximo
    % Vemos cual es el ángulo que corresponde al máximo
    
    RMazaz =[RMazaz;jul(1,1),Maz];
    RMazze =[RMazze;Mze];
    RPMaz = [RPMaz;PMaz];
    RPMze = [RPMze;PMze];
    RAPMaz = [RAPMaz;APMaz];
    RAPMze = [RAPMze;APMze];
    % Unimos las filas Maz y Mze.
    % ....En la parte azimutal incluimos una columna con el día juliano.
    % Unimos las filas PMaz y PMze
    % Unimos las filas PMaz y PMze
    
    MAX=[RMazaz RPMaz RAPMaz RMazze RPMze RAPMze];
    % Unimos las columnas.
end


%% ...ULTIMO DATO................................................

for k=l;
    jule=sscanf(filename,'%*c%*c%3d%2d%*c%*3d');
    julianoe=datenum(2010,1,1)+(jule(1,1))-1;
    he=s((idx2(k))+3:(idx2(k))+10);
    He=sscanf(he,'%2d%*c%2d%*c%*2d');
    HeR= reshape(He,1,2);
    hhe=datenum(he)-734139;
    jhe=julianoe+hhe;
    
    data.Field_of_view='Scan';
    data.Started_at =jhe;
    data.Filter= s((idx3(k))+8:(idx3(k))+8);
    data.CY=s((idx4(k))+3:(idx4(k))+3);
    data.SL=s((idx5(k))+4:(idx5(k))+4);
    
    de=s((idx1(k))+57:b);
    format short g;
    De=sscanf(de,'%f%*c%f%*c%f%*c%f%*c%f');
    fe=length(De);
    ge=fe/5;
    reshape(De,5,ge);
    DFe=ans';
    
    nfe=find (DFe(:,1)==0);
    DFe(nfe,:)=[];
    DFeaz=DFe;
    c3DFeaz=DFeaz(:,3);
    Geaz= mean(c3DFeaz);
    
    DFe=ans';
    nfe=find (DFe(:,2)==0);
    DFe(nfe,:)=[];
    DFeze=DFe;
    c4DFeze=DFeze(:,4);
    Geze= mean(c4DFeze);
    
    neaz=size (DFeaz,1);
    neez=size (DFeze,1);
    jhmeaz=linspace(jhe,jhe,neaz);
    jhmeze=linspace(jhe,jhe,neez);
    jhmteaz=jhmeaz';
    jhmteze=jhmeze';
    
    Datoseaz=[jhmteaz DFeaz ];
    Datoseze=[jhmteze DFeze ];
    
    try
        HHM= [HH;HeR];
    catch
        HHm=HeR
    end
    
    
    
    %%...MAXIMOS A PARTIR DE LOS DATOS NUMÉRICOS BRUTOS....................
    
    [Meaz,eaz]=max(DFeaz(:,5));
    [Meze,eze]=max(DFeze(:,5));
    PMeaz=DFeaz(eaz,1);
    PMeze=DFeze(eze,2);
    AMeaz=DFeaz(eaz,3);
    AMeze=DFeze(eze,4);
    
    MAXED = [jule(1,1) Meaz PMeaz AMeaz Meze PMeze AMeze];
    try
        MAXIMOS=[MAX;MAXED];
        % Unión para las j y la k.
    catch
        MAXIMOS= MAXED;
    end
end


   
   
 %% ...DATOS DE SALIDA.....................................................
 
    data2.Column1='Hora';
    data2.Column2='Minutos';
    data2.Column3='Dia juliano';
    data2.Column4='I máxima az';
    data2.Column5='Pasos azimutales';
    data2.Column6='Grados azimut';
    data2.Column7='I maxima ze';
    data2.Column8='Pasos zenitales';
    data2.Column9='Grados zenit';
    
    MAXIMOSH= [HHM MAXIMOS];
   
    

    data3.Column1='Hora y Día';
    data3.Column2='Pasos azimut';
    data3.Column3='Pasos zenit';
    data3.Column4='Grados azimut';
    data3.Column5='Grados zenit';
    data3.Column6='Intensidad';

%     DATOSaz=[Datoseaz;Datosaz];
%     DATOSze=[Datoseze;Datosze];
    % Se unen filas del archivo y la última parte
    
    
    
      
    
    
    
    
    
 %% Gráficos   
    
 if fplot==1
     
     %..GRAFICOS 2D PASOS.................................................
     
     for  y=1:4:(l-1);
         % Creamos los gráficos de 4 en 4, y abrimos una ventana para cada vez.
         figure
         z= [y:1:(y+3)];
         % A partir del valor inicial de y (1,5,9...) le decimos que cree 4
         % gráficos cuyos datos sean los correspondientes para cada valor de y,
         % que corresponderá con el valor de j del principio del fichero.
         
         if z(1,1) <= (l-1)
             a=z(1,1);
             subplot (2,2,1)
             plot(DFaz{1,a}(:,1),DFaz{1,a}(:,5),'g.-',DFze{1,a}(:,2),DFze{1,a}(:,5),'r.-')
             grid
             xlabel('Pasos az/ze')
             ylabel('Intensidad az/ze')
             legend ('azimut','zenit')
             T=[filename HHG(a,1) TGaz(a,1) TGze(a,1)];
             % Para que en el título salgan el nombre del fichero y la hora
             title(T)
         end
         
         if z(1,2)<= (l-1)
             e=z(1,2);
             subplot (2,2,2)
             plot(DFaz{1,e}(:,1),DFaz{1,e}(:,5),'g.-',DFze{1,e}(:,2),DFze{1,e}(:,5),'r.-')
             grid
             xlabel('Pasos az/ze')
             ylabel('Intensidad az/ze')
             T=[filename HHG(e,1) TGaz(e,1) TGze(e,1)];
             title(T)
         end
         
         if z(1,3) <= (l-1)
             m=z(1,3);
             subplot (2,2,3)
             plot(DFaz{1,m}(:,1),DFaz{1,m}(:,5),'g.-',DFze{1,m}(:,2),DFze{1,m}(:,5),'r.-')
             grid
             xlabel('Pasos az/ze')
             ylabel('Intensidad az/ze')
             T=[filename HHG(m,1) TGaz(m,1) TGze(m,1)];
             title(T)
         end
         
         if z(1,4)<= (l-1)
             d=z(1,4);
             subplot (2,2,4)
             plot(DFaz{1,d}(:,1),DFaz{1,d}(:,5),'g.-',DFze{1,d}(:,2),DFze{1,d}(:,5),'r.-')
             grid
             xlabel('Pasos az/ze')
             ylabel('Intensidad az/ze')
             T=[filename HHG(d,1) TGaz(d,1) TGze(d,1)];
             title(T)
         end
     end
     
     figure
     k=l;
     plot(DFeaz(:,1),DFeaz(:,5),'g.-',DFeze(:,2),DFeze(:,5),'r.-')
     grid
     xlabel('Pasos eaz/eze')
     ylabel('Intensidad eaz/eze')
     legend ('azimut','zenit')
     T=[filename he Geaz Geze];
     title(T)
     
     
     
     
     
     
     
     %...GRAFICOS 2D GRADOS.....................................................
     
     for  y=1:4:(l-1);
         % Creamos los gráficos de 4 en 4, y abrimos una ventana para cada vez.
         figure
         z= [y:1:(y+3)];
         % A partir del valor inicial de y (1,5,9...) le decimos que cree 4
         % gráficos cuyos datos sean los correspondientes para cada valor de y,
         % que corresponderá con el valor de j del principio del fichero.
         
         if z(1,1) <= (l-1)
             a=z(1,1);
             subplot (2,2,1)
             plot((DFaz{1,a}(:,3)-DFaz{1,a}(9,3)),DFaz{1,a}(:,5),'g.-',(DFze{1,a}(:,4)-DFze{1,a}(11,4)),DFze{1,a}(:,5),'r.-')
             % Le quitamos a cada valor de la columna grados el valor correpondiente
             %...al paso 0,0 (fila 9 para el azimut, 11 para el zenit).
             grid
             xlabel('Grados az/ze')
             ylabel('Intensidad az/ze')
             legend ('azimut','zenit')
             T=[filename HHG(a,1) TGaz(a,1) TGze(a,1)];
             % Para que en el título salgan el nombre del fichero y la hora
             title(T)
         end
         
         if z(1,2)<= (l-1)
             e=z(1,2);
             subplot (2,2,2)
             plot((DFaz{1,e}(:,3)-DFaz{1,e}(9,3)),DFaz{1,e}(:,5),'g.-',(DFze{1,e}(:,4)-DFze{1,e}(11,4)),DFze{1,e}(:,5),'r.-')
             grid
             xlabel('Grados az/ze')
             ylabel('Intensidad az/ze')
             T=[filename HHG(e,1) TGaz(e,1) TGze(e,1)];
             title(T)
         end
         
         if z(1,3) <= (l-1)
             m=z(1,3);
             subplot (2,2,3)
             plot((DFaz{1,m}(:,3)-DFaz{1,m}(9,3)),DFaz{1,m}(:,5),'g.-',(DFze{1,m}(:,4)-DFze{1,m}(11,4)),DFze{1,m}(:,5),'r.-')
             grid
             xlabel('Grados az/ze')
             ylabel('Intensidad az/ze')
             T=[filename HHG(m,1) TGaz(m,1) TGze(m,1)];
             title(T)
         end
         
         if z(1,4)<= (l-1)
             d=z(1,4);
             subplot (2,2,4)
             plot((DFaz{1,d}(:,3)-DFaz{1,d}(9,3)),DFaz{1,d}(:,5),'g.-',(DFze{1,d}(:,4)-DFze{1,d}(11,4)),DFze{1,d}(:,5),'r.-')
             grid
             xlabel('Grados az/ze')
             ylabel('Intensidad az/ze')
             T=[filename HHG(d,1)  TGaz(d,1)  TGze(d,1)];
             title(T)
         end
     end
     
     figure
     k=l;
     plot((DFeaz(:,3)-DFeaz(9,3)),DFeaz(:,5),'g.-',(DFeze(:,4)-DFeze(11,4)),DFeze(:,5),'r.-')
     grid
     xlabel('Grados eaz/eze')
     ylabel('Intensidad eaz/eze')
     legend ('azimut','zenit')
     T=[filename he Geaz  Geze];
     title(T)
     
 end


