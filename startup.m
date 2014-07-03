% check externals 
% matlabpath(['c:\gordon\lib\matlab;' matlabpath]);
% libary isuses in mac
setenv('DYLD_LIBRARY_PATH','');

global lotus_date
global lat_izo
global long_izo
global lat_sco
global long_sco

global Meses
global Month_str
c=fix(clock);

%diary(datestr(date));
lotus_date=datenum(1899,12,30);
format compact;
format shortG;
long_izo =-0.287968563;
lat_izo=0.494084967;
lat_sco=0.496939356;
long_sco=-0.283569946;

Meses = ['Ene';'Feb';'Mar';'Apr';'May';'Jun';'Jul';
        'Ago';'Sep';'Oct';'Nov';'Dic'];
 Mes_diaj = [ 1    32    60    91   121   152   182   213   244   274 ...
     305   335 365];
Month_str = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';
        'Aug';'Sep';'Oct';'Nov';'Dic'];
Markers=['+';'o';'.';'*';'d';'p';'x';'s';'h';'^';'>';'<';'v'];

% graficos por defecto
% fuente a 14
set(0,'DefaultfigurePaperType','a4');
set(0,'DefaultfigurePaperUnits','centimeters');
set(0,'DefaultfigureColor',[1,1,1]);
%portrait centered no  fill
%set(0,'DefaultfigurePaperOrientation','portrait');
%set(0,'DefaultfigurePaperPosition',[ 7.45 0.63 19.72 14.79]);
%set(0,'DefaultfigurePaperPosition',[ 0.63 7.45 19.72 14.79]);

%lanscape
 set(0,'DefaultfigurePaperOrientation','landscape');
 set(0,'DefaultfigurePaperPosition',[1.6954 0.63452 26.287 19.715]);
 set(0,'DefaultaxesFontName','Arial');
 set(0,'DefaultTextFontSize',10);
 set(0,'DefaultaxesFontSize',12);
 %set(0,'DefaultaxesColorOrder',[0,0,0;0,0,1;1,0,0;0,0,1;1,0.5,0.5;1,0,1]);

set(0,'DefaultaxesColorOrder',[0,0,0;0,0,1;1,0,0;0,1,0;1,0.5,1;0.5,0,0.5]);
set(0,'DefaultaxesLineStyleOrder', '-o|:x|-|o:|.:|-x|+|:.|:+|:x'); 
%% marker for brewer plot
MK=set(plot(1),'Marker');MK{14}='x';MK(15)=MK(2);MK{16}='p';MK(17)=MK(3);
% 
% blanco y negro%
%set(0,'DefaultaxesColorOrder',[0,0,0;0.25,0.25,0.25]);
%set(0,'DefaultaxesColorOrder',[0,0,0]);
%set(0,'DefaultaxesLineStyleOrder', '-|:|-.|-+|-x|-o|-*|-s|-d|:.|:+|:x|:o|:*');

%eval('cd ..');
%diary(sprintf('%s_%2d%2d',date,c(4),c(5))) 

%opengl autoselect

% set(0,'DefaultFigureWindowStyle','Normal');
% set_figure_toscreen(2)
% set(0,'DefaultFigureWindowStyle','Docked');
%pub.format='latex';
pub.imageFormat='eps' ;
pub.figureSnapMethod='print';% | 'getframe'
pub.useNewFigure=true;
pub.showCode=true;


pwd;