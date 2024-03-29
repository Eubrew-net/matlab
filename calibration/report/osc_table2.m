function [osc_table,osc_matrix,stats]=osc_table2(Cal,ratio_ref,osc_interval)
% calculate the osc_table from ratio_ref
% osc_matrix: tridimensional matrix (nobs x ratio x osc_ranges (length
% osc_interval+1))
% plots the box_plot if stats are outpub
% cambios de sergio
 analyzed_brewer=Cal.analyzed_brewer;

 if nargin==2
  osc_interval=[400,800,1000];
 end
 
  
  mean_all=round(nanmean(ratio_ref(:,2:end))*10)/10; 
  std_all=round(nanstd(ratio_ref(:,2:end))*100)/100;
  
  
  
 aux=group_var(ratio_ref,osc_interval);
 % observations grouped by osc 
 [mean_,std_]=grpstats(aux,aux(:,end),{@(x) nanmean(x,1),@(x) nanstd(x,1,1)});
  mean_=round(mean_*10)/10; std_=round(std_*100)/100;
 
 table_oscs=cellfun(@(x,y) strcat(num2str(x),' +/- ',num2str(y)),...
                   num2cell(cat(1,mean_all,mean_(:,2:end-1))),num2cell(cat(1,std_all,std_(:,2:end-1))),...
                   'UniformOutput',false);
 
 osc_int_str=cellstr(num2str(osc_interval'));
 a=find(aux(:,5)<400);
 a=size(a);
 if a(1,1)==0
     header_=[{'All'};{'700'};{'1000'};{'1200'};{['>',num2str(osc_interval(end))]}]';
     control=1;
 else
     header_=[{'All'};osc_int_str;{['>',num2str(osc_interval(end))]}]';
     control=2;
 end
     
 
 osc_table.data=table_oscs;
 osc_table.row_header=header_;
 osc_table.col_header={Cal.brw_name{analyzed_brewer},'mean osc'};
 
 fprintf(strcat('\nRBCC-E statistics, grouped by osc''s (N simultaneous: ',repmat(' %d ',1,length(analyzed_brewer)),')\n'),...
                           sum(~isnan(ratio_ref(:,2:end-1))));
 displaytable(table_oscs,{Cal.brw_name{analyzed_brewer},'mean osc'},11,'.2f',header_);

% if nargin==2
 
 dat_osc=aux;
 if control==2
     for i=1:length(osc_interval)+1;
         dat1=NaN*aux;
         dat1(aux(:,end)==i,:)=aux(aux(:,end)==i,:);
         dat_osc(:,:,i+1)=dat1;
     end
 elseif control==1
      for i=2:length(osc_interval)+1;
         dat1=NaN*aux;
         dat1(aux(:,end)==i,:)=aux(aux(:,end)==i,:);
         dat_osc(:,:,i)=dat1;
     end
 end
 osc_matrix=dat_osc;

 %end

 if nargout==3
    figure; 
    [stats,hp,hb]=box_plot(dat_osc(:,2:size(ratio_ref,2)-1,:),'Limit','3IQR'); 
    set(gca,'XtickLabel',Cal.brw_str);   
    title('Box-Plot Ozone Deviation to reference by Ozone Slant Column');
    legend(squeeze(hp(:,1,:)),header_);
    box('on');
    arrayfun(@(x,y) set(y,'FaceColor',get(x,'Color')),hp,hb)
 end
