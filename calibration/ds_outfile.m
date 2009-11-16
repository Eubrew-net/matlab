%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ds_outfile(ozone_sum,config,brw,flag1,flag2,dirout)
%
% Programa que imprime un fichero de salida usando las variables de salida
% del programa rep_ozone2.
%
% Requiere que sea cargada el fichero .mat de salida del programa rep_ozone2.
%
% La variable flag1 puede tener 3 valores:
%   0: se imprime un �nico fichero con todos los datos de todos los Brewers
%   1: se imprime un s�lo fichero para cada Brewer con los datos de todos los d�as
%   otro: se imprime un fichero para cada d�a de datos para cada Brewer
%
% La variable flag2 indica si se desea a�adir o crear un fichero nuevo
%   'w': crea un nuevo fichero
%   'a': a�ade a un nuevo fichero
%
% La variable dirout indica el directorio al que se llevar�n los ficheros de
% salida. Si no se le indica ning�n directorio usar� por defecto un directorio
% llamado salida.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ds_outfile(ozone_sum,config,brw,flag1,flag2,dirout)

for nb=1:length(brw)
    % Se renombran las variables de entrada:
    ozo_=ozone_sum{1,nb};
    conf=config{1,nb};
    
    % se seleccionan los datos a imprimir en el fichero restringiendo por
    % desviacion est�ndar de la medida y eliminando valores negativos de ds si
    % los hubiese
    for i=1:length(ozo_)
        try
            indifil{i}=find(ozo_{i}(:,10)<2.5 & ozo_{i}(:,9)>0);
        catch
            indifil{i}=[];
        end
    end

    % se lleva a una variable s�lo los datos que interesan:
    for i=1:length(ozo_)
       ozo{i,1}=ozo_{i}(indifil{i},:);
    end
    
    if flag1==0
        
        % Se a�ade la variable con el n�mero de Brewer
        ozot{nb}=cell2mat(ozo);
        newcol=brw(1,nb)*ones(size(ozot{nb},1),1);
        ozot{nb}=[ozot{nb}(:,1),newcol,ozot{nb}(:,2:end)]; %se a�ade al final el n�mero de Brewer
        configf{nb}=conf{1,1};  %se selecciona la configuracion asignada al primer d�a
                
    elseif flag1==1
        
        % Se llevan todas las variables a una matriz:
        ozot=cell2mat(ozo);
        dj=fix(dia_juliano(ozot(:,1)));
        [Y,M,D,H,MN,S] = datevec(ozot(:,1)); %a�o, mes, d�a, hora, minuto, segundo
        exfech=m2xdate(ozot(:,1));    %hora en formato excel de cada d�a
        hhmmss=time2str(mat2hms(H,MN,S),'24','hms','hms');  %hora:minuto:segundo        
        hdec=timedim(mat2hms(H,MN,S),'hms','hours');    %hora decimal
        yyini=fix((Y(1)./100-fix(Y(1)./100))*100);
        yyfin=fix((Y(end)./100-fix(Y(end)./100))*100);

        % Impresi�n del fichero
        if ~exist('dirout','var')
            dirout='.//salida';
        end
        mkdir(dirout);
        nomfich=sprintf('ds%03d%02d_%03d%02d.%03d',dj(1),yyini,dj(end),yyfin,brw(nb));
        f=fopen(fullfile(dirout,nomfich),flag2);
        if ~strcmp(flag2,'a')
            fprintf(f,'# old ICF: %s\r\n',mat2str(conf{1,1}(:,1)')); %Valores del fichero del primer icf
            fprintf(f,'# new ICF: %s\r\n',mat2str(conf{1,1}(:,2)')); %Valores del fichero del segundo icf
            fprintf(f,'# \r\n'); %l�nea para los valores sl
            fprintf(f,'# \r\n'); %l�nea para las constantes extras
            fprintf(f,'# \r\n'); %l�nea para los filtros
            fprintf(f,'# Ds ozone values selected with sigma<2.5\r\n'); %l�nea para comentarios
            fprintf(f,'# Julian_Day  DD  MM  YY  HH:MM:SS  H_Decimal  Lotus_Date  Hg_Flag  SZA  Air_mass  Temperature  Filter  O3_ds  Sigma_O3_ds  Corrected_O3_ds  Sigma_Corrected_O3_ds  SO2  Sigma_SO2\r\n'); %l�nea para las cabeceras
        end
        %for i=1:size(ozot,1)
        %    fprintf(f,'%03d  %02d  %02d  %04d  %s  %06.3f  %9.3f  %1d  %6.3f  %5.3f  %02d  %1d  %05.1f  %+03.1f  %05.1f  %+03.1f  0.0  0.0\r\n',...
        %        dj(i),D(i),M(i),Y(i),hhmmss(i,:),hdec(i),exfech(i),ozot(i,2:end));
        %end
        
        s=sprintf('%03d  %02d  %02d  %04d  %06d  %06.3f  %9.3f  %1d  %6.3f  %5.3f  %02d  %1d  %05.1f  %+03.1f  %05.1f  %+03.1f  0.0  0.0\r\n',...
            [dj,D,M,Y,hhmmss,hdec,exfech,ozot(:,2:10)]');
        fprintf(f,'%s',s')
        fclose(f);
        clear('ozot')
        
    else
        
        if ~exist('dirout','var')
            dirout='.//salida';
        end
        mkdir(dirout);
        
        for nd=1:length(ozo)
            
            % Se llevan las variables de cada d�a a una matriz:
            try
                dj=fix(dia_juliano(ozo{nd}(:,1)));
                [Y,M,D,H,MN,S] = datevec(ozo{nd}(:,1)); %a�o, mes, d�a, hora, minuto, segundo
                exfech=m2xdate(ozo{nd}(:,1));    %hora en formato excel de cada d�a
                hhmmss=time2str(mat2hms(H,MN,S),'24','hms','hms');  %hora:minuto:segundo        
                hdec=timedim(mat2hms(H,MN,S),'hms','hours');    %hora decimal
                yy=fix((Y(1)./100-fix(Y(1)./100))*100);

                % Impresi�n del fichero
                nomfich=sprintf('ds%03d%02d.%03d',dj(1),yy,brw(nb));
                f=fopen(fullfile(dirout,nomfich),'w');
                fprintf(f,'# old ICF: %s\r\n',mat2str(conf{nd}(:,1)')); %Valores del fichero del primer icf
                fprintf(f,'# new ICF: %s\r\n',mat2str(conf{nd}(:,2)')); %Valores del fichero del segundo icf
                fprintf(f,'# \r\n'); %l�nea para los valores sl
                fprintf(f,'# \r\n'); %l�nea para las constantes extras
                fprintf(f,'# \r\n'); %l�nea para los filtros
                fprintf(f,'# Ds ozone values selected with sigma<2.5\r\n'); %l�nea para comentarios
                fprintf(f,'# Julian_Day  DD  MM  YY  HH:MM:SS  H_Decimal  Lotus_Date  Hg_Flag  SZA  Air_mass  Temperature  Filter  O3_ds  Sigma_O3_ds  Corrected_O3_ds  Sigma_Corrected_O3_ds  SO2  Sigma_SO2\r\n'); %l�nea para las cabeceras
                for i=1:size(ozo{nd},1)
                    fprintf(f,'%03d  %02d  %02d  %04d  %s  %06.3f  %9.3f  %1d  %6.3f  %5.3f  %02d  %1d  %05.1f  %+03.1f  %05.1f  %+03.1f  0.0  0.0\r\n',...
                        dj(i),D(i),M(i),Y(i),hhmmss(i,:),hdec(i),exfech(i),ozo{nd}(i,2:end));
                end
                fclose(f);
                clear('dj','Y','M','D','H','MN','S','exfech','hhmmss','hdec')
            catch
                warning('File not printed')
            end
        end
    end
    clear('ozo_','conf','ozo','indifil')
end

if flag1==0
    %se llevan los datos de todos los Brewers de todos los d�as a una
    %variable
    ozof=cell2mat(ozot');
    [fechf,indi]=sort(ozof(:,1));
    ozofs=ozof(indi,:);
    
    % Se calculan el resto de las variables a ser impresas:
    djf=fix(dia_juliano(fechf));
    [Yf,Mf,Df,Hf,MNf,Sf]=datevec(fechf); %a�o, mes, d�a, hora, minuto, segundo
    exfechf=m2xdate(fechf);    %hora en formato excel de cada d�a
    hhmmssf=time2str(mat2hms(Hf,MNf,Sf),'24','hms','hms');  %hora:minuto:segundo        
    hdecf=timedim(mat2hms(Hf,MNf,Sf),'hms','hours');    %hora decimal
    yyini=fix((Yf(1)./100-fix(Yf(1)./100))*100);
    yyfin=fix((Yf(end)./100-fix(Yf(end)./100))*100);
    
    % Impresi�n del fichero
    if ~exist('dirout','var')
        dirout='.//salida';
    end
    mkdir(dirout);
    nomfich=sprintf('ds%03d%02d_%03d%02d.dat',djf(1),yyini,djf(end),yyfin);
    f=fopen(fullfile(dirout,nomfich),flag2);
    if ~strcmp(flag2,'a')
        for nb=1:length(brw)
            fprintf(f,'# old ICF Brewer#%03d: %s\r\n',brw(nb),mat2str(configf{nb}(:,1)')); %Valores del fichero del primer icf
            fprintf(f,'# new ICF Brewer#%03d: %s\r\n',brw(nb),mat2str(configf{nb}(:,2)')); %Valores del fichero del segundo icf
        end
        fprintf(f,'# \r\n'); %l�nea para los valores sl
        fprintf(f,'# \r\n'); %l�nea para las constantes extras
        fprintf(f,'# \r\n'); %l�nea para los filtros
        fprintf(f,'# Ds ozone values selected with sigma<2.5\r\n'); %l�nea para comentarios
        fprintf(f,'# Julian_Day  N_Br  DD  MM  YY  HH:MM:SS  H_Decimal  Lotus_Date  Hg_Flag  SZA  Air_mass  Temperature  Filter  O3_ds  Sigma_O3_ds  Corrected_O3_ds  Sigma_Corrected_O3_ds  SO2  Sigma_SO2\r\n'); %l�nea para las cabeceras
    end
    for i=1:size(ozofs,1)
        fprintf(f,'%03d  %03d  %02d  %02d  %04d  %s  %06.3f  %9.3f  %1d  %6.3f  %5.3f  %02d  %1d  %05.1f  %+03.1f  %05.1f  %+03.1f  0.0  0.0\r\n',...
            djf(i),ozofs(i,2),Df(i),Mf(i),Yf(i),hhmmssf(i,:),hdecf(i),exfechf(i),ozofs(i,3:end));
    end
    fclose(f);
    
end

disp('fin')
