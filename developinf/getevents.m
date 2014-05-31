function event_info=getevents(Cal, varargin)

% function event_info=getevents(Cal, varargin)
% 
% Calculo de periodos de analisis a partir de un periodo de tiempo determinado  
% El resultado se puede usar como input de la funcion meanperiods para determinar 
% diferentes agrupamientos. Se utilizan como flag los siguientes:
% 
% - week        : promedios semanales
% - month       : promedios mensuales
% - events      : promedios por eventos
% - month+events: promedios por meses y por eventos
% 
% INPUT
% 
% - Cal : Variable de definiciones -> Cal.Date.CALC_DAYS (periodo de analisis),
%         Cal.n_inst (instrumento a procesar), Cal.events (eventos según se han definido en la 
%         matriz de calibraciones), Cal.events_raw (etiquetas asociadas a los eventos de entrada)
% 
% - grp : argumento de entrada opcional para definir el tipo de eventos requerido. Valores posibles:
%         'events','month','week','month+events'. Por defecto "eventos" mesuales (month)
% 
% OUTPUT 
% 
% - event_info : Estructura con los campos siguientes
%                1) event_info.dates  : Fechas asociadas a los eventos calculados. 
%                2) event_info.labels : Etiquetas asociadas a los eventos calculados
% 
% EXAMPLE:
%               event_info=getevents(Cal,'grp','month');
% 

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='getevents';

arg.addRequired('Cal', @isstruct);
arg.addParamValue('grp', 'month', @(x)any(strcmpi(x,{'events','month','week','month+events'}))); 
% por defecto eventos

arg.parse(Cal, varargin{:});

%%
period=Cal.Date.CALC_DAYS;
% group_time(data,periods)-> si en data hay fechas inferiores a periods(1) tendremos el 0
switch arg.Results.grp
    
    case 'events'  % promedios por eventos segun se ha definido en la matriz de cal. 
        % De todos los eventos posibles (Cal.events{Cal.n_inst}), nos quedamos 
        % con aquellos definidos dentro del periodo de analisis (Cal.Date.CALC_DAYS)
        % Contemplamos tambien el caso period < 1st event (label = 'Bef. 1st evnt')
        events_=Cal.events{Cal.n_inst}(:,1);
        clms=unique(group_time(period',events_));
        if any(clms==0) % Hay datos antes del primer evento en la matriz. Los contemplamos
           events_=cat(1,period(1),events_(clms(clms~=0)));
           events_lbs=cat(2,'Bef. 1st evnt',Cal.events_raw{Cal.n_inst}(clms(clms~=0),3)');
        else
           events_=events_(clms);
           events_lbs=Cal.events_raw{Cal.n_inst}(clms,3)';    
        end
        
    case 'month'  % Promedios mensuales
        % Ahora los eventos seran los meses en period
        events_=unique(datenum(year(period),month(period),1))';
        events_lbs=cellstr(datestr(events_,12))';
        
    case 'month+events' % Promedios mensuales y por eventos
        % unimos los dos conjuntos
        months=unique(datenum(year(period),month(period),1));
        events_=scan_join(months',Cal.events{Cal.n_inst}(:,1));
        clms=unique(group_time(period',events_));% eventos incluidos en el periodo de analisis
        % Tal y como he definido months (1er dia), no deberíamos tener clms=0
        events_=events_(clms);

        events_lbs=cellstr(datestr(events_,2))'; 
        [no id_lbl id_evn]=intersect(events_,Cal.events{Cal.n_inst}(:,1)); 
        events_lbs(id_lbl)=Cal.events_raw{Cal.n_inst}(id_evn,3)';    
        
    case 'week'  % Promedios semanales
        % Ahora los eventos seran las semanas en period
        events_=unique(datenum(year(period),1,weeknum(period)*7-7))';      
        events_lbs=cellstr(datestr(events_,25))';
        clms=unique(group_time(period',events_));
        % no se por que (solo ocurre con el 145)
        if length(clms)~=length(events_)
            events_(end)=[];  events_lbs(end)=[];
        end
end

event_info.dates=events_; event_info.labels=events_lbs; 
