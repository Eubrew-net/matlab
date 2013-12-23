function result=straylight_model(o3c,A1,A2,Cal)
% 
% Volodya:
% A*m [x-k(m*x)^s]-ETC-MS9=0 -> A*m*x-ETC - k*A*m*(m*x)^s =MS9
% o3p- k*m^(s+1)*x^s =MS9  (is not a power of osc)
% 
% SAUNA:
% x=osc
% (ms9-osc*A1)= K*A1(osc)^s+1+ETCo  
% [r,gof,c]=fit(ozone_slant,ms9-o3p,'power2','Robust','on');
%  
 ms9_inst=o3c(:,21);% F corr., en su caso
 m_inst=o3c(:,16);% m from inst
 o3_ref=o3c(:,13);% O3 de la ref, 2 confg.
 o3p=o3_ref.*(10*m_inst*A1); 
 ozone_slant=o3_ref.*m_inst/1000;% osc
 etcs=ms9_inst-o3p;% 1P method
 [grp,m,s]=osc_group(.2:.100:1.800,[etcs ozone_slant]);

 %% ploteo
 f=figure; set(f,'tag',strcat('ETC_StrayLight',Cal.brw_str{Cal.n_inst}));  
 plot(ozone_slant,etcs,'.'); hold on;
 errorbar(m(:,2),m(:,1),s(:,1),'-s'); 
 
 % modelamos el stray-light segun Y = a*x^b+c
 % cflibhelp power
 [r,gof,c]=fit(m(:,2),m(:,1),'power2','Robust','on','StartPoint',[1,3,A2]);
 plot(.3:.1:1.7,r(.3:.1:1.7),'r.-'); grid         
  
 R=coeffvalues(r);     RI=confint(r);
 % K=R(1)/A1/10/100 
 % s=R(2)-1;
 % ETC=R(3)  
%   R(1)=R(1)/ A.new(Cal.n_inst)/1000;  R(2)=R(2)-1;

 hline(RI(:,3),'r:'); h_s(1)=hline(R(3),'r-'); h_s(2)=hline(A2,'g-');        
 title(sprintf('Brewer %s: %4.2e*(osc)^{%4.2f}+%d ',Cal.brw_name{Cal.n_inst},R(1),R(2),round(R(3))));
 ylabel('Extraterrestriall Constant, F_0'); xlabel('Ozone Slant Column [DU/1000]'); 
 l=legend(h_s,{sprintf('ETC cal.: %d  \r\n95%% confidence interval: [%d - %d]',round(R(3)),round(RI(1,3)),round(RI(2,3))),...
             sprintf('1P ETC cal.: %d',round(A2))},'Location','SouthWest');
 set(l,'FontSize',8); 
 
 %% Output
 result.stats=gof; result.stats.RI=RI;
 result.coeff=R;
       
