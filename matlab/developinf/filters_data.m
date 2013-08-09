function filters_data(fi_data,Cal,varargin)

%%
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'filter_data';

% input obligatorio
arg.addRequired('fi_data'); 
arg.addRequired('Cal'); 

% input param - value
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1)); % por defecto, no plot

% validamos los argumentos definidos:
arg.parse(fi_data, Cal, varargin{:});
mmv2struct(arg.Results);

% arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
% arg.addParamValue('config',[], @isfloat); % por defecto, nominal (ver linea 151)
% arg.addParamValue('path_to_file', '.', @isstr); % por defecto, current directory

fi=fi_data{Cal.n_inst}.fi;  fi_avg=fi_data{Cal.n_inst}.fi_avg; 
% control de fechas
if ~isempty(date_range)
    fi(fi_avg(:,1)<date_range(1),:,:)=[]; fi_avg(fi_avg(:,1)<date_range(1),:)=[];   
   if length(date_range)>1
    fi(fi_avg(:,1)>date_range(2),:,:)=[]; fi_avg(fi_avg(:,1)>date_range(2),:)=[];
   end
end
fech=fi_avg(:,1); temp=repmat(fi_avg(:,4),1,6); 

%%
O3W=[   0.00      0.00   -1.00    0.50    2.20   -1.70];
label_filter={'Int.','F{\it#1}','F{\it#2}','F{\it#3}','F{\it#4}','F{\it#5}'};

% correccion de filtros
o3w=cell(size(fi,1),1);
for ii=1:size(fi,1)
    o3w{ii}=O3W*squeeze(fi(ii,4:2:end,2:end)); 
end
o3f=cell2mat(o3w);
[a b c]=grpstats([fech,temp(:,1),o3f],{year(fech),month(fech)},{'mean','sem','numel'});

%% Ploteo
fh=figure; set(fh,'tag','FI_TIME_ETC2');
suptitle([Cal.brw_name{Cal.n_inst}, ' ETC correction factor time evolution. Monthly means']);
errorbar(a(:,1),a(:,3),b(:,3),'Color','k','Marker','s'); 
hold on
errorbar(a(:,1),a(:,4),b(:,4),'Color','b','Marker','s'); 
errorbar(a(:,1),a(:,5),b(:,5),'Color','r','Marker','s'); 
errorbar(a(:,1),a(:,6),b(:,6),'Color','g','Marker','s'); 
errorbar(a(:,1),a(:,7),b(:,7),'Color','m','Marker','s'); 
legend(label_filter(2:end), 'Orientation','Horizontal','Location','NorthOutside');
ylabel('ETC correction');
legend(label_filter(2:end),'Location','North','orientation','horizontal');
datetick; grid;

%% Tabla
fprintf('\r\nETC corr Monthly means: %s\r\n', Cal.brw_name{Cal.n_inst});
tabla_data=cellfun(@(x,y) strcat(num2str(x),' +/- ',num2str(y)),num2cell(a(:,3:end)),num2cell(b(:,3:end)),'UniformOutput',0); 
displaytable(tabla_data,{'ETC corr(FW#21)','ETC corr(FW#22)','ETC corr(FW#23)','ETC corr(FW#24)','ETC corr(FW#25)'},...
             15,'.0f',cellstr(datestr(a(:,1),1)));

