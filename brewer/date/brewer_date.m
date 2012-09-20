%function brewerdate function fecha=brewer_date(dddaa)
%             input= diajuliano año (cadena de los ficheros brewer)
%             output=[fecha matlab,año,mes,dia,diaj]
%             use diames
function fecha=brewer_date(dddaa)

   fecha=num2str(dddaa);
   s=sprintf('%05d\n',dddaa);
   s1=sscanf(s,'%03d%02d',[2,Inf])';
   r=diames(s1(:,2),s1(:,1));
   fecha=datenum(r(:,1),r(:,2),r(:,3));
   fecha=[fecha,r];
   