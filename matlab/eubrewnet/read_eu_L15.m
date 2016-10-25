function [data,cfg_id,leg,head]=read_eu_l51(file)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fid=fopen(file);
if fid
  for i=1:19          % message  
   c{i}=fgets(fid);
  end 
 head=char(c{:});

 fgets(fid);
 s=fgets(fid)
 %s=fgets(fid); 
 %s=fgets(fid);
 %s=fgets(fid);
 i=0;
 config_info={};  % config
 %nx=8;
 %nr=4;
 %while nx<length(s) & nr==4;
 %i=i+1    
 try
 cfg_id=sscanf(s(8:end),'%04d-%02d-%02d, id = %d;');
 cfg_id=reshape(cfg_id,4,[])
 catch
     disp('config not read');
 end
 %nx
 %end
%  while s(3)=='D'
%      i=i+1;
%      config_info{i}=s;
%      [si,sj]=regexp(s,'[=]\d*');
%      cfg_id(i)=sscanf(s(si:sj),'=%d');
%      s=fgets(fid);   % config
%  end
 fgets(fid);    
 for i=1:27 leg{i}=fgets(fid); end%

 
fgets(fid);
format=fgets(fid);
format=strrep(format,'d','f');  
format(1)=[];
head=fgets(fid);

data=textscan(fid,format);
data=cell2mat(data);

%dates to matlab
fecha_1=datenum(data(:,2:7));
fecha_p=datenum(data(:,end-5:end));
fecha_c=datenum(data(:,end-9:end-7));

data(:,2)=fecha_1;
data(:,3:7)=[];
data(:,end-9)=fecha_c;
data(:,end-8:end-7)=[];
data(:,end-5)=fecha_p;
data(:,end-4:end)=[];

%h=strrep(head,'gmt','YYYY,MM,DD,hh,mm,ss');
%h=strrep(h,'process_date','pYYYY,pMM,pDD,phh,pmm,pss');
%h=strrep(h,'configdate','cYYYY,cMM,cDD');

%date_mat=data(:,10);
%data=[date_mat,data];
%data=textscan(fid,'','delimiter','TZ,');
%date_mat=data(:,7);
%%salida igual que read_overpas
%data=[date_mat,data];
%date_fields=find(~cellfun(@isempty,strfind(leg,'ISO 8601')));
%date_fileds=[2,27];
%leg=insertrows(leg',leg(date_fileds)',date_fileds)';
%date_fileds=[3,28];
%leg=insertrows(leg',leg(date_fileds)',date_fileds)'; %inser a nan 
%leg=['Date Matlab',leg(1:3),'NAN',leg(4:end)];  % checl the nan
%leg=['Date Matlab',leg]; 
else
    disp('file error');
end
fclose(fid);
end

