function stats_summ=LangStats_summ(Cal,data)

stats_summ=cell(1,2);
for cf=1:2
    % N, airmass range
    AM=cellfun(@(x) x(~isnan(x(:,4)),[1 2 4:8],cf),data.r,'UniformOutput',0);
    AM_N=cellfun(@(x) size(x,1),AM); AM_N(AM_N==0)=NaN;
    AM_mrange=cellfun(@(x) cat(2,min(x(:,2)),max(x(:,2))),AM,'UniformOutput',0);
    AM_idx=cellfun(@(x) isempty(x),AM_mrange); AM_mrange(AM_idx)=repmat({[NaN NaN]},length(find(AM_idx)),1);

    PM=cellfun(@(x) x(~isnan(x(:,9)),[1 2 9:13],cf),data.r,'UniformOutput',0);
    PM_N=cellfun(@(x) size(x,1),PM); PM_N(PM_N==0)=NaN;
    PM_mrange=cellfun(@(x) cat(2,min(x(:,2)),max(x(:,2))),PM,'UniformOutput',0);
    PM_idx=cellfun(@(x) isempty(x),PM_mrange); PM_mrange(PM_idx)=repmat({[NaN NaN]},length(find(PM_idx)),1);

    % Root Squared
    AM_rs=data.rs(:,2:6,cf);
    PM_rs=data.rs(:,7:11,cf);

    % Write results to file
    stats_summ{cf}=cat(2,data.rs(:,1,cf),AM_N,cell2mat(AM_mrange),AM_rs,PM_N,cell2mat(PM_mrange),PM_rs);

    fid = fopen(sprintf('Brewer_SummStats%d_%s_cfg%d.txt',Cal.Date.cal_year,Cal.brw_str{Cal.n_inst},cf), 'wt'); 
    fprintf(fid, strcat('%%Date N(AM) min_m(AM) max_m(AM)',... 
                               'RS_Slit#1(AM) RS_Slit#2(AM) RS_Slit#3(AM) RS_Slit#4(AM) RS_Slit#5(AM)',...
                               'N(PM) min_m(PM) max_m(PM)',... 
                               'RS_Slit#1(PM) RS_Slit#2(PM) RS_Slit#3(PM) RS_Slit#4(PM) RS_Slit#5(PM)\n'));
    for i=1:size(stats_summ{cf},1)
        fprintf(fid, '%f %d %f %f %f %f %f %f %f %d %f %f %f %f %f %f %f\n',stats_summ{cf}(i,:));
    end
    fclose(fid);
end
