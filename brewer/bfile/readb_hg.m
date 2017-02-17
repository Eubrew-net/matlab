function [ap,hgs]=readb_hg(bfile)
% hg
% 03:01:37
%  .9988
%  1020.279
%  1020
%  281903
%  30
%  0

% hgscan
%  0
% wide 296
% warm= 4.15
% 03:00:12FEB 
% 11/
% 17


%  549
%  1036
%  3246
%  17530
%  38588
%  61671
%  82705
%  103146
%  122776
%  138969
%  140450
%  132164
%  112951
%  90320
%  68183
%  46560
%  26178
%  6178
%  632
%  252
% 
%  238
%  604
%  6026
%  26094
%  46867
%  67919
%  90540
%  112669
%  133090
%  141453
%  139823
%  123460
%  104495
%  84318
%  63204
%  39587
%  17849
%  3468
%  1039
%  597



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
    jco=strmatch('hg',l);
    jsc=strmatch('hgscan',l);
    j1=ismember(jco,jsc);
    jhg=jco(~j1);
    if ~isempty(jhg)
        co=l(jhg);
        datacell=cellfun(@(x) textscan(x(3:end),'%f','Delimiter',{':',' ',char(13)},'MultipleDelimsAsOne',1),co);
        ap=cell2mat(datacell');
        dates=repmat(datefich',1,size(ap,2));
        dates(1,:)=dates(1,:)+datenum([zeros(size(dates));ap(1:3,:)]')';
        j_c=find(diff(ap(1,:))<-1)+1;  % date change
        dates(1,j_c:end)=dates(1,j_c:end)+1;
        
        
        ap=[dates;ap]';
    else
        ap=[];
    end
    if ~isempty(jsc)
        co=l(jsc);
        %datacell=cellfun(@(x) textscan(x(5:end),'%f','Delimiter',{':',' ',char(13)},'MultipleDelimsAsOne',1),co);
        [c1,c2]=cellfun(@(x) textscan(x(7:end),' %*f wide %f warm= %f %f %f %f %*3c   %f %f ',...
            'Delimiter',{'/',':',' ',char(13)},'MultipleDelimsAsOne',1),co,'UniformOutput',false);
        c1=cell2mat(cellfun(@(x) cell2mat(x),c1,'UniformOutput',false));
        c3=cellfun(@(x,y) textscan(x(y:end),'%f','Delimiter',{'/',':',' ',char(13)},'MultipleDelimsAsOne',1),co,c2);
        c3=cell2mat(c3')';
        hgs=[c1,c3];
        dates=repmat(datefich',1,size(hgs,1))';
        dates(:,1)=dates(:,1)+datenum([zeros(size(dates)),hgs(:,3:5)]);
        j_c=find(diff(hgs(:,3))<-1)+1;  % date change
        dates(1,j_c:end)=dates(1,j_c:end)+1;        
        hgs=[dates,hgs];
    else
        hgs=[];
    end
    
    