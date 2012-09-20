function [omidata,omiall,head]=omi_overpass(file)
% input filename or string with the file
% example 
%  omi=urlread('http://avdc.gsfc.nasa.gov/pub/data/satellite/Aura/OMI/V03/L2OVP/OMTO3/aura_omi_l2ovp_omto3_v8.5_izana_300.txt');
%  omi_overpass(omi);
% OMIDATA -> DATE OZONE LAT LON SZA DIS HEIG  OZONE N
%        (12,8,9,11,10,14,12,7]  
%Izana, Spain                                     OVPID: 300   Latitude:   28.290 deg.      Longitude:  -16.490 deg.     Altitude:    2367 m
% EOS Aura OMI OMTO3 (v8.5, Collection 3),   Generated:  18-Feb-2009      by http://avdc.gsfc.nasa.gov
% 
% Criteria : Direct geographic collocation; L2 quality flag equal to 0 or 1.
% 
%1 Datetime : Date and time%
%2           :   
%3 MJD2000  : Modified Julian Day 2000
%4 Year     : Year
%5 DOY      : Day Of Year
%6 sec. (UT): Elapsed time (seconds, UT)
%7 Orbit    : Aura orbit number
%8 CTP      : OMI Cross Track Position (0-59)
%9  Lat.     : CTP center latitude (degree)
%10 Lon.     : CTP center longitude (degree)
%11 Dist.    : Distance between the station and the CTP (km)
%12 SZA      : Solar Zenith Angle (degree)
%13 Ozone    : Total ozone column (DU)
%14 O3blwCld : Ozone below fractional cloud (DU)
%15 Surf. P. : Terrain pressure (hPa)
%16 Cld. P.  : Cloud Pressure (hPa)
%17 Cld. F.  : Cloud Fraction (dimensionless)
%18 Ref.     : Effective surface reflectivity at 360 nm (%)
%19 AI       : UV Aerosol Index (dimensionless)
%20 SOI      : SO2 Index (dimensionless)
% 
% Read format (FORTRAN/IDL): i4.4,2i2.2,a1,3i2.2,i3.3,a1,f14.6,i6,i5.3,i11.5,i8.5,i6,2f8.2,f7.1,2f9.2,3f10.2,f11.3,2f10.2,i8
% 
%Datetime       MJD2000  Year  DOY  sec. (UT)   Orbit   CTP    Lat.    Lon.  Dist.      SZA    Ozone  O3blwCld  Surf. P.   Cld. P.    Cld. F.      Ref.        AI     SOI 
% 28 lineas de cabecera

if exist(file,'file')
  fid=fopen(file)
  for i=1:28
   c{i}=fgets(fid);
  end    
  strvcat(c);
  head=c;
  omi_data=textscan(fid,'','whitespace','TZ ');
  fclose(fid)
else
  %salida igual que read_overpas  
  omi_data=textscan(file,'','whitespace','TZ ','HeaderLines',28,'CollectOutput',1);
end
omi_data=cell2mat(omi_data);
omi_data(omi_data==-90000.00 )=NaN;

omidate=omi_data(:,5)-1+datenum(omi_data(:,4),1,1)+omi_data(:,6)/60/24/60;


omiall=[omidate,omi_data];
%salida igual que toms_overpas
omidata=[omidate,omi_data(:,[13,9,10,12,11,15,13,8])];









%xlswrite([omidat,'',leg)

%20051118 134025825 	2.149.569.801	2005	322	49230	7154	22	33.61	-7.55	12.5	56.67	303.1	1006	6.6	0.78	2
%output_omi=[date time n1 n2 n3 n4 year jday orbit ctp lat lon Dis SZA Ozone  SurfP  Ref SOI ];    
%format_omi='%08dT%09dZ %f %d %d %d %d %f %f %f %f %f %f %f %f %f ';
%[date time n1 n2 n3 n4 year jday orbit ctp lat lon Dis sza Ozone SurfP Ref SOI AI ]=textread(file,format_omi,'headerlines',3,'endofline','\n');
% f=fopen(file,'rt')
% if f ~=-1 
%     fgets(f)
%     fgets(f)
%     fgets(f)
%     omidat=fscanf(f,format_omi);
% end

%tn7date=datenum(tn7dat(:,2),1,1)+tn7dat(:,3)-1+tn7dat(:,4)/60/60/24;
% tomsdata=[tn7date,tn7dat(:,[11:end,10])];
