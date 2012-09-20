function [O3R,lgl_cor,O3S ] = langley_o3_recalculation( lgl,setup,resp,FC )
% Recalcula el Ozono con los resultados del langley (resp)
%O3R cell 2x2 (am/pm, cfg1/cfg2)
% lgl_cor= Ratios y ozono corregidos
lgl_cor=lgl;
% para comprobar _>NaN*ones(size(lgl));
O3R=cell(2,2);
O3S=cell(2,2);
%figure(1);hold on;
for ii=1:2 %config
    if ii==1
        jc=12:18;
    else
        jc= 26:32;
    end
    
    jam=(lgl(:,9)/60<=12);
    jpm=~jam;
    setup_n=setup(:,ii);
    
    for jj=1:2 %am_pm
        
        if jj==1
            jap=jam;
        else
            jap=jpm;
        end
        %lgl_=lgl(jap,:);
        %ix=(ii-1)*2+jj;
        
        setup_n(11)=resp(jj,ii,1,2,1);
        %filter_correction
        
        for ff=1:length(FC)
            Fc=squeeze(resp(jj,ii,2+ff,:,1));
            Fc(isnan(Fc))=0;
            idx_=find(jap & lgl(:,10)==FC(ff));
           
            lgl_cor(idx_,jc)=matadd(lgl(idx_,jc),-Fc');            %plot(lgl(:,1),lgl_cor(:,jc))
        end
        % recalculation
        [o_3,so_2,rat]=ozone_cal_raw(lgl_cor(:,jc),lgl(:,5),770,lgl(:,6),setup_n);
        lgl_cor(jap,jc+7)=[o_3(jap),rat(jap,8:end)];
        o_3(~jap)=NaN;
        O3R{jj,ii}=o_3;

    end
end

end

