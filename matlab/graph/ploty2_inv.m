% plotxy(A)
%
%function h=ploty2_inv(A);
% h=plotyy(A(:,1),A(:,2),A(:,1),A(:,3),fmt);   

function h=ploty2_inv(A,fmt);

figure
if nargin<2
    
   h=plotxx(A(:,2),A(:,1),A(:,3),A(:,1));
else 
   h=plotxx(A(:,2),A(:,1),A(:,3),A(:,1),fmt);   
end
title(inputname(1));