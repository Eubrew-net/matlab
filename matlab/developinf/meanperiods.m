function [data_tab, data_events]=meanperiods(events, period, data)

% function [data_tab, data_events]=meanperiods(events, period, data)
%   
% INPUT
% 
%  - events: column 2=fecha_matlab; column 3=describing_string
%  - period: date vector (matlab date, integer)
%  - data  : matrix. First column is  matlab date.
% 
% TODO: resolution lower than an day
%
% OUTPUT:
% 
% - data_tab: struct with following variables
%             events = strig with the label
%             m      = mean same dimension as data,  %eventos cerrados abiertos  ?  
%             std    = std  same 
%             n      = n    same
%
% - matrix output:
%        1D - n  columns 
%        2D - m evets
%        3D - s stats (1 mean, 2 std, 3 nobs, ....)
% 
% TODO
% data_events; data splited by events, 3 dimension matrix,
%    data selected by events  
%    same dimension as data, third dimension is the event.
%       

events_=cell2mat(events(:,2));
clms=unique(group_time(period',events_));
if any(clms==0)
   events_=cat(1,period(1),events_);
   events_lbs=cat(2,'Bef. 1st evnt',events(clms(clms~=0),3)');
   clms=clms+1;
else
   events_lbs=events(clms,3)';    
end

if isempty(data)
   m=NaN*ones(length(clms),30); m(:,1)=evnts(clms); std=m; N=m;
   data_tab.m=m; data_tab.std=std; data_tab.N=N; data_tab.evnts=events_lbs;     
   return;
end
a=group_time(data(:,1),events_);
[id1 id2]=intersect(clms,unique(a));
[m std N]=grpstats(data,a,{@(x) nanmean(x,1),@(x) nanstd(x,1,1),'numel'});

data_tab.evnts=events_lbs;        
data_tab.m=NaN*ones(length(clms),size(m,2));
data_tab.m(:,1)=events_(clms);

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
data_events(:,:,3)=data_tab.N;






