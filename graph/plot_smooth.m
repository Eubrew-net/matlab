function h=plot_smooth(osc_smooth_a,osc_smooth_b,osc_smooth_c)

     aux2=(matadd(osc_smooth_a(:,[6,7]),-osc_smooth_a(:,2)));
     jk=find(~isnan(osc_smooth_a(:,1)));
     h(1)=boundedline(osc_smooth_a(jk,1)',osc_smooth_a(jk,2)',osc_smooth_a(jk,3)','--b','alpha');
     hold on
     aux2=(matadd(osc_smooth_b(:,[6,7]),-osc_smooth_b(:,2)));
     jk=find(~isnan(osc_smooth_b(:,1)));
     h(2)=boundedline(osc_smooth_b(jk,1)',osc_smooth_b(jk,2)',osc_smooth_b(jk,3)',':r','alpha');
     if nargin==3
       
       jk=find(~isnan(osc_smooth_c(:,1)));
       h(3)=boundedline(osc_smooth_c(jk,1)',osc_smooth_c(jk,2)',osc_smooth_c(jk,3)','-.k','alpha');
     end
     
     box on;
     grid;
     set(gca,'Xlim',[250,1550]);
     set(gca,'YLim',[-3,3]);
     xlabel('Ozone slant path');
     ylabel(' % Relative Difference');
     grid on;
     