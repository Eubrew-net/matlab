%% leemos los ficheros 
path(genpath('.'),path);

% cd(fullfile(pwd,'..\..\uvbrewer157\uvdata\2009'));
% uv157=loaduvl('UV*.157','uvr27808.157');
% 
% cd(fullfile(pwd,'..\..\uvbrewer183\uvdata\2009'));
% uv183=loaduvl('UV*.183','uvr28808.183');
% 
cd('c:\SHICrivm\uvdata\iz3\after');
uv185=loaduvl('UV*.185','uvr31311.185');
% cd(fullfile(pwd,'..\..\uvbrewer185\uvdata\Are2011'));
% uv185=loaduvl('UV*.185','uvr13911.185');

%% formato de intercambio
% Cuidado aqui para trabajar con los datos adecuados
% (recordar la salida del visor)
% write_interchange_brewer(uv033);%uv033;
% write_interchange_brewer(uv183);%uv
%write_interchange_brewer(uv);%uv183
write_interchange_brewer(uv185);%uv185

%% shic
shicpath='c:\SHICrivm\uvdata\';
inst={'iz1','iz2','iz3','033'};
for i=3 %1:size(inst,2),i
    ['*.',inst{i}],[shicpath,inst{i}]
movefile(['*.',inst{i}],[shicpath,inst{i}]);
end
%% Depuracion visor (Manual)
%c:\SHICrivm\uvdata\iz1\

%% comparacion
% Lo primero será cargar al matriz con los uv depurados
% (estarán en los 'E:\red_brewer\uvbrewer???\year\VISOR\uv???.mat' )
days=[]; comparar=[];

x_ref=arrayfun(@(x)~isempty(x.date),uv157);
jday_ref=find(x_ref);

x=arrayfun(@(x)~isempty(x.date),uv185);
jday=find(x);

days=intersect(jday_ref,jday);


for i=1:length(days),i
     % comp_scan(uv157(days(i)),uv183(days(i)));
      [fig_indv,fig_day,ratio,uv,time] = comp_scan_jj(uv157(days(i)),uv185(days(i)));
%       pause
%       if isempty(fig_indv), continue 
%       end
%       for u=1:length(fig_indv)
%       print(fig_indv(u),'-dpsc','-append',['comp2008','_',num2str(157),'_',num2str(183)]) ;
%       end
      
      if isempty(time) 
         continue 
      end
      print(fig_day,'-dpsc','-append',['dailycomp2008','_',num2str(157),'_',num2str(185)]) ;
      close all

      
%      % Construimos una matriz con los scan comunes a cada dia para los dos
%      % brewers, y con los siguientes parametros:
%      % yyyy, dia, tiempo (minutos GMT para 157), time_157-time_157, ratio 
%       comparar = [comparar; repmat(2007,size(time,1),1) repmat(days(i),size(time,1),1) time(:,1) time(:,1)-time(:,2) ratio']
end