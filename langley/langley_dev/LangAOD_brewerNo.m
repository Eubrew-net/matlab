function [brw_indv_aod brw_indv_aod_filters]=LangAOD_brewerNo(data,Cal,varargin)

%
%

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'LangAOD_brewerNo';

% input obligatorio
arg.addRequired('data',@iscell);
arg.addRequired('Cal',@isstruct);

% input param - value
arg.addParamValue('AOD_cfg_custom', [], @(x)isstruct(x));             % default no filter corr

% validamos los argumentos definidos:
arg.parse(data,Cal, varargin{:});


%% defining AOD configuration
fprintf('\nAOD Abs. Cal.: processing Brewer %s\r\n',Cal.brw_name{Cal.n_inst});

% valores por defecto
AOD_cfg.cfgs=1;   
AOD_cfg.airm_rang=[];
AOD_cfg.O3_hday=NaN;
AOD_cfg.AOD_file_filt=''; 
AOD_cfg.AOD_file_I0=''; 
AOD_cfg.cloud_file_filt=''; 
AOD_cfg.cloud_file_I0=''; 
AOD_cfg.F_corr_AOD=[];
AOD_cfg.N_flt=5;
AOD_cfg.N_hday=20;      
AOD_cfg.lgl_days=0;
AOD_cfg.date_range=[]; 
AOD_cfg.plots=0;
AOD_cfg.res_filt=1;
AOD_cfg.plot_flag=0;
AOD_cfg.grp_def=@(x) {year(x) weeknum(x)};       

okfields = fields(AOD_cfg);
    
if ~isempty(arg.Results.AOD_cfg_custom)
    flds=fields(arg.Results.AOD_cfg_custom);
    for j=1:length(flds)
        k = strmatch(flds{j}, okfields);
        if isempty(k)
           fprintf('\nError (Unknown AOD cfg. field: %s)\r\n', flds{j});
           return
        else
           AOD_cfg.(flds{j})=arg.Results.AOD_cfg_custom.(flds{j});         
        end
    end
else
    AOD_cfg=AOD_cfg_dfault;
end

%% Analyzing Neutral Density filters non-neutrality
ozone_lgl_dep{Cal.n_inst}=langley_filter_lvl1(data,'plots',AOD_cfg.plots,...
                                               'airmass',AOD_cfg.airm_rang,...
                                               'O3_hday',AOD_cfg.O3_hday,...
                                               'N_hday',AOD_cfg.N_hday,...
                                               'date_range',AOD_cfg.date_range,...
                                               'lgl_days',0,...
                                               'AOD',AOD_cfg.AOD_file_filt,...
                                               'Cloud',AOD_cfg.cloud_file_filt);

brw_indv_aod_filters = langley_analys_AOD_filter(ozone_lgl_dep,Cal.n_inst,Cal,...
                                                   'res_filt',AOD_cfg.res_filt,'plot_flag',AOD_cfg.plot_flag);

%% statistical filter
% (see e.g. Augustine, J. A., G. B. Hodges, E. G. Dutton, J. J. Michalsky, and C. R. Cornwall (2008), 
% An aerosol optical depth climatology for NOAA’s national surface radiation budget network (SURFRAD), 
% J. Geophys. Res., 113, D11204, doi:10.1029/2007JD009504.)
for slit=1:5
    for filter=1:3
        % AM
       [ax,bx,cx,dx2]=outliers_bp(brw_indv_aod_filters(:,filter+1,slit,AOD_cfg.cfgs),1.5); 
        brw_indv_aod_filters(dx2,filter+1,slit,AOD_cfg.cfgs)=NaN;

        % PM
        [ax,bx,cx,dx2]=outliers_bp(brw_indv_aod_filters(:,filter+5,slit,AOD_cfg.cfgs),1.5); 
        brw_indv_aod_filters(dx2,filter+5,slit,AOD_cfg.cfgs)=NaN;
    end
end
 
%% Time Series
fprintf('\nNeutral Density Correction Factors (I0_corr): Brewer %s\r\n',Cal.brw_name{Cal.n_inst});

corr_slits=NaN*ones(2,5);  
for slit=1:5
    nd0_=cat(1,brw_indv_aod_filters(:,[1 2],slit,AOD_cfg.cfgs),brw_indv_aod_filters(:,[1 6],slit,AOD_cfg.cfgs)); nd0=sortrows(nd0_,1);
    nd3_=cat(1,brw_indv_aod_filters(:,[1 3],slit,AOD_cfg.cfgs),brw_indv_aod_filters(:,[1 7],slit,AOD_cfg.cfgs)); nd3=sortrows(nd3_,1);
    nd4_=cat(1,brw_indv_aod_filters(:,[1 4],slit,AOD_cfg.cfgs),brw_indv_aod_filters(:,[1 8],slit,AOD_cfg.cfgs)); nd4=sortrows(nd4_,1);
    
    figure; ha=tight_subplot(2,1,.048,.1,.075); hold all;
    axes(ha(1)); set(gca,'XTicklabel',[],'box','on','YTickLabelMode','auto'); grid; hold on;
    axes(ha(2)); set(gca,'box','on','YTickLabelMode','auto'); grid; hold on;
    
    % ND#3
    [m_brw,s_brw]=grpstats([nd0(:,1) nd3(:,2)-nd0(:,2)],AOD_cfg.grp_def(nd0(:,1)),{'mean','sem'});
    lmu=sortrows(m_brw,1); lsem=sortrows(cat(2,m_brw(:,1),s_brw(:,2:end)),1);   
    idx=lsem(:,2)==0 | isnan(lsem(:,2)); lsem(idx,:)=[];  lmu(idx,:)=[];  
    axes(ha(1)); [h p]=boundedline(gca,lmu(:,1),lmu(:,2),lsem(:,2),'-k','alpha' ,'transparency', 0.3);
    suptitle(sprintf('ND filters Corr. (Langley, %s - %s): %s, airmass range = [%.2f, %.2f]',...
             datestr(lmu(1,1),22),datestr(lmu(end,1),22),Cal.brw_name{Cal.n_inst},AOD_cfg.airm_rang)); 
    set(p,'Visible','off');
    h=hline(round(median(lmu(:,2))),'-r'); set(h,'LineWidth',2);
    legend(h,sprintf('Slit #%d: ND#3 Corr. = %d',slit,round(median(lmu(:,2)))));
    set(p,'Visible','on');
    corr_slits(1,slit)=median(lmu(:,2));        

    % ND#4: No measurements
    [m_brw,s_brw]=grpstats([nd0(:,1) nd4(:,2)-nd0(:,2)],AOD_cfg.grp_def(nd0(:,1)),{'mean','sem'});
    lmu=sortrows(m_brw,1); lsem=sortrows(cat(2,m_brw(:,1),s_brw(:,2:end)),1);   
    idx=lsem(:,2)==0 | isnan(lsem(:,2)); lsem(idx,:)=[];  lmu(idx,:)=[];  
    axes(ha(2)); [h p]=boundedline(gca,lmu(:,1),lmu(:,2),lsem(:,2),'-k','alpha' ,'transparency', 0.3);
    set(p,'Visible','off');
    h=hline(round(median(lmu(:,2))),'-r'); set(h,'LineWidth',2);
    legend(h,sprintf('Slit #%d: ND#4 Corr. = %d',slit,round(median(lmu(:,2)))));
    set(p,'Visible','on'); linkprop(ha,'XLim');  datetick('x',12,'KeepTicks');
    corr_slits(2,slit)=median(lmu(:,2));
end

% Write results to file
for cf=1:2
    aux=brw_indv_aod_filters(:,:,1,cf);
    for slit=2:5
        aux=cat(2,aux,brw_indv_aod_filters(:,2:end,slit,cf));
    end
    fid = fopen(sprintf('Brewer_LangAOD%d_%s_NDcorr_cfg%d.txt',Cal.Date.cal_year,Cal.brw_str{Cal.n_inst},cf), 'wt'); % Open for writing
    fprintf(fid, strcat('%%Date Slit#1_NDref(AM) Slit#1_ND#3(AM) Slit#1_ND#4(AM) Slit#1_slope(AM)',...
                               'Slit#1_NDref(PM) Slit#1_ND#3(PM) Slit#1_ND#4(PM) Slit#1_slope(PM)',...
                               'Slit#2_NDref(AM) Slit#2_ND#3(AM) Slit#2_ND#4(AM) Slit#2_slope(AM)',...
                               'Slit#2_NDref(PM) Slit#2_ND#3(PM) Slit#2_ND#4(PM) Slit#2_slope(PM)',...
                               'Slit#3_NDref(AM) Slit#3_ND#3(AM) Slit#3_ND#4(AM) Slit#3_slope(AM)',...
                               'Slit#3_NDref(PM) Slit#3_ND#3(PM) Slit#3_ND#4(PM) Slit#3_slope(PM)',...
                               'Slit#4_NDref(AM) Slit#4_ND#3(AM) Slit#4_ND#4(AM) Slit#4_slope(AM)',...
                               'Slit#4_NDref(PM) Slit#4_ND#3(PM) Slit#4_ND#4(PM) Slit#4_slope(PM)',...
                               'Slit#5_NDref(AM) Slit#5_ND#3(AM) Slit#5_ND#4(AM) Slit#5_slope(AM)',...
                               'Slit#5_NDref(PM) Slit#5_ND#3(PM) Slit#5_ND#4(PM) Slit#5_slope(PM)\n'));
    for i=1:size(aux,1)
        fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n',aux(i,:));
    end
    fclose(fid);
end

%% Print results
displaytable(corr_slits,{'Slit#1','Slit#2','Slit#3','Slit#4','Slit#5'},...
                         12,'.5g',{'Filter corr.#3','Filter corr.#4'}); 

%% Procesamos los langleys individuales
ozone_lgl_dep{Cal.n_inst}=langley_filter_lvl1(data,'plots',AOD_cfg.plots,...
                                               'airmass',AOD_cfg.airm_rang,...
                                               'O3_hday',AOD_cfg.O3_hday,...
                                               'N_hday',AOD_cfg.N_hday,...
                                               'F_corr_AOD',AOD_cfg.F_corr_AOD,...                         
                                               'date_range',AOD_cfg.date_range,...
                                               'lgl_days',AOD_cfg.lgl_days,...
                                               'AOD',AOD_cfg.AOD_file_I0,...
                                               'Cloud',AOD_cfg.cloud_file_I0);
if AOD_cfg.lgl_days
   movefile('loglangley.txt',sprintf('loglangley%s_%d.txt',Cal.brw_str{Cal.n_inst},Cal.Date.cal_year)); 
end

[brw_indv_aod stat_aod] = langley_analys_AOD(ozone_lgl_dep,Cal.n_inst,Cal,...
                                                   'res_filt',AOD_cfg.res_filt,'plot_flag',AOD_cfg.plot_flag);
% Resumen de estadísticas
LangStats_summ(Cal,stat_aod);

%% No cloud data -> statistical filter
for slit=1:5
    % AM
    [ax,bx,cx,dx2]=outliers_bp(brw_indv_aod(:,slit+1,AOD_cfg.cfgs),2.5);
    brw_indv_aod(dx2,slit+1,AOD_cfg.cfgs)=NaN;

    % PM
    [ax,bx,cx,dx2]=outliers_bp(brw_indv_aod(:,slit+6,AOD_cfg.cfgs),2.5);
    brw_indv_aod(dx2,slit+6,AOD_cfg.cfgs)=NaN;
end

%% Bounded plot

fprintf('\nIndividual I0: Brewer %s\r\n',Cal.brw_name{Cal.n_inst});

mixed_brw_indv=cell(1,5);

figure; set(gcf,'Tag',sprintf('Lag%s_bound',Cal.brw_str{Cal.n_inst}));
ha=tight_subplot(5,1,.048,.1,.075); hold all;
axes(ha(1)); set(ha(4),'XTicklabel',[],'box','on','YTickLabelMode','auto'); grid; hold on;
axes(ha(2)); set(gca,'XTicklabel',[],'box','on','YTickLabelMode','auto'); grid; hold on;
axes(ha(3)); set(gca,'XTicklabel',[],'box','on','YTickLabelMode','auto'); grid; hold on;
axes(ha(4)); set(gca,'XTicklabel',[],'box','on','YTickLabelMode','auto'); grid; hold on;
axes(ha(5)); set(gca,'box','on','YTickLabelMode','auto'); grid; hold on;

for slit=1:5
    axes(ha(slit));
    plot(brw_indv_aod(:,1,AOD_cfg.cfgs),brw_indv_aod(:,slit+1,AOD_cfg.cfgs),'b.',...
         brw_indv_aod(:,1,AOD_cfg.cfgs),brw_indv_aod(:,slit+6,AOD_cfg.cfgs),'r.');

    mixed_brw_indv_=cat(1,brw_indv_aod(:,[1 slit+1],AOD_cfg.cfgs),brw_indv_aod(:,[1 slit+6],AOD_cfg.cfgs));
    mixed_brw_indv{slit}=sortrows(mixed_brw_indv_(~isnan(mixed_brw_indv_(:,2)),:),1);
    dates=cell2mat(Cal.events_raw{Cal.n_inst}(:,2)); indx=dates>=brw_indv_aod(1,1) & dates<=brw_indv_aod(end,1);

    [m_brw,s_brw,n_brw]=grpstats(mixed_brw_indv{slit},AOD_cfg.grp_def(mixed_brw_indv{slit}(:,1)),{'mean','sem','numel','std'});
    lmu=sortrows(m_brw,1); lsem=sortrows(cat(2,m_brw(:,1),s_brw(:,2)),1); lstd=sortrows(cat(2,m_brw(:,1),n_brw(:,2)),1);
    boundedline(gca,lmu(:,1),lmu(:,2),lsem(:,2),'-k',lmu(:,1),lmu(:,2),lstd(:,2),'-k','alpha' ,'transparency', 0.3);
    set(gca,'YTicklabel',''); set(gca,'YTicklabelMode','manual','YTicklabel',get(ha(1),'YTick'));
    try
      vl=vline(dates(indx),'r-'); set(vl,'LineWidth',1);
    catch exception
      fprintf('%s, Brewer: %s\n',exception.message,Cal.brw_str{Cal.n_inst});   
    end
end
datetick('x',12,'keeplimits','keepticks');
title(ha(1),sprintf('Langley plot (%s - %s): %s, airmass range = [%.2f, %.2f]',...
      datestr(brw_indv_aod(1,1,AOD_cfg.cfgs),28),datestr(brw_indv_aod(end,1,AOD_cfg.cfgs),28),Cal.brw_name{Cal.n_inst},AOD_cfg.airm_rang));
ylabel(ha(3),'I0');
set(ha(1),'XLim',[brw_indv_aod(1,1,AOD_cfg.cfgs)-5 brw_indv_aod(end,1,AOD_cfg.cfgs)+5]); linkprop(ha,'XLim');

% Write results to file
for cf=1:2
    aux=brw_indv_aod(:,:,cf);
    fid = fopen(sprintf('Brewer_LangAOD%d_%s_cfg%d.txt',Cal.Date.cal_year,Cal.brw_str{Cal.n_inst},cf), 'wt'); % Open for writing
    fprintf(fid, strcat('%%Date Slit#1(AM) Slit#2(AM) Slit#3(AM) Slit#4(AM) Slit#5(AM)',...
                               'Slit#1(PM) Slit#2(PM) Slit#3(PM) Slit#4(PM) Slit#5(PM)',...
                               'Slope#1(AM) Slope#2(AM) Slope#3(AM) Slope#4(AM) Slope#5(AM)',...
                               'Slope#1(PM) Slope#2(PM) Slope#3(PM) Slope#4(PM) Slope#5(PM)\n'));
    for i=1:size(aux,1)
        fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',aux(i,:));
    end
    fclose(fid);
end

%% Brewer#157: ETC, Tabla por eventos + meses
data_=cell(1,5);
event_info=getevents(Cal,'grp','month+events');

fprintf('\r\nBrewer %s: ETC''s by slit (month + events average)\r\n',Cal.brw_name{Cal.n_inst});
for slit=1:5
    data_{slit}=meanperiods(mixed_brw_indv{slit}, event_info);
end
aux=NaN*ones(size(data_{1}.m,1),12);
aux(:,[2 4 6 8 10])=cell2mat(cellfun(@(x) x.m(:,2), data_,'UniformOutput',0));
aux(:,[3 5 7 9 11])=cell2mat(cellfun(@(x) x.std(:,2), data_,'UniformOutput',0));
aux(:,1)= data_{1}.m(:,1); aux(:,end)= data_{1}.N(:,end);

% Command-Print
displaytable(aux(:,2:end),{'Slit#1','#1std','Slit#2','#2std','Slit#3','#3std','Slit#4','#4std','Slit#5','#5std','N'},...
             8,'.1f',data_{1}.evnts);
