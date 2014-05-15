function [langsumm_sync_data langsumm_sync_data_legend] = langley_summ_sync(data,Cal,varargin)

% function [langsumm_sync_data langsumm_sync_data_legend] = langley_summ_sync(summary,summary_old,Cal,varargin)
% 
% Devuelve como salida los datos simultáneos (Tsync=5 minutos) de la triada RBCC-E para el análisis Langley. 
% Se mantiene para la salida el mismo formato de la antigua ozone_lgl: 39 campos
% MS9's para las dos configuraciones consideradas: new y old (checking configuration)
% 
% Los  summarios están corregidos por filtros, con lo cual se trabaja con el campo 9 (si no se aplica 
% la función filter_corr, entonces tendríamos que el campo 9 es la MS9 std !!)
% 
% OUTPUT:
% - langsumm_sync_data: datos simultáneos de la triada RBCC-E para el análisis Langley.
%                       Celda para cada intrumento con tantas matrices como días analizados
% - langsumm_sync_data_legend={
%     'date'  'lat'  'long' 'sza'  'm2 '  'm3 '  'flag'  'NaN'  'tst'  'filt'  'temp' ... % 1-11              
%      'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...      % 12-18 
%      'O3 old'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 old'  ...  % 19-25 
%      'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...      % 26-32 
%      'O3 new'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 new'  ...  % 33-39 
%                           };
% INPUT:
% - summary, summary_old: (salida de test_recalculation -> celda de NºBrws elementos)
% - Cal
% 
% Input opcional:
% - lalo: [latitud,longitud], por defecto los de Izaña 

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_summ_sync';

% input obligatorio
arg.addRequired('data');
arg.addRequired('Cal');

% input param - value
arg.addParamValue('lalo', [28.3090,16.4994], @isfloat); % por defecto, Izana

% validamos los argumentos definidos:
arg.parse(data,Cal,varargin{:});

%% Obtenemos los datos simultáneos: Medidas individuales
TSYNC=5; orden=Cal.n_ref;
idx_=find(cellfun (@(x) ~isempty(x),data)==1);

% preparamos los datos 
time_ref=cellfun(@(x) fix(x(1,1)),data{1}); data_{1}=data{1};

 for tt=idx_(2:end)
     [idx_1 b]=ismember(time_ref,cellfun(@(x) fix(x(1,1)),data{tt})); 
     id=find(b==0);  b(b==0)=[];
     data_{tt}=repmat({[]},length(time_ref),1); data_{tt}(idx_1,:)=data{tt}(b);
     for id_=1:length(id)   
         data_{tt}(id(id_))={cat(2,time_ref(id(id_)),NaN*ones(1,38))};    
     end
 end

ref_sza=repmat({[]},size(data{1}),1);
ref_m2=repmat({[]},size(data{1}),1);
ref_m3=repmat({[]},size(data{1}),1);
ref_tst=repmat({[]},size(data{1}),1);
ref_flt=repmat({[]},size(data{1}),1);
ref_temp=repmat({[]},size(data{1}),1);
ref_o3_old=repmat({[]},size(data{1}),1);
ref_o3_new=repmat({[]},size(data{1}),1);
ref_ms9_old=repmat({[]},size(data{1}),1);
ref_ms9_new=repmat({[]},size(data{1}),1);
for ii=idx_
    SYNC=repmat({TSYNC},length(data_{ii}),1);
    ll=repmat({arg.Results.lalo},length(data_{ii}),1);
    time=cellfun(@(x,y) fix(x(:,1)*24*60/y)/24/60*y,data_{ii},SYNC,'UniformOutput',0);

    [ZA,m2,m3]=cellfun(@(x,y,z) brewersza((x(:,1)-fix(x(:,1)))*24*60,diaj(y),year(y)-2000,z(1),z(2)),data_{ii},time,ll,'UniformOutput',0);
    [no,no_,tst]=cellfun(@(x,y) sun_pos(x(:,1),y(1),-y(2)),data_{ii},ll,'UniformOutput',0);
    
    med_r6=cellfun(@(x,y) x(:,25),data_{ii},'UniformOutput',0);
    med_r6c=cellfun(@(x,y) x(:,39),data_{ii},'UniformOutput',0); 
    med_o3=cellfun(@(x,y) x(:,19),data_{ii},'UniformOutput',0);
    med_o3c=cellfun(@(x,y) x(:,33),data_{ii},'UniformOutput',0);
    med_flt=cellfun(@(x,y) x(:,10),data_{ii},'UniformOutput',0);
    med_temp=cellfun(@(x,y) x(:,11),data_{ii},'UniformOutput',0);   
%           -------------------------------------     
    ref_sza= cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_sza,time,ZA,'UniformOutput',0);     
    ref_m2 = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_m2,time,m2,'UniformOutput',0); 
    ref_m3 = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_m3,time,m3,'UniformOutput',0); 
    ref_tst = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_tst,time,tst,'UniformOutput',0); 
    ref_flt = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_flt,time,med_flt,'UniformOutput',0); 
    ref_temp = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_temp,time,med_temp,'UniformOutput',0); 
    ref_o3_old = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_o3_old,time,med_o3,'UniformOutput',0); 
    ref_o3_new = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_o3_new,time,med_o3c,'UniformOutput',0); 
    ref_ms9_old = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_ms9_old,time,med_r6,'UniformOutput',0); 
    ref_ms9_new = cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_ms9_new,time,med_r6c,'UniformOutput',0); 
end

%% Final format
langsumm_sync_data_legend={
   'date'  'lat'  'long' 'sza'  'm2 '  'm3 '  'flag'  'NaN'  'tst'  'filt'  'temp' ... % 1-11              
    'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...     % 12-18 
    'O3 old'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 old'  ... % 19-25 
    'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...     % 26-32 
    'O3 new'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 new'  ... % 33-39 
                          };

langsumm_sync_data=cell(max(idx_),1);
aux=cellfun(@(x) NaN*ones(size(x,1),1),ref_sza,'UniformOutput',0);
for jj=1:length(idx_)
    jj_=cellfun(@(x) x+1,repmat({jj},size(data_{1}),1),'UniformOutput',0);
    langsumm_sync_data{idx_(jj)}=cellfun(@(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,z,N) cat(2,a1(:,[1 z]),N,N,a2(:,z),...
        a3(:,z),N,N,a4(:,z),a5(:,z),a6(:,z),N,N,N,N,N,N,N,...
        a7(:,z),N,N,N,N,N,a8(:,z),...
        N,N,N,N,N,N,N,...
        a9(:,z),N,N,N,N,N,a10(:,z)),...
        ref_sza,ref_m2,ref_m3,ref_tst,ref_flt,ref_temp,...  
        ref_o3_old,ref_ms9_old,ref_o3_new,ref_ms9_new,jj_,aux,'UniformOutput',0);
end