function [omidat,leg,head]=read_omi(file)

%Datetime       MJD2000  Year  DOY  sec(UT)   Orbit   CTP     Lat     Lon   Dis     SZA    Ozone  Surf.P      Ref   
%cabecera:

fid=fopen(file)
   c1=fgets(fid)
   c2=fgets(fid)
   c3=fgets(fid)
   label=fgets(fid)
head={c1,c2,c3,label};
   
omi_data=textscan(fid,'','whitespace','TZ ','headerlines',1);
fclose(fid)
%omi_data=textread(file,'','whitespace','TZ ','headerlines',3);
omi_data=cell2mat(omi_data);
omidate=omi_data(:,3)+datenum(1999,12,31);
%salida igual que read_overpas
omidat=[omidate,omi_data];
leg=['date_matlab';'date';mmstrtok(label)];
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
