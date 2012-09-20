%function [x,r,ab,rp,data]=ratiod(a,b,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%TODO input the minute
function [data,time]=ratiod_sza(a,b,name_a,name_b)
% calcula el ratio entre respuestas o lamparas

% 3 minutos 1/( 3  *7E-4)
aux_a(:,1)=fix(a(:,1)*1/(1*7E-4));
aux_b(:,1)=fix(b(:,1)*1/(1*7E-4));


[c,aa,bb]=intersect(aux_a(:,1),aux_b(:,1));
data=[a(aa,:),b(bb,2:end)];
time=[a(aa,1)-b(bb,1)];


if isempty(c) 
   error('no comon elemets to ratio')
end
if size(b,2)~=size(a,2) & size(b,2)==2
    b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
end



%data selection 

j=find(data(:,3)>=2.5 | data(:,2)<=100)
data(j,2:3)=NaN;
j=find(data(:,7)>=2.5 | data(:,6)<=100)
data(j,6:7)=NaN;

j=find( abs(data(:,2)-data(:,6))>70)
% outliers
[stats,outlier,out_indx]=boxparams(data(:,2)-data(:,6),2.5)
data(out_indx,[2,6])=NaN;


%REVISAR

r=[c,data(:,2)./data(:,6)];
r=[r(:,1:2),data(:,4:5)];
ab=[c,data(:,2)-data(:,6)];
ab=[ab(:,1:2),data(:,4:5)];
rp=[c,100* (data(:,2)-data(:,6))./data(:,2)];
rp=[rp(:,1:2),data(:,4:5)];



if nargin==2
    name_a=inputname(1);
    name_b=inputname(2);
end

%r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
%r=[c,log(a(aa,2)./b(bb,2))];
% subplot(2,3,2);
% mmplotxx(data(:,4),data(:,5),[data(:,2),data(:,6)]);


dia=fix(diaj(data(:,1)));

%%PLOT BY DAY
figure;
%subplot(2,2,1);
hour=data(:,1)-fix(data(:,1));
gscatter(hour,data(:,[2,6]),dia)
hold on
h1=plot(hour,data(:,[2]),'o')
h2=plot(hour,data(:,[6]),'x')
set(gca,'XLim',[.25,.75]);
grid;
%legend([h1,h2],name_a,name_b,'location','NorthWestOutSide');
title(['OZONE: ',name_a,'o  ',name_b,' x ']);
datetick('keeplimits','keepticks');
hold off

%estatistics
figure;
jairm=find(data(:,5)>3);
base=ones(size(data(:,5)));
long=base;short=base;
long(jairm)=2;
group={dia,base,long}
data_f=data;
data_f(jairm,:)=NaN;

%subplot(2,3,3);
%%BOX PLOT
boxplot(data(:,2)-data(:,6),group)
%plot(data(:,2),data(:,3),'x');
%rline;
%mmplotxx(data(:,4),data(:,5),data(:,2))
grid;title(['boxplot ',name_a,'-',name_b]);





figure
%subplot(2,2,2);
%%BOXPLOT BY DAY
boxplot(ab(:,2),dia);ylabel('Ozone');
title(['boxplot ',name_a,'-',name_b]);
suptitle(name_b)



figure
%subplot(2,3,4);
%% RATIO
mmplotxx(data(:,4),data(:,5),r(:,2))
grid;title(['ratio %',name_a,' vs ',name_b]);
suptitle(name_b)

figure
%subplot(2,3,5)
%% ABS DIFF
%mmplotxx(data(:,4),data(:,5),ab(:,2))
plot(data(:,5).*data(:,2),ab(:,2))
grid;title(['dif ',name_a,' - ',name_b]);
suptitle(name_b)

figure
%% time distribution
%subplot(2,3,6);
hist(time*60*24*60);
xlabel('seconds');
title('Dist of time dif')
suptitle(name_b)

x=data;
