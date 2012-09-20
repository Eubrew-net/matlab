function theResult = at(theFile)

% at -- Switch to the folder of a given file.
%  at('theFunction') switches to the folder
%   of 'theFunction', as determined by the
%   "which" function.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Feb-2000 22:21:09.
% Updated    30-May-2001 07:24:40.

if nargout > 0, theResult = []; end

if nargin < 1, help(mfilename), return, end

w = which(theFile);

if isempty(w)
	disp([' ## No such file: ' theFile])
	return
elseif isequal(w, 'built-in')
	disp([' ## ' theFile ' is built-in.  Try "at ' theFile '.m".'])
	return
end

[thePath, theName, theExtension, theVersion] = fileparts(w);

if any(thePath), cd(thePath), end

if nargout > 0
	theResult = pwd;
else
	disp([' ## ' pwd])
end
