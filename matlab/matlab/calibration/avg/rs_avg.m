% plotea el fichero run/stop
function rsa=rs_avg(file,date_range);

try
 a=textread(file,'');
catch
    try
     a=read_avg_line(file);   
    catch
     disp(file);
     
     aux=lasterror;
      disp(aux.message)
      return;
    end
end
rs=avgfech(a);

% only six principal slits
rsa=rs(:,[1,4,6:end-1]);
rsa_=rsa;
if nargin>1
    try
     rsa_=rsa(rsa(:,1)>=date_range(1) & rsa(:,1)<=date_range(2),:);
    catch
     disp('errror de seleccion de fecha');
    end
    if isempty(rsa_)
        rsa_=rsa;
    else
        rsa=rsa_;
    end
        
end
num_lab=6;
labs=linspace(rsa(1,1),rsa(end,1),num_lab);

f=figure; set(f,'Tag','RSAVG');
for i=1:6,
    sub=subplot(6,1,i);
    h=ploty(rsa(:,[1,i+1]),'.'); set(h,'MarkerSize',11);
    set(gca,'XLim',[date_range(1)-2,date_range(2)+2]);
    set(gca,'YLim',[0.990,1.010],'YTick',[.997 1.003],'YTickLabel',[.997 1.003],...
            'XTick',labs,'XTickLabel',[],...
            'GridLineStyle','-.','Linewidth',1);
    hl=hline([0.997,1.003],'r-.');     hl=hline(1,'k-');
    if i==1
    text(rsa(1,1)+1,1.0075,'SLIT 0');
    else
    text(rsa(1,1)+1,1.0075,sprintf('SLIT %d',i));
    end
    grid; 
    ylabel('Ratio'); 
end
samexaxis('xmt','off','join','yld',1);%
if i==6
        set(gca,'YTick',[.988 .997 1.003],'YTickLabel',{'','0.997','1.003'},'XTick',labs);
        datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
end
sup=suptitle(sprintf('%s%s','Run/Stop Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
pos=get(sup,'Position'); 
set(sup,'Position',[pos(1)+.02,pos(2)-.05,1]);
