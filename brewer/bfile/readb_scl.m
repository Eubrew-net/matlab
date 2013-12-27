function [sc_avg,sc_raw]=readb_scl(path,varargin)
% MODIFICADO:
%  Juanjo 09/02/2011: Redefino los inputs de la función (Chequeada con la sintaxis original)
%                     Obligatorio; path a ficheros B (normalmente bfile)
%                     Otros dos opcionales;
%                       - 'date_range' -> array de uno o dos elementos (fecha matlab)
%                                         Lo interesante es que se aplica al directorio !!
%                       - 'config'     -> Configuracion (por defecto no config)
%
%  Juanjo 09/02/2012: Hasta ahora, si teníamos un un fichero B y el mismo B_dep
%                     leía los dos, sumando ambos. Corregido (sólo lee el dep, si existe)
%
%%%%%%%   VALIDACIÓN DE ARGUMENTOS DE ENTRADA    %%%%%%%%%%%%
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'readb_scl';

% input obligatorio
arg.addRequired('path'); 

% input param - value
% arg.addParamValue('f_plot', 0, @(x)(x==0 || x==1)); % por defecto no ploteo
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('config', '', @ischar); % por defecto, no config

% validamos los argumentos definidos:
try
  arg.parse(path, varargin{:});
  mmv2struct(arg.Results);
  chk=1;
catch % compatibilidad con version original
  errval=lasterror;
  if length(varargin)==2
      config=varargin{1};
      date_range=varargin{2};
  elseif length(varargin)==1
      config=varargin{1};
      date_range=[];
  else
      config='';
      date_range=[];
  end
  chk=0;
end
%%%%%%%   FIN DE VALIDACIÓN   %%%%%%%%%%%%%%%

sc_avg=[];  sc_raw=[];

s=dir(path);
[p,n,e]=fileparts(path);

% Date filter
if ~isempty(date_range)
    dir_cell=struct2cell(s); files=dir_cell(1,:);
    myfunc=@(x)sscanf(x,'%*c%3d%2d.%*d')';
    A=cell2mat(cellfun(myfunc,files, 'UniformOutput', false)');
%                    Año    Dia
    dates=datejuli(A(:,2),A(:,1));    
    s(dates<fix(date_range(1)))=[];    dates(dates<fix(date_range(1)))=[];
    if length(date_range)>1
       s(dates>fix(date_range(2)))=[]; dates(dates>fix(date_range(2)))=[];
    end
end

hf=[]; 
for i=1:length(s)
    [path nam ext]=fileparts(s(i).name);
    if exist(fullfile(p,[nam,'_dep',ext]),'file')
       continue
    end
    file=s(i).name;
    bfile=fullfile(p,file);

    scraw=[];    scavg=[];
    try
        if isempty(config)
            [scavg,scraw]=readb_sc(bfile);
        else            
            if isinteger(diff(date_range))
               [scavg,scraw]=readb_sc(bfile,config);
            else
               [scavg,scraw]=readb_sc(bfile,config,date_range);               
            end
        end
        sc_avg=[sc_avg;scavg];
        sc_raw=[sc_raw;scraw];

        if ~isempty(scraw )
              disp(['OK->',file]);
%         else
%             
%             disp(['NOSC->',s(i).name]);
        end
        %if ~isempty(scraw )
          
            %             medida=fix(scraw(:,2)/100);
%             for ii=1:size(scavg,1),
%                 h=figure;
%                 hf=[hf,h];
%                 sc_=scraw(medida==ii,:);
%                 sca=scavg(ii,:);
%                 %subplot(3,2,mod(i,6)+1);
%                 polyplot2(sc_(:,3),sc_(:,18));
%                 % polyplot2(sc_(:,3),sc_(:,18).*sc_(:,8));
% 
%                 title({' ',' ',...
%                     sprintf(' airm=%.2f  filter=%d ozone=%.1f  step=%.0f \\Delta hg step=%.1f ',sca(1,[8,9,11,10,21])),...
%                     ['y=',poly2str(round(sca(18:20)*100)/100),'',sprintf(' normr=%.1f',sca(1,17))]});
%                 suptitle([ s(i).name,'  ',datestr(sca(1,1))]);
%                 xlabel('step');
%                 ylabel('ozone');
%             end
%         end

    catch exception
        fprintf('%s (Bfile %s) File/Line: %s/%d\n',exception.message,file,exception.stack(1).name,...
                                                             exception.stack(1).line);
    end
end

% 
% for i=hf
%     h=figure(i);
%     save2word('sc_report_plot.doc');
%     close(h);
% end
% 

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
