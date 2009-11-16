%% Data extraction for summaries  and individual observations
%  Summaries are recalculated from individual measurements
% * SL corretion
% * HG data filter
% * Generic filter
% * j=find( s(:,2)<=2.5  & m(:,2)> 100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5 );
% * ozone std <=2.5
% * ozone range (100-600)
% * data betwenn two good hg
% * only not interupted observations (n=5)

function [summary,cal,sl_correction]=recalculation(ozone_ds,ozone_sum,sl_s,config)
cal_days_setup;
[A,ETC,icf_brw,cfg]=config_table(config);

for i=1:length(brw)
    sl_correction{i}=[];
    cal{i}=[];
    summary{i}=[];

    ozone1=cell2mat(ozone_ds{i});
    ozone_s=cell2mat(ozone_sum{i});
    if ~isempty(ozone1)
        
      idx=diaj(fix(ozone1(:,1)))*1000+fix(ozone1(:,3)/10); 
      idx_s=unique(idx);
    %numero de medida  -> tiempo de la medida central
    %nmed=ozone1(:,3)-fix(ozone1(:,3)/10)*10;
    %jm=find(nmed==3);
    %time=ozone1(jm,[1,4,5]);
    time=grpstats(ozone1(:,[1,4,5,6,7]),idx);
    % temp +filter add
   
    
    
    % SL coruntitled.mrection
    if ~isempty(sl_s{i})
        SL=sl_s{i};
        R6=NaN*ozone1(:,1);
        [a,b]=findm(ozone1(:,1),SL(:,1),.7);
        R6(a,1)=SL(b,2);
    else
        R6=SL_NEW_REF(i)*ones(size(ozone1(:,1)));
    end 
    % opcion 2 interpolada  % R6 smooth mean
    %if ~isempty(sl_s{i})   
      %R6_INT=interp1((R6_{i}(:,1)),R6_{i}(:,2),ozone1(:,1),'pchip');
    %else
      %R6_INT=R6;     
    %end
    
    
    % ds_ozone
    % recalculated whiht the provided icf ozone1(:,15)
    % ozone1(:,8)  recalculated with the  oringinal configuration of the bfile
    % ozone1(:,15) recalculated with the  finnal configuration of the bfile
     o3_=ozone1(:,15);
     ozo_c=o3_+(SL_NEW_REF(i)-R6)./(A(i)*10*ozone1(:,15)); 
     % no SL correction     ozo_c=o3_;
     ozone1(:,8)=ozone1(:,8)+(SL_NEW_REF(i)-R6)./(A(i,1)*10*ozone1(:,15)); 
     sl_correction{i}=[ozone1(:,1),o3_,ozo_c,R6,(SL_NEW_REF(i)-R6)./(A(i)*10*o3_)];

 
     [m,s,n]=grpstats([ozone1(:,[2,15,21,8]),ozo_c],idx(:),{'mean','std','numel'}); 
     % hg ozone_recalculated  MS9, ozone_2 ozone_orig y ozone2_sl_corrected
    

    % filtros
    % sigma <2.5 ozone>100 <600 hg ok
     j=find( s(:,2)<=2.5  & m(:,2)> 100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5 );
     if isempty(j)
        j=find( s(:,2)<=2.5  & m(:,2)> 100 & m(:,2)<600 & n(:,1)==5 );
     end    
     %datos para la calibracion;
     % date,sza,airm, filter, temp, ozono_r sigma_r  ms9 sm9 ozone_org
     % sigma_org   ozone_sl sigma_sl
      summary{i}=[time(j,:),m(j,2),s(j,2),m(j,3),s(j,3),m(j,4),s(j,4),m(j,5),s(j,5)];
   
     if size(idx_s)~=size(m)
       disp('error');
     end
    idx_s=idx_s(j);
    j=findm(idx,idx_s,.1);
    %time hg nmeas sza airm ozone ms9 
    % medidas individuales 
    cal{i}=[ozone1(j,[1,2,3,4,5,6,7,15,21]),ozo_c(j)];
     % time idx_dj sza airm temp filter ozone ms9 ozone_sl
    if ~isempty(j)
     cal{i}(:,2)=cal{i}(:,3)+diaj(fix(ozone1(j,1)))*1000;
    end
    else
     summary{i}=NaN*ones(1,13);
     cal{i}=NaN*ones(1,10);
    
    end

end
