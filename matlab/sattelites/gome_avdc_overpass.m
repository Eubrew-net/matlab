function [omidata,omiall,head]=gome_avdc_overpass(file)
% input filename or string with the file
% example 
%  omi=urlread('http://avdc.gsfc.nasa.gov/pub/data/satellite/Aura/OMI/V03/L2OVP/OMTO3/aura_omi_l2ovp_omto3_v8.5_izana_300.txt');
%  omi_overpass(omi);
% OMIDATA -> DATE OZONE LAT LON SZA DIS HEIG  OZONE N
%        (12,8,9,11,10,14,12,7]  
% Izana, Spain                                     OVPID: 300   Latitude:   28.290 deg.      Longitude:  343.510 deg.     Altitude:    2367 m
% GOME_L2-ERS2,   Generated:   7-Jul-2011      by http://avdc.gsfc.nasa.gov
% 
% Criteria: within 100km radius
% 
% 1Day                 : Number of days since 1st of Jan, 1950  
% 2MillisecondOfDay    : Millisecond Of Day
% 3Orbit               : GOME orbit number
% 4Scan                : Index of the PixelSubset within scan line
% 5Lat.                : Center latitude (degree)
% 6Lon.                : Center longitude (degree)
% 7Dist.               : Distance between the station and the pixel (km)
% 8SZA                 : Solar Zenith Angle (degree)
% 9Cld. Fr.            : Optical cloud recognition algorithm (OCRA) cloud fraction (no unit) (FillValue=-1.0)
% 10Cld. Pr.            : Optical cloud recognition algorithm (OCRA) cloud pressure (mbar) (FillValue=-1.0)
% 11VCD_NO2             : Vertical column density of NO2 (mol/cm2) (FillValue=-1.0)
% 12VCD_NO2_Err         : Error on vertical column density of NO2 (%) (FillValue=-1.0)
% 13VCD_O3              : Vertical column density of O3 (DU) (FillValue=-1.0)
% 14VCD_O3_Err          : Error on vertical column density of O3 (%) (FillValue=-1.0)
% % OMIDATA -> DATE OZONE LAT LON SZA DIS HEIG  OZONE N
%                    14   5    6   8  7    4     14   3    
%        Day  MillisecondOfDay   Orbit  Scan     Lat.     Lon.  Dist.      SZA    Cld. Fr.    Cld. Pr.       VCD_NO2   VCD_NO2_Err        VCD_O3    VCD_O3_Err
% OY  sec. (UT)   Orbit   CTP    Lat.    Lon.  Dist.      SZA    Ozone  O3blwCld  Surf. P.   Cld. P.    Cld. F.      Ref.        AI     SOI 
% 22 lineas de cabecera

if exist(file,'file')
  fid=fopen(file)
  for i=1:22
   c{i}=fgets(fid);
  end    
  c=strvcat(c);
  head=c;
  omi_data=textscan(fid,'','whitespace','TZ ');
  fclose(fid)
else
  %salida igual que read_overpas  
  omi_data=textscan(file,'','whitespace','TZ ','HeaderLines',28,'CollectOutput',1);
end
omi_data=cell2mat(omi_data);
omi_data(omi_data==-1.00 )=NaN;

%omidate=omi_data(:,5)-1+datenum(omi_data(:,4),1,1)+omi_data(:,6)/60/24/60;
omidate=datenum(1950,1,1)+omi_data(:,1)+omi_data(:,2)/24/60/60/1000;

omiall=[omidate,omi_data];
%salida igual que toms_overpas
omidata=[omidate,omi_data(:, [13   5    6   8  7    4     14   13])];









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
