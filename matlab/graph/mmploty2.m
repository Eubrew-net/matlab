% plotxy(A)
%
%function h=ploty(A);
% h=plotyy(A(:,1),A(:,2),A(:,1),A(:,3),fmt);   

function [h]=mmploty2(A,fmt)
if nargin<2 
   [h]=mmplotyy(A(:,1),A(:,2),A(:,3));
else 
   [h]=mmplotyy(A(:,1),A(:,2),fmt{1},A(:,3),fmt{2});   
end
title(inputname(1));