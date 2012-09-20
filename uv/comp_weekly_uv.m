
%% Setup
path_root=fullfile(cell2mat(regexpi(pwd,'^[A-Z]:', 'match')),'UV'); 
path(genpath(fullfile(path_root,'matlab_uv')),path);

cal_month=month(now); cal_year=year(now);
dayend=diaj(now); day0=dayend-15;
% numweek=fix(diaj(datejuli(cal_year,dayend-2))/7);

%% UV
% leemos los ficheros 
s_ref=fullfile(path_root,'Lamps\QL157\uvr\UV2011HIST.txt'); 
fid=fopen(s_ref,'r');
ref=textscan(fid,'%s'); ref=ref{1};
s_ref=fullfile(path_root,'Lamps\QL157\uvr',ref{end}); % respuesta usada como referencia
fclose(fid)

cd(fullfile(path_root,'uvbrewer157/UV2011/raw'));
uv157=loaduvl('UV*.157',s_ref,'date_range',datejuli(cal_year,[day0 dayend]));

% save var var157

write_interchange_brewer(uv157);
shicpath=fullfile(path_root,'uvbrewer157/UV2011/level1a/G1a');
movefile(['*G.','iz1'],shicpath);

% cd '../bdata183';
% uv183=loaduvl('UV*.183','../bfiles/183/uvr36309.183','date_range',datejuli(Cal.Date.cal_year,[Date.day0 Date.dayend]));
% write_interchange_brewer(uv183);

s_ref=fullfile(path_root,'Lamps\QL185\uvr\UV2011HIST.txt'); 
fid=fopen(s_ref,'r');
ref=textscan(fid,'%s'); ref=ref{1};
s_ref=fullfile(path_root,'Lamps\QL185\uvr',ref{end}); % respuesta usada como referencia
fclose(fid)

cd(fullfile(path_root,'uvbrewer185/UV2011/raw'));
uv185=loaduvl('UV*.185',s_ref,'date_range',datejuli(cal_year,[day0 dayend]));
write_interchange_brewer(uv185);

shicpath=fullfile(path_root,'uvbrewer185/UV2011/level1a/G1a');
movefile(['*G.','iz3'],shicpath);

cd ..


days=[]; comparar=[];

x_n157=arrayfun(@(x)~isempty(x.date),uv157);
jday_n157=find(x_n157);

% x_n183=arrayfun(@(x)~isempty(x.date),uv183);
% jday_n183=find(x_n183);

x_n185=arrayfun(@(x)~isempty(x.date),uv185);
jday_n185=find(x_n185);

%% 185 vs 157
close all;
days=intersect(jday_n185,jday_n157);
for i=day0:dayend
      [fig_indv,fig_day,ratio,uv,time] = comp_scan_jj(uv185(i),uv157(i));
      if isempty(time) 
         continue 
      end
%       print(fig_day,'-dpsc','-append',sprintf('dailycomp_week%d_185_157',floor(diaj(now)/7)));
end

%% 183 vs 157
close all;  indx=[];
days=intersect(jday_n183,jday_n185);
for i=Cal.Date.CALC_DAYS
      [fig_indv,fig_day,ratio,uv,time] = comp_scan_jj(uv183(i),uv157(i));
      if isempty(time) 
         continue 
      end
%       print(fig_day,'-dpsc','-append',sprintf('dailycomp_week%d_183_157',floor(diaj(now)/7)));
end