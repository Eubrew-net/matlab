function [grp,g] = group_time( data,periods )
%UNTITLED Summary of this function goes here
% retorna los grupos definidos por tiempo
% periods=[datenum(2009,1,1),datenum(2009,04,20),datenum(2009,09,05),datenum(2009,12,31)];;
% temp_events{Cal.n_inst}={'init','intensity jump','after cal','end_year'}
% vline(periods,'k',temp_events{Cal.n_inst});
% 

g=NaN*ones( size(data,1) ,length(periods)-1);
for ii=1:length(periods)-1;
    g(:,ii)=(data(:,1)>periods(ii) & data(:,1)<periods(ii+1));   
end
[aux,grp]=find(g);

