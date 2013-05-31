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
% - O3 100-600   (removing outliers in ozone) -> hardcode
% - hg flag == 1 (bad Hg measurements removed) -> hardcode
% - n = 5        (DS not aborted) -> hardcode
% 
% SECOND SET OF FILTERS: 
% Data-filters specific to langley analysis. Ussually we work we half-days, AM & PM, true solar time used
% 
% airmass = [1.15 3.5]  (air mass range to analyze) -> optional
% AM,PM std < 2        (Half-day constant ozone) -> optional
% N > 25               (Number of ozone data for each half-day) -> optional
% 
% INPUT
% - data: langley data. Individual (langley_data_cell first output) or 
%         summaries (langley_summ_sync / langley_data_cell output) 
%         
% Input opcional:
% - summ:    0 (default) or 1 (It is mandatory to declare summ=1 when working with summaries)
% - airmass: working airmass range ([1.15 3.5] default)
% - N_flt:   Number of mesurements / filter (NOT implemented)
% - N_hday:  Number of O3 measurements, summaries, for each half day (25 default)
% - O3_hday: Maximum O3 std allowed for each half day (no filter by default)
% 
% OUTPUT: 
% - langley FILTERED data (either individuals or summaries, depending on the input). In all cases:
%                    

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_filter_lvl1';

% input obligatorio
arg.addRequired('data',@iscell);

% input param - value
arg.addParamValue('summ', 0, @(x)(x==0 || x==1));   % por defecto no sumarios

arg.addParamValue('airmass', [1.15 3.5], @isfloat); % default [1.15 3.5] range
arg.addParamValue('N_flt', 5, @isfloat);            % default 5 meas. / filter
arg.addParamValue('N_hday', 25, @isfloat);          % default 25 o3 summaries / hday
arg.addParamValue('O3_hday', NaN, @isfloat);        % default 2 O3 std / hday

% validamos los argumentos definidos:
arg.parse(data, varargin{:});

%% Preparing data
% one-data days removed
j_unique=cellfun(@(x) size(x,1)==1,data); data=data(~j_unique);

%% Data filtering

% summaries from test_recalculation already partially depured
if ~arg.Results.summ 
   [m_sum,s_sum,n_sum,gname]=cellfun(@(x) grpstats(x,fix(x(:,3)/10),{'mean','std','numel','gname'}),...
                                          data,'UniformOutput',false);
                                      
   j=cellfun(@(x,y,z) find(x(:,19)<=2.5  & y(:,19)> 100 & y(:,19)<600 & y(:,2)>0 & z(:,1)==5),...
                      s_sum,m_sum,n_sum,'UniformOutput',false); 
   g_valid=cellfun(@(x) str2double(x),...
           cellfun(@(y,z) y(z),gname,j,'UniformOutput',false),'UniformOutput',false);
   idx_valid=cellfun(@(x,y) ismember(fix(x(:,3)/10),y),data,g_valid,'UniformOutput',false);

   data=cellfun(@(x,y) x(y,:),data,idx_valid,'UniformOutput',false);
   data=data(cell2mat(cellfun(@(x) ~isempty(x),data, 'UniformOutput',false)));
elseif unique(cellfun(@(x) size(x,2),data))==42
   j=cellfun(@(x) find(x(:,41)<=2.5  & x(:,33)> 100 & x(:,33)<600 & x(:,2)==1 & x(:,42)==5),...
                  data,'UniformOutput',false); 
  
   data=cellfun(@(x,y) x(y,:),data,j,'UniformOutput',false);    
   data=data(cell2mat(cellfun(@(x) ~isempty(x),data, 'UniformOutput',false)));
end
   % oz=data;   

%% Second Depuration
% airmass range (default [1.15 3.5])
if length(arg.Results.airmass)==1
   airmass=repmat({arg.Results.airmass},size(data,1),1);
   j_airmass=cellfun(@(x,y) x(:,5)<y,data,airmass,'UniformOutput',false);
else
   airmass=repmat({arg.Results.airmass},size(data,1),1); 
   j_airmass=cellfun(@(x,y) x(:,5)>min(y) & x(:,5)<max(y),data,airmass,'UniformOutput',false);
end
data=cellfun(@(x,y) x(y,:), data,j_airmass,'UniformOutput',false);

%  N filters (defaul 5)
% n_filt=cellfun(@(x) grpstats(x(:,10),x(:,10),{'numel'}),data,'UniformOutput',false);
% data=cellfun(@(x,y) x(y,:), data,j_airmass,'UniformOutput',false);

% Number of ozone data for each half-day > N_hday
j_=cellfun(@(x) x(:,9)/60>12,data,'UniformOutput',false);% 0=AM, 1=PM
j_idx=cellfun(@(x) size(x,1)==2,cellfun(@(x) unique(x)==0 & unique(x)==1,j_,'UniformOutput',false));
j_=j_(j_idx); data=data(j_idx); 
[m_ampm,s_ampm,n_ampm,gname_ampm]=cellfun(@(x,y) grpstats(x(:,[1 33]),y,{'mean','std','numel','gname'}),...
                                          data,j_,'UniformOutput',false);
if ~arg.Results.summ
   N_hday=arg.Results.N_hday*5; 
else
   N_hday=arg.Results.N_hday;
end
N_hday=repmat({N_hday},size(n_ampm,1),1); 

% AM,PM std<2 Half-day constant ozone (default NaN -> no filter)
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
 
%% Tablas
% Creamos alguna tabla con la informaciòn relevante
    colhead={'Diaj','AM','PM','std_am','N_am','std_pm','N_pm'};
    fms = {'d','d','d','.2f','.1f','.2f','.1f'};
    data_tab=[diaj(cellfun(@(x) fix(x(1,1)),m_ampm)),cell2mat(j_am),cell2mat(j_pm),...
          cellfun(@(x) x(1,2),s_ampm),cellfun(@(x) x(1,2),n_ampm),...
          cellfun(@(x) x(2,2),s_ampm),cellfun(@(x) x(2,2),n_ampm)];

    displaytable(data_tab, colhead, 7, fms, cellstr(datestr(cellfun(@(x) fix(x(1,1)),m_ampm))));
    