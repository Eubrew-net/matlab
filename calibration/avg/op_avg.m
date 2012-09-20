% plotea el fichero OPAVG
% Isa, modificado del de Juanjo dt Juanjo 02/11/2009
%% Modificaciones
%  añandido flag de depuracion;


%%
function opa=op_avg(file,varargin)

% Validamos argumentos
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'op_avg';

% input obligatorio
arg.addRequired('file');

% input param - value
arg.addParamValue('ref',NaN,@isfloat);% por defecto no depuracion
arg.addParamValue('outlier_flag','',@(x)(any(strcmp(x,'op')) || isempty(x)));% por defecto no depuracion
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas

% validamos los argumentos definidos:
arg.parse(file, varargin{:});


try
    a= textscan(fopen(file,'rt'),'%s%f%s%s%s%s%d%d%d%s%f%f%d%f%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%s%s%s%s','delimiter',',');
    a{1,9}=a{1,9}+2000;
    f=[a{1,9} a{1,8} a{1,7}];
    %     a{35}= Hora
    fhn=datenum(double(f(:,1:3)))+datenum(a{:,35})-datenum('00:00:00');
    fh= datestr(datenum(double(f(:,1:3)))+datenum(a{:,35})-datenum('00:00:00'));
catch
    disp(file);
    aux=lasterror;
    disp(aux.message)
end

%   op=[a{1} a{2} a{3} a{4} a{5} a{6} a{7} a{8} a{9} a{10} a{11} a{12} a{13} a{14} a{15} a{16} a{17} a{18} a{19} a{20} a{21} a{22} a{23} a{24} a{25} a{26} a{27} a{28} a{29} a{30} a{31} a{32} a{33} a{34} a{35}];
op=[fhn a{14} a{15} a{16} a{17}];
%     a{14}= TE% Voltage representation of Brewer temperature
%     a{15}= NC% Azimuth north correction
%     a{16}= HC% Zenith horizont correction
%     a{17}= SR% Azimut steps per revolution.


if ~isempty(arg.Results.date_range)
    try
        opa=op(op(:,1)>arg.Results.date_range(1),:);
        if length(arg.Results.date_range)>1
            opa=opa(opa(:,1)<arg.Results.date_range(2),:);
        end
    catch
        disp('error de seleccion de fecha');
    end
    if isempty(opa)
        opa=op;
    end
else
    opa=op;
end




% OUTLIERS
% if ~isempty(arg.Results.outlier_flag)
%     % outliers NC
%     [ax,bx,cx,dx1]=outliers_bp(opa(:,3),3);
%     disp(opa(dx1,[1,3]))
%
%     % outliers HC
%     [ax,bx,cx,dx2]=outliers_bp(opa(:,4),3);
%     disp(opa(dx2,[1,4]))
% end


% r=figure; set(r,'Tag','OPAVG');
% s=mmplotyy(opa(:,1),opa(:,3),'.b',opa(:,4),'.k');
% % Izqu:North correcion (b)
% % Der: Horinzont (k)
% hold on
% s=plot(opa(dx1,1),opa(dx1,3),'+r')
% s=plot(opa(dx2,1),opa(dx2,4),'+r');
% hold off
% set(gca,'XLim',[arg.Results.date_range(1)-4 op(end,1)+4]);
% % set(gca,'XLim',[op(1,1)-4 op(end,1)+4]);
% grid;
% datetick('x',25,'keeplimits','keepticks');
% rotateticklabel(gca,20);
% ylabel('North correction');
% sup=suptitle(sprintf('%s%s','Op Test, ',file(regexp(file,'AVG')-2:regexp(file,'AVG')+6)));
% pos=get(sup,'Position');




% if ~isempty(dx1)
%     % outliers NC
%     opa(dx1,3)=NaN;
% end
% if ~isempty(dx2)
%     % outliers HC
%     opa(dx2,4)=NaN;
% end

r=figure; set(r,'Tag','OPAVG');
s=mmplotyy(opa(:,1),opa(:,3),'.b',opa(:,4),'.k');
set(s,'LineWidth',3)
s=mmplotyy('Horizont correction (black dots)');
set(s,'FontWeight','bold');
% Izqu:North correcion (b)
% Der: Horinzont (k)
set(gca,'XLim',[arg.Results.date_range(1)-4 opa(end,1)+4]);
% set(gca,'XLim',[op(1,1)-4 op(end,1)+4]);
grid;
datetick('x',25,'keeplimits','keepticks');
rotateticklabel(gca,20);
ylabel('North correction','FontWeight','bold');
sup=suptitle(sprintf('%s%s','Op Test, ',file(regexp(file,'AVG')-2:regexp(file,'AVG')+6)));
set(sup,'FontWeight','bold');
pos=get(sup,'Position');

