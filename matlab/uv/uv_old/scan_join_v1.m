%function scanjoin [scan]=scan_join(scan0,scan1)
% añade el scan1 (lamda1,medidaN+1) SIMPLE a la matriz de 
% scan0 %(lamda0,medida1,medida2......,medida n)
% salida: scan (lamda,medida,..........medidan+1)
%      lamda union sin repeticion de lamda0 y lamda1
% rellena con nan las longitudes de onda no cumunes
function [scan]=scan_join(scan0,scan1)
% gestiona que los scanes tengan la misma longitud rellenando con nan si es preciso
% scan1 ha de ser un scan SIMPLE solo dos columnas
% 
if isempty(scan0)
    scan=scan1;
    mean=scan1;
    rat=scan1;
    return
    
end
if size(scan1,2)>2
    warning('scan1 ha de ser un scan SIMPLE solo dos columnas')
    scan1=scan1(:,1:2);
end

l=scan0(:,1);
l_0=scan1(:,1);
[D,d,d_0]=setxor(l,l_0);
if isempty(d) & isempty(d_0) % son iguales los scanes               
    
    %scan=[l,scan0(:,2:end),scan1(:,2)]; 
    [I,il,il_0]=intersect(l,l_0);
    scan=[I,scan0(il_0,2:end),scan1(il,2)]; 
    
elseif isempty(d_0)             % 1 esta incluido en 2
    [I,il,il_0]=intersect(l,l_0);
    aux=NaN*l;
    aux(il)=scan1(il_0,2:end);
    scan=[l,scan0(:,2:end),aux];
    
elseif isempty(d)               % 2 esta inclido en 1
    [I,il,il_0]=intersect(l,l_0);
    aux=NaN*l_0;
    aux=repmat(aux,1,size(scan0,2)-1);
    aux(il_0,:)=scan0(il,2:end);
    scan=[l_0,aux,scan1(:,2:end)];
else                            % los dos tienen elementos no comunes
    u=unique([l;l_0]);
    [I,il,il_0]=intersect(u,l_0);
    aux=NaN*u;aux1=aux;
    aux0=repmat(aux,1,size(scan0,2)-1);
    aux1(il)=scan1(il_0,2:end);
    [I,il,il_0]=intersect(u,l);
    aux0(il,:)=scan0(il_0,2:end);
    scan=[u,aux0,aux1];
    %warning('ss')
end     
 

