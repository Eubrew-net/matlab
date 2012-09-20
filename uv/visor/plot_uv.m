function plot_uv(uv,duv)
% function plot_uv(uv) plotea struct uv con los picos
% 
% See Also plot_uvs(uv,a)
if size(uv)==1
    uv(1)=uv;
end
for i=1: length(uv)
%   j=rem(i,2);
%   if rem(i,2)==0 
%      j=2; 
%   end;
%   subplot(2,1,j);   
disp(uv(i).file);
%figure(1);
    h=plotcol([1,2],[2,1]);
    axes(h(1));
    if(size(uv.l,2))>1
        
       w1=waterfall(uv(i).l',uv(i).time'/60,uv(i).uv');
    else
       w1=plot3(uv(i).l',uv(i).time'/60,uv(i).uv');
    end  
    if ~isempty(uv(i).spikes) 
    		hold on;
    		plot3(uv(i).spikes(:,4),uv(i).spikes(:,3)/60,uv(i).spikes(:,5),'r+')
    end  
   
           axis( [2800    5000    -Inf    Inf   -Inf    Inf]);
     colorbar;
     
     drawnow;
       
    if ~isempty(uv(i).spikes) 
       axes(h(3)); 
       plot_uvs(uv(i),uv(i).spikes(:,2));
       ax=axis; ax(1)=2800; ax(2)=3700;
       axis(ax);
    else
%         axes(h(3));
%         a=cost_duv(uv(i));
%         a(:,4)=a(:,4)/25;
%         ploty(a(:,[3,4]),'.');
%         grid;
%         xlabel('hora');
%         ylabel('uvi');
%         title('INDICE UV');
%         ax=axis; ax(1)=6; ax(2)=20;     axis(ax);
%        
    end;   
    textsc(uv(i).file,'title');
    if nargin==2
      if(~isempty(duv(i).duv))
        axes(h(2)); 
        plot(duv(i).duv(:,3)/60,duv(i).duv(:,4),'.')
        grid;
        xlabel('hora');
        ylabel('mW/m2');
        title('DUV');
        ax=axis; ax(1)=6; ax(2)=20;     axis(ax);
       end   
     else
%          axes(h(2));
%          %a=cal_duv(uv(i));
%         ploty(a(:,[3,4]),'.-.');
%         grid;
%         xlabel('hora');
%         ylabel('mW/m2');
%         title('DUV');
%         ax=axis; ax(1)=6; ax(2)=20;     axis(ax);
%        
      end 
%   if rem(i,2)==0  figure; end;
drawnow;
print -dpsc -append  report
end   
   
function [duvc,duvc2,duv] =cost_duv_new(uv)

% calcula el duv siguiendo el método del cost
%duvc-> m´etodo del cost
%duvc2->simula un brewer mk-II (280-325)
%duv-> tal cual
% Expanden el scan considerando la media de las ultimas 5 longitudes de onda hasta 400nm
% sustituida la suma por ingtegral


   lamda=uv(:,1);
   diffey=DV(lamda);
   duv=trapz(lamda/10,diffey.*uv(:,2)*1000); %en mW  por nm

   % rellenamos hasta 400nm paso 0.5nm
   j=find(~isnan(uv(:,2)));
   [ultima_lamda,ultimo]=max(uv(j,1));
   ultimo=j(ultimo);
   duvc=NaN;
   duvc2=NaN;

   if ~isempty(ultima_lamda)

       lamda_f=ultima_lamda+5;
       lamda_c=lamda_f:5:4000;
       lamda=[uv(1:ultimo,1);lamda_c'];
       % rellenamos uv

       uv_5=nanmean(uv(ultimo-5:ultimo,2));
       uv_c=uv_5*ones(size(lamda_c))';
       uv_=[uv(1:ultimo,2);uv_c];

       diffey=DV(lamda);
       duvc=trapz(lamda/10,(diffey.*uv_)*1000); %en mW por nm

       %simulamos un brewer MKII
       j=find(lamda==3250);
       if ~isempty(j)
           uv_5=nanmean(uv_(j-5:j));
           lamda_c=3255:5:4000;
           lamda_2=[lamda(1:j);lamda_c'];
           uv_2c=uv_5*ones(size(lamda_c))';
           uv_2=[uv_(1:j);uv_2c];
           diffey=DV(lamda_2);
           duvc2=trapz(lamda_2,diffey.*uv_2)*100; %en mW por nm
       end
   end

 function DV=DV(lamda)
  DV=zeros(size(lamda));
  %Brewer software
  j=find(lamda<=2980);     DV(j)=1;
  j=find(lamda>2980);     DV(j)=10.^(9.399999E-02*(2980-lamda(j))/10);  %CIE
  j=find(lamda>3280 ) ;   DV(j)=10.^(1.5E-2*(1390-lamda(j))/10);  %UVA

   