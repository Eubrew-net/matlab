function [duvc,duvc2,duv] =cost_duv(uv)

% calcula el duv siguiendo el método del cost
%duvc-> m´etodo del cost
%duvc2->simula un brewer mk-II (280-325)
%duv-> tal cual
% Expanden el scan considerando la media de las ultimas 5 longitudes de onda hasta 400nm
% sustituida la suma por ingtegral
   
   uv(find(isnan(uv(:,2))),:)=[]; % NaN da errores en trapz
   lamda=uv(:,1);
   diffey=DV(lamda); 
   duv=trapz(lamda,diffey.*uv(:,2))*100; %en mW y nm

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
       duvc=trapz(lamda,(diffey.*uv_))*100; %en mW
       
       %simulamos un brewer MKII 
       j=find(lamda==3250);
       if ~isempty(j)
           uv_5=nanmean(uv_(j-5:j));
           lamda_c=3255:5:4000;
           lamda_2=[lamda(1:j);lamda_c'];
           uv_2c=uv_5*ones(size(lamda_c))';
           uv_2=[uv_(1:j);uv_2c];
           diffey=DV(lamda_2);
           duvc2=trapz(lamda_2,diffey.*uv_2)*100; %en mW y nm (1000/10)
       end
   end
 
 function DV=DV(lamda)
  DV=zeros(size(lamda));
  %Brewer software
  j=find(lamda<=2980);     DV(j)=1;
  j=find(lamda>2980);     DV(j)=10.^(9.399999E-02*(2980-lamda(j))/10);  %CIE
  j=find(lamda>3280 ) ;   DV(j)=10.^(1.5E-2*(1390-lamda(j))/10);  %UVA
