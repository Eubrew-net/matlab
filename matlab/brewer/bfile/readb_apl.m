function [ap]=readb_apl(path,plot)
ap_=[];
ap=[];
s=dir(path);
[p,n,e]=fileparts(path);

for i=1: length(s)
    
    try
 
     [ap_]=readb_ap(fullfile(p,s(i).name));
     ap=[ap,ap_];

    catch
        %rethrow(lasterror);
        warning('MATLAB:readb_ap:file_error', ' %s.', s(i).name);
        sx=lasterror;
        disp(sx.message);
        
    end
end



%                % 7    8        9        10      11         12        13      14
%             o3.sl_avg_legend={ 'time_start' 'time_end' 'idx' 'st0'  'stend'  'inc'...
%                 'temp' 'airm'  'filt'  'o3step'  'o3max'  'so2step'  'so2max' 'calc_step'...
%                 'o3stepc' 'o3max' 'normr' 'a'  'b'  'c' 'hg_chg' 'hg_start' 'hg_end'};
%                  % 15          16    17     18   19   20    21         22       23
%             o3.sl_raw=sl_raw;
%             o3.sl_raw_legend={'date';'flg';'idx';'tmp';'fl1';'fl2';'tim';...
%                 'm2 ';'m3*pressure corr';'cy ';'F0 ';'F1 ';'F2 ';'F3 ';...
%                 'F4 ';'F5 ';'F6 ';'o3 ';'so2 ';'o3c ';'so2c '};
