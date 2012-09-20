function [omidata,omiall,head]=gome_avdc_overpass(file)
% input filename or string with the file
% example 
%  omi=urlread('http://avdc.gsfc.nasa.gov/pub/data/satellite/Aura/OMI/V03/L2OVP/OMTO3/aura_omi_l2ovp_omto3_v8.5_izana_300.txt');
%  omi_overpass(omi);
% OMIDATA -> DATE OZONE LAT LON SZA DIS HEIG  OZONE N
%        (18,7,8,9,10,11,18,12]  
%Izana, Spain                                     OVPID: 300   Latitude:   28.290 deg.      Longitude:  343.510 deg.     Altitude:    2367 m
% GOME2_L2-METOPA,   Generated:  20-Sep-2011      by http://avdc.gsfc.nasa.gov
% 
% Criteria: within 100km radius
% 
% 1Datetime            : Date and time
% 2DOY                 : Day Of Year
% 3Day                 : Number of days since 1st of Jan, 1950
% 4MillisecondOfDay    : Millisecond Of Day
% 5Orbit               : GOME2 orbit number
% 6Scan                : Index of the PixelSubset within scan line
% 7Lat.                : Center latitude (degree)
% 8Lon.                : Center longitude (degree)
% 9Dist.               : Distance between the station and the pixel (km)
% 10SZA                 : Solar Zenith Angle (degree)
% 11Cld. Fr.            : Optical cloud recognition algorithm (OCRA) cloud fraction (no unit)
% 12Cld. Pr.            : Optical cloud recognition algorithm (OCRA) cloud pressure (mbar)
% 13VCD_BrO             : Vertical column density of BrO (mol/cm2)
% 14VCD_H2O             : Vertical column density of H2O (kg/m2)
% 15VCD_HCHO            : Vertical column density of HCHO (mol/cm2)
% 16VCD_NO2             : Vertical column density of NO2 (mol/cm2)
% 17VCD_NO2Trop         : Vertical column density of NO2Trop (mol/cm2)
% 18VCD_O3              : Vertical column density of O3 (DU)
% 19VCD_SO2             : Vertical column density of SO2 (DU)
% 
% Read format (FORTRAN/IDL): (i4.4,2i2.2,a1,3i2.2,i3.3,a1,i10,i6,i18,i8.5,i6,2f9.3,f7.1,f9.3,2f12.3,7e14.4)
% 
%            Datetime   DOY       Day  MillisecondOfDay   Orbit  Scan     Lat.     Lon.  Dist.      SZA    Cld. Fr.    Cld. Pr.       VCD_BrO       VCD_H2O      VCD_HCHO       VCD_NO2   VCD_NO2Trop        VCD_O3       VCD_SO2

if exist(file,'file')
  fid=fopen(file)
  for i=1:28
   c{i}=fgets(fid);
  end    
  c=strvcat(c);
  head=c;
  omi_data=textscan(fid,'','whitespace','TZ* ');
  fclose(fid)
else
  disp(file)
  disp('Not found');  
  %salida igual que read_overpas
  %omi_data=textscan(file,'','whitespace','TZ ','HeaderLines',28,'CollectOutput',1);
end
omi_data=cell2mat(omi_data);
omi_data(omi_data==-1.00 )=NaN;

%omidate=omi_data(:,5)-1+datenum(omi_data(:,4),1,1)+omi_data(:,6)/60/24/60;
omidate=datenum(1950,1,1)+omi_data(:,4)+omi_data(:,5)/24/60/60/1000;

omiall=[omidate,omi_data];
%salida igual que toms_overpas
omidata=[omidate,omi_data(:,[19,8,9,10,11,12,19,13])];









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
