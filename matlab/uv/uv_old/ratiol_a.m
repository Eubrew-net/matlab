function [x,r,data]=ratio_l(a,b)
% calcula el ratio entre respuestas o lamparas

figure
if isempty(inputname(1));
    name1=a;
    name2=b;
    title(['ratio ',name1,' vs ',name2]);
else 
    name1=strrep(inputname(1),'_','.');
    name2=strrep(inputname(2),'_','.');
end    
if isstr(a)
    [a,L,di]=loadlamp(a); disp(L)
    [b,L,di]=loadlamp(b); disp(L)

end
[c,aa,bb]=intersect(a(:,1),b(:,1));
data=[c,a(aa,2),b(bb,2)];
subplot(2,2,1);

%ploty2(data);

%r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
%r=[c,log(a(aa,2)./b(bb,2))];
if isempty(c) 
   error('no comon elemets to ratio')
end
subplot(2,2,2);

r=[c,(a(aa,2)./b(bb,2))];

ploty(r);grid;title(['ratio ',name1,' vs ',name2]);

%ratio por intervalos
x=2800:50:3050;
x1=3100:100:4000;
x=[x,x1];
x=x';
x(:,2)=NaN*x(:,1);
x(:,3)=NaN*x(:,1);
for i=1:10
   j=find(r(:,1)>=x(i) & r(:,1)<(x(i+1)));
   x(i,2)=nanmean(r(j,2));
   x(i,3)=nanstd(r(j,2));
end
 subplot(2,1,2);
 ax=errorbar(x(:,1),x(:,2),x(:,3),'o');
 hold on;
 axis([2800,3655,-Inf,Inf]);
 xlabel('wavelength'); 
 ylabel('ratio');
 suptitle([name1,' vs ',name2]);
 grid;

 %legend('dif %')

%axes(ax(2));
%ylabel('sigma %');
%legend('sigma %');

 figure;
 ax=errorbar(x(:,1),x(:,2),x(:,3),'o');
 axis([2800,Inf,0.85,1.15]);
 xlabel('wavelength');
 ylabel('ratio');
 title([name1,' vs ',name2]);
 grid;
