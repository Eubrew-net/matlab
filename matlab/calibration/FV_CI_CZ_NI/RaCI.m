
function [r,ab,rp,data,DataNumRFH_a,DataNumRFH_b,CLongRatio,CLongRatioP,TNumTotal_a,Error]=RaCI(namea,ref,outl)

% Calcula el ratio entre respuestas de ficheros CI.
% Poner los nombres de los CI entre comillas.
% El ratio es respecto a b(ref).
% b y a pueden tener varias columnas (respuesta CI).
% x    = elementos comunes
% r    = ratio
% ab   = diferecia absoluta
% rp   = ration porcentual
% data = 3 columnas (1a es la longitud de onda, 2a son las Cuentas Segundo y la 3a se puede obviar)
% 
%
% Modificación de la función ratiol.
% 23/07/2010 Isabel   Modificado para que como salida tome el error cometido
%                     Nos informa de los error en los ficheros que no se encuentran en el
%                     emplazamiento de referencia y de si el fichero de referencia no existe.
% 26/10/2010 Isabel   Modificado para que no muestre "mean"

%% ...APLICAR RCI PARA OBTENER EL ESPECTRO....................................
[DataNumRFH_a  TNumTotal_a Ea]=ReadCI(namea);

try
    [DataNumRFH_b]=ReadCI(ref);
catch
    disp('Reference file does not exist');
    return
end
Error.log= Ea;

if 1~=length(DataNumRFH_b)
    warning('Refence file length ~= 1. Se escoge el primero')
end

%% ...DEFINICIÓN DE VARIABLES.................................................
% TODO
% if f>1
%     disp('mean');
% end

for j=1:length(DataNumRFH_a)
    % Buscamos longitudes de onda comunes entre namea y ref
    [c{j},index_a{j},index_b]= intersect(DataNumRFH_a{j}(:,2),DataNumRFH_b{1}(:,2));
    data{j}=[c{j},DataNumRFH_a{j}(index_a{j},5:end),DataNumRFH_b{1}(index_b,5:end)];    
    if isempty(c{j})
        error('no comon elements to ratio')
        return
    end  
    
     r{j} = [c{j},(DataNumRFH_a{j}(index_a{j},end)./DataNumRFH_b{1}(index_b,end))]; % ratio
    ab{j} = [c{j},(DataNumRFH_a{j}(index_a{j},end)-DataNumRFH_b{1}(index_b,end))]; % diferencia absoluta
    rp{j} = [c{j},100*(DataNumRFH_a{j}(index_a{j},end)-DataNumRFH_b{1}(index_b,end))./DataNumRFH_b{1}(index_b,end)]; % ratio porc.   
    
   % we remove outliers from individual ratios
   if nargin==3 && outl
      [a,b,c_,out_idx]=outliers_bp(rp{j}(:,2),10.5); 
      if ~isempty(c_)
          Error.out{j}=[rp{j};NaN,DataNumRFH_a{j}(1,1)];
      end
      rp{j}(out_idx,2)  =NaN;   
      data{j}(out_idx,2:end)=NaN;   
   end
   
    % Si comparamos ref con un archivo que contenga menos longitudes de
    % ...onda, no nos hará r, ab y rp , por lo que no hay datos, asi que
    % ...nos quedamos sin esas filas
    % Las rellenamos (1ºC Longitus y segunda datos+relleno)
    if size(c{j},1)<size(DataNumRFH_b{1},1)
        n= size(DataNumRFH_b{1},1)- size(c{j},1);
         r{j} = [DataNumRFH_b{1}(:,2)  [r{j}(:,2); reshape(linspace(NaN,NaN,n),n,1)]];
        ab{j} = [DataNumRFH_b{1}(:,2)  [ab{j}(:,2);reshape(linspace(NaN,NaN,n),n,1)]];
        rp{j} = [DataNumRFH_b{1}(:,2)  [rp{j}(:,2);reshape(linspace(NaN,NaN,n),n,1)]];       
    end        
end

%% ...SALIDA PARA LA UNIÓN DE FICHEROS.......................................
if j>1
    try
        for j=2:length(DataNumRFH_a)
            r{1}= scan_joinCI(r{1},r{j});
            CLongRatio= r{1};
            rp{1}= scan_joinCI(rp{1},rp{j});
            CLongRatioP= rp{1};
            % Unimos por columnas los distintos resultados para el ratio.
            % La primera columna de DataNumRFH_b{1}  es la longitud de onda.
            % Unimos las columna que nos interesan (los resultados ratio) con la CLong.
            % Finalmente tenemos 1ªC longitud, de resto los valores der ratio.
            
        end
    catch
        warning('scanjoinCI')
    end
end

if j==1
    CLongRatio= r{1};
    CLongRatioP= rp{1};
end
