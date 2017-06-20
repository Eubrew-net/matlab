function [ str ] = strd2var( str )
% replace special characters for latex 

str=deblank(str);
str=strrep(str,' ','_');
str=strrep(str,'#','_');
str=strrep(str,'&','_');
str=strrep(str,'?','_');
str=strrep(str,'%','_');
str=strrep(str,'-','_');
str=strrep(str,'.','_');
str=strrep(str,'/','_');
str=strrep(str,'+','_');

%\~{n}






end

