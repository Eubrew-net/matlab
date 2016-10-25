function [data,leg,head]=read_eu_l1(file)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fid=fopen(file)
if fid
  for i=1:20          % message  
   c{i}=fgets(fid);
  end 
 head=char(c{:});

 fgets(fid)
 config_info=fgets(fid);   % config
 fgets(fid)
 for i=1:26 leg{i}=fgets(fid); end%

 
fgets(fid)
format=fgets(fid)
format=strrep(format,';',',')  
format(1)=[];
%data=textscan(fid,format);

data=textscan(fid,'','delimiter','TZ,');
data=cell2mat(data);
date_mat=data(:,7);
%salida igual que read_overpas
data=[date_mat,data];
date_fileds=[2,26];
leg=insertrows(leg',leg(date_fileds)',date_fileds)';
date_fileds=[3,27];  % add a nan
leg=insertrows(leg',leg(date_fileds)',date_fileds)';
leg=['Date Matlab',leg];
else
    disp('file error');
end
fclose(fid);
end

