function [n, m] = month(d)
%MONTH Month of date.
%   Month returns the month in numeric and string form given a serial date
%   number or a date string.
%
%   [N, M] = MONTH(D)
%
%   Inputs:
%   D   - Serial date number(s) or a date string(s).
%
%   Outputs:
%   N   - Numeric month representation.
%   M   - String month representation.
%
%   Example:
%      19-Dec-1994 (728647)
%
%      [n, m] = month(728647)
%      n =
%          12
%      m =
%          Dec
%
%      [n, m] = month('19-Dec-1994')
%      n =
%          12
%      m =
%          Dec
%
%   See also DATEVEC, DAY, YEAR.

%   Copyright 1995-2006 The MathWorks, Inc.
%   $Revision: 1.6.2.4 $   $Date: 2006/06/16 20:08:47 $

if nargin < 1
    error('Finance:month:missingInput', 'Please enter D.')
end

if ischar(d)
    d = datenum(d);
end

% Generate date vectors
c = datevec(d(:));

% Monthly strings
mths = ['NaN';'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul'; ...
    'Aug';'Sep';'Oct';'Nov';'Dec'];

% Extract numeric months
n = c(:, 2);

% Keep track of nan values.
nanLoc = isnan(n);

% Extract monthly strings. (c(:, 2) == 0) handles the case when d = 0.
mthIdx = c(:, 2) + (c(:, 2) == 0);
mthIdx(nanLoc) = 0;
m = mths(mthIdx + 1, :);

% Preserve the dims of the inputs for n. m is a char array so it should be
% column oriented.
if ~ischar(d)
    n = reshape(n, size(d));
end


% [EOF]
