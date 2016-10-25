function [ data,tipo ] = read_woudc_prn( filename)
%   Detailed explanation goes here
f=fopen(filename);s=1;i=1;tipo=[];
while(s)
 fecha=textscan(f,'%04f-%02f-%02f','CollectOutput',1);
 obs=textscan(f,' %c%c %02f:%02f:%02f  %f %f %f %f %f ','CollectOutput',1);
 s=~feof(f);
 try
   fecha=datenum(fecha{1}(end,:))+datenum(0,0,0,obs{2}(:,1),obs{2}(:,2),obs{2}(:,3));
   data{i}=[fecha(1:end-1),obs{2}(1:end-1,4:end)];
   tipo=[tipo;obs{1}(1:end-1,:)];
   i=i+1;
   fseek(f,-4,0); % lee 4 carateres de la siguiente fecha
 catch
   disp('error');
 end
end
disp(i)
end

