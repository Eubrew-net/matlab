function [df,freq_filter,grp_idx ] = ozone_filter_analysis(summary ,plot)
%  Analiza el cambio en el ozono durante el cambio de filtros
%  input variable summary
%  output: df
%   medidas consecutivas con cambio de filtro
%   df=[fecha, filtro_1, filtro_2, summary(filtro_1)-summary(filtro_2)]
%  
if nargin==1 plot=0; end
aux=sortrows(summary,1);
freq_filter=tabulate(aux(:,5))


 cf=diff(aux(:,5));cf=[cf;0]; % 
 cf_idx=find(cf);             % buscamos el cambio de filtro 
 df=[];
 for j=1:length(cf_idx)
     
    %if cf(cf_idx(j))>0  % cambio a filtro superior /inferior funciona ¿? 
     if(aux(cf_idx(j),5)~=aux(cf_idx(j)+1,5))     
       %[fix(aux(j(20),:));fix(aux(j(20)+1,:))];
       df(j,:)=[aux(cf_idx(j),1),aux(cf_idx(j),5),aux(cf_idx(j)+1,5),aux(cf_idx(j),:)-aux(cf_idx(j)+1,:)];
     elseif ( aux(cf_idx(j),5)~=aux(cf_idx(j)-1,5))
       df(j,:)=[aux(cf_idx(j),1),aux(cf_idx(j),5),aux(cf_idx(j)-1,5),aux(cf_idx(j),:)-aux(cf_idx(j)-1,:)];
     else
         disp('why ?');
     end
         
 end
 % valores simltaneos en 10 minutos

 df=df(abs(df(:,4))<datenum(0,0,0,0,10,0),:);

 if plot
     if ~ischar(plot)
         plot=num2str(plot);
     end
 f=figure;
 set(f,'Tag','Ozone_diff_filter')
   boxplot(matmul(df(:,9),sign(df(:,8))),{df(:,2),df(:,3)})
   grid;
   title([plot,' ozone difference by filter'])
 
 f=figure;
 set(f,'Tag','Ozone_diff_group_filter')
 
 
 filtros_brw=[0,64,128,192,256];
 grp_idx=zeros(length(df),4);
 for j=1:4
  grp_idx(:,j)=filtros_brw(j+1)*( (df(:,2)==filtros_brw(j) & df(:,3)==filtros_brw(j+1) ) | ( df(:,2)==filtros_brw(j+1) & df(:,3)==filtros_brw(j)) );
 end
 grpstats(matmul(df(:,[9,13,15]),sign(df(:,8))),sum(grp_idx,2),0.05)
 
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
 suptitle([plot,' Ozone differences by filter change '])
 legend({'cfg1','cfg2','cfg3'})
 
 f=figure;
 set(f,'Tag','Ozone_diff_group_filter')
 
for filter_=0:64:256
 subplot(2,3,(filter_/64)+1);
 j=find(sum(grp_idx,2)==filter_);
 boxplot(matmul(df(j,[9,13,15]),sign(df(j,8))),'labels',{'cfg1','cfg2','cfg3'});
 title( sprintf('Filter #%d',filter_/64));
 grid;
end
suptitle([plot,' Ozone differences by filter'])


end

