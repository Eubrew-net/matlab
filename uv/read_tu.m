%updated version
% do not support interrupted tu routin
% requires scan_join
% TUM: tu scans joined
% T_UN: Normalized joinend scan
% example:
%[tu,t_un]=readd_tu('D08312.183')
%ploty(tu)
%ploty2(mean_lamp(t_un))
function [tum,t_un]=read_tu(Dfile)

tum=[];tus=[];t_un=[];tu=[];
%leemos el fichero en memoriad
f=fopen(Dfile);
if f < 0
    disp(Dfile)
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    
    fileinfo=sscanf(Dfile,'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1))

    l=mmstrtok(s,char(10));
    
    
    % TU
    j_ini=strmatch('Prism',l);
    j_fin=strmatch('Maximum lamp intensity:',l);
    
    for i=1:length(j_fin)
        i;
        try
        aux=str2num(cell2mat(l(j_ini(i)+2:j_fin(i)-2)));
        %tu=[tu;aux];
        tum=scan_join(tum,aux);
        catch
            disp(aux)
            disp(i)
        end
        
        
    end
 t_un=[tum(:,1),matdiv(tum(:,2:end),nanmax(tum(:,2:end)))];   