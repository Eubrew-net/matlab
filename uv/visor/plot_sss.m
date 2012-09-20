function h=plot_sss(uv,a)
% function plot_uvs(uv) plotea uv los scanes a
% a es una matriz de 2 colunnas [dia,scan] (structura uv con varios elementos)
%                     colunma [scan];  
% en desarrollo
for i=1: size(a,1)
   
    if size(a,2)==1  % si a tiene dimension 1 es el scan
      dia=1;
      scan=a(i);
      uv_=uv;
   else    
      dia=a(i,1);
      scan=a(i,2);
      uv_=uv(dia)
   end
   scl=[uv_.l(:,scan),uv_.ss(:,scan)];
   if ~isempty(uv.spikes)
     if any(scan==uv_.spikes(:,2)) 
		   %scl_=[[ uv_.spikes(i,4);uv_.l(:,scan)],[uv_.spikes(i,5);uv_.uv(:,scan)]];
         %scl_=sortrows(scl_,1);
         j=find(uv_.spikes(:,2)==scan); % permite varios picos en un scan
         scl1=[ uv_.spikes(j,4),uv_.spikes(j,5)];
      	ploty(scl1,'r+');   
      	ax=axis; ax(1)=2800; ax(2)=3700;ax(4)=max(scl1(:,2))+0.2;
      	axis(ax);
      	hold on;
      end  
   end   
      ax=axis; ax(1)=2800; ax(2)=3700; ax(3)=0;
      axis(ax); 
     h=ploty(scl,'.-');   
     title(sprintf('scan %d %s tipo %s ',scan,datestr(nanmean(uv_.time(:,scan)/60/24)),...
        uv_.type(:,scan)));
     grid;
     hold off;
   
end   
   
   
   