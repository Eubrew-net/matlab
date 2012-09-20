% function r=diames(ano,diaj) retorna r=[ano,mes,dia,diaj];
function r=diames(ano,diaj)
 j=find(ano <80);
 if ~isempty(j)
    ano(j)=ano(j)+2000;
 end
 j=find(ano<=99);
 if ~isempty(j)
    ano(j)=ano(j)+1900;
 end
 
 
d=datevec(datenum(ano,1,1)+diaj-1);
r=[d(:,1:3),diaj];

% % function r=diames(ano,diaj) retorna r=[ano,mes,dia,diaj];
% %corregido efecto bisiesto
%  
% %  if ano <80 
% %     ano=ano+2000;
% %  elseif ano<=99
% %     ano=ano+1900;
% %  else
% %     ano=ano;
% %  end
% 
% 
% 
%  j=find(ano< 75);     
%  ano(j)=ano(j)+2000; 
%  j=find(ano < 1980),    
%  ano(j)=ano(j)+1900; 
%     
%     
%  YDays = [0,31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334,365];
%  YDaysB =[0,31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335,366];
%  
%     anodiaj=[ano,diaj];
%     r=[];
%     mes=[];
%     dia=[];
% 
%     for a= min(ano):max(ano)
%        
%        hh=find(ano==a); 
%        aux=NaN*diaj;
%        H=diaj(hh);
%        aux(hh)=H;
%        if bisiesto(a)
%           YDays=YDaysB;
%        end   
%        for i=1 :12
%                    
%             YDay0=YDays(i);
%             YDay1=YDays(i+1);  
%          
%        
%         j=find(aux>=YDay0 & aux<YDay1) ;
%         dia(j)=aux(j)-YDay0;
%         mes(j)=i;
% 
%       end
%   end    
% 
% r=[ano,mes',dia',diaj];
%     
% 
