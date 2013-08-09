function h=plot_smooth_(osc_smooth_a,osc_smooth_b,varargin)

% function h=plot_smooth(osc_smooth_a,osc_smooth_b,varargin)
% 
% Admite hasta cinco ploteos:
% If any(varargin)=='bars' -> errorbar, else boundedline
% 
% Si errorbar -> osc_ranges define grupos. Ha de ser de esa manera (TODO grp={groups})
% 
% Example:  h=plot_smooth(osc_smooth_1,osc_smooth_2,osc_smooth_3,osc_smooth_4,'bars'); 
%  
 osc_lim=[250 1850]; osc_ranges=200:50:2000;

 myfunc=@(x)strcmp(x, 'bars'); 
 check_vargs=any(cellfun(myfunc,varargin));

%  osc_smooth_a=osc_smooth_a(~isnan(osc_smooth_a(:,1)),:); 
 osc_smooth_a=osc_smooth_a(osc_smooth_a(:,4)>=2,:);
 jka=osc_smooth_a(:,1)>osc_lim(1) & osc_smooth_a(:,1)<osc_lim(2);

%  osc_smooth_b=osc_smooth_b(~isnan(osc_smooth_b(:,1)),:); 
 osc_smooth_b=osc_smooth_b(osc_smooth_b(:,4)>=2,:);
 jkb=osc_smooth_b(:,1)>osc_lim(1) & osc_smooth_b(:,1)<osc_lim(2);

 if ~check_vargs
   h=boundedline(osc_smooth_a(jka,1)',osc_smooth_a(jka,2)',osc_smooth_a(jka,3)','--b',...
                 osc_smooth_b(jkb,1),osc_smooth_b(jkb,2),osc_smooth_b(jkb,3),':r','alpha');

 if ~isempty(varargin) % hasta 5 ploteos en total
    hold on; marks={'-.k','-g','*m'};
    for vargs=1:length(varargin)
        if ~ischar(varargin{vargs})
           osc_smooth=varargin{vargs};
%            osc_smooth=osc_smooth(~isnan(osc_smooth(:,1)),:); 
           osc_smooth=osc_smooth(osc_smooth(:,4)>=2,:); 
           jk=osc_smooth(:,1)>osc_lim(1) & osc_smooth(:,1)<osc_lim(2);
           try
           h(2+vargs)=boundedline(osc_smooth(jk,1),osc_smooth(jk,2),osc_smooth(jk,3),marks{vargs},'alpha');
           catch
            % h(2+vargs)=[];
           end
        end
    end       
 end
 
 else

    [grpa,ma,sa,na]=osc_group(osc_ranges,[osc_smooth_a(jka,2:end) osc_smooth_a(jka,1)]);
    [grpb,mb,sb,nb]=osc_group(osc_ranges,[osc_smooth_b(jkb,2:end) osc_smooth_b(jkb,1)]);
    h(1)=errorbar(ma(:,end-1),ma(:,1)',ma(:,2)','--sb','MarkerFaceColor','b');
    hold on
    h(2)=errorbar(mb(:,end-1),mb(:,1)',mb(:,2)',':sr','MarkerFaceColor','r');

    if ~isempty(varargin)  % hasta 5 ploteos en total
       marks={'-.sk','-sg','*sm'};
       for vargs=1:length(varargin)
           if ~ischar(varargin{vargs})
              osc_smooth=varargin{vargs};
              osc_smooth=osc_smooth(~isnan(osc_smooth(:,1)),:); 
              jk=osc_smooth(:,1)>osc_lim(1) & osc_smooth(:,1)<osc_lim(2);
              [grp,m,s,n]=osc_group(osc_ranges,[osc_smooth(jk,2:end) osc_smooth(jk,1)]);
              h(2+vargs)=errorbar(m(:,end-1),m(:,1)',m(:,2)',marks{vargs},'MarkerFaceColor',marks{vargs}(end));
           end
       end
    end
    
 end
 
 xlabel('Ozone slant path');  ylabel('Ozone Relative Differences (%)');
 set(gca,'YLim',[-2,2]);
 set(h(h~=0),'LineWidth',2);
 box on;  grid;
         