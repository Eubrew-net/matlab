function nb=toknb(s,D);
% function nb=toknb(s,D);
% 7/4/97 julian
% finds number of elements in string s, delimited by space.
% D is optional delimiter.

if ~exist('D'), D=' ';end

nb=0;

while ~isempty(s),
 nb=nb+1;
 [buf,s]=strtok(s,D);
end

