function [results_rel results_abs]=ozone_filter_analysis_mi(summary,Cal,n_inst,varargin)
%  Analiza el cambio en el ozono durante el cambio de filtros
%  input variable summary
%  output: df
%   medidas consecutivas con cambio de filtro
%   df=[fecha, filtro_1, filtro_2, summary(filtro_1)-summary(filtro_2)]
%  
% Juanjo 14/09/2011: Se a�ade condicional del tipo if isempty() return 
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

cf=diff(aux(:,5));cf=[0;cf];  
 cf_idx=find(cf);% buscamos el cambio de filtro (no nulos) 
%                 indx     primer F#     segundo F#
 chg_filter=[cf_idx,aux(cf_idx-1,5),aux(cf_idx,5),(aux(cf_idx,1)-aux(cf_idx-1,1))*24*60];
% Nos quedamos con medidas que no difieran en m�s de 1/2 hora entre si
 chg_filter=chg_filter(chg_filter(:,end)<=30,:);
 
% DEFINICIONES DE CAMBIO. No considero cambios de m�s de un filtro 
% #0 -> #1 (#1 -> #0), #1 -> #2 (#2 -> #1), #2 -> #3 (#3 -> #2), #3 -> #4 (#4 -> #3) 
 chg_rel={NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5),...
          NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5),...
          NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5),...
          NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5)};

 chg_abs={NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5),...
          NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5),...
          NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5),...
          NaN*ones(fix(size(summary,1)/2),5),NaN*ones(fix(size(summary,1)/2),5)};

      
if isempty(varargin)
   fplot=1; SZA_SYNC=[];
elseif length(varargin)==1
   fplot=varargin{1}; SZA_SYNC=[];
elseif length(varargin)==2
   fplot=varargin{1}; SZA_SYNC=varargin{2};
end

id=1;
for filt=1:4
    % ADELANTE
    idx=chg_filter(chg_filter(:,2)==(filt-1)*64 & chg_filter(:,3)==filt*64,1); idx=sort([idx-1;idx]);
    g=aux(idx,:); primero=g(1:2:end,:);  segundo=g(2:2:end,:); 
  
    % diff. relativa
    dif_rel=(segundo-primero)*100./primero;
    if ~isempty(SZA_SYNC)
       % diferencia en angulo zenital     
       idx_szasync=abs(dif_rel(:,2))<SZA_SYNC;
       dif_rel=dif_rel(idx_szasync,:);
    end
    chg_rel{id}(1:size(dif_rel,1),:)=dif_rel(:,[6 8 9 10 12]);

    % diff. absoluta
    dif_=segundo-primero;
    if ~isempty(SZA_SYNC)
       % diferencia en angulo zenital     
       dif_=dif_(idx_szasync,:);
    end    
    chg_abs{id}(1:size(dif_,1),:)=dif_(:,[6 8 9 10 12]);

    % ATRAS 
    idx=chg_filter(chg_filter(:,2)==filt*64 & chg_filter(:,3)==(filt-1)*64,1); idx=sort([idx-1;idx]);
    g=aux(idx,:); primero=g(1:2:end,:);  segundo=g(2:2:end,:); 
    % diff. relativa
    dif_rel=(primero-segundo)*100./segundo; 
    chg_rel{id+1}(1:size(dif_rel,1),:)=dif_rel(:,[6 8 9 10 12]); 
    % diff. absoluta    
    dif_=primero-segundo; 
    chg_abs{id+1}(1:size(dif_,1),:)=dif_(:,[6 8 9 10 12]);
    
    id=id+2;
end
tableform({'F#0 <-> F#1','F#1 <-> F#2','F#2 <-> F#3','F#3 <-> F#4'},...
          [length(find(~isnan(chg_rel{1}(:,1))))+length(find(~isnan(chg_rel{2}(:,1)))),...
           length(find(~isnan(chg_rel{3}(:,1))))+length(find(~isnan(chg_rel{4}(:,1)))),...
           length(find(~isnan(chg_rel{5}(:,1))))+length(find(~isnan(chg_rel{6}(:,1)))),...
           length(find(~isnan(chg_rel{7}(:,1))))+length(find(~isnan(chg_rel{8}(:,1))))]);

results_rel=cell2mat(chg_rel); results_abs=cell2mat(chg_abs); 

if fplot
   % queso con porcentajes relativos al total
   figure; set(gcf,'Tag','FILTER_DISTRIBUTION');
   label_1=mmcellstr(sprintf('F#%d= |',freq_filter(:,1)./64));
   label_=mmcellstr(sprintf('%.1f%% |',freq_filter(:,3)));
   explode = repmat(1,1,size(freq_filter,1))'; pie3(freq_filter(:,2),explode,strcat(label_1,label_));
   set(findobj(gcf,'Type','text'),'Backgroundcolor','w');
   title(sprintf('%s%s','Filters:  ',Cal.brw_name{Cal.n_inst}),'FontSize',12,'FontWeight','Bold');
    
   f=figure;  set(f,'Tag','Ozone_diff_filter_rel');
   rectangle('Position',[.5,-0.5,8,1],'FaceColor',[.95 .95 .95]); hold on; 
   try
        boxplot(results_rel(:,1:3:end),'notch','on',...% ploteamos campo 6
               'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192'}); 
   catch
        boxplot(results_rel(:,1:10),'notch','on',...% ploteamos campo 6
               'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192','256-320','320-256'}); 
        sprintf('Cuidado. Hay que comprobar que se est� haciendo aqu�!!!')
   end
   set(gca,'YLim',[-2 2]); ylabel('Relative Difference (%)');  hline(0,'-.k');  grid;
   title(sprintf('Ozone difference by filter chg. %s\r\n Referenced always to lower filter for each group',Cal.brw_name{Cal.n_inst}));

   f=figure;  set(f,'Tag','Ozone_diff_filter');   hold on; 
   try
        boxplot(results_abs(:,1:3:end),'notch','on',...% ploteamos campo 6
               'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192'}); 
   catch
        boxplot(results_abs(:,1:10),'notch','on',...% ploteamos campo 6
               'labels',{'0-64','64-0','64-128','128-64','128-192','192-128','192-256','256-192','256-320','320-256'}); 
   end
   ylabel('Absolute Difference');  hline(0,'-.k');  grid;
   title(sprintf('Ozone difference by filter chg. %s',Cal.brw_name{Cal.n_inst})); 
end