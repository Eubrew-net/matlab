function blsummary=blacklist_summary(fblacklist,summary)
% fblacklist is the path and filename if the blacklist for a especific
% brewer in csv format: 
%   "2010-06-20 07:00:00","2010-06-20 19:00:00","Bad focus"
%
% summary is a ...
%
% example
% bl=blacklist_summary('D:\CODE\iberonesia\RBCC_E\configs\blacklist_157.txt',summary);

    blsummary=summary;
    
    % leemos el blacklist 
    bl=blacklist_read(fblacklist);
   
    %loop for each blacklist rule
    for k=1:length(bl.date_ini)
        blsummary=blsummary(blsummary(:,1) < bl.date_ini(k) | blsummary(:,1) > bl.date_end(k),:);
    end
    
end
