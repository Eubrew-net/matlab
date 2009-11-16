function p=polyfitm(x,y,n)

[paux,s,mu]=polyfit(x,y,n);
% deshacemos el cambio
% xn= x-mu(1)/mu(2) 
% xn-a ->   1/mu2 (x -mu1-mu2* a)
r=roots(paux/paux(1));
rnew=r.*mu(2)+mu(1);
p=paux(1)*poly(rnew)*1/(mu(2)^n);

