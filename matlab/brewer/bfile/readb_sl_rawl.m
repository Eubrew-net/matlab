function [sl_raw,TC,slraw_c]=readb_sl_rawl(path,varargin)
% MODIFICADO:
%  Juanjo 21/01/2011: Redefino los inputs de la función (Chequeada con la sintaxis original)
%                     Obligatorio; path a ficheros B (normalmente bfile)
%                     Otros dos opcionales;
%                       - 'date_range' -> array de uno o dos elementos (fecha matlab)
%                                         Lo interesante es que se aplica al directorio !!
%                       - 'f_plot' -> 1=ploteo, 0=no ploteo 
% 
%  Juanjo 19/04/2011: Si f_plot=1 se plotean los summarios leídos de ficheros B. Dos gráficos:
%                     1) sectores con número de sumarios por día (curiosidad)
%                     2) ploteo de R6 sumario + temperatura sumario
% 
%  Juanjo 10/05/2011: Si existe en bdata### un B*_dep, lo leerá 
% 
%
% Juanjo 14/09/2011: Se añade condicional del tipo if isempty() return 
%                    para salir en caso de no data
%
% Juanjo 22/09/2011: Se añade depurador de ficheros: los ficheros que no cumplan la sintaxis
%                    Bdddyy.### son descartados
% 
% 16/03/2013 Juanjo: Modificado para aceptar diferentes años, siempre con la estructura del
%                    repositorio !! yyyy/bdata###


%%%%%%%   VALIDACIÓN DE ARGUMENTOS DE ENTRADA    %%%%%%%%%%%%
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'readb_sl_rawl';

% input obligatorio
arg.addRequired('path'); 

% input param - value
arg.addParamValue('f_plot', 0, @(x)(x==0 || x==1)); % por defecto no ploteo
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas

% validamos los argumentos definidos:
try
  arg.parse(path, varargin{:});
  mmv2struct(arg.Results);
%   chk=1;
catch % compatibilidad con version original
  errval=lasterror;
  if length(varargin)==2
      plot=varargin{1};
      date_range=varargin{2};
  elseif length(varargin)==1
      plot=varargin{1};
      date_range=[];
  else
      plot=0;
      date_range=[];
  end
%   chk=0;
end
%%%%%%%   FIN DE VALIDACIÓN   %%%%%%%%%%%%%%%

%% FILES search
sl_avg=[]; sl_raw=[]; TC=[];
Bfiles={}; FilesB={}; paths={}; files={}; pat={};

[pathstring f]=fileparts(path); 
if ~isempty(date_range)
    if length(date_range)==2
       DATE=date_range(1):date_range(2); YEAR=unique(year(DATE));
    else
       DATE=date_range(1);               YEAR=unique(year(DATE));
    end
    if length(YEAR)==1
        Bfiles{1}=dir(path);
        dir_cell=struct2cell(Bfiles{1}); FilesB{1}=dir_cell(1,:);
        paths{1}=repmat({pathstring},length(Bfiles{1}),1); 
    else
        for i=1:length(YEAR)
            pathstr=regexprep(pathstring, '\d{4}',num2str(YEAR(i)));
            if isempty(regexp(pathstr, '\d{4}'))
               pathstr=fullfile('..',num2str(YEAR(i)),pathstring);
            end
            Bfiles{i}=dir(sprintf('%s%c%s',pathstr,filesep,f));
            dir_cell=struct2cell(Bfiles{i}); FilesB{i}=dir_cell(1,:);
            paths{i}=repmat({pathstr},length(Bfiles{i}),1);  
        end
    end
    for i=1:length(YEAR)
        files=cat(2,files,FilesB{i});
        pat=cat(1,pat,paths{i});
    end
    FilesB=files; paths=pat;
else
    Bfiles=dir(path);    
    dir_cell=struct2cell(Bfiles); FilesB=dir_cell(1,:);
    paths=repmat({pathstring},length(Bfiles),1);  
end

    myfunc_clean=@(x)regexp(x, '^B\d{5}[.]\d*','ignorecase')';     clean=@(x)~isempty(x); 
    remove=cellfun(clean,cellfun(myfunc_clean,FilesB, 'UniformOutput', false));
    FilesB(~remove)=[];  
    myfunc=@(x)sscanf(x,'%*c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,FilesB, 'UniformOutput', false)');
    if isempty (FilesB)
       disp('No B Files'); 
       sl_raw=NaN; TC=NaN; return
    end
    
% control de fechas
if ~isempty(date_range)
%                  Año    Dia
   dates=datejuli(A(:,2),A(:,1));    
   FilesB(dates<date_range(1))=[]; paths(dates<date_range(1))=[]; dates(dates<date_range(1))=[]; 
   if length(date_range)>1
      FilesB(dates>date_range(2))=[]; paths(dates>date_range(2))=[]; 
   end   
   if isempty(FilesB)
      disp('No B Files in date range'); 
      sl_raw=NaN; TC=NaN; return
   end   
end

%%
textprogressbar('processing sl files: ');

[p n ext]=fileparts(path);
slraw_c=cell(length(FilesB),1);
TC_c=cell(length(FilesB),1);
for i=1:length(FilesB)
    %slraw=[]; TC_=[];
    textprogressbar(100*i/length(FilesB));
    try
      [path nam ext]=fileparts(FilesB{i});
      if exist(fullfile(paths{i},[nam,'_dep',ext]),'file')
         file=fullfile(paths{i},[nam,'_dep',ext]); 
      else
         file=fullfile(paths{i},FilesB{i});
      end      
      [slraw,TC_]=readb_sl_raw(file);
      %sl_raw=[sl_raw;slraw.sl];
      %TC=[TC,[slraw.sls_dep,TC_(3,:)]'];
      slraw_c{i}=slraw.sl;
      TC_c{i}=[slraw.sls_dep,TC_(3,:)]';
      
    catch exception
      fprintf('%s. File %s\n',exception.message, FilesB{i});  
      textprogressbar(i/length(FilesB));
    end
end
sl_raw=cell2mat(slraw_c);
TC=cell2mat(TC_c);
textprogressbar(' sl raw done');

if f_plot
% quesito de frecuencia de SL summaries
figure; t=tabulate(TC(6,:));
p=pie(t(:,2)); title('Num. summaries / per day')
legend(cellstr(num2str(t(t(:,2)~=0,1))));

% SL summary from bfiles ] temperature
TC_plot=reshape(TC,16,size(TC,1)/16);
figure; set(gcf,'Tag','DailySL');
hl1=ploterr(TC_plot(1,:),TC_plot(2,:),[],TC_plot(3,:),'*k'); set(gca,'YLim',[min(TC_plot(2,:)-10) max(TC_plot(2,:)+10)]); 
set(hl1,'LineWidth',2); 
ylabel('SL double ratio MS9');
title(sprintf('Daily means for sl ozone ratio & temperature. Brewer%s\r\n (from bfile sl summaries)',ext(2:end)));
set(gca,'XTickLabels',datestr(get(gca,'XTick'),2));  grid; 
ax(1)=gca; set(ax(1),'Position',[0.1  0.12  0.75  0.72]);% [left bottom width height]
rotateticklabel(gca,30);

ax(2)=axes('Position',get(ax(1),'Position'),...
   'XAxisLocation','top',...
   'YAxisLocation','right',...
   'Color','none','FontSize',10,...
   'XColor','k','YColor','b'); set(ax,'box','off');
hold on; hl2=ploterr(TC_plot(1,:),TC_plot(7,:),[],TC_plot(8,:),'*b');  
set(hl2,'LineWidth',2);  set(gca,'XTicklabels',[],'YLim',[0 40]); 
ylb=ylabel('Temperature','Rotation',-90); pos=get(ylb,'Position'); pos(1)=pos(1)+3;
set(ylb,'Position',pos); 
end

% for i=hf
%     h=figure(i);
%     save2word('sl_report_plot.doc');
%     close(h);
% end
% 

function textprogressbar(c)
% This function creates a text progress bar. It should be called with a 
% STRING argument to initialize and terminate. Otherwise the number correspoding 
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate 
%                       Percentage number to show progress 
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

%% Initialization
persistent strCR;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

%% Main 

if isempty(strCR) && ~ischar(c),
    % Progress bar must be initialized with a string
    error('The text progress must be initialized with a string');
elseif isempty(strCR) && ischar(c),
    % Progress bar - initialization
    fprintf('%s',c);
    strCR = -1;
elseif ~isempty(strCR) && ischar(c),
    % Progress bar  - termination
    strCR = [];  
    fprintf([c '\n']);
elseif isnumeric(c)
    % Progress bar - normal progress
    c = floor(c);
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];
    
    % Print it on the screen
    if strCR == -1,
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end