function [ str ] = string2latex( str )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% change the  latex charater 

str=strrep(str,'_','\_');
str=strrep(str,'#','\#');
str=strrep(str,'&','\&');
str=strrep(str,'ñ','\~n');
str=strrep(str,'%','\%');

%\~{n}






end

