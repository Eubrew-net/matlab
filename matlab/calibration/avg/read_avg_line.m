function avg=read_avg_line(file_input)

avg=[];

% leemos el fichero fuente
    fid=fopen(file_input,'rt');


   
 if fid==-1
	       error(['fichero no encontrado',file_input]);
 end


while ~feof(fid)
   s=fgets(fid);
   [A,COUNT,ERRMSG,NEXTINDEX]=sscanf(s,'%f\r\n',Inf);
   try
     avg=[avg;double(A)'];
   catch
     warning off;
     disp(COUNT);
   end
        
end

fclose(fid);
