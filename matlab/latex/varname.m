function [ output ] = varname( input )
output=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(input));
end

