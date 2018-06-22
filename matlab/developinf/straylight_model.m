function result=straylight_model(data,A1,A2,Cal)
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
 ms9_inst=data(:,21);% F corr., en su caso
 m_inst=data(:,16);% m from inst
 o3_ref=data(:,7);% O3 de la ref, 2 confg.
 o3p=o3_ref.*(10*m_inst*A1); 
 ozone_slant=o3_ref.*m_inst/1000;% osc
 etcs=ms9_inst-o3p;% 1P method
 min_osc=floor(min(ozone_slant)*10)/10;
 max_osc=ceil(max(ozone_slant)*10)/10; 
 step_osc=0.05;
%  [grp,m,s]=osc_group(.2:0.05:1.800,[etcs ozone_slant]);
 [grp,m,s]=osc_group(min_osc:step_osc:max_osc,[etcs ozone_slant]);
%add cero point
 m0=mean(m(m(:,2)<0.5,:));
 
 m0(2)=0.01;
 m1=m0;
 m1(2)=0.1;
 m2=m0;
 m2(2)=0.2;
 
 m=[m0;m1;m2;m];
 s=[s(1,:);s(1,:);s(1,:);s];
 
 %% ploteo
 f=figure; set(f,'tag',strcat('ETC_StrayLight',Cal.brw_str{Cal.n_inst}));  
 plot(ozone_slant,etcs,'.'); hold on;
 errorbar(m(3:end,2),m(3:end,1),s(3:end,1),'-s'); 
 max_osc=2;
 % modelamos el stray-light segun Y = a*x^b+c
 % cflibhelp power
 [r,gof,c]=fit(m(:,2),m(:,1),'power2','Robust','on','StartPoint',[1,3,A2]);
  osc=0.3:.1:2.5;
  plot(osc,r(osc),'r.-'); grid on;    
  plot(osc,predint(r,osc),'r:');
  mf=1:.1:9;mf=mf';
  o3c=[mf.*400/1000,100*(r(mf.*400/1000)-A2)/A1./mf/10./400,100*(predint(r,mf.*400/1000)-A2)/A1./mf/10./400];
  o3r=[ozone_slant,100*(r(ozone_slant)-A2)/A1./m_inst/10./o3_ref,100*(predint(r,ozone_slant)-A2)/A1./m_inst/10./o3_ref];
 
 [r1,gof1,c1]=fit(m(:,2),m(:,1)-A2,'power1','Robust','on','StartPoint',[1,3]);
 plot(.10:.1:max_osc,r1(.1:.1:max_osc)+A2,'r.-'); grid         
 %x=[100*r(mf.*400/1000)/A1./mf/10./400,100*predint(r,mf.*400/1000)/A1./mf/10./400];
 
 R=coeffvalues(r);     RI=confint(r);
 R1=coeffvalues(r1);     RI1=confint(r1);
 
 % K=R(1)/A1/10/100 
 % s=R(2)-1;
 % ETC=R(3)  
%   R(1)=R(1)/ A.new(Cal.n_inst)/1000;  R(2)=R(2)-1;
 set(gca,'XLim',[0.25,2.25]);
 hline(RI(:,3),'r:'); h_s(1)=hline(R(3),'r-'); h_s(2)=hline(A2,'g-'); 

 title(sprintf('Brewer %s: %4.2e*(osc)^{%4.2f}+%d ',Cal.brw_name{Cal.n_inst},R(1),R(2),round(R(3))));
 ylabel('Extraterrestriall Constant, F_0'); xlabel('Ozone Slant Column [DU/1000]'); 
 l=legend(h_s,{sprintf('ETC cal.: %d  \r\n95%% confidence interval: [%d - %d]',round(R(3)),round(RI(1,3)),round(RI(2,3))),...
             sprintf('1P ETC cal.: %d',round(A2))},'Location','SouthWest');
 set(l,'FontSize',8); 
 %% figure
fb=figure
set(fb,'Tag','Correction bounds');
hold on
h1=plot(mf*400,o3c(:,3:end)-o3c(:,2),'-k');
h2=plot(ozone_slant*1000,o3r(:,3:end)-o3r(:,2),'.k');
set(gca,'XLim',[250,2500]); 
xlabel('Ozone Slant Column');
ylabel(' Stray Light ozone correction %')
grid on 
legend([h1(1),h2(1)],'model','observations') 
 %% Output
 result.stats=gof; result.stats.RI=RI;
 result.coeff.R=R; result.coeff.ETC=A2;
 result.stats1=gof1; result.stats1.RI=RI1;
 result.coeff1.R=R1; result.coeff1.ETC1=A2;
 result.model1=r1; result.model=r;
 result.o3c=o3c;  result.o3r=o3r;   
