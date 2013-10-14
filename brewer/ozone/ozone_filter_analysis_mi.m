function [results_rel results_abs]=ozone_filter_analysis_mi(summary,Cal,n_inst,varargin)
%  Analiza el cambio en el ozono durante el cambio de filtros
%  input variable summary
%  output: df
%   medidas consecutivas con cambio de filtro
%   df=[fecha, filtro_1, filtro_2, summary(filtro_1)-summary(filtro_2)]
%  
% Juanjo 14/09/2011: Se añade condicional del tipo if isempty() return 
%                    para salir en caso de no data

if nargin==2
 summary=summary{Cal.n_inst};
else
 summary=summary{n_inst};
 Cal.n_inst=n_inst;
end

if all(isnan(summary))
    disp('No data');
    return
end

aux=sortrows(summary,1); freq_filter=tabulate(aux(:,5));

 cf=diff(aux(:,5));cf=[1;cf];  
 cf_idx=find(cf);% buscamos el cambio de filtro (no nulos) 
 aux=aux(cf_idx,:); cf=cf(cf_idx);
 cf_idx=find(abs(cf)==64);% sólo filtros consecutivos
%                 indx     primer F#     segundo F#
 chg_filter=[cf_idx,aux(cf_idx-1,5),aux(cf_idx,5),(aux(cf_idx,1)-aux(cf_idx-1,1))*24*60];
% Nos quedamos con medidas que no difieran en más de 1/2 hora entre si
 chg_filter=chg_filter(chg_filter(:,end)<=30,:);
 
 chg_rel={NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3),...
          NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3),...
          NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3),...
          NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3)};

 chg_abs={NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3),...
          NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3),...
          NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3),...
          NaN*ones(fix(size(summary,1)/2),3),NaN*ones(fix(size(summary,1)/2),3)};
      
% DEFINICIONES DE CAMBIO. No considero cambios de más de un filtro 
% #0 -> #1 (#1 -> #0), #1 -> #2 (#2 -> #1), #2 -> #3 (#3 -> #2), #3 -> #4 (#4 -> #3) 

id=1;
for filt=1:4
    % ADELANTE
    idx=chg_filter(chg_filter(:,2)==(filt-1)*64 & chg_filter(:,3)==filt*64,1); idx=sort([idx-1;idx]);
    g=aux(idx,:); primero=g(1:2:end,:);  segundo=g(2:2:end,:); 
    % diff. relativa
    dif_rel=(segundo-primero)*100./primero;
    chg_rel{id}(1:size(dif_rel,1),:)=dif_rel(:,[6 10 12]);
    % diff. absoluta
    dif_=segundo-primero;
    chg_abs{id}(1:size(dif_,1),:)=dif_(:,[6 10 12]);

    % ATRAS 
    idx=chg_filter(chg_filter(:,2)==filt*64 & chg_filter(:,3)==(filt-1)*64,1); idx=sort([idx-1;idx]);
    g=aux(idx,:); primero=g(1:2:end,:);  segundo=g(2:2:end,:); 
    % diff. relativa
    dif_rel=(primero-segundo)*100./segundo; 
    chg_rel{id+1}(1:size(dif_rel,1),:)=dif_rel(:,[6 10 12]); 
    % diff. absoluta    
    dif_=primero-segundo; 
    chg_abs{id+1}(1:size(dif_,1),:)=dif_(:,[6 10 12]);
    
    id=id+2;
end
tableform({'F#0 <-> F#1','F#1 <-> F#2','F#2 <-> F#3','F#3 <-> F#4'},...
          [length(find(~isnan(chg_rel{1}(:,1))))+length(find(~isnan(chg_rel{2}(:,1)))),...
           length(find(~isnan(chg_rel{3}(:,1))))+length(find(~isnan(chg_rel{4}(:,1)))),...
           length(find(~isnan(chg_rel{5}(:,1))))+length(find(~isnan(chg_rel{6}(:,1)))),...
           length(find(~isnan(chg_rel{7}(:,1))))+length(find(~isnan(chg_rel{8}(:,1))))]);

results_rel=cell2mat(chg_rel); results_abs=cell2mat(chg_abs); 
if isempty(varargin)
   fplot=1; qplot=1;
elseif size(varargin)==1
   fplot=varargin{1};   qplot=0;
else
   fplot=varargin{1};   qplot=varargin{2};   
end

   % queso con porcentajes relativos al total
   if qplot
      figure; set(gcf,'Tag','FILTER_DISTRIBUTION');
      label_1=mmcellstr(sprintf('F#%d= |',freq_filter(:,1)./64));
      label_=mmcellstr(sprintf('%.1f%% |',freq_filter(:,3)));
      explode = repmat(1,1,size(freq_filter,1))'; pie3(freq_filter(:,2),explode,strcat(label_1,label_));
      set(findobj(gcf,'Type','text'),'Backgroundcolor','w');
      title(sprintf('%s%s','Filters:  ',Cal.brw_name{Cal.n_inst}),'FontSize',12,'FontWeight','Bold');
   end
   
if fplot
   f=figure;  set(f,'Tag','Ozone_diff_filter_rel');
   rectangle('Position',[.5,-0.5,8,1],'FaceColor',[.95 .95 .95]); hold on; 
   boxplot(results_rel(:,1:3:end),'notch','on',...% ploteamos campo 6
                    'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192'}); 
   set(gca,'YLim',[-2 2]); ylabel('Relative Difference (%)');  hline(0,'-.k');  grid;
   title(sprintf('Ozone difference by filter chg. %s\r\n Referenced always to lower filter for each group',Cal.brw_name{Cal.n_inst}));

   f=figure;  set(f,'Tag','Ozone_diff_filter');   hold on; 
   boxplot(results_abs(:,1:3:end),'notch','on',...% ploteamos campo 6
                     'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192'}); 
   ylabel('Absolute Difference');  hline(0,'-.k');  grid;
   title(sprintf('Ozone difference by filter chg. %s',Cal.brw_name{Cal.n_inst})); 
end