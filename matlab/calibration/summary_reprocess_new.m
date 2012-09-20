function [cal,summary,summary_old]=summary_reprocess_new(Cal,ninst,ozone_ds,A,flag_sl,SL_R,SL_B)
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
    
    
    cal=NaN*ones(1,10);summary=NaN*ones(1,13);summary_old=NaN*ones(1,13);
    
    ozone1=cell2mat(ozone_ds{ninst});
    %ozone_s=cell2mat(ozone_sum{ninst}); 
    
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
        % ds_ozone
        % recalculated with the provided icf ozone1(:,15)
        % ozone1(:,8) recalculated with the configuration of the bfile 
        % or first calibration passed

        % Para evitar problemas con el group_time.
         ozo_c=ozone1(:,15)+(SL_REF.(y,2)-R6(:,2))./(10*A.new(y,2).*ozone1(:,5));
        % old siempre se referirá a una sola configuración ?
         ozo_o=ozone1(:,8)+(SL_OLD_REF-R6(:,2))./(A.old*10*ozone1(:,5));
        
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

 