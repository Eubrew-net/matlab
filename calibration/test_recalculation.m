function [cal,summary,summary_old]=test_recalculation(Cal,ninst,ozone_ds,A,SL_R,SL_B,varargin)

%% Data recalculation for summaries  and individual observations
% Summaries are recalculated from individual measurements
% * SL corretion
% * HG data filter
% * Generic filter
% * j=find( s(:,2)<=2.5  & m(:,2)> 100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5 );
% * ozone std <=2.5
% * ozone range (100-600)
% * data betwenn two good hg
% * only not interupted observations (n=5)
%  summary datos para la calibracion;
%         date,sza,airm, temp,filter,ozono_r sigma_r  ms9 sm9  ozone_1 sigma_1
%         ozone_sl sigma_sl
% summary  -> ms9 with new configuration
% 6   ozone r  -> config 2
% 9   ozone 1  -> config 1
% 12  ozone sl -> config 2 + sl 
%
%  summary old -> ms9 with original configuration/b file configuration
% 6  ozone r  -> config 1
% 9  ozone 1  -> config 2
% 12  ozone sl -> config 1 +   sl correction 
% TODO: Documentar parametros de entrada
%
%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'test_recalculation';

% input obligatorio
arg.addRequired('Cal');
arg.addRequired('ninst');
arg.addRequired('ozone_ds');
arg.addRequired('A');
arg.addRequired('SL_R');
arg.addRequired('SL_B');

% input param - value
arg.addParamValue('flag_sl', 0, @(x)(x==0 || x==1)); % por defecto no SL corr
arg.addParamValue('FC', [0 0 0 0 0 0], @isfloat); % por defecto, [0 0 0 0 0 0]
arg.addParamValue('plot_sl', 0, @(x)(x==0 || x==1)); % por defecto no plotea

% validamos los argumentos definidos:
try
  arg.parse(Cal,ninst,ozone_ds,A,SL_R,SL_B, varargin{:});
  mmv2struct(arg.Results);  chk=0;
catch exception
  fprintf('NO INPUT VALIDATION!! %s File: %s, line: %d, brewer: %s\n',...
          exception.message,exception.stack.name,exception.stack.line);
  return
end

if ninst>length(ozone_ds) || isempty(ozone_ds{ninst})
   cal=[]; summary=NaN*ones(1,13); summary_old=NaN*ones(1,13); 
   fprintf('No data for Brewer %s\n',Cal.brw_name{ninst});
   return
end
  
  % Si hay dos fechas en el fichero B esto dará error. Manejarlo 
  fecha=cellfun(@(x) unique(fix(x(:,1))),ozone_ds{ninst},'UniformOutput',false);  
  fecha=cat(1,fecha{:});% ficheros cargados con éxito
  if mean(Cal.Date.CALC_DAYS)>1000                                % fecha matlab
     fecha_days=Cal.Date.CALC_DAYS;                               % todos los días considerados
     
  else                                                            % dia juliano
     fecha_days=Cal.Date.CALC_DAYS+datenum(Cal.Date.cal_year,1,0);% todos los días considerados
  end
 
  % Rehacemos ozone_ds para que tenga igual dimensiones que SL_B, esto es, length(CALC_DAYS)
  % Es importante para garantizar que cada dia de SL_B (con dimensiones las de cALC_DAYS)  
  % se corresponde con la fecha de ozono
  d_=length(Cal.Date.CALC_DAYS);
  ozone=num2cell(repmat(NaN*ones(1,21),d_,1),2);  % 21 para cuando hay SL pero no ozono (p/e LAB)
  idx=ismember(fecha_days,fecha);
  ozone(idx)=ozone_ds{ninst}; 
   
%%
if ~isempty(fecha)

    if flag_sl       
       % SL correction
       RC_new=(SL_R.new(:,ninst+1)-SL_B.new(:,ninst+1))./(A.new(:,ninst+1)*10);
       RC_old=(SL_R.old(:,ninst+1)-SL_B.old(:,ninst+1))./(A.old(:,ninst+1)*10);

      if plot_sl
       figure;
         plot(SL_R.new(:,1),matadd(SL_R.new(:,ninst+1),-SL_B.new(:,ninst+1)),'og');
         hold on; plot(SL_R.old(:,1),matadd(SL_R.old(:,ninst+1),-SL_B.old(:,ninst+1)),'*r');
         set(gca,'YLim',[-20 20]); grid;  datetick('x',2,'Keeplimits','Keepticks');
         title(sprintf('SL correction applied, daily median (Ylimit fixed to [-20 20])\r\n Brewer %s',Cal.brw_name{ninst}));
         legend({'SL ref New','SL ref Old'});
      end 
       ozo_c=cellfun(@(x,y) x(:,15)+y./x(:,5),ozone,num2cell(RC_new),'UniformOutput',false);
       ozo_o=cellfun(@(x,y) x(:,8)+y./x(:,5),ozone,num2cell(RC_old),'UniformOutput',false);       
    else
       % no SL correction
       ozo_c=cellfun(@(x) x(:,15),ozone,'UniformOutput',false);
       ozo_o=cellfun(@(x) x(:,8),ozone,'UniformOutput',false);
    end    
    idx=cellfun(@(x) fix(x(:,3)/10) ,ozone,'UniformOutput',false);

    % y ahora quitamos las filas con NaN, para que no dé problemas el grpstats
    myf=@(x)size(x,1)==1;  widx=cellfun(myf,idx);  
    idx(widx==1)=[]; ozone(widx==1)=[]; ozo_o(widx==1)=[]; ozo_c(widx==1)=[];
      
    [m,s,n]=cellfun(@(a,b,c,d) grpstats([a(:,[1,4,5,6,7,2,15,21,8]),b,a(:,14),c],d,{'mean','std','numel'}),...
                                      ozone,ozo_c,ozo_o,idx,'UniformOutput',false);  
                                  
    j=cellfun(@(a,b,c) (a(:,5+2)<=2.5 & b(:,5+2)>100 & b(:,5+2)<600 & b(:,5+1)>0 & c(:,5+1)==5),...
                        s,m,n,'UniformOutput',false);
                    
    summary    =cellfun(@(a,b,y) cat(2,a(y,1:5),a(y,5+2),b(y,5+2),a(y,5+3),b(y,5+3),...
                                   a(y,5+4),b(y,5+4),a(y,5+5),b(y,5+5)),m,s,j,'UniformOutput',false);
    summary_old=cellfun(@(a,b,y) cat(2,a(y,1:5),a(y,5+4),b(y,5+4),a(y,5+6),b(y,5+6),...
                                   a(y,5+2),b(y,5+2),a(y,5+7),b(y,5+7)),m,s,j,'UniformOutput',false);
    
    summary=cell2mat(summary);  summary_old=cell2mat(summary_old);

else
    summary=repmat(NaN,1,9);    summary_old=repmat(NaN,1,9);
end

%%  Medidas individuales
% Aplicamos a las medidas individuales los mismos filtros que al recalcular los sumarios
cal=[];
ss=cellfun(@(x) find(x==0),j,'UniformOutput',false);  
[t,l]=cellfun(@(a,b) ismember(a,b),idx,ss,'UniformOutput',false); 


cal_idx=cellfun(@(x) x==0,t,'UniformOutput',false);
%                   time idx_dj idx_group sza airm temp filter ozone ms9 ms9o ozone_corrected
cal=cell2mat(cellfun(@(x,y,z) [x(z,[1,2,3,4,5,6,7,15,14,21]),y(z)],...
                                      ozone,ozo_c,cal_idx,'UniformOutput',false));

if chk
    % Se muestran los argumentos que toman los valores por defecto
  disp('--------- Validation OK --------------') 
  disp('List of arguments given default values:') 
  if ~numel(arg.UsingDefaults)==0
     for k=1:numel(arg.UsingDefaults)
        field = char(arg.UsingDefaults(k));
        value = arg.Results.(field);
        if isempty(value),   value = '[]';   
        elseif isfloat(value), value = num2str(value); end
        fprintf('   ''%s''    defaults to %s\n', field, value);
     end
  else
     disp('               None                   ')
  end
  disp('--------------------------------------') 
end

