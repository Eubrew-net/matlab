% retorna decimal
function [diaj,datev]=diaj2(date)
   if isstr(date)
       date=datenum(date);
   end;
   date=date(:);  
   datev=datevec(date);
   diaj=(date)-datenum(datev(:,1),1,1)+1;
   