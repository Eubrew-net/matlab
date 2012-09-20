function f=plot_osc_smooth(osc_smooth,f)  

if nargin==2
    f=figure(f);
else
 f=figure; 
end
set(f,'Tag','RATIO_SMOOTH'); 
aux2=(matadd(osc_smooth(:,[6,7]),-osc_smooth(:,2)));
jk=find(~isnan(osc_smooth(:,1)));
errorfill(osc_smooth(jk,1)',osc_smooth(jk,2)',osc_smooth(jk,3)','b')
hold on
errorfill(osc_smooth(jk,1)',osc_smooth(jk,2)',abs([aux2(jk,1),aux2(jk,2)])','r')
box on;
grid;
set(gca,'Xlim',[250,1550]);
set(gca,'YLim',[-3,3]);
xlabel('Ozone slant path');
ylabel(' % ratio');
%title( [name_a,' - ',name_b,'/ ',name_b])
grid on;
    