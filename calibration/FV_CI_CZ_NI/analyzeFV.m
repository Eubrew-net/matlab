function [MAXIMOSHT Error]=analyzeFV(path,fplot)
% This function analyze FV files and gives the response of each one

% [MAXIMOSHT_017 Error_017]=analyzeFV('E:\CODE\aro2010\bdata017\FV2*10.017',0);
% [MAXIMOSHT_017 Error_017]=analyzeFV('E:\CODE\aro2010\bdata017\FV2*10.017',1);

%%  MODIFICADO:
%  26/10/2010 Isabel: Modificados titulos y ejes para que salgan en negrita
%                     Se muestran los archivos que dan error
%  26/10/2010 Isabel: Comentados las salidas de las columnas y
%                     FVFiles=dir(path)y display error


% MAXIMOSHT.Column1='MatlabDataTime';
% MAXIMOSHT.Column2='Hours';
% MAXIMOSHT.Column3='Minutes';
% MAXIMOSHT.Column4='Julian day';
% MAXIMOSHT.Column5='I max az';
% MAXIMOSHT.Column6='azimut steps';
% MAXIMOSHT.Column7='Azimut degrees';
% MAXIMOSHT.Column8='I max ze';
% MAXIMOSHT.Column9='zenit steps';
% MAXIMOSHT.Column10='Zenit degrees'

if nargin==1 fplot=0;end


%% FV FILES

FVFiles=dir(path);
FilesFV=[];
for i=1:length(FVFiles)
    Files=cellstr(FVFiles(i,1).name);
    FilesFV=[FilesFV;Files];
end
if isempty (FilesFV)
    warning ('No Files')
end


%% DEFINING VARIABLES

MAXIMOSHT=[];
MAXIMOSHTColum=[];
Error=[];


%% FV FUNCTION

for i=1:length(FilesFV)
    try
        
        [MAXIMOSH]= readFV(fullfile(fileparts(path),FilesFV{i}),fplot);
        MAXIMOSHT=[MAXIMOSHT;MAXIMOSH];
        
    catch
        Error=[Error;FilesFV{i}];
        %ex=lasterror;
        %disp(ex);
    end
end
% display (Error)
%  Covert data into matlab datatime
%  MAXIMOSHT.Column1='Hour';
%  MAXIMOSHT.Column2='Minutes';
%  MAXIMOSHT.Column3='Julian day';

FechaMatlab=brewer_date((MAXIMOSHT(:,3)*100)+10);
HoraMinutos= MAXIMOSHT(:,1)*60 + MAXIMOSHT(:,2);
HoraMinutos= HoraMinutos/60/24;
FHmatlab= (FechaMatlab(:,1)+ HoraMinutos);
MAXIMOSHT=[FHmatlab MAXIMOSHT];


%% PLOT DATA

figure
P=plot(MAXIMOSHT(:,1),MAXIMOSHT(:,6),'rv');
interactivelegend(P,cellstr(FilesFV))
datetick('x',25,'keeplimits','keepticks') ;
grid
xlabel('Time','FontWeight','bold')
ylabel('azimut steps','FontWeight','bold')
legend ('azimut')
T=['Max Az'];
T=title(T);
set(T,'FontWeight','bold');
sup=suptitle(sprintf('%s%s','FV Report, ',FilesFV{end}(regexp(FilesFV{end},'10')+3:regexp(FilesFV{end},'10')+5)));
set(sup,'FontWeight','bold');
% try 
%     sup=suptitle(sprintf('%s%s','FV Report, ',TM{end}(regexp(TM{end},'5')+4:regexp(TM{end},'5')+6)));
% end

figure
P=plot(MAXIMOSHT(:,1),MAXIMOSHT(:,9),'gv');
interactivelegend(P,cellstr(FilesFV))
datetick('x',25,'keeplimits','keepticks') ;
grid
xlabel('Time','FontWeight','bold')
ylabel('zenit steps','FontWeight','bold')
legend ('zenit')
T=['Max Ze'];
T=title(T);
set(T,'FontWeight','bold');
sup=suptitle(sprintf('%s%s','FV Report, ',FilesFV{end}(regexp(FilesFV{end},'10')+3:regexp(FilesFV{end},'10')+5)));
set(sup,'FontWeight','bold');
% try
%     sup=suptitle(sprintf('%s%s','FV Report, ',TM{end}(regexp(TM{end},'5')+4:regexp(TM{end},'5')+6)));
% end



%% PLOT DIFFERENT DAYS DATA US TIME
% !!!!!!!!!!BE CAREFUL WITH THE CHANGES

%  HoraMinutos= MAXIMOSHT(:,1)*60 + MAXIMOSHT(:,2);
%  HoraMinutos= HoraMinutos/60/24;
%  figure
%  P=plot(HoraMinutos(:),MAXIMOSHT(:,5),'rv')
%  interactivelegend(P,cellstr(TM))
%  grid
%  datetick;
%  xlabel('Hora')
%  ylabel('Pasos azimutales')
%  legend ('azimut')
%  T=['Max Az'];
%  title(T)
%  sup=suptitle(sprintf('%s%s','FV Report, ',TM{end}(regexp(TM{end},'10')+3:regexp(TM{end},'10')+5)));
%  try
%      sup=suptitle(sprintf('%s%s','FV Report, ',TM{end}(regexp(TM{end},'5')+4:regexp(TM{end},'5')+6)));
%  end
%
%  HoraMinutos= MAXIMOSHT(:,1)*60 + MAXIMOSHT(:,2);
%  HoraMinutos= HoraMinutos/60/24;
%  figure
%  P=plot(HoraMinutos(:),MAXIMOSHT(:,8),'gv')
%  interactivelegend(P,cellstr(TM))
%  grid
%  datetick;
%  xlabel('Hora')
%  ylabel('Pasos zenitales')
%  legend ('zenit')
%  T=['Max Ze'];
%  title(T)
%  sup=suptitle(sprintf('%s%s','FV Report, ',TM{end}(regexp(TM{end},'10')+3:regexp(TM{end},'10')+5)));
%  try
%      sup=suptitle(sprintf('%s%s','FV Report, ',TM{end}(regexp(TM{end},'5')+4:regexp(TM{end},'5')+6)));
%  end
%

% data2.Column1='MatlabDataTime';
% data2.Column2='Hours';
% data2.Column3='Minutes';
% data2.Column4='Julian day';
% data2.Column5='I max az';
% data2.Column6='azimut steps';
% data2.Column7='Azimut degrees';
% data2.Column8='I max ze';
% data2.Column9='zenit steps';
% data2.Column10='Zenit degrees'

end
 