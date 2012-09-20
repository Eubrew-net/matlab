%% setup
%clear all; 
path(genpath(fullfile(pwd,'../matlab')),path);
file_setup='etc2009_setup'; 
eval(file_setup);     % configuracion por defecto
Cal.file_save='Triad2009';

%% load data
%
%
icf={};cfg={};
load(Cal.file_save,'ozone_raw','dsum','ozone_sum','ozone_ds','config','sl','sl_cr','hg','log','missing');
ozone_lgl=cell(Cal.n_brw,1);
for i=1:Cal.n_brw
    o3_raw=cell2mat(ozone_raw{i});
    o3_ds=cell2mat(ozone_ds{i});
    cfg_aux=cell2mat(config{i});

    
ozone_lgl{i}=[o3_raw(:,1:11),o3_raw(:,19:25),o3_ds(:,8:14),...
            o3_raw(:,26:32),o3_ds(:,15:21)];
icf{i}=[cfg_aux(53:53:end,1),cfg_aux(1:53:end,1),cfg_aux(8:53:end,:),cfg_aux(11:53:end,:)];
cfg{i}=reshape(cfg_aux,53,[],3);
end
ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
          'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  %   % 12-18 cuentas/segundo  config 1                    
          'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... %  % 19-25ratios (Rayleight corrected !!)                 
          'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  % % 26-32Segund configuracion                           
          'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... % 33-39ratios (Rayleight corrected !!) 
                                                    
         };
icf_legend={
        'A1cfg1' 'A1cfg2' 'A1bf' 'ETCcfg1' 'ETCcfg2' 'ETCbf'  ...  % 40-42 (A1) 43-45 (EtC)
 }
%%
langley_days=[
% 39	2009
% 40	2009
% 41	2009
% 46	2009
% 81	2009
% 98	2009
% 108	2009
% 110	2009
% 112	2009
% 113	2009
% 115	2009
% 135	2009
% 136	2009
% 158	2009
213	2009
228	2009
230	2009
233	2009
236	2009
239	2009
240	2009
244	2009
276	2009
277	2009
278	2009
279	2009
280	2009
281	2009
282	2009
283	2009
286	2009
288	2009
289	2009
290	2009
293	2009
];
n_brw=Cal.n_brw;
n_days=length(langley_days);
results=NaN*zeros(n_days,2,2,4,8); 
brw_r=NaN*zeros(n_brw,n_days,2,2,4,8);
%results=NaN*zeros(n_days,2,2,4,8);
%save(Cal.file_save,'-APPEND','ozone_raw','dsum','ozone_sum','ozone_ds','config','sl','sl_cr','hg','log','missing');
rb={}; 
statt=cell(n_brw,n_days,2,2);
for nd=1:n_days
  for nb=1:n_brw
    
    aux=ozone_lgl{nb};
    auxb=icf{nb};
    auxc=cfg{nb};
    %%
    disp(Cal.brw_str(nb))
    
    
  
        %% DAYS SETUP
        % DESCRIPTIVE TEXT
        
        fecha=datenum(langley_days(nd,2),1,0)+langley_days(nd,1);
        
        j=find(fix(aux(:,1))==fecha);
        o3.ozone_lgl=aux(j,:);
        lgl=aux(j,:);
        j=find(auxc(end,:,1)==fecha);
        setup=squeeze(auxc(:,j,:));
        
        %recalculation
        %[o_3,so_2,rat]=ozone_cal_raw(lgl(:,12:18),lgl(:,5),770,lgl(:,6),setup(:,1));
        
        % depuracion de observaciones
        [m,s,n,g]=grpstats(lgl(:,[2,19,33]),fix(lgl(:,3)/10));
        j=find(s(:,2)<1.0 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
        idx=cellfun(@str2num,g(j));
        t=ismember(fix(lgl(:,3)/10),idx);
        lgl=lgl(t,:);
        
        % plot
         switch nb
            case 1  
                FC=[]; 
            case 2
                FC=256;
            case 3
                FC=[192,256];
        end
        try
            %results(nd,:,:,:,:)=plot_langley(lgl,Cal.brw_str(nb));
            [brw_r(nb,nd,:,:,:,:),statt(nb,nd,:,:)]=simple_langley(lgl,Cal.brw_str(nb),NB);
            disp('OK');
        catch
            disp(sprintf(' Error, brewer %d dia %d ',nb,nd));
        end
        snapnow;       
        
        %%
  end
    %rb{nb}=results;
    disp(Cal.brw_str(nb));
    snapnow;
    close all;
end

%% 185 case
%rf=reshape(squeeze(r(:,:,:,4,1:2)),21,8);errorbar(repmat(langley_days(:,1),1,4),rf(:,1:4),rf(:,5:8),'.')