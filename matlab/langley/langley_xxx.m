%% load data
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

91	2011	0
93	2011	2
94	2011	1
95	2011	0
96	2011	0
97	2011	2
98	2011	0
99	2011	0
100	2011	0
101	2011	0
102	2011	0
103	2011	2
104	2011	2
105	2011	0
106	2011	0
107	2011	1
109	2011	0
111	2011	2
112	2011	1
113	2011	2
114	2011	1
115	2011	0
116	2011	0
125	2011	1
126	2011	2
127	2011	0
129	2011	0
130	2011	2
132	2011	0
133	2011	0
134	2011	1
135	2011	0
136	2011	2
137	2011	1
138	2011	1
139	2011	0
140	2011	0
141	2011	0];

n_days=length(langley_days);
results=NaN*zeros(n_days,2,2,4,8);
aux=ozone_lgl{3};

for nd=1:n_days

%% DAYS SETUP
% DESCRIPTIVE TEXT

    fecha=datenum(langley_days(nd,2),1,0)+langley_days(nd,1);

    auxb=icf{1};
    auxc=cfg{1};
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

    try
    results(nd,:,:,:,:)=plot_langley(lgl,185);
    info(nd)=[nd,185];
    catch
        disp(langley_days(nd));
    end
    snapnow;

    close all;
 %%
end

%% END
