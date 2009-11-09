function cell2csv(filename,cellArray,delimiter,format)
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
    delimiter = ',';
end

datei = fopen(filename,'w');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        var = eval(['cellArray{z,s}']);
        
        if size(var,1) == 0
            var = '';
        end
        
        if isnumeric(var) == 1
            var=var(:)';
            if nargin==4
            var = num2str(var,format);
            else
             var = num2str(var);
            end
      
        end
        if iscell(var)
            var=cell2str(var,delimiter);
        end    
            
        fprintf(datei,' %s ',var);  
        
        if s ~= size(cellArray,2)
            fprintf(datei,[delimiter]);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);