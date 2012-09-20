function [ratio,uv,time]=comp_scan_ua(uv1,uv2)

% eleccion de candidatos
ratio=[];uv=[];time=[];l=[];
c1=find(uv1.type(2,:)=='a'); % scanes tipo ua sincronizados
c2=find(uv2.type(2,:)=='a'); % scanes tipo ua sincronizados


% comprobamos la simultaniedad 

time1=uv1.time(1,c1)/60;
time2=uv2.time(1,c2)/60;
if ~isempty(uv1.time) & ~ isempty(uv2.time)

    time1=uv1.time(1,:)/60;
    time2=uv2.time(1,:)/60;

%Longitud de onda de sincronismo  --->revisar presupone que son iguales
     [l_1,j1]=find(uv1.l==2865);
     [l_2,j2]=find(uv2.l==2865);
%leyendas y titutlos
  disp([uv1.file,' ',uv2.file]);
  inst1=uv1.inst;
   if ~ischar(inst1)
       inst1=num2str(inst1);
   end
leg1=strtok(inst1,' ');   
inst2=uv2.inst;
if ~ischar(inst2)
       inst2=num2str(inst2);
end
leg2=strtok(inst2,' ');

% buscamos las comunes
[c,i1,i2]=intersect(round(uv1.time(1,:)),round(uv2.time(2,:))) % tiempos comunes (al minuto)

uv2.time(1,:)=uv2.time(2,:); %chapuza
% buscamos las longitudes de onda comunes
count=length(c)
   

for i=1:count
   figure
   [cl,l1,l2]=intersect(uv1.l(:,i1(i)),uv2.l(:,i2(i)));
   x=[uv1.l(l1,i1(i)),uv2.l(l2,i2(i))];
   y=[uv1.uv(l1,i1(i)),uv2.uv(l2,i2(i))];
   j=find(x<2950);
   x(j,:)=NaN;
   y(j,:)=NaN;
   y2=100*((y(:,1)-y(:,2))./y(:,2));
   x2=x(:,1);
   [h,a,b]=plotyy(x,y,x2,y2,'semilogy','plot');
   set(a(2),'Marker','o','MarkerSize',4);
   set(a(1),'Marker','+','MarkerSize',5);
   
   set(b,'Marker','s','MarkerSize',4);
   
   axes(h(1));
   ylabel(' Spectral Irradiance W/m^2/nm ');
   axes(h(2));
   ylabel(' Ratio (%) ');
   xlabel(' wavelength (A) ');
   set(a(1),'linewidth',1);
   l1=legend(a,sprintf('%8s  %03s',datestr(uv1.time(1,i1(i))/60/24,15),leg1),...
            sprintf('%8s  %03s', datestr(uv2.time(1,i2(i))/60/24,15),leg2),2);
   set(l1,'FontWeight','demi');
   l2=legend(b,sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2),4);
   set(l2,'FontWeight','demi');
   
   ht=title(sprintf(' Intercomparison plot %03s vs %03s %02d/%02d',...
       leg1,leg2,uv1.date(1,1),uv1.date(2,1)));
   set(ht,'Fontweight','bold');
   axes(h(2));
   ax=axis;
   ax(3)=-30;
   ax(4)=30;
   axis(ax);
   set(h(2),'YTick',[30,20,10,5,0,-5,-10,-20,-30]*-1);
   grid
   ratio=[ratio,y2];
   uv=[ uv,[x2,y]];  
   l=[l,x2];
   time=[time;[ uv1.time(1,i1(i)),uv2.time(1,i2(i))]];
   set(h(1),'Ylim',[1E-6,10],'YtickMode','Auto','YtickLabelMode','Auto');   
   print('-dpsc','-append',['comp_',leg1,'_',leg2]) ;
   if i==13
       saveas(gcf,['comp_12h_',leg1,'_',leg2],'fig')
   else   
        close;
   end
end
if(count>0)
% intercomparacion
figure
orient tall

h=plot(l(:,(2:2:end)),ratio(:,(2:2:end)),':');
legend(h,datestr(time((2:2:end),1)/60/24,15));
grid
hold on
if(size(ratio,2)>1)
 
    %h2=errorbar(x2,nanmean(ratio'),nanstd(ratio'),'k');
    h2=plot(x2,nanmean(ratio'),'-k');
    
 set(h2,'linewidth',3);
end 
axis([-Inf,Inf,-25,25]);
 ht=title(sprintf(' Intercomparison ratio %03s vs %03s %02d/%02d',...
       leg1,leg2,uv1.date(1,1),uv1.date(2,1)));
   set(ht,'Fontweight','bold');


xlabel(' wavelength (A) ')
ylabel(sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2))
hold off;
print('-dpsc',['compr_',leg1,'_',leg2]) ;
saveas(gcf,['compr_',leg1,'_',leg2],'fig')    
end
end




