function [dt,rs,dtavg,rsavg]=read_dt(path)
 dtavg=[];
 rsavg=[];
 dt=[]; rs=[];
 
 s=dir(path);
 p=fileparts(path);
 for i=1:length(s)
  try
     [dtavg_,rsavg_]=readb_dt(fullfile(p,s(i).name));
     dtavg=[dtavg;dtavg_];
     rsavg=[rsavg;rsavg_];
  catch
     warning(s(i).name) 
 end
 end
 
 %plots
 
    


 if ~isempty(dtavg) %dead time on bfile
      dt=[dtavg(:,1),dtavg(:,30:33)];
        %subplot(2,1,1)
        p1=confplot(dt(:,[1,4,5]));hold on;
        p2=errorbard(dt(:,1:3),'bo');
        datetick('keeplimits');grid
        legend([p1(1),p2],'dt high','dt low');
        title('Dead Time Test');
        ylabel('Time 10^-^9 seconds');
 end

 figure;
    if ~isempty(rsavg)
        rs=[rsavg(:,1),rsavg(:,19:26)];
        %subplot(2,1,2)
        plot(rs(:,1),rsavg(:,[19,21:26]));
        datetick;
        set(gca,'Ylim',[0.990,1.01]);
        hline([0.997,1.003])
        grid
    end
            
 