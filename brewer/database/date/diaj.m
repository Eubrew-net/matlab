function [diaj,datev]=diaj(date)
   if isstr(date)
       date=datenum(date);
   end;
   date=date(:);  
   datev=datevec(date);
   diaj=fix(date)-datenum(datev(:,1),1,1)+1;
   