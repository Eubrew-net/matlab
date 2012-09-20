function [h2o,Outliers]=h2o_avg(file,varargin)

% 1. Julian day (jjjyy)
% 2. Temperature at the PMT (°C)
% 3. ‘Fan’ Temperature in °C - used in the absolute humidity calculation.
% 4. Temp of base plate (°C)
% 5. Moisture measured in grams of water per cubic meter of air.
% 6. Relative Humidity (%)    

% Validamos argumentos
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'h2o_avg';
% Input obligatorio
arg.addRequired('file');
% Input param - value
arg.addParamValue('outlier_flag','',@(x)(any(strcmp(x,'h2o')) || isempty(x)));% por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
% Validamos los argumentos definidos:
arg.parse(file, varargin{:});
mmv2struct(arg.Results);

%%
try
  a=read_avg_line(file,1000);
catch
  disp(file);  aux=lasterror;  disp(aux.message)
  return;
end

h2o=avgfech(a);
if ~isempty(date_range)
    try
        h2o=h2o(h2o(:,1)>arg.Results.date_range(1),:);
        if length(arg.Results.date_range)>1
            h2o=h2o(h2o(:,1)<arg.Results.date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
end

%% OUTLIERS
if ~isempty(outlier_flag)
    % outliers Lamp I
    [ax,bx,cx,dx]=outliers_bp(h2o(:,7),2);%  Moisture measured in grams of water per cubic meter of air
else
    dx=[];
end

%%
f=figure; set(f,'Tag','H2OAVG');
h=mmplotyy(h2o(:,1),h2o(:,7),'.k',h2o(:,5),'.b'); set(h,'LineWidth',2.5)
h=mmplotyy('Fan Temperature (\circC)');     set(h,'FontWeight','bold');  hold on
h=plot(h2o(dx,1),h2o(dx,7),'+r');  set(h,'LineWidth',2.5);      hold off
datetick('x',25,'keeplimits','keepticks'); rotateticklabel(gca,20); grid; 
ylabel('Absolute Humidity (gm^{-3})','FontWeight','bold');
sup=suptitle(sprintf('%s%s','Humidity, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(sup,'FontWeight','bold'); pos=get(sup,'Position');
legend('Hum (gm^{-3})','Temp (\circC)','Location','Best')

%% Outliers
Outliers =[h2o(dx,:)];
