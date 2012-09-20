%promedia mensualmente
%la primera columna es la fecha en formato matlab
%[media,media_year,media_dseason,sigma_year,sigma,ndat]=month_mean(data,NMIM)
% NMIN numero minimo de observaciones para considerarlo valido
% por defecto 12
% TODO: salidas en fecha agrupando año y medias mensuales
function stats=meanmonth(data,NMIN)
  
  if nargin==1
      NMIN=12;
  end
  year_ini=year(min(data(:,1)));
  year_fin=year(max(data(:,1)));
  
  date=datevec(data(:,1));
  date=date(:,[1,2]);
  anos=-1;
  media=[];
  media_year=[];
  sigma_year=[];
  media_dseason=[];
  sigma=[];
  ndat=[];  
  for mes=1:12
     j=find(date(:,2)==mes);
     if isempty(j) 
          linea=NaN*data(1,:);
          lineas=NaN*data(1,:);
     elseif length(j)<NMIN;
          linea=[length(j),NaN*(data(1,2:end))];
          lineas=[length(j),NaN*(data(1,2:end))];
     else
          linea=[length(j),nanmean(data(j,2:end))];
          lineas=[length(j),nanstd(data(j,2:end))];
     end
     media_year(mes,:)=[mes,linea];
     sigma_year(mes,:)=[mes,lineas];
  end
     
  linean=[];
  for ano=year_ini:year_fin
      anos=anos+1;

      for mes=1:12
           indice=(ano-1978)*12+mes;
           fecha_m=datenum(ano,mes,15);
          j=find(date(:,1)==ano & date(:,2)==mes);
          if isempty(j)
              linea=NaN*data(1,:);
              lineas=NaN*data(1,:);
              linean=NaN*data(1,:);
% consideramos NMIN como en numero de dias minimo para considerar la media              
%               if length(j)==1
%                 linea=[length(i),data(j,2:end)];
%                 lineas=[length(i),0*data(j,2:end)];                    
          elseif length(j)<NMIN 
                 linea=[length(i),NaN*data(1,2:end)];
                 lineas=[length(i),NaN*data(1,2:end)];
                 linean=[length(i),NaN*data(1,2:end)];
          else    
                linea=[length(j),nanmean(data(j,2:end))];
                lineas=[length(j),nanstd(data(j,2:end))];
                linean=[length(i),sum(~isnan(data(j,2:end)))];                  
          end
         media(anos*12+mes,:)=[fecha_m,ano,mes,linea];
         sigma(anos*12+mes,:)=[fecha_m,ano,mes,lineas];
         ndat(anos*12+mes,:)=[fecha_m,ano,mes,linean];
         media_dseason(anos*12+mes,:)=[fecha_m,ano,mes,linea(:,2:end)-media_year(mes,3:end)];         
      end
  end


 stats=struct('media',media,'media_year',media_year,...
              'media_dseason',media_dseason,'sigma_year',sigma_year,...
              'sigma',sigma,'ndat',ndat);    
