%[ tomsdata,tomsall]=read_overpass(file)
% read toms overpass files
% output
%
%  
% tomsdata
% for compatibilty with GOME
% TOMS DATE OZONE LAT LON SZA DIS PRES  OZONE SCN
% GOME DATE OZONE LAT LON SZA DIS HEIG  OZONE N
%
% tomsall as origingal file except date fields
% TOMS OVERPASS 
%1   MJD  	Modified Julian Day. Astronomical Julian Day number*, less 2,400,000.5 The number is given to the nearest 1/10 day.
%2   Year 	The four-digit Gregorian year number of the TOMS measurement.
%3   Day 	The day number (day 1 through 366) of the TOMS measurement.
%4   sec-UT 	The number of seconds from midnight, Universal Time. on the day specified by Year and Day.
%5  2 SCN 	TOMS instrument scan position (1--35 for N7 and EP; 1--37 for Adeos)
%6  3 LAT 	Latitude of the center of the IFOV.
%7  4 LON 	Longitude of the same.
%8  5 DIS 	Distance from site and IFOV center position, in km.
%9  6 PT 	Terrain pressure at IFOV center, in (atm x 100)
%10 7 SZA 	Solar zenith angle, in degrees, at time and location of IFOV
%11 8 OZONE 	TOMS Version-7 best total ozone, in Dobson Units (DU)
%12 9 REF 	TOMS Version-7 reflectivity at 380 nm (N7, M3) or 360 nm (EP, Adeos).
%13 10 A.I. 	TOMS Version-7 aerosol index.
%14 11 SOI 	TOMS Version-7 Sulfur dioxide index.


function [tomsdata,tomsall]=toms_overpass(file)

 tn7dat=textread(file,'','headerlines',4);
 tn7date=datenum(tn7dat(:,2),1,1)+tn7dat(:,3)-1+tn7dat(:,4)/60/60/24;
 tomsdata=[tn7date,tn7dat(:,[11,6,7,10,8,9,11,5])];
 tomsall= [tn7date,tn7dat(:,5:end)];   
