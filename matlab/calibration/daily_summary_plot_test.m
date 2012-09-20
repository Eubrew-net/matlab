%% PLOT

load(file_save);


n_ref_colors=[
    1,0,0;
    1,.33,.33;
    1,.667,.667;
    ]
n_ref_mk=['x','+','o'];
n_ref=[1,2,3];


c=jet(length(brw)*2);       
f=figure; 
set(f,'Tag','_GlobalPlot_');
h=plot(1);
MK=set(plot(1),'Marker');
for i=length(MK):length(brw)
   MK{i}='.';
end
MK{n_inst}='d';

try
MK{strmatch('.',MK)}='o';
catch
end

% separa los dias -> nice plot
for i=1:length(brw)
aux=sortrows(summary{i},1);
[dias,j]=unique(diaj(aux(:,1)),'first');
B=aux(j,:);
B(:,2:end)=NaN;
aux=insertrows(aux,B,j);
[dias,j2]=unique(diaj(aux(:,1)),'last');
B=aux(j2,:);
B(:,2:end)=NaN;
aux=insertrows(aux,B,j2);
summary{i}=insertrows(aux,B,j2);
end
[dias,j]=unique(diaj(summary{n_inst}(:,1)),'first');
clf
hold on;
for i=1:length(brw)
   k(i)=ploty(summary{i}(:,[1,end-1]),'o');
   if i==n_inst 
       k(length(brw)+1)=ploty(summary_old{i}(:,[1,end-1]),'bs');
   end
   set(k(i),'color',c(i,:),'Marker',MK{i},'MarkerSize',2);
   if any(i==n_ref) 
        set(k(i),'color',n_ref_colors(i,:),'Marker',n_ref_mk(i),'LineStyle','-','LineWidth',2,'MarkerSize',4);
   elseif i==n_inst;
        set(k(i),'color',[0,1,0],'Marker','.','LineStyle','-','LineWidth',2);
   end
   if mod(i,2)==1 
       set(k(i),'MarkerFaceColor',c(i,:))
   end
end  
legend(k,[brw_name,([brw_name{n_inst},'_s_l'])],'Location','BestOutside');
datetick('keepticks');
axis([datenum(cal_year,1,1)+dias(1),datenum(cal_year,1,1)+dias(end),240,340])
box on
grid
ylabel('Dobson Units')
title([' RBCC-E ',num2str(cal_year)])
xlabel('Date')

%% Final status day 246-248
for dj=dias'  
    c=(hot(length(brw)+2));       
    f=figure; 
%     set(f,'Tag',sprintf('%s%i','DayPlot_',num2str(dj)));
%     h=plot(1);
%     clf
    hold on;
    for i=1:length(brw)        
       k(i)=ploty(summary{i}(:,[1,end-1]),'.');
       set(k(i),'color',c(i,:),'Marker',MK{i},'MarkerSize',2);
       if i==n_ref 
        set(k(i),'color',[1,0,0],'Marker','d','LineStyle','-','LineWidth',2);
       elseif  i==n_inst
         set(k(i),'color',[0,1,0],'Marker','d','LineStyle','-','LineWidth',2);
         gscatter(summary{i}(:,1),summary{i}(:,end-1),summary{i}(:,5),[0,1,0],'.xpsd')
       end
       if i==n_inst
         k(length(brw)+1)=ploty(summary_old{i}(:,[1,end-1]),'bs');
         
         % k(length(brw)+2)=ploty(summary_old{i}(:,[1,7]),'c.');
       end
      if mod(i,2)==1 
         set(k(i),'MarkerFaceColor',c(i,:))
      end
    end
%     suptitle('RBCC-E ')
if i==n_inst
    gscatter(summary{i}(:,1),summary{i}(:,end-1),summary{i}(:,5),[0,1,0],'.xpsd',[],1,'',cellstr(num2str((0:5)')));
end
    
    set(gca,'Xlim',[datenum(cal_year,1,1)+dj-1+.25,datenum(cal_year,1,1)+dj-.20]);
    set(gca,'Ylim',[220,380]);
    
    
    legend(k,[brw_name,([brw_name{n_inst},'_s_l'])],'Location','BestOutside');
    %     legend([brw_name{1},brw_name{n_inst},([brw_name{n_inst},'_s_l'])],-1);
    datetick('keeplimits');
    box on;    grid;
    ylabel('Dobson Units');     xlabel('Hour (GMT)');
    title(datestr(datenum(cal_year,1,1)+dj-1));
    set(f,'Tag',sprintf('%s%s','DayPlot_',num2str(dj)));
end

try
    snapnow;
catch
    disp('Report warning');
end