
function [results AnchoBanda]= Lmax(spec,FH)
 
results=cell(1,3); AnchoBanda=cell(1,3); 
wb_real=[2967.283,3021.504,3341.484];

%%
idx=1;
for peak=[2967,3020,3341]    
    for j=1:size(spec,2)    
        lm=cell(1,3); lmt=cell(1,3);          
        spec{:,j}(:,5)= spec{:,j}(:,5)/max(spec{j}(:,5));
        lm{idx}=find(spec{:,j}(:,2)==peak);    
        if ~isempty(lm{idx})
           lmt{idx}=lm{idx}-30:lm{idx}+30; d1=spec{:,j}(lmt{idx},1:5);
                        
%       MÉTODO DE LAS PENDIENTES 
           minCS=min(spec{:,j}(:,5)); % Minimo valor de todo el espectro (ruido de fondo)
           [a,i]=max(d1(:,5)); % Máximo de Cuentas/ segundos del dato real.
           lc1=d1(i,2); % Longitud de corte asociada a este máximo.
           r1=a - minCS;
           h1=r1-r1*2/10; s1=r1*2/10;  % Le quito un 20% por la parte superior e inferior
        
           d12080=d1(find(d1(:,5)>s1 & d1(:,5)<h1),:);              
           d12080_up=d12080(d12080(:,2)<lc1,:); d12080_dw=d12080(d12080(:,2)>lc1,:);
                
           p_up1=polyfit(d12080_up(:,2),d12080_up(:,5),1);
           p_dw1=polyfit(d12080_dw(:,2),d12080_dw(:,5),1);
           xc1=-(p_up1(2)-p_dw1(2))/(p_up1(1)-p_dw1(1));
           yc1=polyval(p_up1,xc1); 
        
%            xc1anchobup= (0.5- p_up1(1,2))/p_up1(1,1);
%            xc1anchobdw= (0.5- p_dw1(1,2))/p_dw1(1,1);
           xc1anchobup= (0.5*yc1 - p_up1(1,2))/p_up1(1,1);
           xc1anchobdw= (0.5*yc1 - p_dw1(1,2))/p_dw1(1,1);
           AnchoB1= (xc1anchobdw-xc1anchobup);% AnchoB1= (xc1anchobdw-xc1anchobup)/2;
           
%       MÉTODO DEL CENTRO DE MASAS      
           xc1cm=trapz(d1(:,2),d1(:,2).*d1(:,5))/trapz(d1(:,2),d1(:,5));           

% %       Ploteo para chequear las cosas
%          chkup=polyval(p_up1,d12080_up(1,2):0.2:lc1+.8); 
%          chkdw=polyval(p_dw1,lc1-.8:0.2:d12080_dw(end,2));
%          figure
%          plot (spec{:,j}(:,2),spec{:,j}(:,5)); hold on; 
%          plot (d12080(:,2),d12080(:,5),'b*');
%          plot(d12080_up(1,2):0.2:lc1+.8,chkup,'-m'); plot(lc1-.8:0.2:d12080_dw(end,2),chkdw,'-m');
%          vline([lc1,xc1],'-');
%          vline ([xc1anchobup xc1anchobdw],'r-');
% %        Centro de masas
%          xc1cm_=trapz(d1(:,5),d1(:,2).*d1(:,5))/trapz(d1(:,5),d1(:,2));% en intensidad
%          vline(xc1cm,'-m');    hline(xc1cm_,'-m');
%          xc1anchobup_= (xc1cm_ - p_up1(1,2))/p_up1(1,1);
%          xc1anchobdw_= (xc1cm_ - p_dw1(1,2))/p_dw1(1,1);
%          AnchoB1_= (xc1anchobdw_-xc1anchobup_);
%          vline ([xc1anchobup_ xc1anchobdw_],'g-');

                
%       DIFERENCIA ENTRE AMBOS MÉTODOS       
           LR1=wb_real(idx);% Longitud real
           DMP1= LR1 - xc1;% Error (Metodo pendientes - Nominal)
           DMCM1= LR1 - xc1cm;% Error (Metodo centro masas - Nominal)
        
%       Fecha=sscanf(filename,'%*2c%5d%*c%*3d');
           MPMCMDM1= [FH{j} LR1 xc1 DMP1 xc1cm DMCM1 a ];
           results{idx}=[results{idx};MPMCMDM1];
           AnchoBanda{idx}=[AnchoBanda{idx};AnchoB1];     
        end                 
end
    idx=idx+1;
end
    