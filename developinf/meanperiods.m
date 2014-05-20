function [data_stat, data_events]=meanperiods(events, period, data)
% function [data_stat, data_events]=meanperiods(events, period, data)
%   
% imput:
%  events: fecha_lotus fecha_matlab describing_string  icf SL_ref 
%  period: date vector :matlab date  (integer)
%  data: matrix first column is  matlab date.
% dates are integers (day).
%% TODO: resolution lower than an day
%
% output: 
% data_tab
%  .events= strig with the label
%  .m     = mean same dimension as data,  %eventos cerrados abiertos  ?  
%  .std   = std  same 
%  .n     = n    same
%
% matrix output
%  1 - n  columns 
%  2 - m evets
%  3 - s stats (1 mean, 2 std, 3 nobs, ....)
%% TODO
% data_events; data splited by events, 3 dimension matrix,
%    data selected by events  
%    same dimension as data, third dimension is the event.
%       
n_out=3; %(mean std and n)
events=cell2mat(events(:,2));
clms=unique(group_time(period',evnts));
events_lbs=events(unique(clms),3)';

if isempty(data)
   m=NaN*ones(length(clms),30); m(:,1)=evnts(clms); std=m; N=m;
   data_tab.m=m; data_tab.std=std; data_tab.N=N; data_tab.evnts=events_lbs;     
   return;
end
a=group_time(data(:,1),events);
[id1 id2]=intersect(clms,unique(a));
[m std N]=grpstats(data,a,{@(x) nanmean(x,1),@(x) nanstd(x,1,1),'numel'});

data_tab.evnts=events_lbs;        
data_tab.m=NaN*ones(length(clms),size(m,2));
data_tab.m(:,1)=evnts(clms);

%init
data_tab.std=data_tab.m;
data_tab.N=data_tab.m;



data_tab.m(id2,:)=m;
data_tab.std(id2,:)=std;
data_tab.N(id2,:)=N;

n_events=length(events_lbs);
n_col=size(data,2);

data_events=NaN*ones(n_events,n_col,3);

data_events(:,:,1)=data_tab.m;
data_events(:,:,2)=data_tab.std;
data_events(:,:,2)=data_tab.N;






