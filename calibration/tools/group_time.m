function [ grp,g ] = group_time( data,periods )
% function [ grp,g ] = group_time( data,periods )
% clasify data in time periods 
% input: % data= time  
%   time periods; assume periods period(i) -> period(i+1)
% output  
%   grp= assing data to periods
%   g  = group matrix 
%
%Updates: before and after the periods
% Example standard lamp correction
%    SL_NEW_REF -> [date R6_ref]  ausume periods date(i)-> date(i+1) R6(i)  
%    R6         -> date measured R6           
%           y=group_time(R6(:,1),SL_NEW_REF(:,1));
%           ozo_c=ozone1(:,15)+(SL_NEW_REF(y,2)-R6(:,2))./(10*A.new(y,2).*ozone1(:,5));
%  will be an error if SL_NEW_REF do not include  reference values for the
%  period. Line 29.
% 
% periods=[datenum(2009,1,1),datenum(2009,04,20),datenum(2009,09,05),datenum(2009,12,31)];;
% temp_events{Cal.n_inst}={'init','intensity jump','after cal','end_year'}
% vline(periods,'k',temp_events{Cal.n_inst});
% 

g=NaN*ones( size(data,1) ,length(periods)+1);
for ii=0:length(periods);
    if(ii==0)
     g(:,ii+1)=(data(:,1)<periods(1));% Las configs. se aplican a partir de   
    elseif ii==length(periods)
     g(:,ii+1)=(data(:,1)>=periods(end));    
    else    
     g(:,ii+1)=(data(:,1)>=periods(ii) & data(:,1)<periods(ii+1));% Las configs. se aplican a partir de
    end
end
[aux,grp]=find(g);
grp=grp-1;
if(any(grp==0))
    disp('index =0 will be an error if you use for matrix asigment');
end
end

