function [avg,ERR]=read_avg_line(file_input,NCOLS)


avg=[];
ERR=[];
jerr=1;
if nargin==1 NCOLS=18; end

% leemos el fichero fuente
    fid=fopen(file_input,'rt');
   
 if fid==-1
	error(['fichero no encontrado',file_input]);
 end

idx=1; count_=[]; avg_={};
while ~feof(fid)
   s=fgets(fid);
   try
      [A,COUNT,ERRMSG,NEXTINDEX]=sscanf(s,'%f\r\n',Inf);   count_=[count_,COUNT];
      avg_{idx}=A;  idx=idx+1;
      if COUNT==NCOLS  
         avg=[avg;double(A)'];
      end
   catch
     ERR{jerr}={s,ERRMSG,COUNT};
     warning off;
     jerr=jerr+1;
   end
        
end

if NCOLS==1000
   row=length(count_); col=max(count_); idx=unique(count_);
   avg=NaN*ones(row,col);
   for ii=1:length(idx)
       idx_=find(count_==idx(ii));
       avg(idx_,:)=horzcat(cell2mat(avg_(idx_))',NaN*ones(length(idx_),abs(idx(ii)-col)));
   end
end
fclose(fid);
