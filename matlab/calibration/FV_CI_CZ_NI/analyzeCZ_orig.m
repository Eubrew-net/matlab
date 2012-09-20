
function [RL1 RL2 RL3 AnchoB1 AnchoB2 AnchoB3 Error]=analyzeCZ(path,varargin)
% This function analyze CZ files and gives the response of each one.

% [RL1 RL2 RL3 Error]=analyzeCZ('E:\CODE\aro2010\bdata017\CZ*.017')

%     RL.Columna1='Matlab Data/Time';
%     RL.Columna2='Real wavelength';
%     RL.Columna3='Wavelength obtained with Slope Method';
%     RL.Columna4='Diference Real/SP';
%     RL.Columna5='Wavelength obtained with Masa Center Method';
%     RL.Columna6='Diference Real/MCM';
%     RL.Columna7='Intensity Lmax';
%
%%  TODO: 
%        ¿Es necesario pasarle el nombre CZ?
% 
%%  MODIFICADO:
%  22/07/2010 Isabel: Añadido nombre de Brewer a la gráfica.
%
%  10/08/2010 Juanjo: Retocados los ploteos para hacerlo acorde al resto del report de calibración
% 
%  13/08/2010 Juanjo: Modificado el control de inputs. Ahora se hace uso de clase inputParser. 
%                     Obligatorios: path. 
%                     Opcionales: date_range. Por defecto date_range=[]. Se requiere brewer_date.m
%                     Se muestran al final del script los parametros que
%                     han tomado un valor por defecto.
%                     Ya no es necesario trabajar desde el directorio donde se hallan los
%                     ficheros CZ. En cualquier caso funciona de esa manera

%  20/10/2010 Isabel: Salen las 3 gráficas para las 3 longitudes de onda (2967,3022,3341).
%                     Pero en lugar de salir 3, sale sólo 1 con los datos
%                     de las longitudes 2967 y 3341

%  26/10/2010 Isabel: Se muestran los ficheros de error
%                     Modificados titulos y ejes para que aparezcan en
%                     negrita
%                     Se comenta el display del error y CZFiles=dir(path);
%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'analyzeCZ';

% input obligatorio
arg.addRequired('path'); 

% input param - value,varargin
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas

% validamos los argumentos definidos:
try
arg.parse(path, varargin{:});
mmv2struct(arg.Results);
chk=1;
catch
  errval=lasterror;
  chk=0;
end

%% CZ FILES    
CZFiles=dir(path);
FilesCZ=[]; FilesCZ_m=[];
for i=1:length(CZFiles)
    FilesCZ=[FilesCZ;cellstr(CZFiles(i,1).name)];
    FilesCZ_m=[FilesCZ_m;brewer_date(str2num(CZFiles(i).name(3:end-4)))];    
end
if isempty (FilesCZ)
    warning ('No CZ Files');
end

% control de fechas
if ~isempty(date_range)
   indx=FilesCZ_m(:,1)<date_range(1); 
   FilesCZ(indx)=[]; FilesCZ_m(indx,:)=[];
   if length(date_range)>1
      indx=FilesCZ_m(:,1)>date_range(2);
      FilesCZ(indx)=[]; FilesCZ_m(indx,:)=[];
   end
   
if isempty(FilesCZ)
    disp('No files in date range');
    datestr(date_range);
    return;
end
   
end
%% DEFINING VARIABLES
RL1=[]; 
RL2=[]; 
RL3=[];
AnchoB1=[];
AnchoB2=[];
AnchoB3=[];
Inf=[]; 
Error=[];
pathstr=fileparts(path);

%     RL.Columna1='Matlab Data/Time';
%     RL.Columna2='Real wavelength';
%     RL.Columna3='Wavelength obtained with Slope Method';
%     RL.Columna4='Diference Real/SP';
%     RL.Columna5='Wavelength obtained with Masa Center Method';
%     RL.Columna6='Diference Real/MCM';
%     RL.Columna7='Intensity Lmax';



%% LMAX FUNCTION

for i=1:length(FilesCZ)
    
% spec.Column1='Time (GTM)';
% spec.Column2='Wavelength (Ang)';
% spec.Column3='Step number';
% spec.Column4='Raw Counts';
% spec.Column5='Counts/Second';
    
    try
        [spec FH]=ReadCZ(fullfile(pathstr,FilesCZ{i}));
        [L1 L2 L3 AB1 AB2 AB3]= Lmax(spec,FH);
        RL1=[RL1;L1];
        RL2=[RL2;L2];
        RL3=[RL3;L3];
        AnchoB1=[AnchoB1;AB1];
        AnchoB2=[AnchoB2;AB2];
        AnchoB3=[AnchoB3;AB3];
    
%         if  exist ('Warning')
%             EWarning=[EWarning;FilesCZ{i}];
%         end
    catch
        Error=[Error;FilesCZ{i}];
    end
end
% display (Error)

%% WARNINGS

if isempty(RL1) && isempty(RL2) && isempty(RL3)
    warning('Standard Lamp')
end

if ~isempty(Error) 
    E=cellstr(Error);
end

 
% If there is something wrong look for the file.
% find(RL1(:,1)==734190.9004444445)
% datestr(734190.9004444445)
% julianday(734190.9004444445)= 52
% [GRT FH]= ReadCZ('CZ05210.201')


%% 2D GRAPHS
    
if ~isempty(L1)
    RL=RL1; l=2967; AnchoB= [AnchoB1 RL(:,1)];
elseif ~isempty(L2)
    RL=RL2; l=3020; AnchoB= [AnchoB2 RL(:,1)];
else ~isempty(L3)
    RL=RL3; l=3341; AnchoB= [AnchoB3 RL(:,1)];
end

try
    figure;  set(gcf,'Tag','CZ_Report');
    subplot(3,1,1:2)
    plot(RL(:,1),RL(:,4),'ro',RL(:,1),RL(:,6),'gs');
    set(gca,'YLim',[-0.6 0.6],'XTicklabel',[],'GridLineStyle','-.','Linewidth',1);
    ylabel('Diff.  (A)','FontWeight','bold');
    pos=get(gca,'YLim');
    sup=suptitle(sprintf('%s%s','CZ files, Brw#',FilesCZ{end}(end-2:end))); set(sup,'Position',[0.50,-0.1,0]);
    set(sup,'FontWeight','bold');
    if size(RL,1)>1
    text(RL(end-1,1),pos(2),sprintf('Ref. Line: %s A',num2str(l)),'BackgroundColor','w','HorizontalAlignment','center');
    end
    grid; legend ('Slope method 2967.28 A','Center of Mass method 2967.28 A',...
                  'Location','NorthOutside','Orientation','Horizontal');   legend('boxoff');

    try
        hold on
        plot(RL3(:,1),RL3(:,4),'r*',RL3(:,1),RL3(:,6),'gp');
        legend ('Slope method 2967.28 A','Center of Mass method 2967.28 A',...
                'Slope method 3341.48 A','Center of Mass method 3341.48 A',...
                'Location','NorthOutside','Orientation','Horizontal');
        hold off
         text(RL1(end-1,1),pos(2),'Ref. Line \equiv 2967.28 A and 3341.48 A','BackgroundColor','w','HorizontalAlignment','center');      
    end
     hline([-0.13 0.13],{'k','k'}); 
    
    subplot(3,1,3)
    plot(AnchoB(:,2),AnchoB(:,1),'om');
    set(gca,'YLim',[5 7],'GridLineStyle','-.','Linewidth',1);
    ylabel('FWHM (A)','FontWeight','bold');
    grid;
    try
        AnchoB3= [AnchoB3 RL3(:,1)];
        hold on
        plot(AnchoB3(:,2),AnchoB3(:,1),'oy');
    end
    datetick('x',25,'keeplimits','keepticks') ;
    hline(6.5,'-k');
end



%% Para los simples
% try
%     sup=suptitle(sprintf('%s%s','CZ Report, ',FilesCZ{end}(regexp(FilesCZ{end},'5')+4:regexp(FilesCZ{end},'5')+6)));
%     pos=get(sup,'Position');
% end


% try
%     figure;
%     % subplot(3,1,2)
%     Q=plot(RL2(:,1),RL2(:,4),'co',RL2(:,1),RL2(:,6),'ms');
%     datetick('x',25,'keeplimits','keepticks') ;
%     rotateticklabel(gca,20);
%     grid;
%     legend ('R3022-MP','R3022-CM',2)
%     xlabel('Fecha/Hora');
%     ylabel('Diferencia');
% end
% 
% try
%     figure;
%     % subplot(3,1,3)
%     R=plot(RL3(:,1),RL3(:,4),'yo',RL3(:,1),RL3(:,6),'ks');
%     datetick('x',25,'keeplimits','keepticks') ;
%     rotateticklabel(gca,20);
%     grid;
%     legend ('R3341-MP','R3341-CM',2)
%     xlabel('Fecha/Hora');
%     ylabel('Diferencia');
%     hold off
% end


%% 
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

end 
