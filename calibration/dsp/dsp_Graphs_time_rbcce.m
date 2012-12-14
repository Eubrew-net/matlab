function [wv_matrix wv]=dsp_Graphs_time_rbcce(varargin)

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'dsp_Graphs_time_rbcce';

% input param - value,varargin
arg.addParamValue('brw', [157,183,185,201], @isfloat); % por defecto, no control de fechas
arg.addParamValue('date_range',[], @isfloat); % por defecto no depuracion

% validamos los argumentos definidos:
try
  arg.parse(varargin{:}); 
  mmv2struct(arg.Results); 
catch exception
  fprintf('NO INPUT VALIDATION!! %s File: %s, line: %d, brewer: %s\n',...
         exception.message,exception.stack.name,exception.stack.line);
  return    
end

%% Cargar datos
eval('join_setup');
load('..\DSP\dsp_summary.mat');

%%
dsp_info=cell(4,4); 
res=cell(1,4); info=cell(1,4); detail=cell(1,4);
wv_matrix=[];%ones(1,27); %cuantos ?

indx=1; dd_base=1:365;
for  idx=brw
  brwi= find(Cal.brw==idx);

  if isempty(date_range)
     yr=2006:year(now);     dd=cell(length(yr),1); 
     for yy=1:length(yr)
         dd{yy}=1:365;
     end
  else
     dd={};  dat_f=datevec(date_range);  dat_diaj=diaj(date_range);
     yr=dat_f(1,1); dd{1}=dat_diaj(1):365;
     if length(date_range)>1
        yr=yr:dat_f(2,1);  
        for gr=2:length(yr)
            if gr==length(yr)
               dd{gr}=1:dat_diaj(2);
            else
               dd{gr}=dd_base;
            end
        end
     end
  end      
  
  for yid=1:length(yr)
      yar=yr(yid);
   for datei=dd{yid}
      try
        [info_,res_,detail_ salida_]=dsp_look(Cal.brw(brwi),datei+datenum(yar,1,1),dsp_summary);
        
        info_date=cat(2,dsp_info{:,1});
        
        if isempty(info_date) || ~any(info_date==info_)
            dsp_info{indx,1}=info_;
            dsp_info{indx,2}=res_;
            dsp_info{indx,3}=detail_;
            %result
            res{indx,brwi}=res_;
            info{indx,brwi}=info_;
            detail{indx,brwi}=detail_;    
            salida{indx,brwi}=salida_;    
            % cal_step detail es el elemento penúltimo.
            % date Brw idx wl_0 wl_2 wl_3 wl_4 wl_5 wl_6 fwhm_0 fwhm_2 fwhm_3 fwhm_4 fwhm_5 fwhm_6 cal_ozonepos ozonepos o3_0 o3_2 o3_3 o3_4 o3_5 o3_6
            wv_matrix.QUAD(indx,:)=[info_,brwi,indx,salida_.QUAD{end-1}.thiswl,salida_.QUAD{end-1}.fwhmwl/2,...
                               salida_.QUAD{end-1}.cal_ozonepos,salida_.QUAD{end-1}.ozone_pos,salida_.QUAD{end-1}.o3coeff];             
            wv_matrix.CUBIC(indx,:)=[info_,brwi,indx,salida_.CUBIC{end-1}.thiswl,salida_.CUBIC{end-1}.fwhmwl/2,...
                               salida_.CUBIC{end-1}.cal_ozonepos,salida_.CUBIC{end-1}.ozone_pos,salida_.CUBIC{end-1}.o3coeff];             
%             wv.res(:,:,indx)=NaN*ones(size(res_,1),size(res_,2)+1); wv.res(:,2:end,indx)=res_(:,:,1); wv.res(:,1,indx)=repmat(info_,size(res_,1),1);
%             wv.detail(:,:,indx)=NaN*ones(size(res_,1),size(res_,2)+1); wv.res(:,2:end,indx)=res_(:,:,1); wv.res(:,1,indx)=repmat(info_,size(res_,1),1);
            wv.salida_QUAD{indx}=salida_.QUAD; wv.salida_CUBIC{indx}=salida_.CUBIC; wv.info{indx}=info_;
                           
            indx=indx+1;                               
        end
       
      catch exception
            fprintf('Error in dsp_look: year %d, Brewer %d, index %d\n File: %s, line: %d, brewer: %s\n',...
                               yar,brwi,indx,exception.message,exception.stack.name,exception.stack.line);
      end
   end
 end
 disp(Cal.brw(brwi));  
end

%%
lamda_nominal=[3032.06 3063.01 3100.53 3135.07 3168.09 3199.98];% from dsp_report
for ii=brw            
  i= find(Cal.brw==ii);
  jx=find(wv_matrix.QUAD(:,2)==i);
  figure; set(gcf,'Tag','Wavelength');
  plot(wv_matrix.QUAD(jx,1),matadd(wv_matrix.QUAD(jx,4:9),-lamda_nominal),'*');% mean(wv_matrix.QUAD(1:5,4:9),1) 
  ylabel('Wavelengh - Nominal wavelength (A)');
  title(sprintf('%s\n Nominal Wl(A): %s',Cal.brw_name{i},num2str(lamda_nominal))); % round(mean(wv_matrix.QUAD(jx,4:9),1)*10)/10
  legend(mmcellstr(sprintf(' Slit%01d|',[0,2:6])),'Location','SouthWest');
  datetick('x',12,'KeepLimits','KeepTicks'); grid;  lh=hline([0.1,-0.1]); set(lh,'LineWidth',2);

  figure; set(gcf,'Tag','FWHM');
  plot(wv_matrix.QUAD(jx,1),matadd(wv_matrix.QUAD(jx,10:15),-mean(wv_matrix.QUAD(jx,10:15),1)),'*')
  ylabel('FWHM - mean (FWHM), (A)');
  title([Cal.brw_name{i},'. Mean FWHM (A): ',num2str(round(mean(wv_matrix.QUAD(jx,10:15),1)*100)/100)])
  legend(mmcellstr(sprintf(' Slit%01d|',[0,2:6])));
  datetick('x',12,'KeepLimits','KeepTicks'); grid;  lh=hline([0.05,-0.05]); set(lh,'LineWidth',2);
end
      