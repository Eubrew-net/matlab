function [dep,idx]=michalsky_dep(data,n_iter,eps,fplot)    
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
if nargin==1
    n_iter=2;
    eps=0.1;
else
    eps=0.1;
end
if nargin~=4
  fplot=0;
end
% filtro de derivada
% la derivada de la masa optica respecto al tiempo tiene que ser positva
% negativa para etc
% para aislar el ruido de equipo se promedia en intervalos de 1 minuto
% funciona mejor con tiempo que con masa optica
% pasamos a minutos
% data(:,1)=((data(:,1)-fix(data(:,1)))*24*60*1)/1;
% 
% sm=grpstats(data,fix(data(:,2)*1000)/1000);
%[idx,gn]=grp2idx(fix(data(:,2)*1000)/1000); 
%airm=cellfun(@str2num,gn);
sm=data;
sm(end,:)=NaN;
db=diff(sm);
%db(end)=NaN;

%j=find(db<eps);
%sm(j,2)=NaN;

%figure
%% la primera derivada es mayor que dos veces la media
idx=[];
for i=1:10
 db=diff(sm);
 nd=[sm,[db;[NaN,NaN,NaN]]];
 nd=[nd,nd(:,6)./nd(:,4),nd(:,6),nd(:,5)];
 nd=[nd,[NaN;diff(nd(:,7))]];
if i==1 idx=[length(nd),1];end

 % ploty(sm(:,[2,3]),'b-')
 % hold on;
 % title('derivative')
%ploty(nd(:,[1,4]))
%quitamos los datos
j=find(abs(nd(:,end))>3*nanstd(nd(:,end)));
if isempty(j)
    break
end
%ploty(nd(j,[2,3]),'go')
%ploty(nd(j+1,[2,3]),'ro')
%ploty(nd(j-1,[2,3]),'bo')
nd(j,3:end)=NaN;
nd(j+1,3:end)=NaN;
nd(j-1,3:end)=NaN;
jx=unique([j,j+1,j-1]);
jx=jx(:);
aux=jx; aux(:,2)=i;
try
 idx=[idx;aux];
catch
 disp('o');
end
%sm=sm(~isnan(nd(:,3)),:);
sm(isnan(nd(:,3)),3)=NaN;
end

%j=find(abs(nd(:,7))<3*nanmean(nd(:,7)));
%ploty(nd(j,[2,3]),'r+')
%nd(j,3:end)=NaN;
 
dep=sm;
% si todo va bien
%idx_=isnan(sm(:,3));
%all(find(idx_)==sort(idx(:,1)))
if fplot
    figure;
    ploty(data(:,[1,3]));
    hold on;
    ploty(data(idx,[1,3]),'r+');

figure;
ploty(sm(:,[2,3]),'k.')
title('regress');
robust_line
[b,stats]=robustfit(sm(:,2),sm(:,3));
figure;
plot(sm(:,2),stats.resid)
title('residuos');
hold on;
dep=sm;
end
end

end

