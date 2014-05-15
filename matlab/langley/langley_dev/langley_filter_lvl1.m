function [data data_tab] = langley_filter_lvl1(data,varargin)

% General function for langley data level 1 filtering.
% Normal data-filters applied to O3 summaries are now used to refine langley data.
% Additionally we use data-filters specific to langley analysis
%
% It works with summaries as well as with individual measurements
% In the case of summaries as calculated from test_recalculation.m function, it is not needed first
% set of filters (already implemented / applied)
%
% It is mandatory to declare optional input summ = 1 when working with summaries
%
% FIRST SET OF FILTERS:
% Common to all summaries (not needed when working directly with summaries from test recalculation)
%
% - std < 2.5    (it is better to work with more restricted 1.5 criterion) -> hardcode
% - O3 100-600   (removing outliers in ozone)                              -> hardcode
% - hg flag == 1 (bad Hg measurements removed)                             -> hardcode
% - n = 5        (DS not aborted)                                          -> hardcode
%
% SECOND SET OF FILTERS:
% Data-filters specific to langley analysis. Ussually we work we half-days, AM & PM, true solar time used
% Defined through optional arguments (see below).
%
% INPUT
% - data: langley data. Individual (langley_data_cell first output) or
%         summaries (langley_summ_sync / langley_data_cell output)
%
% Input optional:
% - summ       : 0 (default) or 1 (It is mandatory to declare summ=1 when working with summaries)
% - airmass    : Working airmass range (no filter default). It could be 1 or 2 length vector
% - N_hday     : Number of O3 measurements, summaries, for each half day (20 default)
% - O3_hday    : Maximum O3 std allowed for each half day (no filter by default)
% - N_flt      : Number of mesurements / filter (NOT implemented)
% - F_corr     : Filter correction factors to  be applied. It could be directly from configuration
%                matrix (as produced by read_cal_config_new, F_corr variable). This is the preferred form
%                (1 vector / day). It could be also simply a 6-vector, e.g. [0  0  0  11  NaN  0]
% - date_range : As usual. Default No date filter
% - AOD        : AOD lvl1.5 from AERONET. Daily AOD_340 < 0.05, when filtered (no filter by default)
% - Cloud      :
% - plots      :
% - lgl_days   :
% 
% OUTPUT:
% - langley FILTERED data (either individuals or summaries, depending on the input). In all cases:
%
% EXAMPLE:   (ozone_lgl{ii} is output from langley_data_cell function
%             AOD_data from aeronet webpage
%             Cloud data from bsrn -> cloud_screening(path_to_aux_dir,AOD_file,1))
%
% ozone_lgl_dep{ii}=langley_filter_lvl1(ozone_lgl{ii},'plots',0,...
%                           'airmass',[1.15 4],'F_corr',Fcorr{ii},'O3_hday',2.5,...
%                           'AOD','130101_131231_Izana.lev15');
%                           'Cloud',fullfile('bsrn','cloudScreening.txt'),...
%                           'date_range',datenum(2014,1,[-200,125]),'lgl_days',1);

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_filter_lvl1';

% input obligatorio
arg.addRequired('data',@iscell);

% input param - value
arg.addParamValue('summ', 0, @(x)(x==0 || x==1));         % por defecto no sumarios

arg.addParamValue('airmass'   , []     , @isfloat);       % default all airmasses
arg.addParamValue('N_flt'     , 5      , @isfloat);       % default 5 meas. / filter (NOT implemented)
arg.addParamValue('N_hday'    , 20     , @isfloat);       % default 25 o3 summaries / hday
arg.addParamValue('O3_hday'   , NaN    , @isfloat);       % default NaN O3 std / hday
arg.addParamValue('F_corr'    , []     , @(x)iscell(x) || isvector(x)); % default no filter corr
arg.addParamValue('date_range', []     , @isfloat);       % default all airmasses
arg.addParamValue('AOD'       , ''     , @(x)ischar(x));  % default no AoD filtering
arg.addParamValue('Cloud'     , ''     , @(x)ischar(x));  % default no cloud-screening
arg.addParamValue('plots'     , 0      , @(x)(x==0 || x==1));  % default no individual plots
arg.addParamValue('lgl_days'  , 0      , @(x)(x==0 || x==1));  % default no table

% validamos los argumentos definidos:
arg.parse(data, varargin{:});

%% Preparing data
% one-data days removed
j_unique=cellfun(@(x) size(x,1)==1,data); data=data(~j_unique);

%% Date Filter
if ~isempty(arg.Results.date_range)
   fch=cellfun(@(x) unique(fix(x(:,1))),data);
   data(fch<arg.Results.date_range(1))=[];
   if length(arg.Results.date_range)>1
      fch(fch<arg.Results.date_range(1))=[];
      data(fch>arg.Results.date_range(2))=[];
   end
end

%% Filter corr
if ~isempty(arg.Results.F_corr)
    f_corr=arg.Results.F_corr;
    if isstruct(f_corr)
       a=ismember(f_corr.new(:,1),cellfun(@(x) unique(fix(x(:,1))),data));
       f_corr.old=f_corr.old(a,:); f_corr.new=f_corr.new(a,:);
    end

    for dd=1:size(data,1)
        MS9_corr=data{dd}(:,[10 25 39]);
        if isstruct(f_corr)
           for filtro=1:6
               idx_flt=MS9_corr(:,1)==64*(filtro-1);
               MS9_corr(idx_flt,2:end)=matadd(MS9_corr(idx_flt,2:end),-[f_corr.old(dd,filtro+1) f_corr.new(dd,filtro+1)]);
           end
           data{dd}(:,[25 end])=MS9_corr(:,2:end);
        else
           for filtro=1:6
               idx_flt=MS9_corr(:,1)==64*(filtro-1);
               MS9_corr(idx_flt,2:end)=matadd(MS9_corr(idx_flt,2:end),-repmat(f_corr(filtro),1,2));
           end
           data{dd}(:,[25 end])=MS9_corr(:,2:end);
        end
    end
end
data_orig=data;

%% Second Depuration: airmass range (default [])
if ~isempty(arg.Results.airmass)
    airmass_range=length(arg.Results.airmass);
    switch airmass_range
        case 1
           airmass=repmat({arg.Results.airmass},size(data,1),1);
           j_airmass=cellfun(@(x,y) x(:,5)<y,data,airmass,'UniformOutput',false);
        case 2
          airmass=repmat({arg.Results.airmass},size(data,1),1);
          j_airmass=cellfun(@(x,y) x(:,5)>min(y) & x(:,5)<max(y),data,airmass,'UniformOutput',false);
    end
    data=cellfun(@(x,y) x(y,:), data,j_airmass,'UniformOutput',false);
end
data_days=data;
j_empty=cellfun(@(x) isempty(x),data_days); data_days=data_days(~j_empty);

%%  N filters (defaul 5) TODO
% n_filt=cellfun(@(x) grpstats(x(:,10),x(:,10),{'numel'}),data,'UniformOutput',false);
% data=cellfun(@(x,y) x(y,:), data,j_airmass,'UniformOutput',false);

%% Number of ozone data for each half-day > N_hday
% We split data into AM / PM
j_=cellfun(@(x) x(:,9)/60>12  ,data     ,'UniformOutput',false);% 0=AM, 1=PM
data_AM=cellfun(@(x,y) x(~y,:),data,j_  ,'UniformOutput',false);
data_PM=cellfun(@(x,y) x(y,:) ,data,j_  ,'UniformOutput',false);

[s_am,n_am]=cellfun(@(x,y) grpstats(x(:,33),fix(x(:,1)),{'std','numel'}),data_AM,'UniformOutput',false);
[s_pm,n_pm]=cellfun(@(x,y) grpstats(x(:,33),fix(x(:,1)),{'std','numel'}),data_PM,'UniformOutput',false);

if ~arg.Results.summ
   N_hday=arg.Results.N_hday*5;
else
   N_hday=arg.Results.N_hday;
end
j_am=cellfun(@(x,y) x<y,n_am,repmat({N_hday},length(n_am),1),'UniformOutput',false); j_am(cellfun(@(x) isempty(x),j_am))={false};
j_pm=cellfun(@(x,y) x<y,n_pm,repmat({N_hday},length(n_pm),1),'UniformOutput',false); j_pm(cellfun(@(x) isempty(x),j_pm))={false};

data_AM(cell2mat(j_am))={[]}; data_PM(cell2mat(j_pm))={[]};

%% AM,PM O3std < 2 Half-day constant ozone (default NaN -> no filter)
if ~isnan(arg.Results.O3_hday)
   j_am=cellfun(@(x,y) x>y,s_am,repmat({arg.Results.O3_hday},length(n_am),1),'UniformOutput',false); j_am(cellfun(@(x) isempty(x),j_am))={false};
   j_pm=cellfun(@(x,y) x>y,s_pm,repmat({arg.Results.O3_hday},length(n_pm),1),'UniformOutput',false); j_pm(cellfun(@(x) isempty(x),j_pm))={false};

   data_AM(cell2mat(j_am))={[]}; data_PM(cell2mat(j_pm))={[]};
end

%% Remove high AOD days (AOD_340 > 0.05)
if ~isempty(arg.Results.AOD)
    data_AM(cellfun(@(x) isempty(x),data_AM))={NaN}; data_AM_=repmat({NaN},length(data_AM),1); 
    data_PM(cellfun(@(x) isempty(x),data_PM))={NaN}; data_PM_=repmat({NaN},length(data_PM),1); 
    try
       aod_m=read_aeronet_ampm(arg.Results.AOD);

       [id_am loc_am]=ismember(fix(aod_m(:,1)),cellfun(@(x) unique(fix(x(:,1))),data_AM));
       data_AM_(loc_am(loc_am~=0))=data_AM(loc_am(loc_am~=0));
       aod_am=aod_m(id_am,:);        idx_am=aod_am(:,4)>0.01; 
       [id_am loc_am]=ismember(fix(aod_am(idx_am,1)),cellfun(@(x) unique(fix(x(:,1))),data_AM_)); 
       data_AM_(loc_am)={NaN}; data_AM_(cellfun(@(x) length(x)==1,data_AM_))={[]};
       
       [id_pm loc_pm]=ismember(fix(aod_m(:,1)),cellfun(@(x) unique(fix(x(:,1))),data_PM)); 
       data_PM_(loc_pm(loc_pm~=0))=data_PM(loc_pm(loc_pm~=0));
       aod_pm=aod_m(id_pm,:);        idx_pm=aod_m(id_pm,8)>0.01; 
       [id_pm loc_pm]=ismember(fix(aod_pm(idx_pm,1)),cellfun(@(x) unique(fix(x(:,1))),data_PM_)); 
       data_PM_(loc_pm)={NaN}; data_PM_(cellfun(@(x) length(x)==1,data_PM_))={[]};
        
       data_AM=data_AM_;  data_PM=data_PM_;
    catch exception
       fprintf('%s (AOD filter fails!!)\n',exception.message);
    end
end

%% Cloud Screening
if ~isempty(arg.Results.Cloud)
    data_AM(cellfun(@(x) isempty(x),data_AM))={NaN}; data_AM_=repmat({NaN},length(data_AM),1); 
    data_PM(cellfun(@(x) isempty(x),data_PM))={NaN}; data_PM_=repmat({NaN},length(data_PM),1); 
    try       
       clouds=load(arg.Results.Cloud);

       [id_am loc_am]=ismember(fix(clouds(:,1)),cellfun(@(x) unique(fix(x(:,1))),data_AM)); 
       data_AM_(loc_am(loc_am~=0))=data_AM(loc_am(loc_am~=0));
       clouds_am=clouds(id_am,:);        idx_am=clouds(id_am,3)~=1; 
       [id_am loc_am]=ismember(fix(clouds_am(idx_am,1)),cellfun(@(x) unique(fix(x(:,1))),data_AM_)); 
       data_AM_(loc_am)={NaN}; data_AM_(cellfun(@(x) length(x)==1,data_AM_))={[]};
                     
       [id_pm loc_pm]=ismember(fix(clouds(:,1)),cellfun(@(x) unique(fix(x(:,1))),data_PM)); 
       data_PM_(loc_pm(loc_pm~=0))=data_PM(loc_pm(loc_pm~=0));
       clouds_pm=clouds(id_pm,:);        idx_pm=clouds(id_pm,4)~=1; 
       [id_pm loc_pm]=ismember(fix(clouds_pm(idx_pm,1)),cellfun(@(x) unique(fix(x(:,1))),data_PM_)); 
       data_PM_(loc_pm)={NaN}; data_PM_(cellfun(@(x) length(x)==1,data_PM_))={[]};
        
       data_AM=data_AM_;  data_PM=data_PM_;
    catch exception
       fprintf('%s (AOD filter fails!!)\n',exception.message);
    end
end

%% Preparing output
%  cat AM / PM, empty days removed
data=cellfun(@(x,y) cat(1,x,y),data_AM, data_PM,'UniformOutput',false);
data=data(cellfun(@(x) ~isempty(x),data));

%% Tabla
fprintf('Selected days: conditions\r\n');

j_=cellfun(@(x) x(:,9)/60>12,data,'UniformOutput',false);
j_idx=cellfun(@(x) unique(x)+1,j_,'UniformOutput',false); 
[s_ampm,n_ampm]=cellfun(@(x,y) grpstats(x(:,33),y,{'std','numel'}),data,j_,'UniformOutput',false);

aux_ampm=NaN*ones(length(data),12); 
for jj=1:length(data)% cellfun doesn't support explicit assignment
   aux_ampm(jj,j_idx{jj})=1;
   aux_ampm(jj,j_idx{jj}+2)=s_ampm{jj};
   aux_ampm(jj,j_idx{jj}+4)=n_ampm{jj};
end

if ~isempty(arg.Results.AOD)
    id=ismember(fix(aod_m(:,1)),cellfun(@(x) unique(fix(x(:,1))),data)); 
    aod_ampm=aod_m(id,:);
    aux_ampm(:,7:10)=aod_ampm(:,[3 4 7 8]);
end

if ~isempty(arg.Results.Cloud)
    id=ismember(fix(clouds(:,1)),cellfun(@(x) unique(fix(x(:,1))),data)); 
    cloud_ampm=clouds(id,:);
    aux_ampm(:,11:12)=cloud_ampm(:,3:4);
end

data_tab=[diaj(cellfun(@(x) fix(x(1,1)),data)),aux_ampm(:,[1 3 5 7:8 11 2 4 6 9:10 12])];
colhead={'Diaj','AM','O3_std','N','AOD','AOD_std','Cld',...
                'PM','O3_std','N','AOD','AOD_std','Cld'};
fms = {'d','d','.2f','d','.4f','.5f','d','d','.2f','d','.4f','.5f','d'};
displaytable(data_tab, colhead, 8, fms, cellstr(datestr(cellfun(@(x) fix(x(1,1)),data))));
 
%% Tabla con condiciones para todos los días
if arg.Results.lgl_days
   fprintf('\nAll days: conditions\r\n');
   j_=cellfun(@(x) x(:,9)/60>12  ,data_days     ,'UniformOutput',false);% 0=AM, 1=PM
   j_idx=cellfun(@(x) unique(x)+1,j_,'UniformOutput',false); 

   [s_ampm,n_ampm]=cellfun(@(x,y) grpstats(x(:,33),[fix(x(:,1)) y],{'std','numel'}),data_days,j_,'UniformOutput',false);      
   
   aux_ampm=NaN*ones(length(data_days),12); 
   aux_ampm(:,1)=cellfun(@(x) fix(x(1,1)),data_days); aux_ampm(:,2)=cellfun(@(x) diaj(x(1,1)),data_days);
   for jj=1:length(data_days)
       aux_ampm(jj,j_idx{jj}+2)=s_ampm{jj};
       aux_ampm(jj,j_idx{jj}+4)=n_ampm{jj}; 
   end

   if ~isempty(arg.Results.AOD)
    [id loc]=ismember(fix(aod_m(:,1)),unique(fix(aux_ampm(:,1)))); 
    aod_ampm=aod_m(id,:); aux_ampm=aux_ampm(loc(loc~=0),:);
    aux_ampm(:,7:10)=aod_ampm(:,[3 4 7 8]);
   end

   if ~isempty(arg.Results.Cloud)
      [id loc]=ismember(fix(clouds(:,1)),unique(fix(aux_ampm(:,1)))); 
      cloud_ampm=clouds(id,:); aux_ampm=aux_ampm(loc(loc~=0),:);
      aux_ampm(:,11:12)=cloud_ampm(:,3:4);
   end

   colhead={'Diaj','O3_std','N','AOD','AOD_std','Cld',...
                   'O3_std','N','AOD','AOD_std','Cld'};
   fms = {'d','.2f','d','.4f','.5f','d','.2f','d','.4f','.5f','d'};
   displaytable(aux_ampm(:,[2 3 5 7:8 11 4 6 9:10 12]), colhead, 8, fms, cellstr(datestr(fix(aux_ampm(:,1)))));
end

%% Ploteo de días individuales. Con / Sin filtros
    if arg.Results.plots
        props = {'ylabel', 'xlabel','title'}; 
        uno=cellfun(@(x) unique(fix(x(:,1))),data_orig,'UniformOutput',1);
        dos=cellfun(@(x) unique(fix(x(:,1))),data,'UniformOutput',1);
        [s d f]=intersect(uno,dos);

       for dd=1:length(d)
           lgl_orig=data_orig{d(dd)};   jpm_orig=(lgl_orig(:,9)/60>12); jam_orig=~jpm_orig;
           lgl_=data{f(dd)};            jpm=(lgl_(:,9)/60>12); jam=~jpm;
           
           figure; set(gcf,'Tag',sprintf('%s%d','DayLangley_',diaj(unique(fix(lgl_(:,1))))));
           ax(1)=subplot(3,2,[1 3]); ax(3)=subplot(3,2,5); ax(2)=subplot(3,2,[2 4]); ax(4)=subplot(3,2,6);           
           for ampm=1:2
               if ampm==1
                  jk=jam; jk_orig=jam_orig;
               else
                  jk=jpm; jk_orig=jpm_orig;
               end
               if ~any(jk),  continue; end
               m_ozone=lgl_(jk,5);
               X=[ones(size(m_ozone)),m_ozone];
%              Brewer method: first cfg
               P_brw_first =lgl_(jk,25);
               [coeff_first,ci_first,r_first]=regress(P_brw_first,X);
               P_brw_second=lgl_(jk,39);
%              Brewer method: second cfg
               [coeff_second,ci_second,r_second]=regress(P_brw_second,X);

               % ajuste
               axes(ax(ampm));
               gscatter(lgl_orig(jk_orig,5),lgl_orig(jk_orig,25),lgl_orig(jk_orig,10),'','x',{},'off','');
               hold on; gscatter(lgl_orig(jk_orig,5),lgl_orig(jk_orig,39),lgl_orig(jk_orig,10),'','.',6,'off','','');
               title(sprintf('%s (%d)',datestr(nanmean(lgl_(jk,1)),0),diaj(unique(fix(lgl_(jk,1))))));
               if ~isempty(arg.Results.airmass)
                  v=vline_v(arg.Results.airmass,'-k'); set(v,'LineWidth',2);
               end
               ax_(2) = axes('Units',get(ax(ampm),'Units'),'Position',get(ax(ampm),'Position'),...
                            'Parent',get(ax(ampm),'Parent'));
               set(ax_(2),'YAxisLocation','right','XAxisLocation','Top','Color','none', ...
                         'XLim',get(ax(ampm),'XLim'),'XTickLabel','','FontSize',7);
               m_o3=grpstats(lgl_orig(jk_orig,[1 5 33]),fix(lgl_orig(jk_orig,3)/10),{'mean'});
               hold on; plot(m_o3(:,2),m_o3(:,3),'.');
               ylabel('O3 (DU)'); set(gca,'YLim',[min(m_o3(:,3))-15 max(m_o3(:,3))+15],'HandleVisibility','Off'); 
               text([.75,.75,.75,.75],[0.05,0.05*3,0.05*5,0.05*7] ,...
                    {sprintf('O3 std=%.2f',nanstd(lgl_(jk,33))),...
                     sprintf('N=%d',length(lgl_(jk,33)))       ,...
                     sprintf('ETC_1=%d',fix(coeff_first(1)))  ,...
                     sprintf('ETC_2=%d',fix(coeff_second(1)))},'Units','Normalized','FontSize',8,'BackgroundColor','w')

               % residuos
               axes(ax(ampm+2));
               gscatter(m_ozone,r_first,lgl_(jk,10),'','o',4,'off','','');
               hold on; gscatter(m_ozone,r_second,lgl_(jk,10),'','.',3,'off','','');
               if ~isempty(arg.Results.airmass)
                  v=vline_v(arg.Results.airmass,'-k'); set(v,'LineWidth',2);
               end
           end
           set(ax,'Xgrid','on','Ygrid','on','box','on');
           labelEdgeSubPlots('Airmass','Residuos'); 
           set(findobj(gcf,'Type','axes'),'FontSize',8); 
           set(cell2mat(get(ax,props)),'FontSize',8);            
           ylabel(ax(1),'MS9');
           snapnow                                                
       end
    end

