
function cfg=getcfgs(period,config,varargin)

% function  cfg=getcfgs(Cal,config,varargin)
% 
% A simple function to get cal. constants used to recalculate Brewer data
% 
% INPUT:
% - period: Periodo de analisis (vector de fechas matlab)
% - config: Configuraciones a procesar. Puede ser:
%           1) path a icf (string)
%           2) matriz de calibraciones
% - events: Vector de definición de eventos (see e.g. getevents function). 
%           Opcional (por defecto vacio)
% 
% OUTPUT:
% - cfg   : Used configs (same number as events). Two-fields structure: 
%           Cal. constants / legend. All fields are named as follows:
%
%     'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5'
%     'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)','csn'
%     'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5'
%     'R6','R5','F#2_C','F#3_C','F#4_C'
% 
% En el caso de pasar un vector de eventos la funcion devuelve una configuracion por evento
% Si events=[], entonces la funcion devuelve tantas configuraciones como eventos hay definidos
% en la matriz de calibracion para el periodo de analisis considerado (en el caso de un icf 
% devolvera una unica configuracion)
% 
% 
% EXAMPLE: 
%        events_cfg=getcfgs(Cal,icf)   
% 
% Podemos calcular vector de eventos como
%     event_info=getevents(Cal,'grp',arg.Results.grp);
% 
% o bien definirlo
%     events_cfg=struct('dates',datenum(2014,1,[1 14]),'labels',{{'uno','dos'}});
% 
% y usarlo como entrada de getevents
%     events_cfg=getcfgs(Cal,icf,'events',event_info.dates);    
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='getcfgs';

arg.addRequired('period', @isfloat);
arg.addRequired('config', @(x)isfloat(x) || ischar(x));

arg.addParamValue('events', [], @isfloat); 

arg.parse(period, config, varargin{:});

%%
cfg.legend={
    'Usage date','o3 Temp coef 1','o3 Temp coef 2','o3 Temp coef 3','o3 Temp coef 4','o3 Temp coef 5',...
    'O3 on O3 Ratio','ETC on O3 Ratio','Dead time (sec)','csn',...
    'ND filter 0','ND filter 1','ND filter 2','ND filter 3','ND filter 4','ND filter 5',...
    'R6','R5','F#2_C','F#3_C','F#4_C'
           };      
       
%%
if ischar(config)                 % Path a fichero de configuracion
   [fpath,ffile,fext]=fileparts(config);
   if ~strcmpi(fext,'.cfg')
      cal=read_icf(config); cal_id=[1 2:6 8 11 13 14 17:22 27:28 29:31];
      if ~isempty(arg.Results.events) % Configuraciones asociadas a los eventos
         cfg.data=repmat(cal(cal_id),1,length(arg.Results.events));          
      else                            % Configuraciones asociadas al periodo de analisis (solo 1)
         cfg.data=NaN*ones(length(cfg.legend),length(arg.Results.events));
         icf_id=group_time(arg.Results.events,config(2,3:end));
         cfg.data(:,icf_id~=0)=config(cal_id,icf_id(icf_id~=0)+2);

         cfg.data=cal(cal_id,:);
      end
   else
      cal=load(config);     cal_id=[1 2:6 8 11 13 14 17:22 27:28 29:31];
      if ~isempty(arg.Results.events) % Configuraciones asociadas a los eventos
         cfg.data=NaN*ones(length(cfg.legend),length(arg.Results.events));
         icf_id=group_time(arg.Results.events,cal(1,:));
         cfg.data(:,icf_id~=0)=cal(cal_id,icf_id(icf_id~=0));     
      else                            % Configuraciones asociadas al periodo de analisis 
         icf_id=unique(group_time(period',cal(1,:)));
         if any(icf_id==0)  
            cfg.data=NaN*ones(length(cfg.legend),length(icf_id));
            cfg.data(:,icf_id~=0)=cal(cal_id,icf_id(icf_id~=0));  cfg.data(1,1)=period(1);          
         else
            cfg.data=cal(cal_id,icf_id);
         end                    
      end   
   end
         
elseif isfloat(config) % Matriz de calibracion (una sola calibracion!!-> la pasada)
     cal_id=[2 3:7 9 12 14 15 18:23 28:32];    
     if ~isempty(arg.Results.events)% Configuraciones asociadas a los eventos
        cfg.data=NaN*ones(length(cfg.legend),length(arg.Results.events));
        icf_id=group_time(arg.Results.events,config(2,3:end));
        cfg.data(:,icf_id~=0)=config(cal_id,icf_id(icf_id~=0)+2);
     else                           % Configuraciones asociadas al periodo de analisis
        icf_id=unique(group_time(period',config(2,3:end)));
        if any(icf_id==0)  
           cfg.data=NaN*ones(length(cfg.legend),length(icf_id));
           cfg.data(:,icf_id~=0)=config(cal_id,icf_id(icf_id~=0)+2);  cfg.data(1,1)=period(1);          
        else
           cfg.data=config(cal_id,icf_id+2);
        end
     end
end

