function [P,s,v]=polyplot2(x,y)

%
[p,s,mu]=polyfit(x,y,2);
% denormalizamos
P(1)=p(1)/mu(2)^2;
P(2)=p(2)/mu(2)-2*p(1)*mu(1)/mu(2)^2;
P(3)=p(1)*mu(1)^2/mu(2)^2+p(3)-mu(1)*p(2)/mu(2);

v=[-P(2)/2/P(1),polyval(P,-P(2)/2/P(1))];

plot(x,y,'.');
hold on;
plot(x,polyval(P,x),'r-')
hline(v(2),'r-',num2str(v(2)));
vline(v(1),'b-',num2str(v(1)));
title({' ','  ',' ',});
%title( [poly2str(round(p*100)/100),' normr=',num2str([s.normr])]);

