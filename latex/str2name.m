function [ str ] = str2name( str )
str=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(str));
end

