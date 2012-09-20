% function date_=datejul(ano,diaj);
% retorna la fecha, formato matlab 
% recibe diaj y año como argumentos

 function date_=datejul(ano,diaj);

 if nargin==1
     diaj=ano(:,2);
     ano=ano(:,1);
 end
 
 j=find(ano< 75);     
 ano(j)=ano(j)+2000; 
 j=find(ano < 1980);    
 ano(j)=ano(j)+1900; 

 diames_=datevec(datenum(ano,1,1)+diaj-1);
 date_=[datenum(diames_(:,1),diames_(:,2),diames_(:,3)),ano,diaj];
 
 




