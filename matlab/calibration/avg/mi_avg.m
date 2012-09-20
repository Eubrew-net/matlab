% plotea el fichero MIOAVG
% Isa, modificado del de Juanjo dt Juanjo 02/11/2009
%% Modificaciones
%  añandido flag de depuracion;
% 28/10/2010 Isabel  Comentados:
%     disp('OUTLIERS Micrometer steps');
%     disp(datestr(mia(dx1,1)))
%     disp('OUTLIERS Filter wheel steps');
%     disp(datestr(mia(dx2,1)))
% 12/11/2010 Isabel  Introducido nuevo output para los outliers.

%%
function [mia,OutMSFW]=mi_avg(file,varargin)

% Validamos argumentos
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'mi_avg';
% Input obligatorio
arg.addRequired('file');
% Input param - value
arg.addParamValue('ref',NaN,@isfloat);% por defecto no depuracion
arg.addParamValue('outlier_flag','',@(x)(any(strcmp(x,'mi')) || isempty(x)));% por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
% Validamos los argumentos definidos:
arg.parse(file, varargin{:});
%%
try
    a=fileread (file);
    format bank;
    a= sscanf(a,'%f%*c%*c%*c%f%*c%f%*c%f%*c%f%*c%f%*c%f');
    a= reshape(a,7,length(a)/7);
    a= a';
catch
    try
        a= sscanf(a,'%f%*c%*c%*c%f%*c%f%*c%f%*c%f%*c%f%*c%f%*c%f%*c%f%*c');
        a= reshape(a,9,length(a)/9);
        a= a';
    catch
        disp(file);
        aux=lasterror;
        disp(aux.message)
        return;
    end
end
mi=avgfech(a);
if ~isempty(arg.Results.date_range)
    try
        mia=mi(mi(:,1)>arg.Results.date_range(1),:);
        if length(arg.Results.date_range)>1
            mia=mia(mia(:,1)<arg.Results.date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
    if isempty(mia)
        mia=mi;
    end
else
    mia=mi;
end

%% OUTLIERS
if ~isempty(arg.Results.outlier_flag)
    % outliers Micrometer steps
    [ax,bx,cx,dx1]=outliers_bp(mia(:,6),3);
    %     disp('OUTLIERS Micrometer steps');      disp(datestr(mia(dx1,1)))
    %     disp(mia(dx1,[1,6]))
    % Outliers Filter wheel steps..........................................
    [ax,bx,cx,dx2]=outliers_bp(mia(:,8),3);
    %     disp('OUTLIERS Filter wheel steps');    disp(datestr(mia(dx2,1)))
    %     disp(mia(dx2,[1,8]))
end
%%
f=figure;                                           set(f,'tag','MIOAVG');
h=mmplotyy(mia(:,1),mia(:,6),'.c',mia(:,7),'.k');   set(h,'LineWidth',2.5);
h=mmplotyy('Offset constant from ICF');             set(h,'FontWeight','bold');
%Izq:steps to zero (c)
%Der:offset constant from ICF (k)
hold on
h=plot(mia(dx1,1),mia(dx1,6),'+r');                 set(h,'LineWidth',2);
h=mmplotyy('Offset constant from ICF');             set(h,'FontWeight','bold');
hold off
set(gca,'XLim',[arg.Results.date_range(1)-4 mia(end,1)+4]);
datetick('x',25,'keeplimits','keepticks');          rotateticklabel(gca,20);
T=title(sprintf('%s%s','Micrometer Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(T,'FontWeight','bold');
ylabel('Micrometer 1 steps','FontWeight','bold');
grid; orient portrait;

j=figure;                                            set(j,'tag','MIOAVG');
k=mmplotyy(mia(:,1),mia(:,8),'.c',mia(:,9),'.k');    set(k,'LineWidth',2.5);
k=mmplotyy('Offset constant from ICF');              set(k,'FontWeight','bold');
%Izq:steps to zero (c)
%Der:offset constant from ICF (k)
hold on
h=plot(mia(dx2,1),mia(dx2,8),'+r');                  set(h,'LineWidth',2);
h=mmplotyy('Offset constant from ICF');              set(h,'FontWeight','bold');
hold off
set(gca,'XLim',[arg.Results.date_range(1)-4 mia(end,1)+4]);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
T=title(sprintf('%s%s','Micrometer Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(T,'FontWeight','bold');
ylabel('Filter Wheel 3 steps','FontWeight','bold');
grid; orient portrait;

%%
if ~isempty(dx1)
    % Outliers Micrometer steps
    mia(dx1,6)=NaN;
end
if ~isempty(dx2)
    % Outliers Filter wheel steps
    mia(dx2,8)=NaN;
end
%%
f2=figure; set(f,'tag','MIOAVGOut');
h2=mmplotyy(mia(:,1),mia(:,6),'.c',mia(:,7),'.k');    set(h2,'LineWidth',2.5);
h2=mmplotyy('Offset constant from ICF(black dots)');  set(h2,'FontWeight','bold');
%Izq:steps to zero (c)
%Der:offset constant from ICF (k)
set(gca,'XLim',[arg.Results.date_range(1)-4 mia(end,1)+4]);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
T=title(sprintf('%s%s','MicrometerOut Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(T,'FontWeight','bold');
ylabel('Micrometer 1 steps','FontWeight','bold');
grid; orient portrait;

j2=figure; set(j,'tag','MIOAVGOut');
k2=mmplotyy(mia(:,1),mia(:,8),'.c',mia(:,9),'.k');    set(k2,'LineWidth',2.5);
k2=mmplotyy('Offset constant from ICF (black dots)');
set(k2,'FontWeight','bold');
%Izq:steps to zero (c)
%Der:offset constant from ICF (k)
set(gca,'XLim',[arg.Results.date_range(1)-4 mia(end,1)+4]);
datetick('x',25,'keeplimits','keepticks');  rotateticklabel(gca,20);
T=title(sprintf('%s%s','MicrometerOut Test, ',file(regexp(file,'AVG')-3:regexp(file,'AVG')+6)));
set(T,'FontWeight','bold');
ylabel('Filter Wheel 3 steps','FontWeight','bold');   grid; orient portrait;

%% Outliers
Jul=(([001:365]')*100)+10;                Fecha=brewer_date(Jul);
MFecha=Fecha(:,1);                        FechaAnual=datestr(MFecha);
OutliersMS =[Fecha(:,1)]; OutliersMS (:,end)=0;  try for i=1:size(dx1,1);  O1=find(Fecha(:,1)==mia(dx1(i),1));  OutliersMS (O1,:) =NaN; end; end
OutliersFW =[Fecha(:,1)]; OutliersFW (:,end)=0;  try for i=1:size(dx2,1);  O2=find(Fecha(:,1)==mia(dx2(i),1));  OutliersFW (O2,:) =NaN; end; end
OutMSFW    =[Fecha OutliersMS OutliersFW];

