
function [wl fwhm]=analyzeCZ(path,varargin)

% This function analyze Custom Scans files and gives the response of each one.
% 
% OUTPUT
% 
% - wl: Resultados del análisis. Matriz (m,6), siendo m el número total de
%       escanes analizados y las siguientes 6 columnas:
%       'Fecha','wl real','wl, método pendientes','Diferencia','wl, método centro masas','Diferencia','Intensidad Lmax'
% 
% - fwhm:  
%
% MODIFICADO:
%      
% 22/07/2010 Isabel: Añadido nombre de Brewer a la gráfica.
%
% 10/08/2010 Juanjo: Retocados los ploteos para hacerlo acorde al resto del report de calibración
% 
% 13/08/2010 Juanjo: Modificado el control de inputs. Ahora se hace uso de clase inputParser. 
%                    Obligatorios: path. 
%                    Opcionales: date_range. Por defecto date_range=[]. Se requiere brewer_date.m
%                    Se muestran al final del script los parametros que
%                    han tomado un valor por defecto.
%                    Ya no es necesario trabajar desde el directorio donde se hallan los
%                    ficheros CZ. En cualquier caso funciona de esa manera
% 
% 20/10/2010 Isabel: Salen las 3 gráficas para las 3 longitudes de onda (2967,3022,3341).
%                    Pero en lugar de salir 3, sale sólo 1 con los datos
%                    de las longitudes 2967 y 3341
% 
% 26/10/2010 Isabel: Se muestran los ficheros de error
%                    Modificados titulos y ejes para que aparezcan en
%                    negrita. Se comenta el display del error y CZFiles=dir(path);
% 
% 16/03/2013 Juanjo: Modificado para aceptar diferentes años, siempre con la estructura del
%                    repositorio !! yyyy/bdata###. Añadido input opcional plot_flag (default: 1)

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'analyzeCZ';

% input obligatorio
arg.addRequired('path'); 

% input param - value,varargin
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('plot_flag' ,  1, @(x)(x==0 || x==1)); % por defecto, ploteo

% validamos los argumentos definidos:
try
   arg.parse(path, varargin{:});
   mmv2struct(arg.Results);
   chk=1;
catch exception
   fprintf('%s',exception.message);  
   chk=0;
end

%% CZ FILES  
CZFiles={}; FilesCZ={}; paths={}; files={}; pat={};

[pathstring f]=fileparts(path); 
if ~isempty(date_range)
    if length(date_range)==2
       DATE=date_range(1):date_range(2); YEAR=unique(year(DATE));
    else
       DATE=date_range(1);               YEAR=unique(year(DATE));
    end
    if length(YEAR)==1
        CZFiles{1}=dir(path);
        dir_cell=struct2cell(CZFiles{1}); FilesCZ{1}=dir_cell(1,:);
        paths{1}=repmat({pathstring},length(CZFiles{1}),1); 
    else
        for i=1:length(YEAR)
            pathstr=regexprep(pathstring, '\d{4}',num2str(YEAR(i)));
            if isempty(regexp(pathstr, '\d{4}'))
                pathstr=strcat('..\',num2str(YEAR(i)),'\',pathstring);
            end
            CZFiles{i}=dir(sprintf('%s%c%s',pathstr,filesep,f));
            dir_cell=struct2cell(CZFiles{i}); FilesCZ{i}=dir_cell(1,:);
            paths{i}=repmat({pathstr},length(CZFiles{i}),1);  
        end
    end
    for i=1:length(YEAR)
        files=cat(2,files,FilesCZ{i});
        pat=cat(1,pat,paths{i});
    end
    FilesCZ=files; paths=pat;
else
    CZFiles=dir(path);    
    dir_cell=struct2cell(CZFiles); FilesCZ=dir_cell(1,:);
    paths=repmat({pathstr},length(CZFiles),1);  
end

    myfunc_clean=@(x)regexp(x, '^(cz|hl|hs)\d{5}[.]\d*','ignorecase')';     clean=@(x)~isempty(x); 
    remove=cellfun(clean,cellfun(myfunc_clean,FilesCZ, 'UniformOutput', false));
    FilesCZ(~remove)=[];  
    myfunc=@(x)sscanf(x,'%*2c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,FilesCZ, 'UniformOutput', false)');
    if isempty (FilesCZ)
       disp('No CZ Files'); 
       wl={}; fwhm={}; return
    end
    
% control de fechas
if ~isempty(date_range)
%                  Año    Dia
   dates=datejuli(A(:,2),A(:,1));    
   FilesCZ(dates<date_range(1))=[]; paths(dates<date_range(1))=[]; dates(dates<date_range(1))=[]; 
   if length(date_range)>1
      FilesCZ(dates>date_range(2))=[]; paths(dates>date_range(2))=[]; 
   end   
   if isempty(FilesCZ)
      disp('No CZ Files in date range'); 
      wl={}; fwhm={}; return
   end   
end

%% DEFINING VARIABLES 
IT= 0.1147; wb_real=[2967.283,3021.504,3341.484];

%% LMAX FUNCTION
wl=cell(1,3); fwhm=cell(1,3); 
for i=1:length(FilesCZ)        
    try
        data=read_cz(fullfile(paths{i},FilesCZ{i}));   
        spec=cell(1,length(data)); FH=cell(1,length(data));
        for ss=1:length(data)
%       Vamos a rehacer las C/s, por lo del \%
            dark=sscanf(data(ss).info.dark(end-5:end),'%f');
            cycles=data(ss).info.cy;            
            CS= 2* (data(ss).scan(:,4)-dark)/ (cycles*IT);
            spec{ss}=data(ss).scan; spec{ss}(:,5)=CS;        
            
            FH{ss}=datenum([data(ss).info.ano+2000,data(ss).info.mes,data(ss).info.dia]);
            FH{ss}=FH{ss}+nanmean(data(ss).scan(:,1)/(24*60));
        end

        [L1 AB1]= Lmax(spec,FH);
        wl{1}=[wl{1};L1{1}];  wl{2}=[wl{2};L1{2}];  wl{3}=[wl{3};L1{3}];
        fwhm{1}=[fwhm{1};AB1{1}];  fwhm{2}=[fwhm{2};AB1{2}];  fwhm{3}=[fwhm{3};AB1{3}];  
        
    catch exception
         fprintf('%s File: %s, line: %d; %s\n',...
                 exception.message,exception.stack.name,exception.stack.line,FilesCZ{i});
    end   
end

% Break
if all(cellfun(@(x) isempty(x),wl))
    disp('Check which lamp scan''s');
    return
end

%% 2D GRAPHS   
if plot_flag
    wich=find(cellfun(@(x) ~isempty(x),wl)==1);
    if length(wich)>1
    disp('¿Qué Hacer con varias longitudes a la vez? TODO'); 
    wich=1;
    end

    try
        figure; set(gcf,'Tag','CZ_Report');
        subplot(3,1,1:2)
        plot(wl{wich}(:,1),wl{wich}(:,4),'ro',wl{wich}(:,1),wl{wich}(:,6),'gs'); ax(1)=gca;
        set(gca,'YLim',[-.5 .5],'XLim',[min(wl{wich}(:,1)) max(wl{wich}(:,1))],...
                'XTicklabel',[],'GridLineStyle','-.','Linewidth',1);
        ylabel('Diff.  (A)','FontWeight','bold');    
        sup=suptitle(sprintf('%s scan on %7.2f line. Brw#%s',FilesCZ{end}(1:2),...
                     wb_real(wich),FilesCZ{end}(end-2:end))); set(sup,'FontWeight','bold');  
        grid; l=legend('Slope method','Center of mass method','Location','NorthWest','Orientation','Horizontal'); 
        set(l,'FontSize',9);    hline([-0.13 0.13],'-k'); 
    
        subplot(3,1,3)
        plot(wl{wich}(:,1),fwhm{wich}(:,1),'om'); ax(2)=gca;
        set(gca,'YLim',[5 7],'XLim',[min(wl{wich}(:,1)) max(wl{wich}(:,1))],...
                'GridLineStyle','-.','Linewidth',1);
        ylabel('FWHM (A)','FontWeight','bold');  grid; 
        linkprop(ax,{'XLim'}); datetick('x',25,'keeplimits','keepticks');  hline(6.5,'-k');       
                
    catch exception
        fprintf('Error in plot: %s\n',exception.message);
    end
end

%% 
  if chk
      % Se muestran los argumentos que toman los valores por defecto
      disp('--------- Validation OK --------------'); 
      disp('List of arguments given default values:');
      if ~numel(arg.UsingDefaults)==0
         for k=1:numel(arg.UsingDefaults)
             field = char(arg.UsingDefaults(k));
             value = arg.Results.(field);
             if isempty(value),   value = '[]';   
             elseif isfloat(value), value = num2str(value); end
             fprintf('   ''%s''    defaults to %s\n', field, value);
         end
      else
         disp('               None                   ');
      end
      disp('--------------------------------------'); 
  else
      disp('NO INPUT VALIDATION!!');
      fprintf('%s',errval.message);
  end 