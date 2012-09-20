function instreset

%instreset
%
% Closes and deletes all instruments.
%
% (c) 2001 Richard Medlock. rmedloc@celestica.com


ins = instrfind;

NumberOfInstruments = length(ins);

for i = 1:NumberOfInstruments
    
    fclose(ins(i))
    delete(ins(i))
    
end

