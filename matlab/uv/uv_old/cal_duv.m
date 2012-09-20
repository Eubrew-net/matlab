function duv=calc_duv(uv)

time=nanmean(uv.time)/60/24;
  for i=1:length(time);
      fecha(i)=datenum(uv.date(2,i),1,1)+uv.date(1,i)-1+time(i);
      duv(i)=cost_duv([uv.l(:,i),uv.uv(:,i)]);
  end
duv=[fecha;duv]';  

function [duv,duvc,duv_mkII] =cost_duv(uv)

% calcula el duv siguiendo el método del cost
% Expanden el scan considerando la media de las ultimas 5 longitudes de onda hasta 400nm
   
% quitamos los nan
  j=find(isnan(uv(:,2)));
  uv(j,:)=[];
   lamda=uv(:,1);
   diffey=DV(lamda); 
   
   
   duv=trapz2(lamda,diffey.*uv(:,2)); % A->nm en mW
   %   duv=0.5*nansum(diffey.*uv(:,2))*1000; %en mW

   % rellenamos hasta 400nm paso 0.5nm
   j=find(~isnan(uv(:,2)));
   [ultima_lamda,ultimo]=max(uv(j,1));
   ultimo=j(ultimo);
   duvc=NaN;
   duv_mkII=NaN;
      
   if ~isempty(ultima_lamda)
       
       lamda_f=ultima_lamda+5;
       lamda_c=lamda_f:5:4000;
       lamda=[uv(1:ultimo,1);lamda_c'];
       % rellenamos uv
       
       uv_5=nanmean(uv(ultimo-5:ultimo,2));
       uv_c=uv_5*ones(size(lamda_c))';
       uv_=[uv(1:ultimo,2);uv_c];
       
       diffey=DV(lamda); 
         %duvc=0.5*nansum(diffey.*uv_)*1000; %en mW
         duvc=trapz2(lamda,diffey.*uv_)*100; % A->nm en mW
   
       %simulamos un brewer MKII 
       j=find(lamda>=3250);

       if ~isempty(j) & j(1)>5
           j=j(1);
           uv_5=nanmean(uv_(j-5:j));
           lamda_c=3255:5:4000;
           lamda_2=[lamda(1:j);lamda_c'];
           uv_2c=uv_5*ones(size(lamda_c))';
           uv_2=[uv_(1:j);uv_2c];
           diffey=DV(lamda_2);
           %duvc2=0.5*nansum(diffey.*uv_2)*1000; %en mW
           duv_mkII=trapz2(lamda_2,diffey.*uv_2)*100; % A->nm en mW
       else
          disp('corto'); 
       end
   end
%  
%    if duv<=0 duv=NaN;
%    if duvc<=0 duvc=NaN;
%    if duv_mkII<=0 duv_mkII=NaN;
%    
   
   
 function DV=DV(lamda)
  DV=ones(size(lamda))*NaN;
  %Brewer software
  j=find(lamda<=2980);     DV(j)=1;
  j=find(lamda>2980);     DV(j)=10.^(9.399999E-02*(2980-lamda(j))/10);  %CIE
  j=find(lamda>3280 ) ;   DV(j)=10.^(1.5E-2*(1390-lamda(j))/10);%UVA
  j=find(lamda>4000) ;   DV(j)=NaN;

  function int=trapz2(x,y)
  
    j=find(isnan(x)); x(j)=[];;y(j,:)=[];
    j=findmnan(y); x(j)=[];;y(j,:)=[];
  
  
     int=trapz(x,y);
  
function [j,i]=findmnan(B)
j=[];i=[];

for ii=1:size(B,2)
   
   jj=find((isnan(B(:,ii))));
   j=[j;jj];
   if ~isempty(jj) i=[i;ii.*ones(size(jj))]; end
         
end   