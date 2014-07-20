function [f_hist,f_ev,f_sc,f_smooth]=ratio_ref_plots(Cal,ratio_ref)
   
if length(Cal.analyzed_brewer)+2 ==size(ratio_ref,2)

%% hist
    f_hist=figure;
    [a,b]=hist(ratio_ref(:,2:end-1),[-2,-1.5,-1,-.75,-.5,-.25,0,.25,.5,.75,1,1.5,2]);
    bar(b,matdiv(100*a,sum(a)));
    title('Relative differences to mean. Percentage');
    legend(Cal.brw_name{Cal.analyzed_brewer});
    set(f_hist,'Tag','hist');

%% time
    f_ev=figure;
    %fech=fix(ref_m(jsim,1)/1)*1;
    [m,s,n,sem]=grpstats(ratio_ref,fix(ratio_ref(:,1)),{'mean','std','numel','sem'});
    x=m(:,1);
    %j=find(n(:,1)>=1); only works if reference is the first
    X=repmat(x,1,length(Cal.analyzed_brewer));
    %errorbar(X(j,:),m(j,:),2*s(j,:)./sqrt(n(j,:)),'*');
    errorbar(X,m(:,2:end-1),sem(:,2:end-1),'*'); 
    set(gca,'YLim',[-1.5 1.5]); legend(Cal.brw_name{Cal.analyzed_brewer}); grid
    datetick('x','mm/dd','Keepticks','keeplimits');
    title('daily ratios with respect to mean and standard error')
    set(f_ev,'Tag','time_ev');
 %% scatterhist
 
    f_sc=figure
    h=plot(ratio_ref(:,end),ratio_ref(:,2:5),'.'); 
    hold all
    h=scatterhist(ratio_ref(:,end),ratio_ref(:,end-1)); set(findobj(gcf,'Type','Line'),'MarkerSize',5);
    hold on
    h=plot(ratio_ref(:,end),ratio_ref(:,2:5),'.');
    legend(h,Cal.brw_str(Cal.analyzed_brewer));
    set(f_sc,'Tag','hist_osc');
 %%
 try
    f_smooth=figure
    s={};
    for ii=1:length(Cal.analyzed_brewer)
        [aux,s{Cal.analyzed_brewer(ii)}]=mean_smooth(ratio_ref(:,end),ratio_ref(:,ii+1),.125);
        hold on;
    end
    
   %n_plot=~cellfun('isempty',s);
    if length(Cal.analyzed_brewer)<=5 % plot_smooth_ admite hasta 5 ploteos
       h=plot_smooth_(s{Cal.analyzed_brewer});      
    else
       h=plot_smooth_(Cal.analyzed_brewer(1:5)); set(h(h~=0),'LineStyle','-');
    end
    set(h(h~=0),'LineStyle','-');
       set(h,'LineWidth',3);
       title({ sprintf('Smooth ratio to the reference day %d to %d of %d',...
           [diaj([min(ratio_ref(:,1)),max(ratio_ref(:,1))]);Cal.Date.cal_year]),...
           'Smooth ratio: every point is averaged with the 12.5% neighbour'...         
           });
          
    legend(h,Cal.brw_str(Cal.analyzed_brewer));
    set(f_smooth,'Tag','Triad_osc_smooth_alt');
   
 catch
    disp('check plot_smooth function')
 end
    
    

else
    disp(' ErrorDimensions of ratio_ref are not agree with analyzed brewer');
    disp(' Last column must be the osc ')
end
    