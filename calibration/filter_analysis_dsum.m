function df=filter_analysis_dsum(dsum,Cal)
%function df=filter_analysis_dsum(dsum,Cal)
%df=[date1,filter1,filter2,difftime,diffilter,diffozo,difms9,diffairmas];
if nargin==2   
aux=cellfun(@filter_analysis_data,dsum{Cal.n_inst},'UniformOutput',false);
df=cell2mat(aux);
tplot=Cal.brw_str(Cal.n_inst); 

elseif nargin==1
aux=cellfun(@filter_analysis_data,dsum,'UniformOutput',false);
df=cell2mat(aux);
tplot=' brw '
else
    disp('revisa');
end

    
    
filtros_brw=0:5;
grp_idx=zeros(length(df),4);
for j=1:5
  grp_idx(:,j)=filtros_brw(j+1)*( (df(:,2)==filtros_brw(j) & df(:,3)==filtros_brw(j+1) ) | ( df(:,2)==filtros_brw(j+1) & df(:,3)==filtros_brw(j)) );
  label_f{j}=sprintf('filter %d->%d',filtros_brw(j),filtros_brw(j+1))
end

[m,s,n,g]=grpstats(matmul(df(:,[7]),sign(df(:,5))),sum(grp_idx,2),{'mean','meanci','numel','gname'})
f=str2num(cell2mat(g));
f4=find(f==4);f_4=[m(f4),s(f4,:),n(f4)];
f3=find(f==3);f_3=[m(f3),s(f3,:),n(f3)];
 



f=figure;
set(f,'Tag','Ozone_diff_filter');
try
boxplot(matmul(df(:,6),sign(df(:,5))),sum(grp_idx,2),'label',label_f,...
    'notch','on')
catch
boxplot(matmul(df(:,6),sign(df(:,5))),sum(grp_idx,2),...
    'notch','on')
end
grid;
title([tplot,' Ozone (DU) difference by filter change'])
boldify;
%grpstats(matmul(df(:,7),sign(df(:,5))),{df(:,2),df(:,3)},0.05)

 f=figure;
 set(f,'Tag','Ozone_diff_group_filter')
 errorbar(str2num(cell2mat(g)),m,m+s(:,1),s(:,2)-m);
 
 title([tplot,sprintf(' FILTER CORRECTION #4 %.0f ci=[%.0f,%.0f] nobs=%d ',f_4),...
        sprintf(' FILTER CORRECTION #3 %.0f ci=[%.0f,%.0f] nobs=%d ',f_3)])
set(gca,'Ylim',[-50,50]);
grid
boldify;
end 
 
 
 
 
 
 
 
 
 
 
 
 
 function  df=filter_analysis_data(dsum)
     %function  df=filter_analysis_data(dsum)
     %df=[date1,filter1,filter2,difftime,diffilter,diffozo,difms9,diffairmas];
     %
     % input
     % ozone.dsum_legend'
     % ans =
     %   Columns 1 through 16
     %     'date'    'hgflag'    'lat '    'angz'    'ang2'    'airm'    'temp'    'filt'    'ozo '    'sozo'    'so2 '    'sso2'    'ms4 '    'sms4'    'ms5 '    'sms5'
     %   Columns 17 through 24
     %     'ms6 '    'sms6'    'ms7 '    'sms7'    'ms8 '    'sms8'    'ms9 '    'sms9'
     %tabulate(dsum(:,8))
     %%
     %dsum=sortrows(dsum,1);
     % ozone std <2.5 no cloud
     dsum=dsum(dsum(:,10)<2.5,:);
     % 
     df=NaN*ones(1,8);
     try
         cf=diff(dsum(:,8));
         cf=[cf;0];
         cf_idx=find(cf);
         if ~isempty(cf_idx)
             for j=1:length(cf_idx)
                 %if cf(cf_idx(j))>0  % cambio a filtro superior /inferior funciona ¿?
                 if(dsum(cf_idx(j),8)~=dsum(cf_idx(j)+1,8))
                     %[fix(aux(j(20),:));fix(aux(j(20)+1,:))];
                     df(j,:)=[dsum(cf_idx(j),1),dsum(cf_idx(j),8),dsum(cf_idx(j)+1,8),dsum(cf_idx(j),[1,8,9,23,6])-dsum(cf_idx(j)+1,[1,8,9,23,6])];
                 elseif ( dsum(cf_idx(j),8)~=dsum(cf_idx(j)-1,8))
                     df(j,:)=[dsum(cf_idx(j),1),dsum(cf_idx(j),8),dsum(cf_idx(j)-1,8),dsum(cf_idx(j),[1,8,9,23,6])-dsum(cf_idx(j)-1,[1,8,9,23,6])];
                 else
                     disp('why ?');
                 end
             end
          %filter ten_minutes   
          df=df(abs(df(:,4))<datenum(0,0,0,0,5,0),:);
          %airmass filter 0.05
          df=df(abs(df(:,8))<0.03,:);
            
             
         else
             df=NaN*ones(1,8);
         end       
     catch
         disp(datestr(unique(fix(dsum(:,1)))));
         df=NaN*ones(1,8);
     end
     if isempty(df)
         df=NaN*ones(1,8);
     end
 end    
     
     
 
 
 
 
 
%  subplot(3,1,1);
%  boxplot(matmul(df(:,9),sign(df(:,8))),sum(grp_idx,2),'plotstyle','compact','colors','k')
%  hold on;
%  title('Config 1');
%  subplot(3,1,2);
%  boxplot(matmul(df(:,13),sign(df(:,8))),sum(grp_idx,2),'plotstyle','compact','colors','b')
%  title('Config 2');
%  subplot(3,1,3);
%  boxplot(matmul(df(:,15),sign(df(:,8))),sum(grp_idx,2),'plotstyle','compact','colors','g')
%  title('Config 3');
%  
%  suptitle([plot,' Ozone differences by filter change '])
%  legend({'cfg1','cfg2','cfg3'})
%  
%  f=figure;
%  set(f,'Tag','Ozone_diff_group_filter')
%  
% for filter_=0:64:256
%  subplot(2,3,(filter_/64)+1);
%  j=find(sum(grp_idx,2)==filter_);
%  boxplot(matmul(df(j,[9,13,15]),sign(df(j,8))),'labels',{'cfg1','cfg2','cfg3'});
%  title( sprintf('Filter #%d',filter_/64));
%  grid;
% end
% suptitle([plot,' Ozone differences by filter'])
% 
% 
% 
% figure;
%  boxplot(matmul(df(:,11),sign(df(:,8))),{df(:,2),df(:,3)})