function data_tab=meanperiods(data,event)

%   function data_tab = meanperiods(data,event)
%  
% Calculo de estadisticas (promedio, desviacion standard y numero de elementos) para
% un conjunto de periodos. Los intervalos de produccion de estadisticas estan definidos 
% a partir de un vector de eventos (fechas) 
% 
% INPUT
% 
%  - data  : matrix. First column is date (matlab)
%  - events: Salida de la funcion getevents (dates y labels)
% 
% TODO: resolution lower than an day
%
% OUTPUT:
%  
%  - data_tab: Structure with following fields
% 
%             1) m      = mean 
%             2) std    = std   
%             3) n      = n    
%             4) events = cellstring with events' labels
%
% - matrix output: TODO
%        1D - n  columns 
%        2D - m evets
%        3D - s stats (1 mean, 2 std, 3 nobs, ....)
% 
% TODO
% data_events; data splited by events, 3 dimension matrix,
%    data selected by events  
%    same dimension as data, third dimension is the event.
%       
 
%%
if isempty(data)
   m=NaN*ones(event.dates,30); m(:,1)=event.dates; std=m; N=m;
   data_tab.m=m; data_tab.std=std; data_tab.N=N; data_tab.evnts=event.labels;     
   return;
end

a=group_time(data(:,1),event.dates);
if any(a==0)
   fprintf('Removing data before 1st event as input.\n');
   data(a==0,:)=[]; a(a==0)=[]; 
end
[m std N]=grpstats(data,a,{@(x) nanmean(x,1),@(x) nanstd(x,1,1),'numel'});

%% Structure: init
data_tab.m=NaN*ones(length(event.dates),size(m,2));
data_tab.m(:,1)=event.dates; data_tab.std=data_tab.m; data_tab.N=data_tab.m;

% assigning
data_tab.m(unique(a),:)=m; data_tab.m(:,1)=event.dates;
data_tab.std(unique(a),:)=std;
data_tab.N(unique(a),:)=N;
data_tab.evnts=event.labels;        

%% Matrix: init
% n_events=length(event.labels); n_col=size(data,2);
% data_events=NaN*ones(n_events,n_col,3);
% 
% % assigning
% data_events(:,:,1)=data_tab.m;
% data_events(:,:,2)=data_tab.std;
% data_events(:,:,3)=data_tab.N;
