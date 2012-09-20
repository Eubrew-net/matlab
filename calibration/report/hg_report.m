function hg1 = hg_report(n_inst,hg,Cal,varargin)
% INPUT: celda hg
%      1,        2,      3,       4,        5,           6,        7,    8,    9,      10,        11  
% fecha matlab, hora, minutos, segundos, correlacion, step calc., step, int., temp., step diff, Hg flag
% parametros opcionales
%  n_config: numero de configuracion por defecto n_config=0 usa la matriz o
%  la configuracion 2 (como estaba antes-modificar por confuso)
%  
% OUTPUT: 
%
% Alberto Julio 2011

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'hg_report';

% input obligatorio
arg.addRequired('n_inst'); 
arg.addRequired('hg'); 
arg.addRequired('Cal'); 

% input param - value
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion
arg.addParamValue('n_config', 0, @(x)(x==0 || x==1)); % por defecto no depuracion

% validamos los argumentos definidos:
try
  arg.parse(n_inst,hg,Cal, varargin{:});
  mmv2struct(arg.Results);
  chk=1;
catch
  errval=lasterror;
  chk=0;
end

if n_config==0
[a b c]=fileparts(Cal.brw_config_files{n_inst,2});
if ~isempty(strcat(b,c))
   if strcmp(c,'.cfg')
      config=read_icf(Cal.brw_config_files{n_inst,2},datejuli(Cal.Date.cal_year,Cal.Date.dayend));
   else
      config=read_icf(Cal.brw_config_files{n_inst,2});
   end
else
   config=read_icf(Cal.brw_config_files{n_inst,2});
end
else
   config=read_icf(Cal.brw_config_files{n_inst,n_config});
end
hg_leg={'fecha','hora','minutos','segundos','correlacion',...     
        'step calc', 'step ','hg int','temp','step diff','hg flag'};

%   plot(diaj2(hg1(:,1)),hg1(:,6)-mean(hg1(:,6)),'s')
%   hold on;
%   gscatter(diaj2(hg17(:,1)),hg17(:,6)-mean(hg17(:,6)),hg17(:,9));
%   gscatter(diaj2(hg157(:,1)),hg157(:,6)-mean(hg157(:,6)),hg157(:,9))
  
if ~isempty(hg{n_inst}(1:end))
    hg1=cell2mat(hg{n_inst}(1:end));
else
    return
end

% control de fechas
if ~isempty(date_range)
   hg1(hg1(:,1)<date_range(1),:)=[];
   if length(date_range)>1
      hg1(hg1(:,1)>date_range(2),:)=[];
   end
end

% nos interesa, paso, paso real, diff paso intensidad temperatura
col_p=[6,7,8,10,5,9];

% filtrado de outliers
if outlier_flag==1
    figure; set(gcf,'Tag','Hg_Dep');
%      for ii=1:length(col_p)
% el otro de interquartile:   
%         filtered=[];
%         [s,filtered]=medoutlierfilt_nan(hg1(:,col_p(ii)),1.5,1,0);
%         hg1(:,col_p(ii))=filtered; 

           %  depuración a partir de correlacion
           [params,b,out]=boxparams(hg1(:,5),2.5);
           interquartileRange = params(4)-params(2);
           ha=tight_subplot(2,1,.075,[.1 .085],[.1 .1]);
           axes(ha(1)); plot(hg1(:,1),hg1(:,5),'.','MarkerSize',5);
           set(gca,'Ylim',[0.991 1]);
           hold on;    plot(hg1(out,1),hg1(out,5),'rx','MarkerSize',15);
           ylabel('Correlation'); title(Cal.brw_name{n_inst});
           set(ha(1),'XtickLabel',''); xlim=get(gca,'XLim');
           
           axes(ha(2)); mmplotyy(hg1(out,1),hg1(out,5),'o',hg1(out,10),'x');
           set(gca,'Xlim',[xlim(1),xlim(2)])
           datetick(gca,'x',2,'KeepLimits','KeepTicks')
           hg_dep=hg1(out,:); hg1(out,2:end)=NaN;           
%       end
else
    params=[];
end

figure; ha=tight_subplot(3,1,.075,[.1 .085],[.1 .1]); 
      axes(ha(1));  
      plot(hg1(:,1),hg1(:,6),'*r',hg1(:,1),hg1(:,7),'ko'); set(gca,'FontSize',10);
      hline(config(14),'-k');  hline(config(14)+[-1 0 1] ,'--k');  
      grid; t=title(sprintf('%s (CSN = %d)',hg_leg{6},config(14))); 
      set(t,'FontWeight','Bold','FontSize',12);
      
      axes(ha(2)); 
      plot(hg1(:,1),hg1(:,5),'.');
      if ~isempty(params)
          set(gca,'Ylim',[params(1) params(end)+0.0000001]);%  params=[lowerAdjacentValue lowerQuartile med upperQuartile upperAdjacentValue]
          t=title(sprintf('%s (%f)',hg_leg{5},interquartileRange));
      end
      set(gca,'FontSize',10); grid;  
      set(t,'FontWeight','Bold','FontSize',12);
      l=legend(gca,Cal.brw_name{n_inst},'Location','Best');
      set(l,'TextColor','m','FontSize',12,'FontWeight','Demi');

      axes(ha(3));  
      mmplotyy(hg1(:,1),hg1(:,8),'ko',hg1(:,9),'*r',[5 40]);
      grid; t=title(sprintf('%s (black) & %s (red)',hg_leg{8},hg_leg{9})); 
      set(t,'FontWeight','Bold','FontSize',12);
  
      set(ha(1:2),'XtickLabel','');
      datetick(ha(3),'x',6,'KeepLimits','KeepTicks'); % mm/dd
      xlabel(sprintf('mm/dd(/%d)',Cal.Date.cal_year));

      linkprop(ha,'XLim');

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
        disp(sprintf('   ''%s''    defaults to %s', field, value))
     end
  else
     disp('               None                   ')
  end
  disp('--------------------------------------') 
else
     disp('NO INPUT VALIDATION!!')
     disp(sprintf('%s',errval.message))
end
