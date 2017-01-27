function [ap]=readb_ap(bfile)

sr=[];si=[];
%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(bfile)
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    [PATHSTR,NAME,EXT] = fileparts(bfile);
    fileinfo=sscanf([NAME,EXT],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1))

    l=mmstrtok(s,char(10));
    
    %jsum=strmatch('summary',l);
    jco=strmatch('ap',l);
    

    if ~isempty(jco)
        co=l(jco);
        datacell=cellfun(@(x) textscan(x(3:end),'%f','Delimiter',{':',' ',char(13)},'MultipleDelimsAsOne',1),co);
        ap=cell2mat(datacell');
        dates=repmat(datefich',1,size(ap,2));
        dates(1,:)=dates(1,:)+datenum([zeros(size(dates));ap(1:3,:)]')';
        ap=[dates;ap];
    else
        ap=[];
    end
    
    
    