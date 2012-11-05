function [config,TC,DT,extrat,absx,AT] = process_config( bfile,config_file)
%process configuration file
% TODO : comprobar es innecesario el if(cfg), enviar siempre la fecha del
% fichero
%   Detailed explanation goes here
% READ CONFIGURATION
% 1 si no le damos configuracion-> la lee del fichero B
% 2 si la configuracion es el nombre del fichero ICF la lee del fichero
% 2 si tiene dos configuraciones la del fichero B pasa a al 3
% 3 si es una variable considera que es una tabla de configuracion, config
% 1 es la del fichero b config 2 es la de la matriz de configuraciones
% config:
% colunna 1 % 1º configuracion (cuando 2 configs.) o la del fichero B
% columna 2 % 2º configuracion (o única configuración)
% columna 3 % configuracion del fichero B
%
%
% Varialbes internas
% config_, TC_.... matriz de configuracion
% config_B,TC_B.... Configuracion del fichero B
% config_1,  configuracion 1º ....
% config_2 , configuracion 2º 

% primera configuracio la del fichero B

%determinamos la fecha del fichero
[path,name,ext]=fileparts(bfile);
fileinfo=sscanf([name,ext],'%c%03d%02d.%03d');
datefich=datejul(fileinfo(3),fileinfo(2));


[config_bfile,TC_B,DT_B,extrat_B,absx_B,AT_B]=readb_config(bfile);
config(:,1)=config_bfile;
config(:,3)=config_bfile;
TC_B=tc_coeff(TC_B);

% la primera es la del fichero B, en el caso de una sola configuración
    TC_1=TC_B; TC_2=NaN*TC_1;
    AT_1=AT_B;AT_2=NaN*AT_1;
    DT_1=DT_B;DT_2=NaN*DT_1;
    extrat_1=extrat_B;extrat_2=NaN*extrat_1;
    absx_1=absx_B;absx_2=NaN*absx_1;
    
% matriz de configuracion fecha+ icf
if nargin>1 & isnumeric(config_file)  % matriz  de configuraciones
    cal_idx=max(find(config_file(1,:)<=datefich(1))); % calibracion mas proxima
    datestr(config_file(1,cal_idx) )
    if ~isnan(config_file(2:6,cal_idx))
        TC_=config_file(2:6,cal_idx); end
    if ~isnan(config_file(13,cal_idx))
        DT_=config_file(13,cal_idx);  end
    if ~isnan(config_file(11:12,cal_idx))
        extrat_=config_file(11:12,cal_idx); end %    B1=extrat(1);B2=extrat(2);
    if ~isnan(config_file(8:10,cal_idx))
        absx_=config_file(8:10,cal_idx);    end % A1=absx(1);A2=absx(2);A3=absx(3);
    if ~isnan(config_file(17:22,cal_idx))
        AT_=config_file(17:22,cal_idx);     end % atenuacion
    config(:,2)=config_file(:,cal_idx); %quitamos la fecha
    TC_2=tc_coeff([TC_(:)',config_file(26,cal_idx)]'); % temperature coef for lamda1    
    
elseif  nargin>1 && ischar(config_file) % 1 fichero configuracion/ matriz de configuraciones
    
    [fpath,ffile,fext]=fileparts(config_file);
    if strcmp(fext,'.cfg')
        [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file,datefich(1));
        config(:,2)=config_2;
        TC_2=tc_coeff(TC_2);           
    else
        [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file);
        config(:,2)=config_2;
        config(:,1)=config_bfile;
        TC_2=tc_coeff(TC_2);
    end
    
elseif nargin>1 && iscellstr(config_file) % dos configuraciones
%    Config1
    [fpath,ffile,fext]=fileparts(config_file{1});
    if strcmp(fext,'.cfg')
      [config_1,TC_1,DT_1,extrat_1,absx_1,AT_1]=read_icf(config_file{1},datefich(1));
    else
      [config_1,TC_1,DT_1,extrat_1,absx_1,AT_1]=read_icf(config_file{1});     
    end
    config(:,1)=config_1;
    TC_1=tc_coeff(TC_1);   

%    Config2
    [fpath,ffile,fext]=fileparts(config_file{2});
    if strcmp(fext,'.cfg')
      [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file{2},datefich(1));
    else
      [config_2,TC_2,DT_2,extrat_2,absx_2,AT_2]=read_icf(config_file{2});
    end
    config(:,2)=config_2;
    TC_2=tc_coeff(TC_2);   
    
elseif nargin==1
    TC_1=TC_B; TC_2=NaN*TC_1;
    AT_1=AT_B;AT_2=NaN*AT_1;
    DT_1=DT_B;DT_2=NaN*DT_1;
    extrat_1=extrat_B;extrat_2=NaN*extrat_1;
    absx_1=absx_B;absx_2=NaN*absx_1;   
else
    if nargin~=1
        disp('ERROR de configuracion');
    end
end
config=[config;repmat(datefich(1),1,size(config,2))];

%% compatible con versiones antiguas
TC=[TC_1;TC_2;TC_B];
AT=[AT_1,AT_2,AT_B];
AT=AT';
DT=[DT_1,DT_2,DT_B];
DT=DT';
extrat=[extrat_1,extrat_2,extrat_B];
absx=[absx_1,absx_2,absx_B];



    function TC=tc_coeff(TC)
        %% correccion de los coeficientes de temperatura
        % 5420 REM get O3 TC's
        % 5422 FOR J=2 TO 6:INPUT#8,TC(J):NEXT
        % 5424 TC(0)=TC(2)-TC(5)-3.2*(TC(5)-TC(6)):TQ(0)=TC(0)
        % 5426 TC(1)=TC(3)-TC(5)-.5*(TC(4)-TC(5))-1.7*(TC(5)-TC(6)):
        % cambiamos los indices.
        TC=TC(:)';
        TC=[NaN,NaN,TC];
        TC(1)=TC(3)-TC(6)-3.2*(TC(6)-TC(7));
        TC(2)=TC(5)-TC(6)-.5*(TC(5)-TC(6))-1.7*(TC(6)-TC(7));
    end


    










end

