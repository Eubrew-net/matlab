function [avg,avg2,avg3,ERR]=read_avg_line(file_input,NCOLS)


avg=[];
avg2=[];
avg3=[];
ERR=[];
jerr=1;
if nargin==1 NCOLS=18; 
else
if length(NCOLS)==1
    NCOLS(2)=NCOLS(1);
end
end
% leemos el fichero fuente
    fid=fopen(file_input,'rt');
   
 if fid==-1
	error(['fichero no encontrado',file_input]);
 end

idx=1; count_=[]; avg_={};
while ~feof(fid)
   s=fgets(fid);
   s=strrep(s,':',' ');
   s=strrep(s,'OFF->',' ');
   try
      [A,COUNT,ERRMSG,NEXTINDEX]=sscanf(s,'%f\r\n',Inf);
      count_=[count_,COUNT];
      avg_{idx}=A;  idx=idx+1;
      if COUNT==NCOLS(1)  
         avg=[avg;double(A)'];
      elseif COUNT==NCOLS(2)
         avg2=[avg2;double(A)'];
      else
         avg3=[avg3;double(A)']; 
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
