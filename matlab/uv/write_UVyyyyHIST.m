
nbr='185';  
s_ref=dir(strcat('..\Lamps\','QL',nbr,'\UVRES'));


fid=fopen(fullfile('..\Lamps\QL185\UVRES',strcat('UV',num2str(year(now)),'HIST','.txt')),'w');
fprintf(fid,'DD.MM.YYYY uvrdddaa.###\r\n');
str=[];
for i=1:length(s_ref)
    name=s_ref(i).name;
    if strncmpi(name,'uvr',3)
       newvar=name;
       str=[str;brewer_date(sscanf(name,'%*c%*c%*c%d.%*d'))];
    else
        continue
    end
end    

str=sortrows(str,1);
for i=1:length(str)
    fprintf(fid,'%02d.%02d.%d uvr%03d%02d.%s\r\n',str(i,4),str(i,3),str(i,2),str(i,end),str(i,2)-2000,nbr); 
end

fclose all