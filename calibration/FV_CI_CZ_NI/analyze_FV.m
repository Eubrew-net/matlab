function [azimut zenit]=analyze_FV(path,varargin)
%good
%data_out=read_fv('.\bdata157\FV13311.157',1);
%bad
%data_out=read_fv('.\bdata157\FV11711.157',1);
%FV_fit ajusta la medida fv a un trapecio simetrico interpolando entre los
%datos. la parte superior del trapecio es una parbola
%
%                xu(2)->  ++++++++   <-xd(2)
%                        +        +
%                       +          +
%                      +            +
%                     +              +
%      BASE up+++++++ <-xu(1)  xd(1)-> +++++BASE down
%data_aux= cat(1,data_out{:,1})
%Fecha	brewer	azimuth	xm	vmax	step_max	r2_up	r2_dw	r_top	
%xup_base	xup_top	xdw_base	xdw_top	fwhm	A	B	C	b1	c1	b2	c2
%
% 1	Fecha	734637.3592	734637.3736	734637.3792
% 2	brewer	157	157	157
% 3	azimuth	=1 zenit=2
% 4	xm	    maximo de la parabola   17.3453442	17.98439407	17.82481985
% 5	vmax	cuentas maximas usadas para normalizar
% 6	step_max pasos de las cuentas maximas
% 7	r2_up	coeff correlacion de la rampa de subida
% 8	r2_dw	coeff correlacion de la rampa de bajada
% 9	r_top	coeff correlacion de la parabola
% 10	xup_base	corte de la rampa subida en la base (0)
% 11	xup_top	    corte de la rampa subida en la cima (1)
% 12	xdw_base    corte de la rampa bajada en la base (0)
% 13	xdw_tope    corte de la rampa bajada en la cima (1)
% 14	fwhm	ancho del triangulo (ideal)
% 15	A	coeff cuadratico de la parabola
% 16	B	coeff lineal de la parabola
% 17	C	constante de la parabola
% 18	b1	coeff lineal de la base up
% 19	c1	constante de la base up
% 20	b2	coeff lineal de la base dw
% 21	c2	coeff lineal de la base dw
% 
%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'analyze_FV';

% input obligatorio
arg.addRequired('path'); 

% input param - value,varargin
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('analisis_flag', 0, @(x)(x==0 || x==1)); % por defecto no plots detallados (demasiados) 
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1)); % por defecto no plots individuales

% validamos los argumentos definidos:
arg.parse(path, varargin{:});
mmv2struct(arg.Results);

warning('off');

%% FV FILES + date_range
s=dir(path);
if ~isempty(date_range)
    dir_cell=struct2cell(s); files=dir_cell(1,:);
    myfunc=@(x)sscanf(x,'%*2c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,files, 'UniformOutput', false)');
%                    Año    Dia
    dates=datejuli(A(:,2),A(:,1));    
    s(dates<date_range(1))=[];    dates(dates<date_range(1))=[];
    if length(date_range)>1
       s(dates>date_range(2))=[]; dates(dates>date_range(2))=[];
    end
end
if ~isempty(s)
    FilesFV = struct2cell(s); 
    FilesFV = FilesFV(1,:);  
else
    disp('No FV''s'); azimut=[]; zenit=[];
    return
end

%% Lectura 
[pathstr nam ext]=fileparts(path);
aux1=[]; aux2=[];
data_out={};
for i=1:length(FilesFV)
    data_out = read_fv(fullfile(pathstr,FilesFV{i}),analisis_flag);
    aux1=[aux1;cat(1,data_out{:,1})];
    aux2=[aux2;cat(1,data_out{:,2})];    
end

aux1(:,9)=sqrt(aux1(:,9));
%ajuste coordinado
R1=sqrt(prod(aux1(:,7:8),2)).*(~isnan(aux1(:,9)));
R2=sqrt(prod(aux2(:,7:8),2)).*(~isnan(aux2(:,9)));

jok=find(R1>0.95);
dj=unique(fix(diaj2(aux1(:,1))));
if plot_flag
   for ii=1:length(dj)
       figure;
       set(gcf,'Tag',sprintf('FV_Report_%03d',dj(ii)));
       ha=tight_subplot(2,1,.03,[.15 .1],[.08 .05]);
       axes(ha(1))
       plot(diaj2(aux1(:,1)),aux1(:,[4 6]),'.',diaj2(aux1(jok,1)),aux1(jok,[4 6]),'o');
       title(sprintf('FV correction: %03d %s',dj(ii),path));  ylabel('Azimut');
       set(ha(1),'Xlim',[dj(ii)+0.3,dj(ii)+0.8],'XTickLabel','','YLim',[-50 50]); 
       hline([-25 25],'-k',{'-25','25'}); grid
       axes(ha(2))
       plot(diaj2(aux2(:,1)),aux2(:,[4 6]),'.',diaj2(aux2(jok,1)),aux2(jok,[4 6]),'s');
       ylabel('Zenith'); xlabel('Date');
       set(ha(2),'Xlim',[dj(ii)+0.3,dj(ii)+0.8],'YLim',[-10 10]);  hline([-5 5],'-k'); grid
       datetick('x','HH:MM','KeepTicks','KeepLimits');
   end
else
   figure; set(gcf,'Tag','FV_Report');
   ha=tight_subplot(2,1,.03,[.15 .1],[.08 .05]);
   axes(ha(1))
   plot(aux1(:,1),aux1(:,[4 6]),'.',aux1(jok,1),aux1(jok,[4 6]),'o');
   title(sprintf('FV correction: %s',path));  ylabel('Azimut'); set(ha(1),'XTickLabel','');
   set(ha(1),'YLim',[-50 50]);  grid;  hline([-25 25],'-k',{'-25','25'});
   axes(ha(2))
   plot(aux2(:,1),aux2(:,[4 6]),'.',aux2(jok,1),aux2(jok,[4 6]),'s');
   ylabel('Zenith');
   set(ha(2),'YLim',[-10 10]);  grid;  hline([-5 5],'-k');
   datetick('x',2,'KeepTicks','KeepLimits'); 
end
azimut=aux1; zenit=aux2;
