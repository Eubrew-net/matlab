function [data,dataall,head]=gome_avdc_overpass(file)

if exist(file,'file')
 s=fileread('Pandora101_IZO_20111121_lev3.txt');
 s1=strrep(s,'SO','01');
 s1=strrep(s1,'SU','02');
 s1=strrep(s1,'SB','03'); 
 l=strfind(s1,char(13));
 s1(l(77):l(78))
 head=s1(l(1):l(78));
 omi_data=textscan(s1(l(78):end),'','Headerlines',80,'whitespace','TZ ');
else
  disp(file)
  disp('Not found');  
  %salida igual que read_overpas
  %omi_data=textscan(file,'','whitespace','TZ ','HeaderLines',28,'CollectOutput',1);
end
omi_data=cell2mat(omi_data);
%omi_data(omi_data==-1.00 )=NaN;
(
%omidate=omi_data(:,5)-1+datenum(omi_data(:,4),1,1)+omi_data(:,6)/60/24/60;
omidate=datenum(num2str(data(:,2)*1000000+data(:,3)),'yyyymmddHHMMSS'))

omiall=[omidate,omi_data];
%salida igual que toms_overpas
omidata=[omidate,omi_data(:,1+[27,28,32,33,38,39,41,44,47])];









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
