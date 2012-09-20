%function [gomedata,gomeall]=gome_overpass(file)
%  read GOME SCIAMACHY overpass files
% output
% gomedata:
% GOME DATE OZONE LAT LON SZA DIS HEIG  OZONE N
% TOMS DATE OZONE LAT LON SZA DIS PRES  OZONE SCN
% gomealll - as file 
%
% ;For each satellite orbit going from north to south overpass data are identified using 
% ; a collocation radius of 300 km. From all collocations for a given orbit the  mean total ozone 
% ; is calculated. At high latitudes more than one orbit may pass a site, so that more than one 
% ; value may be provided for a given day, For questions contact mark.weber@uni-bremen.de  
% ;
% ; Typical overpass file name, e.g GO099HOH.dat, for overpass data is SSNNNMMM.dat with 
% ; SS=GO (GOME) or SS=SC (SCIAMACHY), NNN=WOUDC station number, MMM=abbreviation for WOUDC 
% ; location, e.g. HOH for Hohenpeissenberg.
% ;
% ; column 1: UTC overpass date [yyyymmdd]    
% ; column 2: UTC overpass time [hhmmss]
% ; column 3: station latitude 
% ; column 4: station longitude 
% ; column 5: mean SZA [degs] of all overpass data
% ; column 6: mean distance [km] of all satellite ground pixels within 300 km
% ; column 7: mean scene height [m] of all satellite ground pixels 
% ; column 8: mean satellite total ozone of all collocated data
% ; column 9: number of collocated satellite ground pixels during overpass
% ;
% ; sample output:
% ;
% ; 19950628 095907  47.8   11.3  28.6  130   785  303.8  15
% ; 19950630 103605  47.9   10.6  26.5  135   868  317.8  15
% ; 19950701 100453  47.8    9.8  28.5  185   753  321.0  23
% ; 

function [gomedata,gomeall]=gome_overpass(file)

 gomedat=textread(file,'','headerlines',0);
 s=sprintf('%.0fT%.0f|',[gomedat(:,1),gomedat(:,2)]');
 s=mmcellstr(s);
 gomedate=datenum(s,'yyyymmddTHHMMSS');
 % TOMS OVERPAS  DATE OZONE REF SO2 AI SZA
 % GOME OVERPAS  DATE OZONE DIS HEI NC SZA
 gomedata=[gomedate,gomedat(:,[8,3:end])];
 gomeall=[gomedate,gomedat(:,3:end)];
