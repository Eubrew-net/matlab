%function [y_stat,y_sort]=mean_smooth(x,y,tol,plot)
% media desviacion estandard n elementos error estandard intervalo de
% confianza al 95%
function [y_stat,f]=mean_smooth(x,y,tol,plot)
y_stat=zeros(size(x,1),size(y,2),7);
for j=1:size(y,2)
    y_=y(:,j);
    
    for i=1:length(x)
        if ~isnan(x(i))
            ix=find(abs(x(i)-x)<tol*x(i));
            [m,s,n,sem,meamco]=grpstats(y_(ix),[],{'mean','std','numel','sem','meanci'});
            y_stat(i,j,:)=[x(i),m,s,n,sem,meamco];
        else
            y_stat(i,j,:)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN];
            %y_stat(i,:)=[nanmean(y(ix)),nanstd(y(ix)),length(~isnan(y(ix))),...
            %    prctile(y(ix),[2.5 25 50 75 97.5])];
        end
    end
end
%y_sort=sortrows(y_stat,1);
if size(y,2)==1
    y_stat=squeeze(y_stat);
end
if nargin >3
    if plot==1
        for j=1:size(y,2)
            if size(y,2)==1
               y_sort=sortrows(y_stat);
            else
            y_sort=sortrows(squeeze(y_stat(:,j,:)),1);
            end
            y_sort(y_sort(:,4)<5,:)=[];
            aux=y_sort(1:end-2,:);
            aux2=(matadd(aux(:,[6,7]),-aux(:,2)));
            errorfill(aux(:,1)',aux(:,2)',aux(:,3)','b');
            hold on
            
            f=errorfill(aux(:,1)',aux(:,2)',abs([aux2(:,1),aux2(:,2)])','r');
            box on; grid;
        end
    end
end
        