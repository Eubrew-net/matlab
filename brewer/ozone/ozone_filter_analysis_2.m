function [df,dfx,freq_filter,grp_idx ] = ozone_filter_analysis_2(summary ,plot)
%  Analiza el cambio en el ozono durante el cambio de filtros
%  input variable summary
%  output: df
%   medidas consecutivas con cambio de filtro
%   df=[fecha, filtro_1, filtro_2, summary(filtro_1)-summary(filtro_2)]
%  
if nargin==1 plot=0; end
aux=sortrows(summary,1); % ordenamos por fechas

freq_filter=tabulate(aux(:,5));

% valores simltaneos en 10 minutos
 tf=diff(aux(:,1));tf=[tf;0]; % 
 tf_idx=find(tf<datenum(0,0,0,0,10,0));

 aux=aux(tf_idx,:);  
 cf=diff(aux(:,5));cf=[cf;0]; % 
 cf_idx=find(cf);             % buscamos el cambio de filtro 
 df=[];
 for j=1:length(cf_idx)
     
    %if cf(cf_idx(j))>0  % cambio a filtro superior /inferior funciona ¿? 
     if(aux(cf_idx(j),5)~=aux(cf_idx(j)+1,5))     
       %[fix(aux(j(20),:));fix(aux(j(20)+1,:))];
       df(j,:)=[aux(cf_idx(j),1),aux(cf_idx(j),5),aux(cf_idx(j)+1,5),aux(cf_idx(j),:)-aux(cf_idx(j)+1,:)];
     elseif ( aux(cf_idx(j),5)~=aux(cf_idx(j)-1,5))
       disp('check');  
       df(j,:)=[aux(cf_idx(j),1),aux(cf_idx(j),5),aux(cf_idx(j)-1,5),aux(cf_idx(j),:)-aux(cf_idx(j)-1,:)];
     else
         disp('why ?');
     end
         
 end
 % valores simltaneos en 10 minutos

 df=df(abs(df(:,4))<datenum(0,0,0,0,5,0),:);
 %revisar
 jone=find(abs(df(:,2)-df(:,3))==64);   
 dfx=[min(df(jone,2:3),[],2),sign(df(jone,8))];
 dfx=[df(jone,1),dfx,matmul(sign(df(jone,8)),df(jone,4:end))];
 
 if plot
     if ~ischar(plot)
         plot=num2str(plot);
     end
     
 % one filter steps    
 f=figure 
 boxplot(matmul(df(jone,9),sign(df(jone,8))),{df(jone,2),df(jone,3)});
 set(f,'Tag','Ozone_diff_one_filter')
 grid;
 title([plot,' ozone difference by filter, one filter change'])
 ylabel('DU'); 
 
 
 %%
 f=figure;
 %subaxis(4,1,1,'sv',0,'sh',0.1);
 f_used=unique(dfx(:,2));
 for i=1:length(f_used),
     %subaxis(i+1);
     subplot(length(f_used),1,i);
     jf=find(dfx(:,2)==f_used(i)); 
     boxplot(dfx(jf,9),month(dfx(jf,1))+ 100*(year(dfx(jf,1))) );
     grid on;
     hline(0);
     ylabel(['F#',num2str(f_used(i))]) ;
end
 set(f,'Tag','Ozone_diff_one_filter_month')
 % samexaxis('abc','xmt','on','ytac','join','yld',1)
 suptitle([plot,' ozone difference by filter, vs month '])
 

 %% 
 
 f=figure;
 set(f,'Tag','Ozone_diff_filter')
 boxplot(matmul(df(:,9),sign(df(:,8))),{df(:,2),df(:,3)})
 grid;
 title([plot,' ozone difference by filter'])
 
 f=figure;
 set(f,'Tag','Ozone_diff_group_filter')
 
 
 filtros_brw=[0,64,128,192,256];
 grp_idx=zeros(length(df),4);
 for j=1:length(filtros_brw)-1;
  grp_idx(:,j)=filtros_brw(j+1)*( (df(:,2)==filtros_brw(j) & df(:,3)==filtros_brw(j+1) ) | ( df(:,2)==filtros_brw(j+1) & df(:,3)==filtros_brw(j)) );
 end
 grpstats(matmul(df(:,[9,13,15]),sign(df(:,8))),sum(grp_idx,2),0.05);
 title([plot,' Filter change  mean and confidence interval']);
 set(gca,'YLIM',[-3,3]);
 %suptitle([plot,' Ozone differences by filter change '])
 legend({'cfg1','cfg2','cfg3'})
 ylabel(' O3_{F#N)} - O3_{F#(N+1)} (DU)')
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

%%
 f=figure;
 set(f,'Tag','Ozone_diff_group_filter')
 f_used=unique(sum(grp_idx,2));i
for i=1:length(f_used);
 subplot(length(f_used),1,i);
 j=find(sum(grp_idx,2)==f_used(i));
 try
  boxplot(matmul(df(j,[9,13,15]),sign(df(j,8))),'labels',{'cfg1','cfg2','cfg3'});
 catch
  hist(matmul(df(j,[9,13,15]),sign(df(j,8))))
 end 
  ylabel( sprintf('F#%d',f_used(i)));
 grid;
end
samexaxis('abc','xmt','on','ytac','join','yld',1)
suptitle([plot,' Ozone differences by filter'])


end

