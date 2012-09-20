%function [x,r,ab,rp,data]=ratio_min_ozone(a,b,min,name_a,name_b)
% calcula el ratio entre series temporales
% el ratio es respecto a b
% b puede  y a pudede tener varias columnas
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%
% Special Version for ozone measurements
% input argument:  date, ozone,airm, sza,ms9,sms9, temperature, filter

function [outlier,data_out,outlier_idx]=ratio_min_ozone_dep(a,b,n_min,varargin)
% calcula el ratio entre respuestas o lamparas
%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'ratio_min_ozone_dep';

% input obligatorio
arg.addRequired('a'); 
arg.addRequired('b'); 
arg.addRequired('n_min'); 

% input param - value
arg.addParamValue('lim',3, @isfloat); % por defecto, umbral depuracion = 3

% validamos los argumentos definidos:
try
arg.parse(a,b,n_min,varargin{:});
mmv2struct(arg.Results);
chk=1;

catch
  errval=lasterror;
  chk=0;
end

MIN=60*24;

%a(find(a(:,2)<190 | a(:,2)>500),:)=NaN;
%b(find(b(:,2)<190 | b(:,2)>500),:)=NaN;


%n_min=10;
[aa,bb]=findm_min(a(:,1),b(:,1),n_min/MIN);
c=a(aa,1);
data=[c,c-b(bb,1),a(aa,2:end),b(bb,2:end)];
rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];
% dos posibilidades 1 sin temperatura y filtro
if size(b,2)==6;
 osc=data(:,8).*data(:,9);
 sza=data(:,10);
else
 osc=data(:,10).*data(:,11);  % de la referencia
 sza=data(:,12);
end

y=mean_smooth(osc,rp(:,2),0.25);
[outlier.m_,outlier.s_,outlier.r,outlier.idx]=outliers_bp(y(:,5)-rp(:,2),lim); 
outlier_idx=outlier.idx;

data_out=data(outlier.idx,:);    
     
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