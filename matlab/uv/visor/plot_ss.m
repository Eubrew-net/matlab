function plot_ss(uv,duv)
% function plot_uv(uv) plotea struct uv con los picos
% 
% See Also plot_uvs(uv,a)

for i=1: length(uv)
%   j=rem(i,2);
%   if rem(i,2)==0 
%      j=2; 
%   end;
%   subplot(2,1,j);   
disp(uv(i).file);
%figure(1);
    h=plotcol([1,2],[3,1]);
    axes(h(1));
    if(size(uv(i).l,2))>1
        
       w1=waterfall(uv(i).l',uv(i).time'/60,uv(i).ss');
       
    else
       w1=plot3(uv(i).l',uv(i).time'/60,uv(i).ss');
    end  
    if ~isempty(uv(i).spikes) 
    		hold on;
    		plot3(uv(i).spikes(:,4),uv(i).spikes(:,3)/60,uv(i).spikes(:,5),'r+')
    end  
   
           axis( [2800    4000    -Inf    Inf   -Inf    1]);
     colorbar;
     
     drawnow;
       
    if ~isempty(uv(i).spikes) 
       axes(h(3)); 
       plot_uvs(uv(i),uv(i).spikes(:,2));
       ax=axis; ax(1)=2800; ax(2)=3700;
       axis(ax);
    else
         axes(h(3));
         plot(uv(i).time'/60,uv(i).ss',':.');
         grid;
         xlabel('hora');
         ylabel('mw/m2');
         title(' UV');
         ax=axis; ax(1)=6; ax(2)=20;     axis(ax);
       
    end;   
    suptitle(uv(i).file);
    if nargin==2
      if(~isempty(duv(i).duv))
        axes(h(2)); 
        plot(duv(i).duv(:,3)/60,duv(i).duv(:,4),'.')
        grid;
        xlabel('hora');
        ylabel('mW/m2');
        title('DUV');
        ax=axis; ax(1)=6; ax(2)=20;     axis(ax);
       end   
     else
         axes(h(2));
         plot(uv(i).l,uv(i).ss,'.-');
         grid;
         xlabel('hora');
         ylabel('mw/m2');
         title(' UV');
         ax=axis; ax(1)=2900; ax(2)=4000;     axis(ax);
      % ax=axis; ax(1)=6; ax(2)=20;     axis(ax);
%        
      end 
%   if rem(i,2)==0  figure; end;
orient landscape;

drawnow;
set(gcf, 'PaperPositionMode', 'auto');
print -dpsc -append  reportizo
close
end   
   
   