% plotxy(A)
%
%function h=ploty(A);
% h=plot(A(:,1),A(:,2:end));
function h=ploty(A,fmt);
if nargin<2 
   h=plot(A(:,1),A(:,2:end));
else 
   h=plot(A(:,1),A(:,2:end),fmt);   
end
title(inputname(1));