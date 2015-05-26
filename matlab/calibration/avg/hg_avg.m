% plotea el fichero HGOAVG
% Isa, modificado del de Juanjo rs Juanjo 02/11/2009
%% Modificaciones
%  añandido flag de depuracion;
% 28/10/2010 Isabel  Comentados:
%     disp('OUTLIERS HG');
%     disp(datestr(hga(dx,1)))
% 12/11/2010 Isabel  Introducido nuevo output para los outliers.
% 06/2015 ALBERTO Added severall columns


%%
function [hga,OutHG]=hg_avg(file,varargin)

% Validamos argumentos
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'hg_avg';
% Input obligatorio
arg.addRequired('file');
% Input param - value
arg.addParamValue('outlier_flag','',@(x)(any(strcmp(x,'hg')) || isempty(x)));% por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
% Validamos los argumentos definidos:
arg.parse(file, varargin{:});
%%
a2=[];
try
    a=textread(file,'');
catch
    try
        [a,a2]=read_avg_line(file,[4,7]);
        if ~isempty(a2)
            a=[a;a2(:,1:4)];
        end
    catch
        disp(file);
        aux=lasterror;
        disp(aux.message)
        return;
    end
end
% Only time, Intensity and Temperature
hg=avgfech(a);      hga=hg(:,[1,4,5:end-1]);       hga_=hga;
if ~isempty(arg.Results.date_range)
    try
        hga_=hga(hga(:,1)>arg.Results.date_range(1),:);
        if length(arg.Results.date_range)>1
            hga_=hga_(hga_(:,1)<arg.Results.date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
    if isempty(hga_)
        hga_=hga;
    else hga=hga_;
    end
end
%% OUTLIERS
if ~isempty(arg.Results.outlier_flag)
    % outliers Lamp I
    [ax,bx,cx,dx]=outliers_bp(hga(:,2),3);
    %     disp('OUTLIERS HG');                     disp(datestr(hga(dx,1)))
    %     hgad=hga(dx,2);
    %     disp(hga(dx,[1,2]));
else
    dx=[];
end
%%
f=figure;                                         set(f,'Tag','HGOAVG');
h=mmplotyy(hga(:,1),hga(:,2),'.g',hga(:,3),'.k'); set(h,'LineWidth',2.5)
h=mmplotyy('Temperature(black dots)');            set(h,'FontWeight','bold');  hold on
h=plot(hga(dx,1),hga(dx,2),'+r');                 set(h,'LineWidth',2.5);      hold off
% Izqu:Lamp Intensity (g)
% Dcha:Temp (k)
set(gca,'XLim',[arg.Results.date_range(1)-4 hga(end,1)+4]);                    grid;
datetick('x',25,'keeplimits','keepticks');        rotateticklabel(gca,20);
ylabel('Lamp Intensity','FontWeight','bold');
sup=suptitle(sprintf('%s%s','Hg Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(sup,'FontWeight','bold');                     pos=get(sup,'Position');
if ~isempty(dx)
    % outliers Lamp I
    hga(dx,2)=NaN;


f2=figure;                                        set(f,'Tag','HGOAVGOut');
h2=mmplotyy(hga(:,1),hga(:,2),'.g',hga(:,3),'.k');
h=mmplotyy('Temperature  (black dots)');           set(h,'FontWeight','bold');
% Izqu:Lamp Intensity (g)
% Dcha:Temp (k)
set(h2,'LineWidth',2.5)             
set(gca,'XLim',[arg.Results.date_range(1)-4 hga(end,1)+4]);
grid;  datetick('x',25,'keeplimits','keepticks');
rotateticklabel(gca,20);         ylabel('Lamp Intensity','FontWeight','bold');
sup=suptitle(sprintf('%s%s','HgOut Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(sup,'FontWeight','bold');                      pos=get(sup,'Position');
end
%% Outliers
Jul=(([001:365]')*100)+10;                Fecha=brewer_date(Jul);
MFecha=Fecha(:,1);                        FechaAnual=datestr(MFecha);
OutliersHG =[Fecha(:,1)]; OutliersHG (:,end)=0;  try for i=1:size(dx1,1);  O1=find(Fecha(:,1)==hga(dx1(i),1));  OutliersHG (O1,:) =NaN; end; end
OutHG      =[Fecha OutliersHG];
