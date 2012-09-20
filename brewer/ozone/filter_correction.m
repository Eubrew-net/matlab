function [summary, summary_old]=filter_correction(summary,summary_old,inst,A,ETC_C,date_range)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%ETC_C=[0,0,0,7,15,0];
summary=summary{inst};
summary_old=summary_old{inst};

if nargin==5
    date_range=[];
end

A_factor_new=A.new(inst)*10.*summary(:,3)';
A_factor_old=A.old(inst)*10.*summary_old(:,3)';

Fn=1+summary(:,5)/64;
Fc_new=ETC_C(Fn);

Fn=1+summary_old(:,5)/64;
Fc_old=ETC_C(Fn);


FC_new=Fc_new./A_factor_new;
FC_old=Fc_old./A_factor_old;


if ~isempty(date_range)
   FC_new(summary(:,1)<date_range(1))=0;
   Fc_new(summary(:,1)<date_range(1))=0;
   FC_old(summary_old(:,1)<date_range(1))=0;
   Fc_old(summary_old(:,1)<date_range(1))=0;
   
   if length(date_range)>1
      FC_new(summary(:,1)>date_range(2))=0;
      Fc_new(summary(:,1)>date_range(2))=0;
      FC_old(summary_old(:,1)>date_range(2))=0;
      Fc_old(summary_old(:,1)>date_range(2))=0;
   end
end
                    
        
        summary(:,[6,12])=matadd(summary(:,[6,12]),-FC_new');   % cal2       
        summary(:,9)=summary(:,8); % MS9
        summary(:,8)=summary(:,9)-Fc_new'; % MS9 corrected
    
        summary_old(:,[6,12])=matadd(summary_old(:,[6,12]),-FC_old');   % cal2       
        summary_old(:,9)=summary_old(:,8); % MS9
        summary_old(:,8)=summary_old(:,9)-Fc_old'; % MS9 corrected
    

