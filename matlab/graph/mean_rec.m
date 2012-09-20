%mean rect, calcula la media en el rectangulo seleccionado
% para cada serie seleccionada
a=ginput;

h=findobj('parent',gca)
for i=1:length(h)

if strcmp(get(h(i),'type'),'line')
   hi=h(i);  
    x=get(hi,'XData');
    y=get(hi,'YData');
    datacolor = get(hi,'Color');


   dat=[x',y'];
   dat=dat(find(dat(:,1)>a(1,1) & dat(:,1)<a(2,1)),:);
   n=length(dat(:,2));
   hold on 
   if ~isempty(n)
   h1=plot(dat(:,1),dat(:,2),'p');
   set(h1,'Color',datacolor);

   med=nanmean(dat(:,2))
   med2=trimmean(dat(:,2),20)
   med3=nanmedian(dat(:,2))
   sig=nanstd(dat(:,2))
   err=sig/sqrt(length(dat(:,2)))
   
   t=gtext(sprintf(' Mean selection %f +/- %f std=%f n=%d',med,err,sig,n));
   set(t,'Color',datacolor);
   end
end
end
