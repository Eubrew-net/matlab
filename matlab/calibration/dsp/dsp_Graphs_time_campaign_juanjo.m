function wv_matrix=dsp_Graphs_time_campaign_juanjo(file_setup,data,fprint)

%
% date Brw idx wl_0 wl_2 wl_3 wl_4 wl_5 wl_6 fwhm_0 fwhm_2 fwhm_3 fwhm_4 fwhm_5 fwhm_6 cal_ozonepos ozonepos o3_0 o3_2 o3_3 o3_4 o3_5 o3_6
%

% Cargar datos
eval(file_setup);   load(data);

%%
idx=0;
for  brwi=1:Cal.n_brw
    if brwi>length(dsp_summary)
        continue
    else
        dsp_s=dsp_summary{brwi};
        if isempty(dsp_s)
           continue
        end
    end
    dsp_s_info=cell2mat(cellfun(@(x) datenum(x,'dd-mmm-yyyy'),dsp_s.info,'UniformOutput',false))';

    if ~isempty(dsp_s_info)
        for indx=1:length(dsp_s_info)
            info=dsp_s_info(indx);
            try
               salida=dsp_s.salida{indx};
            catch exception
               fprintf('%s, brewer: %s\n',exception.message,Cal.brw_name{brwi});
               wv_matrix(brwi+idx,:)=[info,Cal.brw(brwi),indx,NaN,NaN,NaN*ones(1,6),NaN*ones(1,6),NaN*ones(1,6)];
               idx=idx+1; continue
            end
% date Brw idx wl_0 wl_2 wl_3 wl_4 wl_5 wl_6 fwhm_0 fwhm_2 fwhm_3 fwhm_4 fwhm_5 fwhm_6 cal_ozonepos ozonepos o3_0 o3_2 o3_3 o3_4 o3_5 o3_6
            wv_matrix(brwi+idx,:)=[info,Cal.brw(brwi),indx,salida.QUAD{end-1}.thiswl,salida.QUAD{end-1}.fwhmwl/2,...
                                   salida.QUAD{end-1}.cal_ozonepos,salida.QUAD{end-1}.ozone_pos,salida.QUAD{end-1}.o3coeff];             
            idx=idx+1;
        end
    else
        wv_matrix(end+1,:)=NaN*ones(1,23);            
    end
end
wv_matrix(wv_matrix(:,1)==0,:)=[];

%%
lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];% from dsp_report
for i=1:Cal.n_brw                   
  jx=find(wv_matrix(:,2)==Cal.brw(i));
  if isempty(jx)
     continue
  end
  figure
  plot(wv_matrix(jx,1),matadd(wv_matrix(jx,4:4+5),-lamda_nominal),'*');% mean(wv_matrix(1:5,4:9),1) 
  ylabel(' (A) Wavelengh - Nominal wavelength');
  title(sprintf('Brewer %s\n Nominal Wavelenghts (A): %s',Cal.brw_name{i},num2str(lamda_nominal))); % round(mean(wv_matrix(jx,4:9),1)*10)/10
%   plot(wv_matrix(jx,1),matadd(wv_matrix(jx,4:9),-mean(wv_matrix(jx,4:9),1)),'.')
%   ylabel([ ' (A) Wavelengh - mean wavelength (2009-2011)'  ]);
%   title(['Brewer # ',Cal.brw_str{i},'mean wavelenghts (A) ',num2str(round(mean(wv_matrix(jx,4:9),1)*10)/10)])
  legend(mmcellstr(sprintf(' Slit%01d|',[0,2:6])),'Location','SouthWest');
  datetick('x',12,'KeepLimits','KeepTicks'); grid;  lh=hline([0.1,-0.1]); set(lh,'LineWidth',2);

  figure
  plot(wv_matrix(jx,1),matadd(wv_matrix(jx,10:10+5),-mean(wv_matrix(jx,10:10+5),1)),'*')
%   plot(wv_matrix(jx,1),matadd(wv_matrix(jx,10:15),-mean(wv_matrix(jx,10:15),1)),'.')
  ylabel(' (A) FHWM - mean (FHWM)');
  title(['Brewer # ',Cal.brw_name{i},'. Mean FHWM (A): ',num2str(round(mean(wv_matrix(jx,10:15),1)*100)/100)])
  legend(mmcellstr(sprintf(' Slit%01d|',[0,2:6])));
  datetick('x',12,'KeepLimits','KeepTicks'); grid;  lh=hline([0.05,-0.05]); set(lh,'LineWidth',2);
end

%%       
if exist('fprint','var')
   fid=fopen(fullfile(Cal.path_root,'dsp_summ.txt'),'w');
   fprintf(fid,'%%date Brw idx wl_0 wl_2 wl_3 wl_4 wl_5 wl_6 fwhm_0 fwhm_2 fwhm_3 fwhm_4 fwhm_5 fwhm_6 cal_ozonepos ozonepos o3_0 o3_2 o3_3 o3_4 o3_5 o3_6 \n\r');
   for l=1:size(wv_matrix,1)
       fprintf(fid,'%f %d %d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %f %f %f %f %f %f %d %d %7.5f %7.5f %7.5f %7.5f %7.5f %7.5f\n\r',wv_matrix(l,:));
   end
end
fclose all

