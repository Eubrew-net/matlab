function [summary_old_corr summary_corr]=filter_corr(summary,summary_old,inst,A,ETC_C)

%  Updated:
%  - 27/11/2012 (Juanjo): Ahora puede aplicar la corrección por periodos, 
%                         según están definidos en la matriz de calibración
%                         (y dados por read_cal_config_new)
% 
% Aplica la corrección a ETC (por filtros) definida según
% 
%             ETC_corr(f)=(ETC + ETC_C(f))
% 
% donde ETC_C(f) será la corrección calculada para el filtro f. 
% Con esto, el ozono corregido resulta ser
% 
%             O3_corr(f)=(MS9(f)-(ETC+ETC_C(f)))/(10xAxm)=
%                       =(MS9(f)- ETC)/(10xAxm)-ETC_C(f)/(10xAxm)=
%                       = O3(f) - cor(f)
% donde
%             cor(f)=ETC_C(filtro)./(10*A_new(j).*summary{inst}(j,3))';
%   
if ~isempty(summary{inst})

    if size(A.new,1)>1
       [a b]=ismember(fix(summary{inst}(:,1)),fix(A.new(:,1))); 
       if b~=0
          A_new=A.new(b,inst+1);    A_old=nanmean(A.old(:,inst+1));           
       else
          A_new=NaN;    A_old=NaN; 
       end
    else
       A_old=A.old(inst); A_new=A.new(inst);
    end
    if isstruct(ETC_C)
       [a b]=ismember(fix(summary{inst}(:,1)),fix(ETC_C.new(:,1))); 
       if b~=0
          ETC_C=ETC_C.new(b,2:end);           
       else
          ETC_C=[NaN,NaN,NaN,NaN,NaN,NaN];
       end
    else
       ETC_C=ETC_C;           
    end

    for filtro=1:6%, filtro   
       cor=zeros(size(summary{inst}(:,1)));
       corETC=zeros(size(summary{inst}(:,1)));
                    
       j=find(summary{inst}(:,5)==64*(filtro-1)); 
       if ~isempty(j)
           if size(ETC_C,1)>1
              corETC(j)=ETC_C(j,filtro);
           else
              corETC(j)=ETC_C(filtro);               
           end
           
           if length(A_new)>1
              cor(j)=corETC(j)./(10*A_new(j).*summary{inst}(j,3));
           else
              cor(j)=ETC_C(filtro)./(10*A_new.*summary{inst}(j,3))';
           end
        
           summary{inst}(j,6)=summary{inst}(j,6)-cor(j);   % cal2
%            summary{inst}(j,10)=summary{inst}(j,10)-cor(j); % cal1
           summary{inst}(j,12)=summary{inst}(j,12)-cor(j); % cal2+sl
        
           summary{inst}(j,9)=summary{inst}(j,8); % MS9
           summary{inst}(j,8)=summary{inst}(j,9)-corETC(j); % MS9 corrected
       end
    
       cor_old=zeros(size(summary{inst}(:,1)));
       corETC_old=zeros(size(summary{inst}(:,1)));
    
       jo=find(summary_old{inst}(:,5)==64*(filtro-1));
       if ~isempty(jo)
           if size(ETC_C,1)>1
              corETC_old(jo)=ETC_C(j,filtro);
           else
              corETC_old(jo)=ETC_C(filtro);               
           end
           
           if length(A_old)>1
              cor_old(jo)=ETC_C(filtro)./(10*A_old(j).*summary_old{inst}(jo,3))';
           else
              cor_old(jo)=ETC_C(filtro)./(10*A_old.*summary_old{inst}(jo,3))';
           end
        
           summary_old{inst}(jo,6)=summary_old{inst}(jo,6)-cor_old(jo);   % cal1
%            summary_old{inst}(jo,10)=summary_old{inst}(jo,10)-cor_old(jo); % cal2
           summary_old{inst}(jo,12)=summary_old{inst}(jo,12)-cor_old(jo); % cal1+sl
        
           summary_old{inst}(jo,9)=summary_old{inst}(jo,8); % MS9
           summary_old{inst}(jo,8)=summary_old{inst}(jo,9)-corETC_old(jo); % MS9 corrected
       end
    end
    summary_old_corr=summary_old{inst}; summary_corr=summary{inst};
    
else
    summary_old_corr=NaN*ones(1,13); summary_corr=NaN*ones(1,13);
end

