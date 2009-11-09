function [sc_avg,sc_raw]=readb_scl(path,config,plot)

sc_avg=[];
sc_raw=[];
s=dir(path);
[p,n,e]=fileparts(path);
if nargin>1
[pc,nc,ec]=fileparts(config);
end
hf=[];

disp(s)
for i=1: length(s)
    scraw=[];
    scavg=[];
    try
        if nargin==1
            [scavg,scraw]=readb_sc(fullfile(p,s(i).name));
        else
            file=fullfile(p,s(i).name);
            [scavg,scraw]=readb_sc(file,config);
        end
        sc_avg=[sc_avg;scavg];
        sc_raw=[sc_raw;scraw];

        if ~isempty(scraw )
              disp(['OK->',s(i).name]);
        else
            
            disp(['NOSC->',s(i).name]);
        end
        %if ~isempty(scraw )
          
            %             medida=fix(scraw(:,2)/100);
%             for ii=1:size(scavg,1),
%                 h=figure;
%                 hf=[hf,h];
%                 sc_=scraw(medida==ii,:);
%                 sca=scavg(ii,:);
%                 %subplot(3,2,mod(i,6)+1);
%                 polyplot2(sc_(:,3),sc_(:,18));
%                 % polyplot2(sc_(:,3),sc_(:,18).*sc_(:,8));
% 
%                 title({' ',' ',...
%                     sprintf(' airm=%.2f  filter=%d ozone=%.1f  step=%.0f \\Delta hg step=%.1f ',sca(1,[8,9,11,10,21])),...
%                     ['y=',poly2str(round(sca(18:20)*100)/100),'',sprintf(' normr=%.1f',sca(1,17))]});
%                 suptitle([ s(i).name,'  ',datestr(sca(1,1))]);
%                 xlabel('step');
%                 ylabel('ozone');
%             end
%         end

    catch
        %rethrow(lasterror);
        warning('MATLAB:readbsl:file_error', ' %s.', s(i).name);
        %sx=lasterror;
        %disp(sx.message);
        
    end
end

% 
% for i=hf
%     h=figure(i);
%     save2word('sc_report_plot.doc');
%     close(h);
% end
% 

%                % 7    8        9        10      11         12        13      14
%             o3.sc_avg_legend={ 'time_start' 'time_end' 'idx' 'st0'  'stend'  'inc'...
%                 'temp' 'airm'  'filt'  'o3step'  'o3max'  'so2step'  'so2max' 'calc_step'...
%                 'o3stepc' 'o3max' 'normr' 'a'  'b'  'c' 'hg_chg' 'hg_start' 'hg_end'};
%                  % 15          16    17     18   19   20    21         22       23
%             o3.sc_raw=sc_raw;
%             o3.sc_raw_legend={'date';'flg';'idx';'tmp';'fl1';'fl2';'tim';...
%                 'm2 ';'m3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
%                 'F4 ';'F5 ';'F6 ';'o3 ';'so2 ';'o3c ';'so2c '};
