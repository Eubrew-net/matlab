function hg1 = hg_report(n_inst,hg,Cal,varargin)
% INPUT: celda hg
%      1,        2,      3,       4,        5,           6,        7,    8,    9,      10,        11  
% fecha matlab, hora, minutos, segundos, correlacion, step calc., step, int., temp., step diff, Hg flag
% parametros opcionales
%  n_config: numero de configuracion por defecto n_config=0 usa la matriz o
%  la configuracion 2 (como estaba antes-modificar por confuso)
%  
% OUTPUT: 
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
arg.addParamValue('n_config', 0, @(x)(x==0 || x==1)); 

% validamos los argumentos definidos:
arg.parse(n_inst,hg,Cal, varargin{:});

%%
if arg.Results.n_config==0
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
hg_leg={'Date','hour','minute','second','correlatio',...     
        'Calc. step', 'Int. step','Intensity','Temp.','Step diff.','hg flag'};

if ~isempty(hg{n_inst}(1:end))
    hg1=cell2mat(hg{n_inst}(1:end));
else
    return
end

% control de fechas
if ~isempty(arg.Results.date_range)
   hg1(hg1(:,1)<arg.Results.date_range(1),:)=[];
   if length(arg.Results.date_range)>1
      hg1(hg1(:,1)>arg.Results.date_range(2),:)=[];
   end
end

% filtrado de outliers
if arg.Results.outlier_flag==1    
   %  depuración a partir de correlacion
   [params,b,out]=boxparams(hg1(:,5),2.5);
   interquartileRange = params(4)-params(2);

   figure; set(gcf,'Tag','Hg_Dep');
   ha=tight_subplot(2,1,.075,[.1 .085],[.1 .1]);
   axes(ha(1)); plot(hg1(:,1),hg1(:,5),'.','MarkerSize',5);
   set(gca,'Ylim',[0.991 1]);
   hold on;    plot(hg1(out,1),hg1(out,5),'rx','MarkerSize',15);
   ylabel('Correlation'); title(Cal.brw_name{n_inst});
   set(ha(1),'XtickLabel',''); 
          
   axes(ha(2)); mmplotyy(hg1(out,1),hg1(out,5),'s',hg1(out,10),'sr');
   ylabel('Correlation'); mmplotyy('Step Diff.');
   linkprop(ha,'XLim');   datetick(gca,'x',2,'KeepLimits','KeepTicks');
   legend('Corr.','Step Diff.','Location','North','Orientation','Horizontal');

   hg1(out,2:end)=NaN;           
else
    params=[];
end

%%
% nos interesa: date, correlatio, calc. step, int. step, intensity, temperature, step diff.
% col_p=[1,5,6,7,8,9,10];

figure; 
p=plot(hg1(:,1),hg1(:,6),'*r',hg1(:,1),hg1(:,7),'ko'); 
set(p,'MarkerSize',4); set(gca,'FontSize',10);
hline(config(14),'-k');  hline(config(14)+[-1 0 1] ,'--k');  
grid; t=title(sprintf('%s: %s (CSN = %d)',Cal.brw_name{n_inst},hg_leg{6},config(14))); 
set(t,'FontWeight','Bold','FontSize',12);
datetick(gca,'x',6,'KeepLimits','KeepTicks'); % mm/dd
      
figure; 
p=patch([min(diff(hg1(:,9))) max(diff(hg1(:,9))) max(diff(hg1(:,9))) min(diff(hg1(:,9)))],...
        [-1 -1 +1 +1],[.93 .93 .93]);
set(p,'LineStyle','None','HandleVisibility','Off');    
hold on; plot(diff(hg1(:,9)),diff(hg1(:,6)),'*k'); grid;  
set(gca,'YTickLabel',get(gca,'YTick'),'XTickLabel',get(gca,'XTick'),'layer','top');
t=title(sprintf('%s: CSN diff. vs Temperature',Cal.brw_name{n_inst})); 
set(t,'FontWeight','Bold','FontSize',12);

figure; 
m=mmplotyy(hg1(:,1),hg1(:,8),'k.',hg1(:,9),'.r',[5 40]);
set(m,'MarkerSize',8); ylabel('Int. (\times10^5)'); grid; 
t=title(sprintf('%s: Hg Intensity vs Temperature',Cal.brw_name{n_inst})); 
set(t,'FontWeight','Bold','FontSize',12);
datetick('x',6,'KeepLimits','KeepTicks'); mmplotyy('Temperature');
