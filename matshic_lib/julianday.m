function [jday,day,month,year]=julianday(ddate)
% function [jday,day,month,year]=julianday(ddate)
% 19 11 97 julian
% calculates julian day from time of PC
%jday is number;
% 3 12 97 julian correct julianday
% 10 12 1998 julian add day field.
% 27 1 99 julian use floor to convert jday to integer

if nargin==0,
  ddate=date;
end
if ~isempty(ddate),
[year,month,day]=datevec(ddate);

jday=floor(datenum(ddate)-datenum(year,1,1)+1); % calculate julianday
else
  jday=[];
  day=[];
  month=[];
  year=[];
end
    
%day=str2num(datestr(ddate,7));
%month=str2num(datestr(ddate,5));
%year=str2num(datestr(ddate,10));


