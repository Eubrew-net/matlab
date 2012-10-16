%function [x,r,ab,rp,data]=ratio_min_month(a,b,min,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%TODO input the minute
function [x,r,ab,rp,data]=ratio_min_month(a,b,n_min,name_a,name_b)
% calcula el ratio entre respuestas o lamparas
MIN=60*24;
%n_min=10;
[aa,bb]=findm(a(:,1),b(:,1),n_min/MIN);
c=a(aa,1);
% PORQUE NO RULA no busca todos !!!
% 3 minutos 1/( 3  *7E-4)
%aux_a(:,1)=fix(round(a(:,1)*MIN)/n_min);
%aux_b(:,1)=fix(round(b(:,1)*MIN)/n_min);
%[c,aa,bb]=intersect(aux_a(:,1),aux_b(:,1));
data=[a(aa,1),a(aa,1)-b(bb,1),a(aa,2:end),b(bb,2:end)];
data_l=size(a,2);
ref_b=repmat(b(bb,2),1,data_l-1);

  r=[c,a(aa,2:end)./ref_b];
  ab=[c,(a(aa,2:end)-ref_b)];
  rp=[c,100*(a(aa,2:end)-ref_b)./ref_b];
x=data;  
% medias mensuales   
   mdata=meanmonth(data,5);
   mrp=meanmonth(rp,5);
   mab=meanmonth(ab,5);

if nargin>3
    figure;
    orient landscape;
    subplot(2,2,1);
    ploty(data(:,[1,3:end]),'.');grid;title('medidas');
    hold on;
    errorbar([mdata.media(:,1),mdata.media(:,1)],mdata.media(:,[6,7]),mdata.sigma(:,[6:7]),'o');
    plot([mdata.media(:,1),mdata.media(:,1)],mdata.media(:,[6,7]),'-','linewidth',3);
    if nargin==2
        name_a=inputname(1);
        name_b=inputname(2);
    end
    legend(name_a,name_b);
    axis('tight')
    datetick('keeplimits');
    %r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
    %r=[c,log(a(aa,2)./b(bb,2))];
    if isempty(c)
        error('no comon elemets to ratio')
    end
    
    % revisar esto
    if size(b,2)~=size(a,2) & size(b,2)==2
        b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
    end

    subplot(2,2,2);
    plot(data(:,3),data(:,3+data_l-1),'cx');
    hold on
    plot(mdata.media(:,6),mdata.media(:,7),'o')
    [h,r]=rline;
    set(h(1),'linewidth',3);
    grid;title([name_a,' vs ',name_b]);


    subplot(2,3,4);
    ploty(rp);grid;title(['ratio %',name_a,' vs ',name_b]);
    hold on;
    errorbar(mrp.media(:,1),mrp.media(:,5),mrp.sigma(:,5),'ro');
    plot(mrp.media(:,1),mrp.media(:,5),'r','linewidth',3);
    axis('tight');
    datetick('keeplimits');
    
    subplot(2,3,5);
    ploty(ab);grid;title(['dif ',name_a,' - ',name_b]);
    hold on;
    errorbar(mab.media(:,1),mab.media(:,5),mab.sigma(:,5),'ro');
    plot(mrp.media(:,1),mrp.media(:,5),'r','linewidth',3);
    axis('tight');
    datetick('keeplimits');
    
    
    subplot(2,3,6);
    plot(data(:,2)*60*24,data(:,3)-data(:,3+data_l-1),'.');grid;
    title('difference vs time difference (min) ');
    xlabel('min');
    
    % Medias mensuales y diferencia estacional
    
    mm=meanmonth(rp,3);
    if size(mm.media,1)>2
    figure
     %subplot(2,1,1)
      
      errorbar(mm.media(:,1),mm.media(:,5),mm.sigma(:,5),'o');
      datetick('keeplimits')
      ylabel('ratio %');
      title([' 100 * ',name_a,' - ',name_b,'//',name_a,' monthly means' ]);
    figure  
    %subplot(2,1,2);
       errorbar(1:12,mm.media_year(:,3),mm.sigma_year(:,3),'o')
       ylabel('ratio %');   
       ax_mes_en
       title([' 100 * ',name_a,' - ',name_b,'//',name_a,' monthly means' ]);
    end
end
