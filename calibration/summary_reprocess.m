function [cal,summary,summary_old]=summary_reprocess(file_setup,ninst,ozone_ds,ozone_sum,A,sl_s,flag_sl,sl_ref)

%% Data recalculation for summaries  and individual observations
% Summaries are recalculated from individual measurements
% * SL corretion
% * HG data filter
% * Generic filter
% * j=find( s(:,2)<=2.5  & m(:,2)> 100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5 );
% * ozone std <=2.5
% * ozone range (100-600)
% * data betwenn two good hg
% * only not interupted observations (n=5)
%  summary datos para la calibracion;
%         date,sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1
%         ozone_sl sigma_sl
% summary  -> ms9 with new configuration
% 6   ozone r  -> config 2
% 9   ozone 1  -> config 1
% 12  ozone sl -> config 2 + sl 
%
%  summary old -> ms9 with original configuration/b file configuration
% 6  ozone r  -> config 1
% 9  ozone 1  -> config 2
% 12  ozone sl -> config 1 +   sl correction 
% 
% Now sl_s can be {sl(original config),sl_s(final config)} En este ordem!!

    if ~isempty(file_setup)
        if isstruct(file_setup)
           try
             [path nam fext]=fileparts(file_setup.brw_config_files{ninst,2});
             
             if strcmp(fext,'.cfg')% matriz de confgs.                
                cfg=load(file_setup.brw_config_files{ninst,2});

                SL_NEW_REF=[cfg(1,:);cfg(27,:)]'; 
                SL_OLD_REF=file_setup.SL_OLD_REF(ninst);
                A.new=[cfg(1,:);cfg(8,:)]'; A.old= A.old(ninst);
                
             else% dos configuraciones
                SL_NEW_REF=file_setup.SL_NEW_REF(ninst);
                SL_OLD_REF=file_setup.SL_OLD_REF(ninst);     
                A.new=A.new(ninst); A.old= A.old(ninst);
             end
             
           catch% Le pasamos las SL de ref. como primer argumento
             disp(sprintf('Old Style: %s',lasterr));               
             SL_NEW_REF=file_setup.SL_NEW_REF(ninst);
             SL_OLD_REF=file_setup.SL_OLD_REF(ninst);                           
             A.new=A.new(ninst); A.old= A.old(ninst);
           end
        else
           eval(file_setup)
        end
    else 
       SL_NEW_REF=sl_ref(2);
       SL_OLD_REF=sl_ref(1);
       A.new=A.new(ninst); A.old= A.old(ninst);
    end    
    cal=NaN*ones(1,10);summary=NaN*ones(1,13);summary_old=NaN*ones(1,13);
    
    ozone1=cell2mat(ozone_ds{ninst});
    ozone_s=cell2mat(ozone_sum{ninst}); 
    
 if ~isempty(ozone1)   
    idx=diaj(fix(ozone1(:,1)))*1000+fix(ozone1(:,3)/10); 
    idx_s=unique(idx);
    %numero de medida  -> tiempo de la medida central
    %nmed=ozone1(:,3)-fix(ozone1(:,3)/10)*10;
    %jm=find(nmed==3);
    %time=ozone1(jm,[1,4,5]);
    time=grpstats(ozone1(:,[1,4,5,6,7]),idx);
    % temperature and filter added
    
    
    % SL correction
    if flag_sl
        disp('SL correction applied');
        % ahora quiero que R6 sea el original para summary_old y el
        % recalculado para summary
        if (length(sl_s)==2 && iscell(sl_s{2}))
            % original
            sl_orig=sl_s{1};
            if ~isempty(sl_orig{ninst})
               SL_orig=sl_orig{ninst}; % median value
               R6_orig=NaN*ozone1(:,1); 
               [a,b]=findm(ozone1(:,1),SL_orig(:,1),.7);
               R6_orig(a,1)=SL_orig(b,1); R6_orig(a,2)=SL_orig(b,2); 
            else
               R6_orig=SL_NEW_REF*ones(size(ozone1(:,1)));
            end
            % final
            sl_fin=sl_s{2};
            if ~isempty(sl_fin{ninst})
               SL_fin=sl_fin{ninst}; % median value
               R6=NaN*ozone1(:,1); 
               [a,b]=findm(ozone1(:,1),SL_fin(:,1),.7);
               R6(a,1)=SL_fin(b,1); R6(a,2)=SL_fin(b,2); 
            else
               R6=SL_NEW_REF*ones(size(ozone1(:,1)));
            end
            try
                figure;
                plot(R6_orig(:,1),matadd(R6_orig(:,2),-R6(:,2)),'*'); 
                title('R6 daily median (old - new ratio)'); datetick('x',6,'keeplimits','keepTicks'); grid
            end
        else
            if ~isempty(sl_s{ninst})
               SL=sl_s{ninst}; % median value
               R6=NaN*ozone1(:,1); 
               [a,b]=findm(ozone1(:,1),SL(:,1),.7);
               R6(a,1)=SL(b,1); R6(a,2)=SL(b,2); 
            else
               R6=SL_NEW_REF*ones(size(ozone1(:,1)));
            end            
        end
        % ds_ozone
        % recalculated with the provided icf ozone1(:,15)
        % ozone1(:,8) recalculated with the configuration of the bfile 
        % or first calibration passed

        % Para evitar problemas con el group_time.
        % Puede ocurrir por ejemplo si el date_range en sl_report_jday es
        % inferior a los CALC_DAYS
           isn=isnan(R6(:,1)); 
           R6(isn,1)=ozone1(isn,1); R6(isn,2)=NaN;
           if size(SL_NEW_REF,1)>1
              y=group_time(R6(:,1),SL_NEW_REF(:,1));
              ozo_c=ozone1(:,15)+(SL_NEW_REF(y,2)-R6(:,2))./(10*A.new(y,2).*ozone1(:,5));
           else
              ozo_c=ozone1(:,15)+(SL_NEW_REF-R6(:,2))./(A.new*10*ozone1(:,5));
           end
           
           if length(sl_s)==2
              ozo_o=ozone1(:,8)+(SL_OLD_REF-R6_orig(:,2))./(A.old*10*ozone1(:,5));
              % old siempre se referirá a una sola configuración ?
           else              
              ozo_o=ozone1(:,8)+(SL_OLD_REF-R6(:,2))./(A.old*10*ozone1(:,5));
           end
    else
        % no SL correction
        ozo_o=ozone1(:,8);        
        ozo_c=ozone1(:,15); 
    end
    
    % sl_cor{i}=[ozone1(:,1),o3_,ozo_c,R6,(SL_NEW_REF(i)-R6)./(A(i)*10*o3_),...
    % R6_INT,(SL_NEW_REF(i)-R6_INT)./(A(i)*10*o3_)];
    % ozone time,ozone_recalculated,ozone_sl_corrected,R6,R6 correction,
    % R6_interpolated,R6 interpolated correction
    
    % ozone 1 hgflag 15-> ozone rc, 21->R6rc  8->ozone orig ozone corr R6
    % orig
    [m,s,n]=grpstats([ozone1(:,[2,15,21,8]),ozo_c,ozone1(:,14),ozo_o],idx(:),{'mean','std','numel'});
    
    % recalculated averaged
    %summaries hg ozone_recalculated  y MS9 y ozone sl corrected

   % filtros
   % sigma <2.5 ozone>100 <600 hg ok
   j=find( s(:,2)<=2.5  & m(:,2)> 100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5 );
   %datos para la calibracion;
   % date,sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1
   % ozone_sl sigma_sl
   summary=[time(j,:),m(j,2),s(j,2),m(j,3),s(j,3),m(j,4),s(j,4),m(j,5),s(j,5)];
   %datos para la calibracion;
   % date,sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_2 sigma_2
   % ozone_sl sigma_sl
   summary_old=[time(j,:),m(j,4),s(j,4),m(j,6),s(j,6),m(j,2),s(j,2),m(j,7),s(j,7)];
   
%    % control de outliers (desviacion standard mayor de 2.5)
try 
   figure; set(gcf,'Tag','filter_sd');
   j_out=find(s(:,2)>2.5 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
   summary_out=[time(j_out,:),m(j_out,2),s(j_out,2),m(j_out,3),s(j_out,3),...
                  m(j_out,4),s(j_out,4),m(j_out,5),s(j_out,5)];
   filtro=unique(summary(:,5)); filtro=filtro(filtro>0);
   for idx=1:length(filtro)
       subplot(2,2,idx)
       summary_f=summary(summary(:,5)==filtro(idx),:);
       summary_outf=summary_out(summary_out(:,5)==filtro(idx),:);
       plot(summary_f(:,3).*summary_f(:,6),summary_f(:,6),'o');
       hold on; plot(summary_outf(:,3).*summary_outf(:,6),summary_outf(:,6),'xr');
       set(gca,'YLim',[250 350]); grid
       lg=legend(sprintf('F#%d',filtro(idx)),'Location','SouthWest');
       set(lg,'FontWeight','Bold','FontSize',6,'HandleVisibility','off');
   end
   suptitle(sprintf('Standard Deviation>2.5 Brewer%s',file_setup.brw_name{ninst}));
   suplabel('Ozone (DU)','y',[.123 .08 .84 .84]);  suplabel('Ozone Slant path','x',[.08 .11 .84 .84]);

end
   if size(idx_s)~=size(m)
       disp('error');
   end
   idx_s=idx_s(j);
   j=findm(idx,idx_s,.1);
   %time hg nmeas sza airm ozone ms9 
   % medidas individuales 
   cal=[ozone1(j,[1,2,3,4,5,6,7,15,14,21]),ozo_c(j)];
   % time idx_dj sza airm filter temp ozone ms9 ms9o ozone_corrected
   if ~isempty(j)
     cal(:,2)=cal(:,3)+diaj(fix(ozone1(j,1)))*1000;
   end
 end
