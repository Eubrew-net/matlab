function [diaj,datev]=diaj(date)
   if isstr(date) date=datenum(date); end
   
   datev=datevec(date);
   diaj=date-datenum(datev(:,1),1,1)+1;
   