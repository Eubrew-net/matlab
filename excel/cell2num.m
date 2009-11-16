function x = cell2num(X)
% a = cell2num(A)
% The input 'A' is a numeric cell array (one number per cell)
% The output 'a' is a numeric matrix.

%% This program was tested under versions 5.2 and 5.3 on PC 
%
% Created at: sept. 1999  by
%                         |
%                         V
%          e-mails: jonathan@ndc.soreq.gov.il
%                   bar-sagi@actcom.co.il

[N M]=size(X);
y=cat(2,X{:});
x = reshape(y,N,M);
