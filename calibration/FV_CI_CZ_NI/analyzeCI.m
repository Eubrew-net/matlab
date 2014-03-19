
function [LRatPFHT ErrorRaCI]=analyzeCI(path,nameb,varargin)
% This function analyze CI files and gives the response for each one respect nameb.
% We want all ratios appear.
% The output is a matrix (Ratio %) with the Data/Time and T. 
% 
% [LRatPFHT_185 ErrorRaCI_185 ErrorRCI_185]=analyzeCI('E:\CODE\aro2010\bdata185\CI2*10.185','CI20110.185');
%  
%%  TODO: 
%        ¿Es necesario pasarle el nombre CI?
%        Comprobar depuración de outliers. Eliminarlos en su caso??
% 
%%   MODIFICADO:
%  23/07/2010 Isabel  Modificado para que como salida tome el error cometido
%                     al usa la funcion RCI (error individual)
%                     al usar la función RaCI (error al comparar)
%
%  10/08/2010 Juanjo: Retocados los ploteos para hacerlo acorde al resto del report de calibración
% 
%  13/08/2010 Juanjo: Modificado el control de inputs. Ahora se hace uso de clase inputParser. 
%                     Obligatorios: path, nameb (scan tomado como referencia)
%                     Opcionales: date_range (por defecto no date_range). Se requiere brewer_date.m 
%                                 depuracion (0 ó 1). Para hacer uso de interactivelegend. Por defecto 0
%                                 outlier_flag (0 ó 1). Por defecto 0
%                     Se muestran al final del script los parametros que han tomado un valor por defecto.   
%                     Ya no es necesario trabajar desde el directorio donde se hallan los
%                     ficheros CI. En cualquier caso funciona de esa manera
%  26/10/2010 Isabel  Modificados titulos y ejes para que salgan en negrita.
%                     Se muestran los outliers.
%                     Se comenta el que muestre los outliers,CIFiles=dir(path);
% 16/03/2013 Juanjo:  Modificado para aceptar diferentes años, siempre con la estructura del
%                     repositorio !! yyyy/bdata###

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'analyzeCI';

% input obligatorio
arg.addRequired('path'); 
arg.addRequired('nameb'); 

% input param - value,varargin
arg.addParamValue('date_range',  [], @isfloat);            % por defecto, no control de fechas
arg.addParamValue('depuracion',   0, @(x)(x==0 || x==1));    % por defecto no depuracion
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion

% validamos los argumentos definidos:
try
    arg.parse(path, nameb, varargin{:});
    mmv2struct(arg.Results);
    chk=1;
catch exception
    fprintf('%s',exception.message);  
    chk=0;
end

%% CI FILES
CZFiles={}; FilesCZ={}; paths={}; files={}; pat={};

[pathstring f]=fileparts(path); 
if ~isempty(date_range)
    if length(date_range)==2
       DATE=date_range(1):date_range(2); YEAR=unique(year(DATE));
    else
       DATE=date_range(1);               YEAR=unique(year(DATE));
    end
    if length(YEAR)==1
        CIFiles{1}=dir(path);
        dir_cell=struct2cell(CIFiles{1}); FilesCI{1}=dir_cell(1,:);
        paths{1}=repmat({pathstring},length(CIFiles{1}),1); 
    else
        for i=1:length(YEAR)
            pathstr=regexprep(pathstring, '\d{4}',num2str(YEAR(i)));
            if isempty(regexp(pathstr, '\d{4}'))
               pathstr=strcat('..\',num2str(YEAR(i)),'\',pathstring);
            end
            CIFiles{i}=dir(sprintf('%s\\%s',pathstr,f));
            dir_cell=struct2cell(CIFiles{i}); FilesCI{i}=dir_cell(1,:);
            paths{i}=repmat({pathstr},length(CIFiles{i}),1);  
        end
    end
    for i=1:length(YEAR)
        files=cat(2,files,FilesCI{i});
        pat=cat(1,pat,paths{i});
    end
    FilesCI=files; paths=pat;
else
    CIFiles=dir(path);    
    dir_cell=struct2cell(CIFiles); FilesCI=dir_cell(1,:);
    paths=repmat({pathstr},length(CIFiles),1);  
end

    myfunc_clean=@(x)regexp(x, '^ci\d{5}[.]\d*','ignorecase')';     clean=@(x)~isempty(x); 
    remove=cellfun(clean,cellfun(myfunc_clean,FilesCI, 'UniformOutput', false));
    FilesCI(~remove)=[];  
    myfunc=@(x)sscanf(x,'%*2c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,FilesCI, 'UniformOutput', false)');
    if isempty (FilesCI)
       disp('No CI Files'); 
       wl={}; fwhm={}; return
    end
    
% control de fechas
if ~isempty(date_range)
%                  Año    Dia
   dates=datejuli(A(:,2),A(:,1));    
   FilesCI(dates<date_range(1))=[]; paths(dates<date_range(1))=[]; dates(dates<date_range(1))=[]; 
   if length(date_range)>1
      FilesCI(dates>date_range(2))=[]; paths(dates>date_range(2))=[]; 
   end   
   if isempty(FilesCI)
      disp('No CI Files in date range'); 
      LRatPFHT={}; ErrorRaCI={}; return
   end   
end

%% DEFINING VARIABLES 
RatiosFiles=[];
RatiosPFiles=[];
FHj=[];
FHjtodos=[];
Ttodosai=[];
ErrorRaCI=[];

%% RaCI FUNCTION
%...CLongRatiosPFiles...........................................................
for i=1:length(FilesCI)
    [a b ext]=fileparts(FilesCI{i});
    if exist(fullfile(paths{i},[b,'_dep',ext]),'file')
       file_d=fullfile(paths{i},[b,'_dep',ext]); 
    else
       file_d=fullfile(paths{i},[b,ext]); 
    end
    
    try
        [r{i},ab{i},rp{i},data{i},DataNumRFH_a{i},DataNumRFH_b{i},...
         CLongRatio{i},CLongRatioP{i},TNumTotal_a{i},Error]=RaCI(file_d,nameb,outlier_flag);
        
        % Obtenemos valores para cada fichero.
        RatiosFiles       = [RatiosFiles          CLongRatio{i}(:,2:end)];
        RatiosPFiles      = [RatiosPFiles         CLongRatioP{i}(:,2:end)];
        CLongRatiosFiles  = [CLongRatio{1}(:,1)   RatiosFiles ];
        CLongRatiosPFiles = [CLongRatioP{1}(:,1)  RatiosPFiles];
        if isfield(Error,'out')
           ErrorRaCI      = [ErrorRaCI            cell2mat(Error.out)];
        end
        % Unimos los valores de los ratios de cada fichero, esto es la segunda
        %...columna de cada salida de datos, pues la primera es la longitud de
        %...onda.
        % Le anadimos la longitud (1C, el resto son los ratios)
                      
        %...FECHA/HORA............................................................
        f=length(DataNumRFH_a{i});
        for   j=1:f;
            fhj= DataNumRFH_a{i}{j}(1,1);
            FHj= sort([FHj fhj]);
        end        
        % Cogemos el dato de salida "DataNumRFH_a{i}{j}(1,1)" de cada fichero (DataNumRFH_a{i}).
        % Dentro de cada DataNumRFH_a{i} puede haber, a su vez varias repeticiones DataNumRFH_a{i}.
        % Asociamos una FH matlab a cada columna CS, esto es el primer dato
        % ...de la primera columna y fila de DataNumRFH_a{i}
        % Unimos en fila los valores de FH
        % Tenemos una fila con valores Fecha/Hora matlab asociado a cada columna CS.
        
        try
            for   j=1:f;
                fhjtodos= DataNumRFH_a{i}{j}(:,1);
                FHjtodos= [FHjtodos fhjtodos];
            end
        end
        % En lugar de coger solo un dato asociado a cada columna CS, cogemos
        % ...los valores asociados a cada valor, para poder hacer la
        % ...representación gráfica 3D.
                       
        %...TEMPERATURA.......................................................
        Ttodosai= [Ttodosai TNumTotal_a{i}];
        
        % Cada vez que lee un fichero me salen los valores de la temperatura
        % ...del fichero que estamos referenciando(en fila). Cada valor corresponde
        % ...a una repetición j. Así que una parte Ttodosai podemos tener uno o dos valores.
        % Tenemos fila de T asociada a cada columna Ratio.
        
        
        %...DATOS DE SALIDA........................................................
        
        NaNFHjT= [NaN FHj];
        NaNTTai= [NaN  Ttodosai];
        % La primera columna es la L (xlo que añadimos un espacio vacío a nuestra fila FH)
        % La primera columna es la Longitud (xlo que añadimos un espacio vacío a nuestra fila Ttodosai)
        LRatFH=  [CLongRatiosFiles ; NaNFHjT];
        LRatPFH= [CLongRatiosPFiles; NaNFHjT];
        LRatFHT=  [LRatFH;  NaNTTai];
        LRatPFHT= [LRatPFH; NaNTTai];
        % Unimos todas las columnas ratio/longitud, con la fila Fecha hora.
        % Unimos el resultado con la fila  T también                
    catch
%         ErrorRaCI=[ErrorRaCI;FilesCI{i}];
        %ex=lasterror;
        %disp(ex);
    end
end

if ~isempty(ErrorRaCI)
    ErrorRaCI= ErrorRaCI(:,[1 2:2:end]);
end
data_plot=[];
for ii=1:length(data)
    aux=data{ii};
    for jj=1:length(aux)
        data_plot=scan_join(data_plot,aux{jj}(:,1:2));
    end
end

% Depuración
if outlier_flag==1   
   [m,s]=mean_lamp(CLongRatiosPFiles);
   [a,b,c,out_idx]=outliers_bp(nanmean(s(:,2:end),1),5.5);
   if ~isempty(out_idx)    
      disp('warning: remove some outlier');
%       outlier_ci=datestr(LRatPFHT(end-1,out_idx+1));   
      ErrorRaCI = [ErrorRaCI,LRatPFH(:,out_idx+1)];
   end
   CLongRatiosPFiles(:,out_idx+1)=NaN;  data_plot(:,out_idx+1)=NaN;
end

%% GRÁFICOS 2D
figure;
set(gcf,'Tag','CI_Report');
subplot(2,1,1);
Cp=size(data_plot,2);
gris_line(Cp+1); ploty(data_plot);
set(gca,'XTicklabel',[],'GridLineStyle','-.','Linewidth',1);
ylabel('SL Intensity','FontWeight','bold'); title('');
text(3100,nanmean(max(data_plot(:,2:end)))/2,...
    sprintf('%d scans from %s to %s',length(FHj), datestr(FHj(1),1), datestr(FHj(end),1)),...
    'BackgroundColor','w','HorizontalAlignment','center'); grid;
sup=suptitle(sprintf('%s%s','CI files, Brw#',nameb(end-2:end))); set(sup,'FontWeight','bold');

subplot(2,1,2);
Cp=size(CLongRatiosPFiles,2);
gris_line(Cp+5); P=ploty(CLongRatiosPFiles(:,[1,2:end]));
set(gca,'GridLineStyle','-.','Linewidth',1);
xlabel('Wavelength (A)','FontWeight','bold'); ylabel('Ratio %','FontWeight','bold');
title('');
pos=get(gca,'YLim'); [pathstr, name, ext] = fileparts(nameb);
text(3100,pos(2),sprintf('Reference CI file: %s',[name,ext]),...
    'BackgroundColor','w','HorizontalAlignment','center');
grid;
hold on;
plot(CLongRatiosPFiles(:,1),nanmean(CLongRatiosPFiles(:,3:end)'),'r-','LineWidth',1.5);
if depuracion
    legend(P,cellstr(datestr(FHj)),-1);
    interactivelegend(P,cellstr(num2str(diaj(FHj))));
end

figure;
Cp=size(CLongRatiosPFiles,2);
[m,s,n,n_]=grpstats(CLongRatiosPFiles(:,2:end),fix(CLongRatiosPFiles(:,1)/100)*100,0.5);

figure;  set(gcf,'Tag','CI_ratios');
errorbar(repmat(FHj',1,size(m,1)),m',s','o'); legend(n_,'location','best');
set(gca,'GridLineStyle','-.','Linewidth',1); grid;
if ~exist('YEAR','var'), YEAR=unique(year(FHj)); end
if length(YEAR)>1
   datetick('x',6,'Keeplimits','Keepticks');
else
   set(gca,'XtickLabel',diaj(get(gca,'XTick')));    
end
xlabel('Day ','FontWeight','bold'); ylabel('Ratio %','FontWeight','bold');
[pathstr, name, ext] = fileparts(nameb);
title(sprintf('Mean and standard dev (10 nm averaged)\nRef: %s',[name,ext]));

%hold on;
%plot(CLongRatiosPFiles(:,1),nanmean(CLongRatiosPFiles(:,3:end)'),'r-','LineWidth',1.5);

%...Temperatura.....................................................

% FTRatiosFiles= [Ttodosai; RatiosFiles];
% figure
% Ct=size(Ttodosai,2);
% gris_line(3*Ct);
% P=plot(FTRatiosFiles(1,:),FTRatiosFiles(2:end,:))
% interactivelegend(P,cellstr(datestr(FHj)));
% grid;
% xlabel('T');
% ylabel('Ratio %');
% title('');
% Creamos la Matriz T+Ratios y representamos R us T

% figure
% Cp=size(FHjt,2);
% gris_line(3*Cp);
% P=plot(LRatFHT(end,2:end),LRatFHT(100,2:end),'-o')
% interactivelegend(P,cellstr(datestr(FHj)));
% grid;
% xlabel('T ');
% ylabel('Ratio para una L');
% title('');
% Representamos de la matriz salida.Donde 100 es la posición de la fila
%...y cada fila está asociada a una L.


%...GRÁFICOS 3D...................................................
%...FechaHora.....................................................

% figure
% Cp=size(FHjt,2);
% gris_line(3*Cp);
% P=plot3(CLongRatiosFiles:,1),CLongRatiosFiles (:,2:end),FHjtodos(:,1:end),'-o')
% interactivelegend(P,cellstr(datestr(FHj)));
% grid;
% xlabel('Longitud onda (ang)');
% ylabel('Ratio ');
% zlabel('FH');
% title('');
%
%         try
%             figure
%             Cp=size(FHjtodos,2);
%             gris_line(3*Cp);
%             P=plot3(CLongRatiosPFiles(:,1),CLongRatiosPFiles(:,2:end),FHjtodos(:,1:end),'-o');
%             interactivelegend(P,cellstr(datestr(FHj)));
%             grid;
%             xlabel('Longitud onda (ang)');
%             ylabel('Ratio %');
%             zlabel('FH');
%             title('');
%         end



% %% ELIMINACIÓN DE ERRORES...................................
% 
% CLongRatiosPFilesSinErrores=CLongRatiosPFiles;
% 
% % Escogemos una longitud de onda en concreto viendo la gráfica anterioir(por ejemplo la 3200A. fila 68)
% % find(CLongRatiosPFiles(:,1)==longitud de interés)
% 
% %         [params, outside_values,index]= boxparams (LRatPFHT(50,2:end),2);
% %         RatPFHT= LRatPFHT;
% %         RatPFHT(:,1)=[];
% %         RatPFHT(:,index)=[];
% %         FHj(:,index)=[];
% %         LRatPFHTSinErrores= [LRatPFHT(:,1) RatPFHT];
% %         CLongRatiosPFilesSinErrores= LRatPFHTSinErrores(1:end-2,:);
% %         % [params, outside_values,index] = boxparams(x,intc)
% %         % Eliminamos las columnas de los valores malos.
% %         % Eliminamos también los valores para la variable FHj, para que siga siendo
% %         % ...correcto el interactivelegend
% %         % Volvemos a representar
% %         % Nuestra matriz sin errores, sin FH y T (Longitudes y Ratios)
% %
% 
% %         subplot(2,1,2);
% %         Cp=size(CLongRatiosPFilesSinErrores,2);
% %         gris_line(3*Cp);
% %         P=ploty(CLongRatiosPFilesSinErrores);
% %         interactivelegend(P,cellstr(datestr(FHj)));
% %         grid;
% %         xlabel('Longitud onda (ang)');
% %         ylabel('Ratio %');
% %         title('');
% %         hold on
% 
% 
% % index=find(LRatPFHT(end-1,2:end)==datenum('01-Mar-2008 20:08:12'))
% % Buscamos el indice de la columna que queremos eliminar
% 
% 
% 
% 
% %...MEDIA DE LOS VALORES DE ERROR PARA CADA LONGITUD...................................
% 
% 
% MediaFilasCLongRatiosPFilesSinErrores = nanmean(CLongRatiosPFilesSinErrores(:,2:end),2);
% LMedia= [CLongRatioP{1}(:,1) MediaFilasCLongRatiosPFilesSinErrores];
% % CLongRatiosPFilesSinErrores es mi matriz datos sin error.
% % Hacemos las medias de los ratio por filas.
% % Obtenemos un vector medias (columna)
% 
% hold on;
% gris_line(Cp+5);
% ploty(LMedia,'r-');
% grid;
% xlabel('Wavelength (A)');
% ylabel('Ratio %');
% title('');
% 
% 
% 
% 
% 
% %...MEDIA MENSUAL....................................................
% % Basado en la función mean_month
% try
%     [LMedia_mes LMedia_ano Ano_MesT]=month_meanCI(LRatPFHTSinErrores);
%     
%     gris_line(3*Cp);
%     P=ploty(LMedia_mes,'c-');
%     interactivelegend(P,cellstr(Ano_MesT))
%     grid;
%     xlabel('Longitud onda (ang)');
%     ylabel('Ratio %');
%     title('');
%     hold off
% end

  if chk
      % Se muestran los argumentos que toman los valores por defecto
      disp('--------- Validation OK --------------') 
      disp('List of arguments given default values:') 
      if ~numel(arg.UsingDefaults)==0
         for k=1:numel(arg.UsingDefaults)
             field = char(arg.UsingDefaults(k));
             value = arg.Results.(field);
             if isempty(value),   
                value = '[]';   
             elseif isfloat(value), 
                value = num2str(value); 
             end
             fprintf('   ''%s''    defaults to %s\n', field, value);
         end
      else
         disp('               None                   ');
      end
      disp('--------------------------------------'); 
  else
      disp('NO INPUT VALIDATION!!');
      fprintf('%s',errval.message);
  end
