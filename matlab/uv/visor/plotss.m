function h=plotss(uv,s)
% plotea un elemento de la estructura uv
% 3D


% cas%o de lamparas
if ~isempty(strmatch('ln',fieldnames(uv)))
   x=uv.l(:,1);
   %y=uv.ln+(1:length(uv.ln))/1w0;      
   z=uv.counts;
   
   waterfall(x,y,z');
   if nargin==2
     hold on
     h=plot3(uv.l(:,s),y(s)*ones(size(z(:,s))),z(:,s)','..-');
     set(h,'Linewidth',2);
     set(h,'Erasemode','Background');
  end   
  hold off;
  
   


else
   if ~isempty(uv.l)
     if(size(uv.l,2))>1 
        uv.ss(find(uv.ss<0))=NaN;
        %uv.uv(find(uv.ss>1000))=NaN;
        
        waterfall(uv.l',(uv.time/60)',uv.ss');
     else
        plot3(uv.l',(uv.time/60)',uv.ss');
     end   
     xlabel('longitud de onda (nm)');
     ylabel('tiempo (horas)');
     zlabel('irradiancia W/m^2/nm');
     title(uv.file);
   end  
   
   
   
   
   
  if nargin==2
     hold on
     h=plot3(uv.l(:,s),(uv.time(:,s))/60,uv.ss(:,s));
     set(h,'Linewidth',2);
     set(h,'Erasemode','Background');
  end   
  hold off;
 end 