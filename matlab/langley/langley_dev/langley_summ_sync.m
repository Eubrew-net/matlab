function [langsumm_sync_data langsumm_sync_data_legend] = langley_summ_sync(summary,summary_old,Cal,varargin)

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
arg.addRequired('summary');
arg.addRequired('summary_old');
arg.addRequired('Cal');

% input param - value
arg.addParamValue('lalo', [28.3090,16.4994], @isfloat); % por defecto, Izana

% validamos los argumentos definidos:
arg.parse(summary,summary_old,Cal,varargin{:});
mmv2struct(arg.Results);

%% Obtenemos los datos simultáneos: Medidas individuales
TSYNC=5; orden=Cal.n_ref;

ref_sza=[]; ref_m2=[];   ref_m3=[];      ref_tst=[]; 
ref_flt=[]; ref_temp=[]; ref_o3_old=[]; ref_o3_new=[];
ref_ms9_old=[]; ref_ms9_new=[];
for ii=orden
    time=fix(summary{ii}(:,1)*24*60/TSYNC)/24/60*TSYNC;

    [ZA,m2,m3]=brewersza((summary{ii}(:,1)-fix(summary{ii}(:,1)))*24*60,diaj(time),year(time)-2000,lalo(1),lalo(2));
    [no,no_,tst]=sun_pos(summary{ii}(:,1),lalo(1),-lalo(2));
    med_r6=summary_old{ii}(:,8); % (8 = filter corrected)
    med_r6c=summary{ii}(:,8);    % (8 = filter corrected)
    med_o3=summary_old{ii}(:,6); 
    med_o3c=summary{ii}(:,6); 
    med_flt=summary{ii}(:,5)/64; 
    med_temp=summary{ii}(:,4);    
%           -------------------------------------     
    ref_sza=scan_join(ref_sza,cat(2,time,ZA));     
    ref_m2=scan_join(ref_m2,cat(2,time,m2));
    ref_m3=scan_join(ref_m3,cat(2,time,m3));     
    ref_tst=scan_join(ref_tst,cat(2,time,tst));     
    ref_flt=scan_join(ref_flt,cat(2,time,med_flt));
    ref_temp=scan_join(ref_temp,cat(2,time,med_temp));     
    ref_o3_old=scan_join(ref_o3_old,cat(2,time,med_o3));
    ref_o3_new=scan_join(ref_o3_new,cat(2,time,med_o3c));
    ref_ms9_old=scan_join(ref_ms9_old,cat(2,time,med_r6));
    ref_ms9_new=scan_join(ref_ms9_new,cat(2,time,med_r6c));
end

%% Final format
langsumm_sync_data_legend={
   'date'  'lat'  'long' 'sza'  'm2 '  'm3 '  'flag'  'NaN'  'tst'  'filt'  'temp' ... % 1-11              
    'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...     % 12-18 
    'O3 old'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 old'  ... % 19-25 
    'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  ...     % 26-32 
    'O3 new'  'NaN'  'NaN'  'NaN'  'NaN'  'NaN'  'MS9 new'  ... % 33-39 
                          };

dds=unique(fix(ref_ms9_old(:,1))); langsumm_sync_data=cell(length(orden),1);    
for jj=orden
    y=group_time(fix(ref_ms9_old(:,1)),dds);
    for dd=1:length(dds)
        idx=y==dd;
        langsumm_sync_data{jj}{dd,1}=NaN*ones(length(find(idx==1)),39);
        langsumm_sync_data{jj}{dd,1}(:,[1 2 3 4 5 6 9 10 11 19 25 33 39])=cat(2,ref_ms9_old(idx,1),lalo(1)*ones(length(find(idx==1)),1),...
            lalo(2)*ones(length(find(idx==1)),1),ref_sza(idx,jj+1),...
            ref_m2(idx,jj+1),ref_m3(idx,jj+1),ref_tst(idx,jj+1),ref_flt(idx,jj+1),ref_temp(idx,jj+1),...
            ref_o3_old(idx,jj+1),ref_ms9_old(idx,jj+1),...
            ref_o3_new(idx,jj+1),ref_ms9_new(idx,jj+1));
    end
end
