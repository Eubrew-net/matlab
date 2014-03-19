function data = langley_filter_lvl1(data,varargin)

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
% 
% OUTPUT: 
% - langley FILTERED data (either individuals or summaries, depending on the input). In all cases:
%                    
% EXAMPLE:   (ozone_lgl{ii} is output from langley_data_cell function)
% 
%   ozone_lgl_dep{ii}=langley_filter_lvl1(ozone_lgl{ii},...
%                             'airmass',[1.15 4],'F_corr',Fcorr{ii},'O3_hday',2.5,...
%                             'AOD','130101_131231_Izana.lev15');
% 

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
arg.addParamValue('plots'     , 0      , @(x)(x==0 || x==1));  % default no individual plots

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

%%  N filters (defaul 5)
% n_filt=cellfun(@(x) grpstats(x(:,10),x(:,10),{'numel'}),data,'UniformOutput',false);
% data=cellfun(@(x,y) x(y,:), data,j_airmass,'UniformOutput',false);

%% Number of ozone data for each half-day > N_hday
j_=cellfun(@(x) x(:,9)/60>12,data,'UniformOutput',false);% 0=AM, 1=PM
j_idx=cellfun(@(x) size(x,1)==2,cellfun(@(x) unique(x)==0 & unique(x)==1,j_,'UniformOutput',false));
j_=j_(j_idx); data=data(j_idx); data_orig=data_orig(j_idx);
[m_ampm,s_ampm,n_ampm,gname_ampm]=cellfun(@(x,y) grpstats(x(:,[1 33]),y,{'mean','std','numel','gname'}),...
                                          data,j_,'UniformOutput',false);                                      
if ~arg.Results.summ
   N_hday=arg.Results.N_hday*5; 
else
   N_hday=arg.Results.N_hday;
end
N_hday=repmat({N_hday},size(n_ampm,1),1); 

%% AM,PM std<2 Half-day constant ozone (default NaN -> no filter)
if isnan(arg.Results.O3_hday)
   j_am=cellfun(@(x,y) x(1,1)>y,n_ampm,N_hday,'UniformOutput',false);
   j_pm=cellfun(@(x,y) x(2,1)>y,n_ampm,N_hday,'UniformOutput',false);
else 
   O3_hday=repmat({arg.Results.O3_hday},size(n_ampm,1),1);
   j_am=cellfun(@(x,y,z,w) x(1,2)<=y & z(1,1)>=w,s_ampm,O3_hday,n_ampm,N_hday,'UniformOutput',false);
   j_pm=cellfun(@(x,y,z,w) x(2,2)<=y & z(2,1)>=w,s_ampm,O3_hday,n_ampm,N_hday,'UniformOutput',false);    
end

g_valid=cellfun(@(x) str2double(x),...
        cellfun(@(y,z) y(z),gname_ampm,j_am,'UniformOutput',false),'UniformOutput',false);
idx_valid_am=cellfun(@(x,y) ismember(x,y),j_,g_valid,'UniformOutput',false);
g_valid=cellfun(@(x) str2double(x),...
        cellfun(@(y,z) y(z),gname_ampm,j_pm,'UniformOutput',false),'UniformOutput',false);
idx_valid_pm=cellfun(@(x,y) ismember(~x,y),j_,g_valid,'UniformOutput',false);
idx_=cellfun(@(x,y) x | y,idx_valid_am,idx_valid_pm,'UniformOutput',false);
 
data=cellfun(@(x,y) x(y,:),data,idx_,'UniformOutput',false);
data=data(cell2mat(cellfun(@(x) ~isempty(x),data,'UniformOutput', false)));

%% Remove high AOD days (AOD_340 > 0.05)
if ~isempty(arg.Results.AOD)
    try
       fechs=cellfun(@(x) unique(fix(x(:,1))),data); 
       
       [aod,aod_m]=read_aeronet(arg.Results.AOD); 
       [id loc]=ismember(fix(aod_m(:,1)),fechs); loc(loc==0)=[];
       % igualamos aod y data
       aod_orig=aod_m; aod_m=aod_m(id,:); data=data(loc);
       idx=aod_m(:,3)>0.03;
       % Mantenemos info para la tabla
       data(idx)=[];
    catch exception
       fprintf('%s (AOD filter fails!!)\n',exception.message);
    end
end

%% Tablas: creamos alguna tabla con la informaciòn relevante
if arg.Results.summ
    nn=1;
else
    nn=5;
end
    if ~isempty(arg.Results.AOD)
       colhead={'Diaj','AM','PM','O3_std(am)','N(am)','O3_std(pm)','N(pm)','AOD_340','AOD_340_std'};
       fms = {'d','d','d','.2f','d','.2f','d','.3f','.4f'};
       
       fechs=cellfun(@(x) unique(fix(x(:,1))),m_ampm); 
       [id loc]=ismember(fix(aod_orig(:,1)),fechs); 
       loc(loc==0)=[]; aod_orig=aod_orig(id,:); 
       data_tab=[diaj(cellfun(@(x) fix(x(1,1)),m_ampm(loc))),cell2mat(j_am(loc)),cell2mat(j_pm(loc)),...
                 cellfun(@(x) x(1,2),s_ampm(loc)),floor(cellfun(@(x) x(1,2),n_ampm(loc))./nn),...
                 cellfun(@(x) x(2,2),s_ampm(loc)),floor(cellfun(@(x) x(2,2),n_ampm(loc))./nn),aod_orig(:,[2 3])];
       displaytable(data_tab, colhead, 10, fms, cellstr(datestr(cellfun(@(x) fix(x(1,1)),m_ampm(loc)))));
    else
       colhead={'Diaj','AM','PM','O3_std(am)','N(am)','O3_std(pm)','N(pm)'};
       fms = {'d','d','d','.2f','d','.2f','d'};
       
       data_tab=[diaj(cellfun(@(x) fix(x(1,1)),m_ampm)),cell2mat(j_am),cell2mat(j_pm),...
                 cellfun(@(x) x(1,2),s_ampm),cellfun(@(x) x(1,2),n_ampm),...
                 cellfun(@(x) x(2,2),s_ampm),cellfun(@(x) x(2,2),n_ampm)];
       displaytable(data_tab, colhead, 10, fms, cellstr(datestr(cellfun(@(x) fix(x(1,1)),m_ampm))));
    end

%% Ploteo de días individuales. Con / Sin filtros
    if arg.Results.plots
       for dd=1:length(data)
           lgl_orig=data{dd};            
           jpm=(lgl_orig(:,9)/60>12); jam=~jpm;

           figure; 
           a(1)=subplot(3,2,[1 3]); a(3)=subplot(3,2,5); a(2)=subplot(3,2,[2 4]); a(4)=subplot(3,2,6);
           for ampm=1:2
               if ampm==1
                  jk=jam; 
               else
                  jk=jpm; 
               end        
               if ~any(jk),  continue; end        
               m_ozone=lgl_orig(jk,5);
               X=[ones(size(m_ozone)),m_ozone];        
%              Brewer method: first cfg
               P_brw_first =lgl_orig(jk,25);
               [coeff_first,ci_first,r_first,ri_first,st_first]=regress(P_brw_first,X);
               P_brw_second=lgl_orig(jk,39); 
%              Brewer method: second cfg
               [coeff_second,ci_second,r_second,ri_second,st_second]=regress(P_brw_second,X);

               axes(a(ampm)); 
               gscatter(m_ozone,P_brw_first,lgl_orig(jk,10),'','o',{},'off','','MS9'); 
               hold on; g=gscatter(m_ozone,P_brw_second,lgl_orig(jk,10),'','.',6,'off','',''); 
               if ~isempty(arg.Results.airmass)
                  v=vline_v(arg.Results.airmass,'-k'); set(v,'LineWidth',2);
               end
               ax(2) = axes('Units',get(a(ampm),'Units'),'Position',get(a(ampm),'Position'),...
                            'Parent',get(a(ampm),'Parent'));
               set(ax(2),'YAxisLocation','right','XAxisLocation','Top','Color','none', ...
                         'XGrid','off','YGrid','off','Box','off'); 
               m_o3=grpstats(lgl_orig(jk,[1 33]),fix(lgl_orig(jk,3)/10),'mean');                                      
               hold on; plot(m_o3(:,1),m_o3(:,2),'.'); set(gca,'YLim',[min(m_o3(:,2))-15 max(m_o3(:,2))+15]);
               set(gca,'XTicklabels',datestr(get(gca,'XTick'),15),'XDir','reverse'); ylabel('O3 (DU)');
               title(sprintf('%s (%d)',datestr(nanmean(lgl_orig(jk,1)),0),diaj(unique(fix(lgl_orig(jk,1))))));
               text([.8,.8,.8,.8],[0.05,0.05*3,0.05*5,0.05*7] ,...
                    {sprintf('O3 std=%.2f',s_ampm{dd}(ampm+2)),...
                     sprintf('N=%d',n_ampm{dd}(ampm+2))       ,...
                     sprintf('ETC_1=%d',fix(coeff_first(1)))  ,...
                     sprintf('ETC_2=%d',fix(coeff_second(1)))},'Units','Normalized','FontSize',8,'BackgroundColor','w')
               axes(a(ampm+2));
               gscatter(m_ozone,r_first,lgl_orig(jk,10),'','o',4,'off','','Residuos');
               hold on; gscatter(m_ozone,r_second,lgl_orig(jk,10),'','.',6,'off','','');              
               if ~isempty(arg.Results.airmass)
                  v=vline_v(arg.Results.airmass,'-k'); set(v,'LineWidth',2);
               end
               set(a,'Xgrid','on','Ygrid','on','box','on');
           end
%            pause
       end
    end  

