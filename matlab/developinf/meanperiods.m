
function [data_tab m std N]=meanperiods(events, period, data)

evnts=cell2mat(events(:,2));
clms=unique(group_time(period',evnts));
events_lbs=events(unique(clms),3)';

if isempty(data)
   m=NaN*ones(length(clms),30); m(:,1)=evnts(clms); std=m; N=m;
   data_tab.m=m; data_tab.std=std; data_tab.N=N; data_tab.evnts=events_lbs;     
   return;
end
a=group_time(data(:,1),evnts); [id1 id2]=intersect(clms,unique(a));
[m std N]=grpstats(data,a,{@(x) nanmean(x,1),@(x) nanstd(x,1,1),'numel'});

data_tab.evnts=events_lbs;        
data_tab.m=NaN*ones(length(clms),size(m,2)); data_tab.m(:,1)=evnts(clms);
data_tab.std=data_tab.m; data_tab.N=data_tab.m;

data_tab.m(id2,:)=m; data_tab.std(id2,:)=std; data_tab.N(id2,:)=N;
