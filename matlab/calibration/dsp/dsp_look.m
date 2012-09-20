function [info res detail salida]=dsp_look(brewer,date,varargin)

% Función que trabaja con la variable dsp_summary. Dada la fecha date,
% busca el test de dispersión más cercano, y devuelve la fecha
% correspondiente y las variables res y detail
% 
% INPUT:
%  - brewer (integer)
%  - date ('yyyy-mm-dd')
% 
% OUTPUT: [info (fecha matlab), res, detail]
% 
% Example: [a b c]=dsp_look(183,'2010-04-30');

if isfloat(date)
    date=datestr(date,'yyyy-mm-dd');
end
if nargin<2
    warning('Debes dar BREWER (integer) & DATE (''yyyy-mm-dd'')');
end

%TODO: ver como sería mejor (donde poner la funcion etc.)
if isempty(varargin)
   load('../DSP/dsp_summary'); % cargamos la variable
else
   dsp_summary=varargin{1}; 
end

switch brewer
    case 157
        dsp_s=dsp_summary{1};
    case 183
        dsp_s=dsp_summary{2};
    case 185
        dsp_s=dsp_summary{3};
    case 201
        dsp_s=dsp_summary{4};
end
fech=sscanf(date,'%d-%d-%d');

% Seleccionamos año
yrdsp=dsp_s.(['yr',num2str(fech(1))]);

% Check for incoherences
if length(yrdsp.info)~=size(yrdsp.res,2) || length(yrdsp.info)~=size(yrdsp.detail,2)
    disp('Los diferentes campos [info,res,detail] no poseen igual nª de elementos');
    return
end

% Buscamos el más cercano a la fecha de interes
fech=datenum(fech'); [noth idx]=min(abs(yrdsp.info-fech));
%disp('Esto es lo que hay: '); datestr(yrdsp.info) 
%disp(sprintf('... y el más próximo al %s se hizo el %s',date,datestr(yrdsp.info(idx))));

% ... y ya lo tenemos
info=yrdsp.info(idx);
res=yrdsp.res{idx};
detail=yrdsp.detail{idx};
salida=yrdsp.salida{idx};
