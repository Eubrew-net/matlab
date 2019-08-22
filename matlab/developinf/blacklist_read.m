function [blacklist]=blacklist(fblacklist)
% fblacklist is the path and filename if the blacklist for a especific
% brewer in csv format: 
%   "2010-06-20 07:00:00","2010-06-20 19:00:00","Bad focus"
%
% example
% bl=blacklist('D:\CODE\iberonesia\RBCC_E\configs\blacklist_157.txt');

    blacklist=struct('date_ini',[],'date_end',[],'comment',strings(0));
   
    %read blackist file as txt
    try
        %fblacklist=fullfile(path_root,'configs',['blacklist_',num2str(brewer(i)),'.txt']);
        fid = fopen(fblacklist);
        blacklist_txt = textscan(fid,'%s%s%s','delimiter',',','CommentStyle','%');
        fclose(fid);
    catch
        fprintf('File does not exist: %s\n', fblacklist);
        return;  % Jump to next brewer
    end

    %load blacklist struct 
    for j=1:length(blacklist_txt{1})
        blacklist.date_ini(j)=datenum(blacklist_txt{1}{j});
        blacklist.date_end(j)=datenum(blacklist_txt{2}{j});
        blacklist.comment(j)=strrep(blacklist_txt{3}{j},'"','');
    end
    
end
