%Creates a nice looking table with colmne titls and resultes below
%Made by Miroslav Marecic, 19.11.2006
%title row input: title = {'string1' 'string2' 'string3'}

function celltable=tableform(title, data,rows)

if nargin==3
celldata = num2cell(data);
celltable1=[rows(:),celldata];
celltable = [[cellstr(''),title(:)'] ; celltable1];
fprintf('\n')
disp(celltable)
fprintf('\n')
else
celldata = num2cell(data);
celltable = [title ; celldata];
fprintf('\n')
disp(celltable)
fprintf('\n')
end