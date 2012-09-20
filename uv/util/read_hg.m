function [hg,ref,fin_ql,offset,lamp,error]=read_hg(bfile)

% Cuando hay problemas con cambios de día
% TRUCO: hg(1:4(por ejemplo),1)=hg(1:4,1)-1440 
% Si hicieramos medidas de oscuridad, habrá que quitarlas del fichero B 

[a b c]=fileparts(bfile);
bfile=strcat(b,c);  cd(a); 

offset=7;
if strcmp(c(2:end),'033'), offset=4; end

try 
    
%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(bfile);
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    
    fileinfo=sscanf(bfile,'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
    datestr(datefich(1));

    l=mmstrtok(s,char(10));
    jhg=strmatch('hg',l);
    jhgscan=strmatch('hgscan',l);
    jco=strmatch('co',l);
    
    
    sub=l(jco);
    s=sscanf(strcat(sub{:}),'%s');
    in=regexp(s,'ql'); ql=[];
    [q_lamp i] = regexp(s,'(?:[A-Z]?[A-Z]?\d\d\d?\d?\w*done)','match','end'); fin_ql=[];
    for h=1:length(in)
        fin_ql=[fin_ql; sscanf(s(in(h)-8:in(h)-1),'%02d:%02d:%02d')'];
        name=q_lamp{h};
        lamp{h}={sprintf('%s',name(1:(end-4)))};
    end 
%     if fin_ql(:,1)==0
%         ini_ql=24*60+(fin_ql(:,2)-offset)+fin_ql(:,3)./60;
%     else    
        ini_ql=fin_ql(:,1).*60+(fin_ql(:,2)-offset)+fin_ql(:,3)./60;
%     end

    fmt_icf=[
    'inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%3c',...
    ' %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s'];
    buf=l{1}; % get first line, should be version...

    if any(strmatch('version',buf))==1, %then OK
        ind=find(buf==char(13));
        lat=str2num(buf(ind(6):ind(7)));
        long=str2num(buf(ind(7):ind(8)));
        pr=str2num(buf(ind(end-1):end));
    elseif any(strmatch('dh',buf))==1
        disp('old format');
        fmtds=fmtds_old;
        hd=mmstrtok(buf,char(13));
        lat=str2num(hd{6});
        long=str2num(hd{7});
        pr=str2num(hd{end});
    else
        warning('no header information');
    end
    if length(l) >2
        buf=l{2};
        if ~any(strmatch('inst',buf))==1, %then OK
            buf=l{1};
            bufr=mmstrtok(buf,char(13));
            ind=strmatch('inst',bufr);
            cfg=sscanf(char(bufr(ind:end))',fmt_icf);
        else
            cfg=sscanf(buf,fmt_icf);
        end
        b_type=char(cfg(23:25)');
        if strcmp(b_type,'iii') cfg(23)=3;
        elseif strmatch('ii',b_type) cfg(23)=2;
        elseif strcmp(b_type,'v') cfg(23)=5;
        elseif strcmp(b_type,'iv') cfg(23)=4;
        end 
     end


% READ HG
% filtro de hg
% format 
  if isempty(jhgscan)
   hg=sscanf(char(l(jhg))','hg %d:%d:%d %f %f %d %f %d ',[8,Inf]);
  else
    jhg=setdiff(jhg,jhgscan);
    hg=sscanf(char(l(jhg))','hg %d:%d:%d %f %f %d %f %d %d ',[9,Inf]);
  end
  hg(1,find(hg(1,:)==0))=24;
  time_hg=(hg(1,:)*60+hg(2,:)+hg(3,:)/60)'; %a minutos
  flaghg=abs(hg(5,:)-cfg(13))<2; % more than 2 steps change
  flag_hg=find(diff(flaghg)==-1);   % 
  %revisar no es el siguiente sino el proximo no negativo
  time_badhg=time_hg([flag_hg;flag_hg+1]');
  % hg a fecha
  hg=hg';
  hgtime=datefich(1)+time_hg(:)/60/24;
  hg=[time_hg,hg(:,[4,5,6,7,8]),hg(:,5)-cfg(14)];
  ref=cfg(13);  

%  hg(end,1)=hg(end,1)-30
figure;
ar = area(hg(:,1),repmat(ref+1,length(hg(:,1)),1),ref-1);
set(ar,'FaceColor',[204 204 204]./256,'LineStyle','none'); 
h=hline(ref,'k-');set(h,'LineWidth',3);

hold on; hl1=line(hg(:,1),hg(:,3),'Marker','.','MarkerSize',25);
ax1 = gca;
set(ax1,'XColor','k','YColor','k',...
        'YLim',[min(hg(:,3))-5 max(hg(:,3))+5],'XLim',[hg(1,1)-25 hg(end,1)+25],...
        'XTick',hg(1:3:end,1),'XTicklabel',datestr(hgtime(1:3:end),15),'TickLength',[0 0]);
xlim1=get(ax1,'XLim');
ylabel('Hg step'); grid;
set(ax1,'Ygrid','off');

ax2=axes('Position',get(ax1,'Position'),...
         'XAxisLocation','top','YAxisLocation','right',...
         'Color','none','XColor','k','XTick',[],'YColor','k');
hl2 = line(hg(:,1),hg(:,end-1),'Color',[102 102 102]./256,'Parent',ax2,'Marker','s',...
                               'MarkerSize',8,...
                               'MarkerFaceColor',[102 102 102]./256,'LineStyle',':');
set(ax2,'YLim',[min(hg(:,end-1))-5 max(hg(:,end-1))+5],...
        'XLim',xlim1,'TickDir','Out','YMinortick','On'); 
ylabel('Hg Temperature'); grid;                         

set(gcf,'CurrentAxes',ax1);
hold on; v=vline(ini_ql(1),'k-'); set(v,'LineWidth',2);
t=text(ini_ql(1)-5,ref+4,lamp{1},'FontWeight','bold','Fontsize',14);      

  for i=2:length(ini_ql)
      hold on; v=vline(ini_ql(i),'k-');set(v,'LineWidth',2);
      t=text(ini_ql(i)-5,ref+4,lamp{i},'FontWeight','bold','Fontsize',14);    
          if strcmp(lamp{i},lamp{i-1})
              set(t,'Visible','off');        
          else  continue 
          end
  end
  title(sprintf('%s   %s',datestr(datefich(1),29),bfile),'FontSize',12);
  %   print('-djpeg',fullfile(pwd,[datestr(datefich(1),29),'_hg_157']));
  error=[];
catch
    hg=[];ref=[];fin_ql=[];offset=[];lamp=[];
    error = lasterr;
end
   