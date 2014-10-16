function cloud_screening(bsrn_dir,aod_file,varargin)

% Programa para la deteccion de periodos nubosos en la radiacion 
% aplicando los criterios de Long y Ackerman -> adaptación a Izaña
% 
% REF: García, R.D., O.E, García, E. Cuevas, V.E. Cachorro, P.M. Romero-Campos, R. Ramos and A.M. de Frutos, 
% Solar radiation measurements compared to simulations at the BSRN Izaña station. Mineral dust radiative forcing and efficiency study, 
% JGR-Atmospheres, Vol 119, 1-16, DOI: 10.1002/2013JD020301, 2014
% 
% Cumulus                         Low, puffy clouds with clearly defined edges, white or light-grey
% Cirrus & Cirrostratus           High, thin clouds, wisplike or sky covering, whitish
% Cirrocumulus & Altocumulus      High patched clouds of small cloudlets, mosaic-like, white
% Clear sky                       No clouds and cloudiness below 10%
% Stratocumulus                   Low or mid-level, lumpy layer of clouds, broken to almost overcast, white or grey
% Stratus & Altostratus           Low or mid-level layer of clouds, uniform, usually overcast, grey
% Cumulonimbus & Nimbostratus     Dark, thick clouds, mostly overcast, grey
% 
%  Example: cloud_screening(path_to_bsrn,aod_file,'date_range',datenum(Cal.Date.cal_year,1,111),'plot',1)            

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'cloud_screening';

% input obligatorio
arg.addRequired('bsrn_dir',@ischar); arg.addRequired('aod_file',@ischar);

% input param - value
arg.addParamValue('plot'            , 0  , @(x)(x==0 || x==1)); % por defecto no individual plots
arg.addParamValue('date_range'      , [] , @isfloat);           % default all data in bsrn dir
arg.addParamValue('file_write'      , 1  , @(x)(x==0 || x==1)); % default writing results
arg.addParamValue('file_indv_write' , 0  , @(x)(x==0 || x==1)); % default No writing results
arg.addParamValue('cld_umbral'      , 100, @isfloat);           % 100% clear conditions

% validamos los argumentos definidos:
arg.parse(bsrn_dir,aod_file,varargin{:});

%% Declaring variables
% AOD para el ajuste (mejora introducida por Rosa)
try
   [aod,DATA0]=read_aeronet(fullfile(bsrn_dir,aod_file),14);% AOD_500
catch exception
    fprintf('%s: %s Aborting\n',fullfile(bsrn_dir,aod_file),exception.message);
    return
end

if ~isempty(arg.Results.date_range)
   DATA0(DATA0(:,1)<arg.Results.date_range(1),:)=[];
   if length(arg.Results.date_range)>1
      DATA0(DATA0(:,1)<arg.Results.date_range(1),:)=[];
      DATA0(DATA0(:,1)>arg.Results.date_range(2),:)=[];
   end

end
l1=size(DATA0(:,1),1);

%%
results=[];
for i=1:l1    
    aod = DATA0(i,2); dayj=diaj(datenum(DATA0(i,1)));
    file=sprintf('izo_bsrn_corr_%02d%03d.txt',year(DATA0(i,1))-2000,dayj);

    % Leemos BSRN: Cabecera + Datos
    bsrn_f=fopen(fullfile(bsrn_dir,file),'rt');
    if bsrn_f~=-1
       cab=fgetl(bsrn_f); cab_=regexp(cab(2:end), ' ', 'split'); cab_=cellfun(@(x) upper(x),cab_,'UniformOutput',0);
       bsrn=textscan(bsrn_f,repmat('%f ',1,length(cab_)),'CommentStyle','#');      
    else
       continue
    end
    fclose(bsrn_f);
    
    col_sza = strmatch('SZA',cab_);     col_minuto = strmatch('MINUTO_CAMPBELL',cab_);
    col_GLB = strmatch('GLB_AVG',cab_); col_DIF    = strmatch('DIF_AVG',cab_);     
    DATA1=cell2mat(bsrn([1 col_sza,col_minuto,col_GLB,col_DIF])); DATA1(:,1)=datenum(year(DATA0(i,1)),1,dayj,0,DATA1(:,3),0);
    DATA2=DATA1(DATA1(:,2)<70.0,:);% Valores con sza<80
    DATA2(DATA2(:,4)<0,:)=[]; DATA2(DATA2(:,5)<0,:)=[]; DATA2(isnan(DATA2(:,4)),:)=[];

    % Definición de parametros
    sza = DATA2(:,2); mu0 = cos(deg2rad(sza)); ldata = size(DATA2,1);              
    [szanoon j_szanoon] = min(sza); mu0noon = cos(deg2rad(szanoon));  
    Rglobal = DATA2(:,end-1); Rdifusa = DATA2(:,end); Dratio = Rdifusa./Rglobal;
    minuto = DATA2(:,3); Hdec = minuto./60;        
    C = 2; Rt = 1; ventana = 5;
        
    %% Long & Ackerman method
    % Test1: Normalized Total Shortwave Magnitude Test      
    %        Glob_N = Glob/(cos(sza)^b);
    a_glob_max = 1250; a_glob = 1000; a_glob_min = 900; 
    b_glob     = 1.09261 + (0.44034*aod); 
    NTSMT = @(x,y,z) x./(y.^z);
    
    % Maximum Diffuse ShortWave Test
    Dlim = 150*(mu0.^0.5);

    % Change in Magnitude with Time Test
    S0 = 1365.0; % Cte. solar
    Fglob_toa = S0.*mu0;
    
    % Test2: Normalized Diffuse Ratio Variability Test      
    %        Diff_N = Diff_ratio/(cos(sza)^b); 
    a_difu   = 0.1;  b_difu   = -0.8;   
    NDRVT = @(x,y,z) x./(y.^z);
    
    delta_a1 = 10; delta_a2 = 10; delta_b1 = 10; delta_b2 = 10;        idx=1;
    while (delta_a1 > 0.01 || delta_b1 > 0.01 || delta_a2 > 0.01 || delta_b2 > 0.01);        
        clear('ic','CRIT','S');   idx=idx+1;  
        if idx > 50, 
            j_szanoon=1; CRIT=NaN*ones(2,7);
           break 
        end
        % Normalized Total Shortwave Magnitude Test      
        Fglob_norm=NTSMT(Rglobal,mu0,b_glob);
        a_glob0 = a_glob;   b_glob0 = b_glob;
        
        % Normalized Diffuse Ratio Variability Test      
        Dratio_norm=NDRVT(Dratio,mu0,b_difu);
        a_difu0 = a_difu;   b_difu0 = b_difu;
        
        for j=1:ldata
            CRIT(j,1) = minuto(j);
            CRIT(j,2) = sza(j);
            
            % Busco valores dentro del limite de la global criterio 1  
            CRIT(j,3) = 0;
            if Fglob_norm(j)< a_glob_min || Fglob_norm(j)> a_glob_max;
               CRIT(j,3) = 1;
            end
        
            % Busco valores que cumplen el criterio 2
            CRIT(j,4) = 0;
            if Rdifusa(j) > Dlim(j) && j ~= 0;
                CRIT(j,4) = 1;
            end
        
            % (3) Busco los valores que cumplen el criterio 3
            CRIT(j,5) = 0;
            if j>1 && j<ldata-1;
                DFtoa(j) = abs((Fglob_toa(j+1) - Fglob_toa(j-1))/(minuto(j+1)-minuto(j-1)));
                DFglobal(j) = abs((Rglobal(j+1) - Rglobal(j-1))/(minuto(j+1)-minuto(j-1)));
                Limax(j) = DFtoa(j) + C*mu0(j);
                Limin(j) = DFtoa(j) - (Rt*(mu0noon + 0.1)/mu0(j));
                if DFglobal(j) > Limax(j) && DFglobal(j) < Limin(j);
                    CRIT(j,5) = 1;
                end            
            end
        
        	% (4) Buscamos los valores que cumplen el criterio 4    
            CRIT(j,6) = 0;
            if j>ventana && j<ldata-ventana;
                media(j) = mean(Dratio_norm(j-ventana:j+ventana));
                desvi(j) = std(Dratio_norm(j-ventana:j+ventana));
                if desvi(j) > 0.006
                    CRIT(j,6) = 1;
                end
            end
            S(j) = sum(CRIT(j,3:end));
        end
        
        % Buscamos los minutos detectados como despejados en los 4 criterios
        CRIT(:,7) = S; 
        iclear = find(CRIT(:,7) == 0); icloud = find(CRIT(:,7) > 0);
        
        % Calculamos la nueva a y b si hay mas de 100 valores
        if length(iclear) > 100
            ffun = fittype('power1');
            cfun = fit(mu0(iclear),Rglobal(iclear),ffun);
            a_glob = cfun.a; b_glob = cfun.b;
            Rglobal2 = a_glob*(mu0.^b_glob);        
        
            ffun = fittype('power1');
            cfun = fit(mu0(iclear),Dratio(iclear),ffun);
            a_difu = cfun.a; b_difu = cfun.b;
            Rdifusa2 = a_difu*(mu0.^b_difu);
        end
        % Definimos los nuevos valores de los limites minimo y maximo
        a_glob_min = a_glob-150;  a_glob_max = a_glob+150;   
        
        % Calculo si hay diferencia en los coeficientes para la convergencia
        delta_a1 = abs(a_glob - a_glob0); delta_b1 = abs(b_glob - b_glob0);       
        delta_a2 = abs(a_difu - a_difu0); delta_b2 = abs(b_difu - b_difu0);
    end  
    
    %% Representamos global + difusa
    results{i} = [fix(DATA0(i,1)),dayj,ldata,100*length(find(CRIT(1:j_szanoon,7)==0))/length(1:j_szanoon),...
                                             100*length(find(CRIT(1:j_szanoon,7)>0))/length(1:j_szanoon),length(1:j_szanoon),...                       
                                             100*length(find(CRIT(j_szanoon+1:end,7)==0))/length(CRIT(j_szanoon+1:end,7)),... 
                                             100*length(find(CRIT(j_szanoon+1:end,7)>0))/length(CRIT(j_szanoon+1:end,7)),length(CRIT(j_szanoon+1:end,7))];
    if arg.Results.plot
       figure;
       [ax b c]=plotyy(Hdec,Rglobal,Hdec,Rdifusa); 
       set([b c],'Marker','.','LineStyle','None');
       ylabel(ax(2),'Rdiffuse'); ylabel(ax(1),'Rglobal'); grid;
       title(sprintf('%s (%d) AM: clear %4.1f%%, cloudy %4.1f%% -- PM: clear %4.1f%%, cloudy %4.1f%%',...
             datestr(DATA0(i,1),1),diaj(DATA0(i,1)),results{i}(4),results{i}(5),results{i}(7),results{i}(8)));         
       vl=vline_v(DATA2(j_szanoon,3)/60,'-r',{'noon'}); set(vl,'LineWidth',2);
    end  
    
    if arg.Results.file_indv_write
       f1 = fopen(fullfile(bsrn_dir,sprintf('Cloud%03d%d.txt',dayj,year(fix(DATA0(i,1)))-2000)),'w');
       fprintf(f1,'%%date az R_Global, R_difusa, crit1 crit2 crit3 crit4\n');
       try
           aux=cat(2,DATA2(:,1:2), Rglobal, Rdifusa, CRIT(:,3:6));
       catch exception
           aux=cat(2,DATA2(:,1:2), Rglobal, Rdifusa, NaN*ones(length(Rglobal),4));   
           fprintf('%s (Cloud-screening algorithm failed)\r\n',exception.message)
       end
       for row=1:size(Rglobal,1)
           fprintf(f1,'%f %5.2f %6.2f %6.2f %d %d %d %d\n',aux(row,:));
       end
    end
    fclose(f1);

    fprintf('Day: %03d (AM), clear(%%):%4.1f, no_clear(%%):%4.1f, aod:%f -- (PM) clear(%%):%4.1f, no_clear(%%):%4.1f, aod:%f\n',...
                  dayj, results{i}(4), results{i}(5), aod, results{i}(7), results{i}(8), aod);  
              
end
results=results(cellfun(@(x) ~isempty(x),results));

%% Resultados en 1/0

 if arg.Results.file_write
    f1 = fopen(fullfile(bsrn_dir,'cloudScreening.txt'),'w');
    fprintf(f1,'%%date dayj clear_AM clear_PM\n');
    for i=1:size(results,2)
        if results{i}(4)>=arg.Results.cld_umbral
           AM=1;
        else
           AM=0;        
        end
        if results{i}(7)>=arg.Results.cld_umbral
           PM=1;
        else
           PM=0;        
        end
        fprintf(f1,'%f %03d %d %d\n',results{i}(1),diaj(results{i}(1)),AM,PM);
    end
 end   
 fclose all;
