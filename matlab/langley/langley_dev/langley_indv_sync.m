function langindv_sync_data = langley_indv_sync(ozone_lgl,Cal,varargin)

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
% - langsumm_sync_data: datos simultáneos de la triada RBCC-E para el -análisis Langley.
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
arg.FunctionName = 'langley_indv_sync';

% input obligatorio
arg.addRequired('ozone_lgl');
arg.addRequired('Cal');

% input param - value
arg.addParamValue('lalo', [28.3090,16.4994], @isfloat); % por defecto, Izana

% validamos los argumentos definidos:
arg.parse(ozone_lgl,Cal,varargin{:});
mmv2struct(arg.Results);

%% Obtenemos los datos simultáneos: Medidas individuales
TSYNC=.5; 
idx_=find(cellfun (@(x) ~isempty(x),ozone_lgl)==1);

% preparamos los datos 

% usar como tiempo de referencia el periodo de tiempo: Cal.Date.CALC_Days
time_ref=cellfun(@(x) fix(x(1,1)),ozone_lgl{1});
lgl_{1}=ozone_lgl{1};

 for tt=idx_(2:end)
     [idx_1 b]=ismember(time_ref,cellfun(@(x) fix(x(1,1)),ozone_lgl{tt})); 
     id=find(b==0);  b(b==0)=[];
     lgl_{tt}=repmat({[]},length(time_ref),1); lgl_{tt}(idx_1,:)=ozone_lgl{tt}(b);
     for id_=1:length(id)   
         lgl_{tt}(id(id_))={cat(2,time_ref(id(id_)),NaN*ones(1,38))};    
     end
 end

ref_hg_id=repmat({[]},size(lgl_{1}),1); ref_nds=repmat({[]},size(lgl_{1}),1); ref_sza=repmat({[]},size(lgl_{1}),1);
ref_m2=repmat({[]},size(lgl_{1}),1); ref_m3=repmat({[]},size(lgl_{1}),1); ref_sza_cal=repmat({[]},size(lgl_{1}),1);
ref_saz=repmat({[]},size(lgl_{1}),1); ref_tst=repmat({[]},size(lgl_{1}),1); ref_flt=repmat({[]},size(lgl_{1}),1);
ref_temp=repmat({[]},size(lgl_{1}),1);
ref_f0=repmat({[]},size(lgl_{1}),1); ref_f1=repmat({[]},size(lgl_{1}),1); ref_f2=repmat({[]},size(lgl_{1}),1); 
ref_f3=repmat({[]},size(lgl_{1}),1); ref_f4=repmat({[]},size(lgl_{1}),1); ref_f5=repmat({[]},size(lgl_{1}),1);
ref_f6=repmat({[]},size(lgl_{1}),1); ref_o3_1=repmat({[]},size(lgl_{1}),1); ref_r1=repmat({[]},size(lgl_{1}),1);
ref_r2=repmat({[]},size(lgl_{1}),1); ref_r3=repmat({[]},size(lgl_{1}),1); ref_r4=repmat({[]},size(lgl_{1}),1);
ref_r5=repmat({[]},size(lgl_{1}),1); ref_r6=repmat({[]},size(lgl_{1}),1); ref_F0=repmat({[]},size(lgl_{1}),1);
ref_F1=repmat({[]},size(lgl_{1}),1); ref_F2=repmat({[]},size(lgl_{1}),1); ref_F3=repmat({[]},size(lgl_{1}),1);
ref_F4=repmat({[]},size(lgl_{1}),1); ref_F5=repmat({[]},size(lgl_{1}),1); ref_F6=repmat({[]},size(lgl_{1}),1);
ref_O3_2=repmat({[]},size(lgl_{1}),1); ref_R1=repmat({[]},size(lgl_{1}),1); ref_R2=repmat({[]},size(lgl_{1}),1);
ref_R3=repmat({[]},size(lgl_{1}),1); ref_R4=repmat({[]},size(lgl_{1}),1); ref_R5=repmat({[]},size(lgl_{1}),1);
ref_R6=repmat({[]},size(lgl_{1}),1);

for ii=idx_
    o3_lgl=lgl_{ii}; tsync=repmat({TSYNC},size(o3_lgl,1),1);
    time=cellfun(@(x,y) fix(x(:,1)*24*60/y)/24/60*y,o3_lgl,tsync,'UniformOutput',false);
    
%  'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp' ...% 1-11              
    med_hg_id=cellfun(@(x) x(:,2),o3_lgl,'UniformOutput',false);    
    med_nds=cellfun(@(x) x(:,3),o3_lgl,'UniformOutput',false);   
    med_sza=cellfun(@(x) x(:,4),o3_lgl,'UniformOutput',false);     
    med_m2=cellfun(@(x) x(:,5),o3_lgl,'UniformOutput',false);    
    med_m3=cellfun(@(x) x(:,6),o3_lgl,'UniformOutput',false); 
    med_sza_cal=cellfun(@(x) x(:,7),o3_lgl,'UniformOutput',false);    
    med_saz=cellfun(@(x) x(:,8),o3_lgl,'UniformOutput',false);   
    med_tst=cellfun(@(x) x(:,9),o3_lgl,'UniformOutput',false);     
    med_flt=cellfun(@(x) x(:,10),o3_lgl,'UniformOutput',false);    
    med_temp=cellfun(@(x) x(:,11),o3_lgl,'UniformOutput',false); 

%  'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'   ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
    med_f0=cellfun(@(x) x(:,12),o3_lgl,'UniformOutput',false);    
    med_f1=cellfun(@(x) x(:,13),o3_lgl,'UniformOutput',false);   
    med_f2=cellfun(@(x) x(:,14),o3_lgl,'UniformOutput',false);     
    med_f3=cellfun(@(x) x(:,15),o3_lgl,'UniformOutput',false);    
    med_f4=cellfun(@(x) x(:,16),o3_lgl,'UniformOutput',false); 
    med_f5=cellfun(@(x) x(:,17),o3_lgl,'UniformOutput',false);    
    med_f6=cellfun(@(x) x(:,18),o3_lgl,'UniformOutput',false); 

%     'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6' ...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
    med_o3_1=cellfun(@(x) x(:,19),o3_lgl,'UniformOutput',false);    
    med_r1=cellfun(@(x) x(:,20),o3_lgl,'UniformOutput',false);   
    med_r2=cellfun(@(x) x(:,21),o3_lgl,'UniformOutput',false);     
    med_r3=cellfun(@(x) x(:,22),o3_lgl,'UniformOutput',false);    
    med_r4=cellfun(@(x) x(:,23),o3_lgl,'UniformOutput',false); 
    med_r5=cellfun(@(x) x(:,24),o3_lgl,'UniformOutput',false);    
    med_r6=cellfun(@(x) x(:,25),o3_lgl,'UniformOutput',false); 

%     'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'   ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
    med_F0=cellfun(@(x) x(:,26),o3_lgl,'UniformOutput',false);    
    med_F1=cellfun(@(x) x(:,27),o3_lgl,'UniformOutput',false);   
    med_F2=cellfun(@(x) x(:,28),o3_lgl,'UniformOutput',false);     
    med_F3=cellfun(@(x) x(:,29),o3_lgl,'UniformOutput',false);    
    med_F4=cellfun(@(x) x(:,30),o3_lgl,'UniformOutput',false); 
    med_F5=cellfun(@(x) x(:,31),o3_lgl,'UniformOutput',false);    
    med_F6=cellfun(@(x) x(:,32),o3_lgl,'UniformOutput',false); 

%     'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6' ...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                         
    med_O3_2=cellfun(@(x) x(:,33),o3_lgl,'UniformOutput',false);    
    med_R1=cellfun(@(x) x(:,34),o3_lgl,'UniformOutput',false);    
    med_R2=cellfun(@(x) x(:,35),o3_lgl,'UniformOutput',false);    
    med_R3=cellfun(@(x) x(:,36),o3_lgl,'UniformOutput',false);    
    med_R4=cellfun(@(x) x(:,37),o3_lgl,'UniformOutput',false);    
    med_R5=cellfun(@(x) x(:,38),o3_lgl,'UniformOutput',false);    
    med_R6=cellfun(@(x) x(:,39),o3_lgl,'UniformOutput',false);   

%           -------------------------------------     

%     'date'	'hg_id'  'nds'  'sza'  'm2'  'm3'  'sza'  'saz'  'tst'  'filt'  'temp' ...% 1-11              
      ref_hg_id=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_hg_id,time,med_hg_id,'UniformOutput',false); 
      ref_nds=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_nds,time,med_nds,'UniformOutput',false); 
      ref_sza=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_sza,time,med_sza,'UniformOutput',false); 
      ref_m2=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_m2,time,med_m2,'UniformOutput',false); 
      ref_m3=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_m3,time,med_m3,'UniformOutput',false); 
      ref_sza_cal=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_sza_cal,time,med_sza_cal,'UniformOutput',false); 
      ref_saz=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_saz,time,med_saz,'UniformOutput',false); 
      ref_tst=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_tst,time,med_tst,'UniformOutput',false); 
      ref_flt=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_flt,time,med_flt,'UniformOutput',false); 
      ref_temp=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_temp,time,med_temp,'UniformOutput',false); 

%     'f0'  'f1'  'f2'  'f3'  'f4'  'f5'  'f6'   ...  % 12-18 count-rates recalculated 1 (Rayleight uncorrected !!)                   
      ref_f0=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f0,time,med_f0,'UniformOutput',false); 
      ref_f1=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f1,time,med_f1,'UniformOutput',false); 
      ref_f2=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f2,time,med_f2,'UniformOutput',false); 
      ref_f3=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f3,time,med_f3,'UniformOutput',false); 
      ref_f4=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f4,time,med_f4,'UniformOutput',false); 
      ref_f5=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f5,time,med_f5,'UniformOutput',false); 
      ref_f6=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_f6,time,med_f6,'UniformOutput',false); 
      
%     'o3_1'  'r1'  'r2'  'r3'  'r4'  'r5'  'r6' ...  % 19-25 ratios recalculated 1 (Rayleight corrected !!)                 
      ref_o3_1=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_o3_1,time,med_o3_1,'UniformOutput',false); 
      ref_r1=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_r1,time,med_r1,'UniformOutput',false); 
      ref_r2=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_r2,time,med_r2,'UniformOutput',false); 
      ref_r3=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_r3,time,med_r3,'UniformOutput',false); 
      ref_r4=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_r4,time,med_r4,'UniformOutput',false); 
      ref_r5=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_r5,time,med_r5,'UniformOutput',false); 
      ref_r6=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_r6,time,med_r6,'UniformOutput',false); 

%     'F0'  'F1'  'F2'  'F3'  'F4'  'F5'  'F6'   ...  % 26-32 count-rates recalculated 2 (Rayleight uncorrected !!)                   
      ref_F0=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F0,time,med_F0,'UniformOutput',false); 
      ref_F1=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F1,time,med_F1,'UniformOutput',false); 
      ref_F2=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F2,time,med_F2,'UniformOutput',false); 
      ref_F3=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F3,time,med_F3,'UniformOutput',false); 
      ref_F4=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F4,time,med_F4,'UniformOutput',false); 
      ref_F5=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F5,time,med_F5,'UniformOutput',false); 
      ref_F6=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_F6,time,med_F6,'UniformOutput',false); 

%     'O3_2'  'R1'  'R2'  'R3'  'R4'  'R5'  'R6' ...  % 33-39 ratios recalculated 2 (Rayleight corrected !!)                                                                     
      ref_O3_2=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_O3_2,time,med_O3_2,'UniformOutput',false); 
      ref_R1=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_R1,time,med_R1,'UniformOutput',false); 
      ref_R2=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_R2,time,med_R2,'UniformOutput',false); 
      ref_R3=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_R3,time,med_R3,'UniformOutput',false); 
      ref_R4=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_R4,time,med_R4,'UniformOutput',false); 
      ref_R5=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_R5,time,med_R5,'UniformOutput',false); 
      ref_R6=cellfun(@(x,y,z) scan_join(x,cat(2,y,z)),ref_R6,time,med_R6,'UniformOutput',false); 
end

%% Final format
langindv_sync_data=cell(max(idx_),1);    
for jj=1:length(idx_)
    jj_=cellfun(@(x) x+1,repmat({jj},size(lgl_{1}),1),'UniformOutput',0);
    langindv_sync_data{idx_(jj)}=cellfun(@(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,...
        a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,...
        a30,a31,a32,a33,a34,a35,a36,a37,a38,z) cat(2,a1(:,[1 z]),a2(:,z),...
        a3(:,z),a4(:,z),a5(:,z),a6(:,z),a7(:,z),a8(:,z),a9(:,z),a10(:,z),...
        a11(:,z),a12(:,z),a13(:,z),a14(:,z),a15(:,z),a16(:,z),a17(:,z),a18(:,z),...
        a19(:,z),a20(:,z),a21(:,z),a22(:,z),a23(:,z),a24(:,z),a25(:,z),a26(:,z),...
        a27(:,z),a28(:,z),a29(:,z),a30(:,z),a31(:,z),a32(:,z),a33(:,z),a34(:,z),...
        a35(:,z),a36(:,z),a37(:,z),a38(:,z)),...
        ref_hg_id,ref_nds,ref_sza,ref_m2,ref_m3,ref_sza_cal,ref_saz,ref_tst,ref_flt,ref_temp,...  
        ref_f0,ref_f1,ref_f2,ref_f3,ref_f4,ref_f5,ref_f6,...
        ref_o3_1,ref_r1,ref_r2,ref_r3,ref_r4,ref_r5,ref_r6,...
        ref_F0,ref_F1,ref_F2,ref_F3,ref_F4,ref_F5,ref_F6,...
        ref_O3_2,ref_R1,ref_R2,ref_R3,ref_R4,ref_R5,ref_R6,jj_,'UniformOutput',0);
end