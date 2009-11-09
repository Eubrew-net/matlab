%function [x,r,ab,rp,data]=ratio_min_ozone(a,b,min,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%
% Special Version for ozone measurements
% input argument date, ozone,airm, sza,ms9,sms9, temperature, filter

function [x,r,ab,rp,data,osc_out,osc_smooth]=ratio_min(a,b,n_min,name_a,name_b)
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





r=[c,(a(aa,2:end)./b(bb,2:end))];
ab=[c,(a(aa,2:end)-b(bb,2:end))];
rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];
x=[data,rp(:,2:end)];

% dos posibilidades 1 sin temperatura y filtro
if size(b,2)==6;
 osc=data(:,8).*data(:,9);
 sza=data(:,10);
else
 osc=data(:,10).*data(:,11);  
 sza=data(:,12);
end



% ratio ozone slant path
  
    
    osc_ranges=[300,550,850,1250,1500];
    osc_int=[200,400,700,1000,1500];
    osc_grp=[osc<400, osc>=400 & osc<700, osc>=700 & osc<=1000,osc>1000 & osc<1100,osc>1100];
   [osc_x,aux]=find(osc_grp');
    osc_x=osc_ranges(osc_x);
    [m,s,n,er,name]=grpstats(rp(:,2),osc_x,{'mean','std','numel','sem','gname'});
     x=str2num(char(name));
     osc_ratio=[x/1000,m,s,n,er];
     % relleno con NaN
     osc_out=NaN*ones(length(osc_ranges)+2,6);
     for ii=1:length(osc_ranges)
         jj=find(x==osc_ranges(ii),1);
         if ~isempty(jj) & ii<size(osc_ratio,1)
          osc_out(ii+1,2:end)=osc_ratio(ii,:);
         end
     end
    [m1,s1,n1,er1,name1]=grpstats(rp(:,2),[],{'mean','std','numel','sem','gname'});
     osc_=[NaN,m1,s1,n1,er1];
     osc_out(7,2:end)=osc_;

% ratio ozone slant path % Matthias Method
  

    y=mean_smooth(osc,rp(:,2),0.125);
    osc_smooth=sortrows([osc,y(:,1:end)],1);
     
     
if nargin>3
    f=figure;
    set(f,'Tag','RATIOo_1');
    subplot(2,2,1);
    ploty(data(:,[1,3,3+data_l-1]),'.');grid;title('medidas');
    datetick;
    if nargin==2
        name_a=inputname(1);
        name_b=inputname(2);
    end
    legend(name_a,name_b);
    %r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
    %r=[c,log(a(aa,2)./b(bb,2))];
    if isempty(c)
        warning('no comon elemets to ratio')
    end
    if size(b,2)~=size(a,2) & size(b,2)==2
        b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
    end

    subplot(2,2,2);
    plot(data(:,3),data(:,3+data_l-1),'x');
    rline;
    grid;title([name_a,' vs ',name_b]);


    subplot(2,3,4);
    ploty(rp(:,1:2));grid;title(['ratio %',name_a,' vs ',name_b]);
    datetick;
    subplot(2,3,5);
    ploty(ab(:,1:2));grid;title(['dif ',name_a,' - ',name_b]);
    datetick;
    subplot(2,3,6);
    plot(data(:,2)*60*24,data(:,3)-data(:,3+data_l-1),'.');grid;
    title('difference vs time difference (min) ');
    xlabel('min');
    
    f=figure;
    set(f,'Tag','RATIO_2');
    try
        
     gscatter(osc,rp(:,2),diaj(data(:,1)));
     set(gca,'Xlim',[250,1250]);
     xlabel('Ozone slant path');
     ylabel(' % ratio');
     title( [name_a,' - ',name_b,'/ ',name_b])
     box on;
    catch % falla cuando hay un solo dia revisar
     plot(osc,rp(:,2),'.');
     set(gca,'Xlim',[250,1550]);
     xlabel('Ozone slant path');
     ylabel(' % ratio');
     title( [name_a,' - ',name_b,'/ ',name_b])
     box on;
    end
    hold on;
    errorbar(x,m,2*s,'s-');
    grid;
   
   f=figure;
   set(f,'Tag','RATIO_3'); 

    j=find(data(:,1)-fix(data(:,1))>=0.5);
    hold on;
    plot(sza(j),rp(j,2),'o');
    j=find(data(:,1)-fix(data(:,1))<0.5);
    plot(sza(j),rp(j,2),'+');
    xlabel('solar zenith angle');
    ylabel(' % ratio');
    title( [name_a,' - ',name_b,'/ ',name_b])
    legend('AM','PM');
    box on;
    grid;
    %figure;
    f=figure; 
    set(f,'Tag','RATIO_SMOOTH'); 
     aux2=(matadd(osc_smooth(:,[6,7]),-osc_smooth(:,2)));
     errorfill(osc_smooth(:,1)',osc_smooth(:,2)',osc_smooth(:,3)','b')
     hold on
     errorfill(osc_smooth(:,1)',osc_smooth(:,2)',abs([aux2(:,1),aux2(:,2)])','r')
     box on;
     grid;
     set(gca,'Xlim',[250,1550]);
     set(gca,'YLim',[-3,3]);
     xlabel('Ozone slant path');
     ylabel(' % ratio');
     title( [name_a,' - ',name_b,'/ ',name_b])
     grid on;
     
     figure
     set(f,'Tag','RATIO_ERRORBAR');
         errorbar(x,m,2*s,'s-');
         grid;
         box on;
         set(gca,'Xlim',[250,1550]);
         set(gca,'YLim',[-3,3]);
         xlabel('Ozone slant path');
         ylabel(' % ratio');
        title( [name_a,' - ',name_b,'/ ',name_b])
   
     %figure by filter 
    f=figure;
    set(f,'Tag','RATIO_BOTH');
    if size(b,2)==8;   
    try
     
         gscatter(osc,rp(:,2),data(:,end)) %,data(:,end-data_l+1)],'','+o');
         set(gca,'Xlim',[250,1550]);
         xlabel('Ozone slant path');
         ylabel(' % ratio');
         title( [name_a,' - ',name_b,'/ ',name_b])
         box on;
        catch % falla cuando hay un solo dia revisar
         plot(osc,rp(:,2),'.');
         set(gca,'Xlim',[250,1550]);
         xlabel('Ozone slant path');
         ylabel(' % ratio');
         title( [name_a,' - ',name_b,'/ ',name_b])
         box on;
     end
        hold on;
        errorbar(x,m,2*s,'s-');
       grid;
    end
    
    %figure by day
    
    f=figure;
    set(f,'Tag','RATIO_DAY');
    
    dias=unique(diaj(data(:,1)));
    nplots=ceil(length(dias)/2);
    ndias=length(dias);
    b=[];
    for i=1:ndias
      subplot(2,nplots,i);  
      j=find(diaj(data(:,1))==dias(i));
            [f]=mmplotyy(diajul(data(j,1)),[data(j,3),data(j,3+data_l-1)],'.-',...
            rp(j,2),'g.',[-3,3]);    
       mmplotyy([name_a,' - ',name_b,'/ ',name_b]);
       set(f(1),'Marker','x');
     %if i==1 legend( name_a,name_b,-1);end
     box on;
     grid;
    end  
   % [aux,ll(1)]=suplabel('day');
   % [aux,ll(2)]=suplabel(' Ozone DU','y');
   % [aux,ll(3)]=suplabel([name_a,'(x) , ',name_b,'(.)'],'t');
   % set(ll,'FontSize',18);
 end
end