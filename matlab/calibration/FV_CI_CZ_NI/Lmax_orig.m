
function [MPMCMDM1T MPMCMDM2T MPMCMDM3T AnchoBanda1 AnchoBanda2 AnchoBanda3]= Lmax(spec,FH)

% Esta función abre los ficheros CZ, localiza sus tres máximos (aunque el primero solo
%...es de usos interno) y devuelve la longitud de onda a la que se producen
%...(por el método de las pendientes y por el del centro de masas).


% 22/07/2010 Isabel modificado para que el resultado salga como error
%                   relativo y no solo como diferencia absoluta.
% 24/07/2010 Isabel modificado para que el resultado salga como diferencia absoluta.
% 27/07/2010 Isabel modificado para obtener el ancho de banda.
% 20/10/2010 Isabel modificado para obtener el ancho de banda de las 3
%                   longitudes de onda posibles.
% 
%%
MPMCMDM1T=[]; % Para unir los máximos de la primera longitud.
MPMCMDM2T=[]; % Para unir los máximos de la segunda longitud.
MPMCMDM3T=[]; % Para unir los máximos de la tercera longitud.
AnchoBanda1=[];
AnchoBanda2=[];
AnchoBanda3=[];

%% 

t=size (spec,2);
for   j=1:t;
    
    %%....SELECCIONAR GRUPOS DE DATOS.......................................
    
    l1= 2967;
    l2= 3020;  % (3022)Solo a nivel informativo del centro.
    l3= 3341;
    
    data2.Columna1='Fecha+Hora';
    data2.Columna2='Longitud real';
    data2.Columna3='Longitud método pendientes';
    data2.Columna4='Diferencia Real/MP';
    data2.Columna5='Longitud método centro masas';
    data2.Columna6='Diferencia Real/MCM';
    data2.Columna7='Intensidad Lmax';
    
    
    %% FIRST WAVELENGTH
    
    find(spec{:,j}(:,2)==2967);
    lm1= find(spec{:,j}(:,2)==2967);
    % Le decimos que encuentre la longitud de onda que nos interesa.
    % Le asignamos el nombre de lm1.
    
    if ~isempty(lm1)
        lmt1=lm1-30:lm1+30;
        lmtr1=reshape(lmt1,61,1);
        d1=spec{:,j}(lmtr1(1,1):lmtr1(61,1),1:5);
        % Le damos los valores de las longitudes de onda en las que sabemos que más
        % ...o menos van a estar los máximos (Sin tener en cuenta el doblete de la línea 3120)
        % Encontramos el número de filas donde se halla el valor numérico de
        % ...lambda
        % Definimos nuestro campo de trabajo con la longitud de onda central, 10
        % ...más y 10 menos.
        % Pasamos a tener una columna
        % Buscamos los valores de lambda y cuentas/segundo que corresponden a
        % ...las filas de la columna.
        
        
        
        %%....MÉTODO DE LAS PENDIENTES...........................................
        
        minCS=min(spec{:,j}(:,5));
        % Minimo valor de todo el espectro (ruido de fondo)
        [a,i]=max(d1(:,5));
        lc1=d1(i,2);
        % Máximo de Cuentas/ segundos del dato real.
        % Longitud de corte asociada a este máximo.
        r1=max(d1(:,5))- minCS;
        pm1=(max(d1(:,5)))/2;
        h1=r1-r1*2/10;
        s1=r1*2/10;
        % Intervalo de Cuentas/segundo (eje vertical)
        % Obtengo el valor de la mitad.
        % Le quito un 20% por la parte superior.
        % Le quito un 20% por la parte inferior.
        % Ya tengo mis límites h y s, entre los cuales cogeré los puntos que
        % darán lugar a las rectas.
        d12080=d1(find(d1(:,5)>s1 & d1(:,5)<h1),:);
        d12080_up=d12080(find(d12080(:,2)<lc1),:);
        d12080_dw=d12080(find(d12080(:,2)>lc1),:);
        % Buscamos los valores de CS que cumplen las condiciones dadas (entre el 20 y el 80%)
        % Separamos los puntos a la derecha y a la izquiera de la lambda máxima
        % ...no real. Tenemos los puntos para las rectas.
        
        p_up1=polyfit(d12080_up(:,2),d12080_up(:,5),1);
        p_dw1=polyfit(d12080_dw(:,2),d12080_dw(:,5),1);
        xc1=-(p_up1(2)-p_dw1(2))/(p_up1(1)-p_dw1(1));
        yc1=polyval(p_up1,xc1);
        % Ajustamos los datos a una recta.
        % Buscamos la intersección (lambda del máximo).
        % Vemos el valor de C/S asociado.
        ..................................................................
        
%         yc1anchob= yc1/2;
%         xc1anchobup= (yc1anchob- p_up1(1,2))/p_up1(1,1);
%         xc1anchobdw= (yc1anchob- p_dw1(1,2))/p_dw1(1,1);
%         AnchoB2= xc1anchobdw-xc1anchobup ;
%         plot (spec{:,j}(:,2),spec{:,j}(:,5));
%         hold on;
%         vline ([xc1anchobup xc1anchobdw],{'r','r'});
%         hold off
%         
        spec{:,j}(:,5)= spec{:,j}(:,5)/a;
        xc1anchobup= (0.5- p_up1(1,2))/p_up1(1,1);
        xc1anchobdw= (0.5- p_dw1(1,2))/p_dw1(1,1);
        AnchoB1= (xc1anchobdw-xc1anchobup)/2;
%         figure
        %spec{:}(:,5)= spec{:}(:,5)*a;
        %plot (spec{:}(:,2), spec{:}(:,5));
             
        % Dividimos todos los valores de CS por el máximo para normalizarlos.
        % para el valor de y=0,5 calculamos el Ancho de Banda.
        % Buscamos los valores de x asociados al valor de y y los restamos.
    
      
        
        
        
        %%....MÉTODO DEL CENTRO DE MASAS...........................................
        
        xc1cm=trapz(d1(:,2),d1(:,2).*d1(:,5))/trapz(d1(:,2),d1(:,5));
        
        
        %%....DIFERENCIA ENTRE AMBOS MÉTODOS...............
        
        LR1= 2967.283;
        DMP1= xc1-LR1;
        DMCM1= xc1cm-LR1;
        % DMP1= ((xc1-LR1)/LR1)*100;
        % DMCM1= ((xc1cm-LR1)/LR1)*100;
        % Longitud real.
        % Error Real-Metodo pendientes.
        % Error Real-Metodo centro masas.
        
%         Fecha=sscanf(filename,'%*2c%5d%*c%*3d');
        MPMCMDM1= [FH{j} LR1 xc1 DMP1 xc1cm DMCM1 a ];
        MPMCMDM1T=[MPMCMDM1T;MPMCMDM1];
        AnchoBanda1=[AnchoBanda1;AnchoB1];
        % Creamos la matriz con los datos que nos interesan (Fecha+hora,longitud real,
        %...longitud con método pendientes, diferenciacon real, longitud método centro masas,
        %...diferencia con real, intensidad en la longitud de onda)
    end
    
    
    
    
    
    %% SECOND WAVELENGTH
    
    find(spec{:,j}(:,2)==3022);
    lm2= find(spec{:,j}(:,2)==3022);
    
    if ~isempty(lm2)
        lmt2=lm2-30:lm2+30;
        lmtr2=reshape(lmt2,61,1);
        d2=spec{:,j}(lmtr2(1,1):lmtr2(61,1),1:5);
        % Le damos los valores de las longitudes de onda en las que sabemos que más
        % ...o menos van a estar los máximos (Sin tener en cuenta el doblete de la línea 3120)
        % Encontramos el número de filas donde se halla el valor numérico de
        % ...lambda
        % Definimos nuestro campo de trabajo con la longitud de onda central, 25
        % ...más y 25 menos.
        % Pasamos a tener una columna
        % Buscamos los valores de lambda y cuentas/segundo que corresponden a
        % ...las filas de la columna.
        
        
        %%....MÉTODO DE LAS PENDIENTES...........................................
        
        minCS=min(spec{:,j}(:,5));
        % Minimo valor de todo el espectro (ruido de fondo)
        [a,i]=max(d2(:,5));
        lc2=d2(i,2);
        % Máximo de Cuentas/ segundos del dato real.
        % Longitud de corte asociada a este máximo.
        r2=max(d2(:,5))- minCS;
        pm2=(max(d2(:,5)))/2;
        h2=r2-r2*2/10;
        s2=r2*2/10;
        % Intervalo de Cuentas/segundo (eje vertical)
        % Obtengo el valor de la mitad.
        % Le quito un 20% por la parte superior.
        % Le quito un 20% por la parte inferior.
        % Ya tengo mis límites h y s, entre los cuales cogeré los puntos que
        % darán lugar a las rectas.
        d22080=d2(find(d2(:,5)>s2 & d2(:,5)<h2),:);
        d22080_up=d22080(find(d22080(:,2)<lc2),:);
        d22080_dw=d22080(find(d22080(:,2)>lc2),:);
        % Buscamos los valores de CS que cumplen las condiciones dadas (entre el 20 y el 80%)
        % Separamos los puntos a la derecha y a la izquiera de la lambda máxima
        % ...no real. Tenemos los puntos para las rectas.
        
        p_up2=polyfit(d22080_up(:,2),d22080_up(:,5),1);
        p_dw2=polyfit(d22080_dw(:,2),d22080_dw(:,5),1);
        xc2=-(p_up2(2)-p_dw2(2))/(p_up2(1)-p_dw2(1));
        yc2=polyval(p_up2,xc2);
        % Ajustamos los datos a una recta.
        % Buscamos la intersección (lambda del máximo).
        % Vemos el valor de C/S asociado.
        
...........................................................................        
        spec{:,j}(:,5)= spec{:,j}(:,5)/a;
        xc2anchobup= (0.5- p_up2(1,2))/p_up2(1,1);
        xc2anchobdw= (0.5- p_dw2(1,2))/p_dw2(1,1);
        AnchoB2= (xc2anchobdw-xc2anchobup)/2;
%         figure
        %spec{:}(:,5)= spec{:}(:,5)*a;
        %plot (spec{:}(:,2), spec{:}(:,5));
             
        % Dividimos todos los valores de CS por el máximo para normalizarlos.
        % para el valor de y=0,5 calculamos el Ancho de Banda.
        % Buscamos los valores de x asociados al valor de y y los restamos.      
        
        
        
        
        %%....MÉTODO DEL CENTRO DE MASAS...........................................
        
        xc2cm=trapz(d2(:,2),d2(:,2).*d2(:,5))/trapz(d2(:,2),d2(:,5));
        
        
        
        %%....DIFERENCIA ENTRE AMBOS MÉTODOS...............
        
        LR2= 3021.504;
        DMP2= xc2-LR2;
        DMCM2=xc2cm-LR2;
        % DMP2= ((xc2-LR2)/LR2)*100;
        % DMCM2=((xc2cm-LR2)/LR2)*100;
        
%         Fecha=sscanf(filename,'%*2c%5d%*c%*3d');
        MPMCMDM2= [FH{j} LR2 xc2 DMP2 xc2cm DMCM2 a];
        MPMCMDM2T=[MPMCMDM2T;MPMCMDM2];
        AnchoBanda2=[AnchoBanda2;AnchoB2];
    end
    
    
    %% THIRD WAVELENGTH
    
    
    find(spec{:,j}(:,2)==3341);
    lm3= find(spec{:,j}(:,2)==3341);
    
    if ~isempty(lm3)
        lmt3=lm3-30:lm3+30;
        lmtr3=reshape(lmt3,61,1);
        d3=spec{:,j}(lmtr3(1,1):lmtr3(61,1),1:5);
        % Le damos los valores de las longitudes de onda en las que sabemos que más
        % ...o menos van a estar los máximos (Sin tener en cuenta el doblete de la línea 3120)
        % Encontramos el número de filas donde se halla el valor numérico de
        % ...lambda
        % Definimos nuestro campo de trabajo con la longitud de onda central, 10
        % ...más y 10 menos.
        % Pasamos a tener una columna
        % Buscamos los valores de lambda y cuentas/segundo que corresponden a
        % ...las filas de la columna.
        
        
        %%....MÉTODO DE LAS PENDIENTES...........................................
        
        minCS=min(spec{:,j}(:,5));
        % Minimo valor de todo el espectro (ruido de fondo)
        [a,i]=max(d3(:,5));
        lc3=d3(i,2);
        % Máximo de Cuentas/ segundos del dato real.
        % Longitud de corte asociada a este máximo.
        r3=max(d3(:,5))- minCS;
        pm3=(max(d3(:,5)))/2;
        h3=r3-r3*2/10;
        s3=r3*2/10;
        % Intervalo de Cuentas/segundo (eje vertical)
        % Obtengo el valor de la mitad.
        % Le quito un 20% por la parte superior.
        % Le quito un 20% por la parte inferior.
        % Ya tengo mis límites h y s, entre los cuales cogeré los puntos que
        % darán lugar a las rectas.
        d32080=d3(find(d3(:,5)>s3 & d3(:,5)<h3),:);
        d32080_up=d32080(find(d32080(:,2)<lc3),:);
        d32080_dw=d32080(find(d32080(:,2)>lc3),:);
        % Buscamos los valores de CS que cumplen las condiciones dadas (entre el 20 y el 80%)
        % Separamos los puntos a la derecha y a la izquiera de la lambda máxima
        % ...no real. Tenemos los puntos para las rectas.
        
        p_up3=polyfit(d32080_up(:,2),d32080_up(:,5),1);
        p_dw3=polyfit(d32080_dw(:,2),d32080_dw(:,5),1);
        xc3=-(p_up3(2)-p_dw3(2))/(p_up3(1)-p_dw3(1));
        yc3=polyval(p_up3,xc3);
        % Ajustamos los datos a una recta.
        % Buscamos la intersección (lambda del máximo).
        % Vemos el valor de C/S asociado.
        
  .........................................................................      
        spec{:,j}(:,5)= spec{:,j}(:,5)/a;
        xc3anchobup= (0.5- p_up3(1,2))/p_up3(1,1);
        xc3anchobdw= (0.5- p_dw3(1,2))/p_dw3(1,1);
        AnchoB3= (xc3anchobdw-xc3anchobup)/2;
%         figure
        %spec{:}(:,5)= spec{:}(:,5)*a;
        %plot (spec{:}(:,2), spec{:}(:,5));
             
        % Dividimos todos los valores de CS por el máximo para normalizarlos.
        % para el valor de y=0,5 calculamos el Ancho de Banda.
        % Buscamos los valores de x asociados al valor de y y los restamos. 
        
        
        
        
        %%....MÉTODO DEL CENTRO DE MASAS...........................................
        
        xc3cm=trapz(d3(:,2),d3(:,2).*d3(:,5))/trapz(d3(:,2),d3(:,5));
        
        
        %%....DIFERENCIA ENTRE AMBOS MÉTODOS...............
        
        LR3= 3341.484;
        DMP3= xc3-LR3;
        DMCM3= xc3cm-LR3;
        % DMP3= ((xc3-LR3)/LR3)*100;
        % DMCM3= ((xc3cm-LR3)/LR3)*100;
        
%         Fecha=sscanf(filename,'%*2c%5d%*c%*3d');
        MPMCMDM3= [FH{j} LR3 xc3 DMP3 xc3cm DMCM3 a];
        MPMCMDM3T=[MPMCMDM3T;MPMCMDM3];
        AnchoBanda3=[AnchoBanda3;AnchoB3];
    end
    
end

%%
L= [MPMCMDM1T MPMCMDM2T MPMCMDM3T];

if isempty(L)
    error('Standart Lamp');
end
end
    