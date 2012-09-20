function [data_group mean]=plot_ratio(dat,varargin)

% Ploteo de las diferencias relativas porcentuales entre dos equipos

%   INPUTS:
% -------- Necesarios --------
% - dat, ratios porcentuales, salida de la función ratio_min
%        [date(ref), rel.dif., sza(ref), m(ref), ozono(inst), ozono(ref),temp(inst), filter(inst)] 
% 
% -------- Opcionales ---------
% - inst,  por defecto 185 
% - ref,   por defecto 157
% - grp,   1 ó 0 (por defecto 1)
%          1 -> plotea sólo la medias de ratios agrupadas por rangos de osc
%               osc_ranges={'<400','400-550','550-850','850-1250','>1250'};
%          2 -> plotea sólo la medias de ratios agrupadas por rangos de osc         
% - means, media movil con ventana means. Por defecto 30 (medias mensuales, meanmonth)
%         Es media móvil, pero no para cada punto. Por ejemplo, para 15
%         será nanmean(A(1:15,:)), nanmean(A(16:31,:)), ....
% 
% Ejemplo:
%          [r,df,r185_2009orig,dat]=ratio_min(inst0(:,[1,6,3,2,8,9,4,5]),nref0(:,[1,6,3,2,8,9,4,5]),2);
%           plot_ratio(r185_2009orig,'inst',Cal.brw_str{3},'ref',Cal.brw_str{1},'grp',1,'means',15);         

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'plot_ratio';

% input obligatorio
arg.addRequired('dat'); 

% input param - value
arg.addParamValue('inst', '185', @isstr); arg.addParamValue('ref', '157', @isstr);
arg.addParamValue('grp', 1, @isfloat); % por defecto no ratios individuales
arg.addParamValue('means', 30, @isfloat); % por defecto medias mensuales con meanmonth

% validamos los argumentos definidos:
arg.parse(dat, varargin{:});
mmv2struct(arg.Results);

%%
osc_ranges={'<400','400-550','550-850','850-1250','>1250'};

aux=NaN*ones(size(dat,1),size(dat,2)+1);
aux(:,1:end-1)=dat;
      %m_ref  %O3_inst
osc_s=dat(:,4).*dat(:,5);
aux(osc_s<400,end)=1; aux((osc_s>=400 & osc_s<550),end)=2;
aux((osc_s>=550 & osc_s<850),end)=3; aux((osc_s>=850 & osc_s<1250),end)=4;
aux(osc_s>=1250,end)=5;

[m_sza,s_sza,n_sza,grpn]=grpstats(aux(:,[1,2,end]),...
                     {fix(aux(:,1)),aux(:,end)},{'mean','std','numel','gname'});         

data_group=[m_sza,s_sza]; 

if means==30
   mean=meanmonth(dat);
else
   mean=mov(dat,means);
end

if grp
   g=gscatter(m_sza(:,1),m_sza(:,2),m_sza(:,3)); hold on; 
   errorbar(mean.media(:,1),mean.media(:,5),mean.sigma(:,5),'d-','Linewidth',1.5,'MarkerFaceColor','k')
   set(findobj(gca,'type','Line'),'LineStyle','-');    
else
   h=plot(dat(:,1),dat(:,2),'+','MarkerSize',2,'MarkerFaceColor','c'); set(h,'HandleVisibility','off')
   hold on; g=gscatter(m_sza(:,1),m_sza(:,2),m_sza(:,3));
   set(findobj(gca,'type','Line'),'LineStyle','-');    
   errorbar(mean.media(:,1),mean.media(:,5),mean.sigma(:,5),'d-','Linewidth',1.5,'MarkerFaceColor','k')
end
set(gcf,'tag','RATIO_TIME_OSC'); 
set(g,'Marker','+','MarkerSize',1); set(gca,'Ylim',[-3 3]);  grid; box on;  
legend(osc_ranges,'location','West','FontSize',8,'FontWeight','Bold'); 
    
hline([-0.5 0.5],'k--'); hline([-1 0 1],'k-'); 
text(11/13,10/11,[inst,' - ',ref,' / ',ref],'Units','Normalized',...
                           'EdgeColor','k','BackGroundColor','w','FontWeight','Bold');

function outp=mov(data,means)

data=sortrows(data,1);
media=[]; sigma=[]; N=[];
interv=data(1,1):means:data(end,1);

for i=1:length(interv)-1
    try
        idx=find(data(:,1)>interv(i) & data(:,1)<interv(i+1));
    catch
        idx=[];
    end
    media=[media;nanmean(data(idx,:))];
    sigma=[sigma;nanstd(data(idx,:))];        
    N=[N;length(idx)];    
end
outp.media=NaN*ones(size(media,1),11); outp.sigma=NaN*ones(size(sigma,1),11);
outp.media(:,[1 4:11])=[fix(media(:,1)),N,media(:,2:end)];
outp.sigma(:,[1 4:11])=[fix(media(:,1)),N,sigma(:,2:end)];



