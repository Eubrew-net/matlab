function [x,r,data]=ratio_l(a,b)
% calcula el ratio entre respuestas o lamparas


[c,aa,bb]=intersect(a(:,1),b(:,1));
data=[c,a(aa,2:end),b(bb,2:end)];
figure;
subplot(2,2,1);
ploty(data);grid;title('medidas');
%r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
%r=[c,log(a(aa,2)./b(bb,2))];
if isempty(c) 
   error('no comon elemets to ratio')
end
subplot(2,2,2);
r=[c,(a(aa,2:end)./b(bb,2:end))];

ploty(r);grid;title('ratio');
%ratio por intervalos
x=2800:50:3050;
x1=3050:50:7000;

x=[x,x1,3250];
x=sort(x);
x=x';
x=x/10; %(nm)
x(:,2)=NaN*x(:,1);
x(:,3)=NaN*x(:,1);
for i=1:length(x)-1;
   j=find(r(:,1)>=x(i) & r(:,1)<(x(i+1)));
   x(i,2)=nanmean(r(j,2));
   x(i,3)=nanstd(r(j,2));
end
 subplot(2,1,2);
 ax=errorbar(x(:,1),x(:,2),x(:,3),'o');
 axis([280,Inf,0.75,1.25]);
 xlabel('wavelength');
 ylabel('ratio');
 title([inputname(1),' vs ',inputname(2)]);
 grid;
%legend('dif %')
%axes(ax(2));
%ylabel('sigma %');
%legend('sigma %');
 figure;
 ax=errorbar(x(:,1),x(:,2),x(:,3),'o');
 axis([280,inf,0.75,1.25]);
 xlabel('wavelength');
 ylabel('ratio');
 title([inputname(1),' vs ',inputname(2)]);
 grid;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%