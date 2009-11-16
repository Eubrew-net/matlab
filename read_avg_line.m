function [avg,ERR]=read_avg_line(file_input)

avg=[];
ERR=[];
jerr=1;
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
     ERR{jerr}={s,ERRMSG,COUNT};
     warning off;
     jerr=jerr+1;
   end
        
end

fclose(fid);
