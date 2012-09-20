
function [LMedia_mes LMedia_ano Ano_MesT]=month_meanCI(LRatPFHTSinErrores)
% Obtenemos la media para cada longitud de onda en cada mes de cada año.
% Obtenemos la media de cada longitud de onda a lo largo de los años.
  
  if nargin==1
      NMIN=12;
  end
  
  
  
  
 %...DEFINICIONES INICIALES..........................
  year_ini=year(min(LRatPFHTSinErrores(end-1,:)));
  year_fin=year(max(LRatPFHTSinErrores(end-1,:)));
  datet=datevec(LRatPFHTSinErrores(end-1,2:end));
  date=datet(:,[1,2]);
  % Vemos los años inicial y final.
  % Date será una matriz de 6 columnas y tantas filas como columnas tenga
  % ...LRatPFH -1(longitud onda).
  % Nos quedamos con las dos primeras columnas (año y mes).
  
  
  
%   media=[];
%   media_year=[];
%   sigma_year=[];
%   media_dseason=[];
%   sigma=[];
%   ndat=[]; 
  Media_mes=[];
  Ano_MesT=[];

  
  
  
  
  % ...ORDENES.............................................................
  
  for k=year_ini:1:year_fin
      ano=find(date(:,1)==k);
      date_ano=date(ano(1):ano(end),:);
      index_date_ano=[ano date_ano];
      mes=reshape(1:12,12,1);
      % Creamos un bucle, para que tome las ódenes para cada año separado.
      % Que busque dentro de la matriz fecha,las filas que coincidan con el
      % ...año que queremos.
      % Creamos nuestra matriz años (La parte que nos interesa de la date)
      % Le asociamos el index que le corresponde en LRatPFH -1.
      % Definimos nuestros meses.

      for z=1:length(mes)
          j=find(index_date_ano(:,3)==mes(z,:));
          if isempty(j)
              Ano_Mes=datestr([k (z+1) 00 00 00 00],28);
              Ano_Mes=cellstr(Ano_Mes);
              lineaMedia=[LRatPFHTSinErrores(1:end-2,1),NaN*LRatPFHTSinErrores(1:end-2,1)];
          end
          if ~isempty(j)
              Ano_Mes=datestr(datet(index_date_ano(j(1),1),:),28);
              Ano_Mes=cellstr(Ano_Mes);
              lineaMedia=[LRatPFHTSinErrores(1:end-2,1),nanmean(LRatPFHTSinErrores(1:end-2,index_date_ano(j(1),1)+1:index_date_ano(j(end),1)+1),2)];
              %lineaMedia=[LRatPFHT(1:end-2,1),CLRatPFHT(1:end-2,index_date_ano(j(1),1)+1:index_date_ano(j(end),1)+1),2)];
          end
          Media_mes=[Media_mes lineaMedia(:,2)];
          Ano_MesT=[Ano_MesT Ano_Mes];
          %           Media_mes_std=reshape(nanstd(Media_mes,2),length(Media_mes_std),1)
          % Creamos un bucle del primer al último mes.
          % Si no tenemos datos para dicho mes columna NaN
          % Si tenemos datos que haga la media de los mismos.
          % Los unimos por columnas
          % Aparecen 12 por número de años que tengamos.
      end
      Media_ano= nanmean(Media_mes,2);
      LMedia_mes=[LRatPFHTSinErrores(1:end-2,1) Media_mes];
      LMedia_ano=[LRatPFHTSinErrores(1:end-2,1) Media_ano];
      % Creamos nuestra salida de medias asociadas a cada longitud de onda.
     
  end








%   linean=[];
%   for ano=year_ini:year_fin
%       anos=anos+1;
% 
%       for mes=1:12
%            indice=(ano-1978)*12+mes;
%           j=find(date(:,1)==ano & date(:,2)==mes);
%           if isempty(j)
%               linea=NaN*data(1,:);
%               lineas=NaN*data(1,:);
%               linean=NaN*data(1,:);
% % consideramos NMIN como en numero de dias minimo para considerar la media              
% %               if length(j)==1
% %                 linea=[length(i),data(j,2:end)];
% %                 lineas=[length(i),0*data(j,2:end)];                    
%           elseif length(j)<NMIN 
%                  linea=[length(i),NaN*data(1,2:end)];
%                  lineas=[length(i),NaN*data(1,2:end)];
%                  linean=[length(i),NaN*data(1,2:end)];
%           else    
%                 linea=[length(j),nanmean(LRatPFHT(1:end-2,2:length(j)))];
%                 lineas=[length(j),nanstd(LRatPFHT(1:end-2,2:length(j)))];
%                 linean=[length(i),sum(~isnan(LRatPFHT(1:end-2,2:length(j))))];                  
%           end
%          media(anos*12+mes,:)=[indice,ano,mes,linea];
%          sigma(anos*12+mes,:)=[indice,ano,mes,lineas];
%          ndat(anos*12+mes,:)=[indice,ano,mes,linean];
%          
%          media_dseason(anos*12+mes,:)=[indice,ano,mes,linea(:,2:end)-media_year(mes,3:end)];         
%       end
%   end
% 

     
