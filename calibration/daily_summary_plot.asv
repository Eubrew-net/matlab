%% PLOT


c=jet(length(brw)+2);       
f=figure; 
set(f,'Tag','_GlobalPlot_');
h=plot(1);
MK=set(plot(1),'Marker');
for i=length(MK):length(brw)
   MK{i}='.';
end
MK{n_inst}='o';
MK{n_ref}='*';



%MK{n_inst}='+';
MK{n_inst}='o';
MK{n_ref}='*';
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

clf
hold on;
for i=1:length(brw)
   %h(i)=ploty(cal{i}(:,[1,6]),'.');
   %set(h(i),'color',c(i,:));
   k(i)=ploty(summary{i}(:,[1,end-1]),'-*');
   if i==n_inst 
       k(length(brw)+1)=ploty(summary_old{i}(:,[1,end-1]),'bs');
       %k(length(brw)+2)=ploty(summary_old{i}(:,[1,7]),'c.');
   end
   set(k(i),'color',c(i,:),'Marker',MK{i},'MarkerSize',2);
       if i==n_ref || i==1;
        set(k(i),'color',[1,0,0],'Marker','d','LineStyle','-','LineWidth',2);
        set(k(1),'color',[0,1,0],'Marker','d','LineStyle','-','LineWidth',2);
   end
   %k2(i)=ploty(summary{i}(:,[1,4]),':.');
   set(k(i),'color',c(i,:),'Marker',MK{i});
   %set(k2(i),'color',c(i,:),'Marker',MK{i});
   if mod(i,2)==1 
       set(k(i),'MarkerFaceColor',c(i,:))
   end
end  
legend(k,[brw_name,([brw_name{n_inst},'_s_l'])],'Location','Best');
datetick('keepticks');
axis([datenum(cal_year,cal_month,8),datenum(cal_year,cal_month,16),280,340])
box on
grid
ylabel('Dobson Units')
title([' RBCC-E ',num2str(cal_year)])
xlabel('Date')

%% Final status day 246-248


for dj=CALC_DAYS
    
 c=(hot(length(brw)+2));       
    f=figure; 
    set(f,'Tag',['_DayPlot_',num2str(dj)]);
 
    h=plot(1);
    clf
    hold on;
    for i=1:length(brw)
        
       k(i)=ploty(summary{i}(:,[1,end-1]),'.');
       set(k(i),'color',c(i,:),'Marker',MK{i},'MarkerSize',2);
       if i==n_ref || i==1;
        set(k(i),'color',[1,0,0],'Marker','d','LineStyle','-','LineWidth',2);
        set(k(1),'color',[0,1,0],'Marker','d','LineStyle','-','LineWidth',2);
       end
     if i==n_inst
       set(k(i),'color',[0,0,0],'Marker','o','LineStyle','-','LineWidth',2);
       k(length(brw)+1)=ploty(summary_old{i}(:,[1,end-1]),'bs');
       %k(length(brw)+2)=ploty(summary_old{i}(:,[1,7]),'c.');
     end

%        if mod(i,2)==1 
%            set(k(i),'MarkerFaceColor',c(i,:))
%        end
    end
    suptitle('RBCC-E ')
    axis([datenum(cal_year,1,1)+dj-1+.25,datenum(cal_year,1,1)+dj-.20,280,340])
    %legend(k,brw_name,-1);
    legend(k,[brw_name,([brw_name{n_inst},'_s_l'])],-1);
    set(f,'Tag',['__DayPlot__',datestr(datenum(cal_year,1,1)+dj)]);
    datetick('keeplimits');
    box on
    grid
    ylabel('Dobson Units')
    title(datestr(datenum(cal_year,1,1)+dj-1));
    xlabel('Hour (GMT)')
    
   
end

try
    snapnow;
    %close all;
catch
    disp('Report warning');
end
    

