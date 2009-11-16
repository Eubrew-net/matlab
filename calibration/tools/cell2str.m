function datei=cell2str(cellArray,delimiter,format)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(filename,cellArray,delimiter)
%
% filename      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% delimiter = seperating sign, normally:',' (it's default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
if nargin<3
    format='%f';
end
if nargin<2
    delimiter = ',';
end

datei =[]; 
%fopen(filename,'w');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)

        var = eval(['cellArray{z,s}']);

        if size(var,1) == 0
            var = '';
        end

        if isnumeric(var) == 1
            var=var(:)';
            if length(var)==1
                var = num2str(var,format);
            else
                var= sprintf([format,' ',delimiter],var);
            end
        end

        datei=[datei,sprintf([var,delimiter])];
    end
    if s ~= size(cellArray,2)
        datei=[datei,sprintf(delimiter)];
    end
    datei=[datei,sprintf('\b\n')];
end
%fclose(datei);