
function [tu,tus]=readd_tu(bfile)

tu=[];tus=[];
%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(bfile)
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    
    fileinfo=sscanf(bfile,'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1))

    l=mmstrtok(s,char(10));
    
    
    % TU
    j_ini=strmatch('Prism',l)
    j_fin=strmatch('Maximum lamp intensity:',l)
    
    for i=1:length(j_fin)
        i
        try
        aux=str2num(cell2mat(l(j_ini(i)+2:j_fin(i)-2)));
        tu=[tu;aux];
        catch
            disp(cell2mat(l(j_ini(i)+2:j_fin(i)-2)));
        end
        if i==1 % | i==33
            tus=tu;
        else
            try
             tus=[tus,aux(:,2)];
            catch
             disp('error')
            end
        end
        
    end
    