function h=errorbard(A,fmt)

if size(A,2)>2
   
 if nargin<2 
   h=errorbar(A(:,1),A(:,2),A(:,3));
 else 
   h=errorbar(A(:,1),A(:,2),A(:,3),fmt);   
 end 
else
   ploty(A,fmt);
end   