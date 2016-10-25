% function to read struct returned by read_woudc_struct
function [obs_o3,obs_head]=read_woudc(filename)

wx=read_woudc_csv(filename);
time=cellfun(@(x) sscanf(x,'%d:%d:%d'),wx.OBSERVATIONS.Time,'UniformOutput',false);
time=cell2mat(time);

date=datenum(wx.TIMESTAMP.Date{:});
offset=datenum([wx.TIMESTAMP.Date{:},' ',wx.TIMESTAMP.UTCOffset{:}]);

signo=wx.TIMESTAMP.UTCOffset{:}(1);

if signo=='+'  offset=offset-date;
elseif signo=='-' offset=-(offset-date);
else disp('error in offset');
end

gmt=date+(time(1,:)+time(2,:)/60+time(3,:)/60/60)/24-offset;
obs_head=fieldnames(wx.OBSERVATIONS);
wx.OBSERVATIONS=rmfield(wx.OBSERVATIONS,'Time');
wx.OBSERVATIONS.ObsCode=strrep(wx.OBSERVATIONS.ObsCode,'ZS','2');
wx.OBSERVATIONS.ObsCode=strrep(wx.OBSERVATIONS.ObsCode,'DS','1');
wx.OBSERVATIONS.ObsCode=strrep(wx.OBSERVATIONS.ObsCode,'UV','3');
wx.OBSERVATIONS.F324=strrep(wx.OBSERVATIONS.F324,char(13),'0');



t=structfun(@(y) cellfun(@(x) sscanf(x,'%f'),y,'UniformOutput',true),wx.OBSERVATIONS,'UniformOutput',false);
obs_o3=cell2mat(struct2cell(t));
obs_o3=[gmt;obs_o3]';

