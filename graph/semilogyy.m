% plotxy(A)
%
%function h=ploty(A);
% h=plot(A(:,1),A(:,2:end));
function h=semilgoyy(A,fmt)
if nargin<2 
   h=semilogy(A(:,1),A(:,2:end));
else 
   h=semilogy(A(:,1),A(:,2:end),fmt);   
end
title(inputname(1)); warning off;