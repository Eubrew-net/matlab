function t=write_summary_cfg(brw,yr,summary_old,summary,varargin)
t{length(brw),2}=[];
for ii=brw
    brw(ii)=ii;
    if nargin>4
       idx=group_time(summary_old{ii}(:,1),varargin{1}.old(:,1));
       aux_old=cat(2,summary_old{ii},varargin{1}.old(idx,ii+1),...
           varargin{2}.old(idx,ii+1),varargin{3}.old(idx,ii+1),varargin{4}.old(idx,ii+1));
       aux=cat(2,summary{ii},varargin{1}.new(idx,ii+1),varargin{2}.new(idx,ii+1),...
           varargin{3}.new(idx,ii+1),varargin{4}.new(idx,ii+1));
    else
       aux_old=cat(2,summary_old{ii},NaN*ones(size(summary_old{ii},1),4));         
       aux=cat(2,summary{ii},NaN*ones(size(summary_old{ii},1),4));         
    end
    % summary_old
    file_name=strcat('summary_old_Brw',num2str(brw(ii)),'_',num2str(yr),'.txt');
    fid = fopen(file_name, 'wt'); % Open for writing
    fprintf(fid, '%%Date sza m2 temp nd O3_1 std ms9_corr ms9 O3_2 std O3_1_sl std R6_ref R6_calc A1 ETC\n');
    for ll=1:size(aux_old,1)
        fprintf(fid, '%f %6.3f %6.4f %d %d %5.1f %5.2f %6.1f %6.1f %5.1f %5.2f %5.1f %5.2f %5.1f %5.1f %.4f %d\n', aux_old(ll,:));
    end
    t{ii,1}=array2table(aux_old,'VariableNames',varname(cellstr(mmcellstr('Date sza m2 temp nd O3_1 std ms9_corr ms9 O3_2 std O3_1_sl std R6_ref R6_calc A1 ETC',' '))));
    t{ii,1}.idx=(1:height(t{ii,1}))';
    % summary    
    file_name=strcat('summary_Brw',num2str(brw(ii)),'_',num2str(yr),'.txt');
    fiq = fopen(file_name, 'wt'); % Open for writing
    fprintf(fiq, '%%Date sza m2 temp nd O3_1 std ms9_corr ms9 O3_2 std O3_1_sl std R6_ref R6_calc A1 ETC\n');
    for ll=1:size(aux,1)
        fprintf(fiq, '%f %6.3f %6.4f %d %d %5.1f %5.2f %6.1f %6.1f %5.1f %5.2f %5.1f %5.2f %5.1f %5.1f %.4f %d\n', aux(ll,:));
    end
    t{ii,2}=array2table(aux,'VariableNames',varname(cellstr(mmcellstr('Date sza m2 temp nd O3_1 std ms9_corr ms9 O3_2 std O3_1_sl std R6_ref R6_calc A1 ETC',' '))));
    t{ii,2}.idx=(1:height(t{ii,2}))';
end
fclose all;
