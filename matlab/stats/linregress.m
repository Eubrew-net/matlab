%linregres llama a la funcion regres con termino independiente
%function [b,bint,r,rint,stats] = regress(y,X,alpha)


function [b,bint,r,rint,stats] = linregress(y,x,alpha)
if nargin==2
    alpha=0.05;
end
%añandimos el termino independiente
X=[x,ones(size(x))];
%llamamos a regress 
[b,bint,r,rint,stats] = regress(y,X,alpha);

