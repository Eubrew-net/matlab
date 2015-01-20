function write_langley(brw,yr,brw_indv)

for ii=1:length(brw)
    file_name=strcat('Langley_Brw',num2str(brw(ii)),'_',num2str(yr),'.txt');
    fid = fopen(file_name, 'wt'); % Open for writing
    fprintf(fid, '%%Date etc_1_am etc_1_pm slope_1_am slope_1_pm  etc_2_am etc_2_pm slope_2_am slope_2_pm\n');
    for ll=1:size(brw_indv{ii},1)
        aux=reshape(brw_indv{ii}(ll,:,:),1,10); aux(6)=[];
        fprintf(fid, '%f %6.1f %6.1f %7.2f %7.2f %6.1f %6.1f %7.2f %7.2f \n',aux);
    end
 end
fclose all;
