function [dep,idx_rej]=michalsky_filter_2(lgl,FC,fplot)
if nargin==1
    FC=[];
    fplot=0;
end
if nargin==2
    fplot=0;
end
ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
          'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  %   % 12-18 cuentas/segundo  config 1                    
          'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... %  % 19-25ratios (Rayleight corrected !!)                 
          'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  % % 26-32Segund configuracion                           
          'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... % 33-39ratios (Rayleight corrected !!) 
                                                    
         };
jc=[];
dep=lgl;
idx_rej=zeros(size(lgl));

for ii=1:4
    switch ii
        case 1
            jc=[12,14:18];
        case 2
            jc=[17,18];
        case 3
            jc=[26,28:32];
        case 4
            jc=[38,39];
    end
    
    for jj=1:length(jc);
        
        if ~isempty(FC)
            XF=[];
            t=tabulate(lgl(:,10));

             for ff=1:length(FC)
                 if(t(t(:,1)==FC(ff),2)>30) %nuber safe to remove los metemos corregidos
                    XF=[XF,lgl(:,10)==FC(ff)];
                 else                       %los sacamos del analisis 
                    lgl(lgl(:,10)==FC(ff),jc(jj))=NaN;
                 end
             end;
             XF=[ones(size(lgl(:,5))),lgl(:,5),XF];
             try
                c1=regress(lgl(:,jc(jj)),XF);
                %yh=XF(:,1:2)*c1(1:2);
                yh=lgl(:,jc(jj))-XF(:,3:end)*c1(3:end);
                %plot(lgl(:,5),yh,'-',lgl(:,5),lgl(:,jc(jj)),'r.')
             catch
                disp('filter removal errror');
              
             end
        else
           yh=lgl(:,jc(jj)); 
        end
        
    [dep_,idx_rej_]=michalsky([lgl(:,[1,5]),yh]);
    dep(idx_rej_,jc(jj))=NaN;
    idx_rej(idx_rej_(:,1),jc(jj))=idx_rej_(:,2);
    if fplot
        data=lgl(:,[1,5,jc(jj)]);
        data(idx_rej_(:,1),4)=idx_rej_(:,2);
        subplot(1,2,1);hold on;
        gscatter(data(:,2),data(:,3),data(:,4),'krmgbc');
        subplot(1,2,2);hold on;
        gscatter(data(:,1),data(:,3),data(:,4),'krmgbc');
    end
 end
end
end

function [dep,idx]=michalsky(data,n_iter,eps,fplot)    
    
% data: tres columnas tiempo masa optica y radiancia
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
if i==1
    %añadimos el ultimo
    idx=[length(nd),1];
    jx=find(isnan(sm(:,3)));% ya eliminados
    idx=[idx;[jx,ones(size(jx))]];
    
end

 % ploty(sm(:,[2,3]),'b-')
 % hold on;
 % title('derivative')
%ploty(nd(:,[1,4]))
%quitamos los datos
j=find(abs(nd(:,end))>3*nanstd(nd(:,end)));
if isempty(j) || i>n_iter
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
%all(find(idx_)==unique(idx(:,1)))
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