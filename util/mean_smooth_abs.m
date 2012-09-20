function [y_stat,y_sort,f]=mean_smooth_abs(x,y,tol,plot)

y_stat=zeros(size(x,1),6);
for i=1:length(x)
    if ~isnan(x(i))
     ix=find(abs(x(i)-x)<tol);
     [m,s,n,sem,meamco]=grpstats(y(ix),[],{'mean','std','numel','sem','meanci'});
     y_stat(i,:)=[m,s,n,sem,meamco];
    else
      y_stat(i,:)=[NaN,NaN,NaN,NaN,NaN,NaN];   
    %y_stat(i,:)=[nanmean(y(ix)),nanstd(y(ix)),length(~isnan(y(ix))),...
    %    prctile(y(ix),[2.5 25 50 75 97.5])]; 
    end
end

y_sort=sortrows([x,y_stat],1);


if nargin >=3
%figure;
    if plot==1
      aux=y_sort;
      aux(isnan(aux(:,end)),:)=[];
      aux2=(matadd(aux(:,[6,7]),-aux(:,2)));
    errorfill(aux(:,1)',aux(:,2)',aux(:,3)','b');
    hold on
    f=errorfill(aux(:,1)',aux(:,2)',abs([aux2(:,1),aux2(:,2)])','r');
    box on; grid;
    end
end
        