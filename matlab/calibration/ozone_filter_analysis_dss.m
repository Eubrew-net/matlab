function [results_rel results_abs]=ozone_filter_analysis_dss(summary,Cal,n_inst,varargin)
%  Analiza el cambio en el ozono durante el cambio de filtros
%  input variable summary
%  output: df
%   medidas consecutivas con cambio de filtro
%   df=[fecha, filtro_1, filtro_2, summary(filtro_1)-summary(filtro_2)]
%  
% Juanjo 14/09/2011: Se a?ade condicional del tipo if isempty() return 
%                    para salir en caso de no data


col_filter=6;
col_ozo=7;
aux=sortrows(summary,1);
freq_filter=tabulate(aux(:,col_filter))

 cf=diff(aux(:,col_filter));
 cf=[0;cf];  
 cf_idx=find(cf);% buscamos el cambio de filtro (no nulos) 
 aux=aux(cf_idx,:);
 cf=cf(cf_idx);
 cf_idx=find(abs(cf)==1);
 j=find(cf_idx==1);
 cf_idx(j)=2;
 % s?lo filtros consecutivos
%                 indx     primer F#     segundo F#
 chg_filter=[cf_idx,aux(cf_idx-1,col_filter),aux(cf_idx,col_filter),(aux(cf_idx,1)-aux(cf_idx-1,1))*24*60];
% Nos quedamos con medidas que no difieran en m?s de 1/2 hora entre si
 chg_filter=chg_filter(chg_filter(:,end)<=15,:);
 
 chg_rel=repmat({NaN*ones(fix(size(summary,1)/2),2)},1,8);
 chg_abs=repmat({NaN*ones(fix(size(summary,1)/2),2)},1,8);
 
% DEFINICIONES DE CAMBIO. No considero cambios de m?s de un filtro 
% #0 -> #1 (#1 -> #0), #1 -> #2 (#2 -> #1), #2 -> #3 (#3 -> #2), #3 -> #4 (#4 -> #3) 

id=1;
for filt=1:4
    % ADELANTE
    idx=chg_filter(chg_filter(:,2)==(filt-1) & chg_filter(:,3)==filt,1);
    idx=sort([idx-1;idx]);
    g=aux(idx,:); primero=g(1:2:end,:);  segundo=g(2:2:end,:); 
    % diff. relativa
    dif_rel=(segundo-primero)*100./primero; dif_rel(:,1)=nanmean([primero(:,1),segundo(:,1)],2);
    chg_rel{id}(1:size(dif_rel,1),:)=dif_rel(:,[1 col_ozo]);
    % diff. absoluta
    dif_=segundo-primero; dif_(:,1)=nanmean([primero(:,1),segundo(:,1)],2);
    chg_abs{id}(1:size(dif_,1),:)=dif_(:,[1 col_ozo]);

    % ATRAS 
    idx=chg_filter(chg_filter(:,2)==filt & chg_filter(:,3)==(filt-1),1); 
    idx=sort([idx-1;idx]);
    g=aux(idx,:);
    primero=g(1:2:end,:); 
    segundo=g(2:2:end,:); 
    % diff. relativa
    dif_rel=(primero-segundo)*100./segundo; dif_rel(:,1)=nanmean([primero(:,1),segundo(:,1)],2);
    chg_rel{id+1}(1:size(dif_rel,1),:)=dif_rel(:,[1 6]); 
    % diff. absoluta    
    dif_=primero-segundo; dif_(:,1)=nanmean([primero(:,1),segundo(:,1)],2); 
    chg_abs{id+1}(1:size(dif_,1),:)=dif_(:,[1 6]);
    
    id=id+2;
end
tableform({'F#0 <-> F#1','F#1 <-> F#2','F#2 <-> F#3','F#3 <-> F#4'},...
          [length(find(~isnan(chg_rel{1}(:,1))))+length(find(~isnan(chg_rel{2}(:,1)))),...
           length(find(~isnan(chg_rel{3}(:,1))))+length(find(~isnan(chg_rel{4}(:,1)))),...
           length(find(~isnan(chg_rel{5}(:,1))))+length(find(~isnan(chg_rel{6}(:,1)))),...
           length(find(~isnan(chg_rel{7}(:,1))))+length(find(~isnan(chg_rel{8}(:,1))))]);

results_rel=cell2mat(chg_rel); 
results_abs=cell2mat(chg_abs); 
if isempty(varargin)
   fplot=1; qplot=1;
elseif size(varargin)==1
   fplot=varargin{1};   qplot=0;
else
   fplot=varargin{1};   qplot=varargin{2};   
end

   % queso con porcentajes relativos al total
   if qplot
      figure; 
      set(gcf,'Tag','FILTER_DISTRIBUTION');
      label_1=mmcellstr(sprintf('F#%d= |',freq_filter(:,1)));
      label_=mmcellstr(sprintf('%.1f%% |',freq_filter(:,3)));
      explode = repmat(1,1,size(freq_filter,1))'; pie3(freq_filter(:,2),explode,strcat(label_1,label_));
      set(findobj(gcf,'Type','text'),'Backgroundcolor','w');
      title(sprintf('%s%s','Filters:  ',Cal.brw_name{Cal.n_inst}),'FontSize',12,'FontWeight','Bold');
   end
   
if fplot
   f=figure;  set(f,'Tag','Ozone_diff_filter_rel');
   rectangle('Position',[.5,-0.5,8,1],'FaceColor',[.95 .95 .95]); hold on; 
   boxplot(results_rel(:,2:2:end),'notch','on',...% ploteamos campo 6
                    'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192'}); 
   set(gca,'YLim',[-2 2]); ylabel('Relative Difference (%)');  hline(0,'-.k');  grid;
   title(sprintf('Ozone difference by filter chg. %s\r\n Referenced always to lower filter for each group',Cal.brw_name{Cal.n_inst}));

   f=figure;  set(f,'Tag','Ozone_diff_filter');   hold on; 
   boxplot(results_abs(:,2:2:end),'notch','on',...% ploteamos campo 6
                     'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192'}); 
   ylabel('Absolute Difference');  hline(0,'-.k');  grid;
   title(sprintf('Ozone difference by filter chg. %s',Cal.brw_name{Cal.n_inst})); 
   set(gca,'YLim',[-10 10]);
end