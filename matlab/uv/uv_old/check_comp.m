days=[]; comparar=[];

x_ref=arrayfun(@(x)~isempty(x.date),uv157);
jday_ref=find(x_ref);

x=arrayfun(@(x)~isempty(x.date),uv185);
jday=find(x);

days=intersect(jday_ref,jday); % dias comunes a los dos instrumentos estudiados


for i=1:20%length(days),i
      [fig_indv,fig_day,ratio,uv,time,lamda,szar] = comp_scan_jj(uv157(days(i)),uv185(days(i)));

%       if isempty(fig_indv), continue 
%       end
%       for u=1:length(fig_indv)
%       print(fig_indv(u),'-dpsc','-append',['comp2008','_',num2str(157),'_',num2str(183)]) ;
%       end

       print(fig_day,'-dpsc','-append',['dailycomp2008','_',num2str(157),'_',num2str(185)]) ;
       close all
      
      if isempty(time) continue 
      end
      close all
      
%      % Construimos una matriz con los scan comunes a cada dia para los dos
%      % brewers, y con los siguientes parametros:
%      % yyyy, dia, tiempo (minutos GMT para 157), time_157-time_157, ratio 
%       comparar = [comparar; repmat(2007,size(time,1),1) repmat(days(i),size(time,1),1) time(:,1) time(:,1)-time(:,2) ratio']
end