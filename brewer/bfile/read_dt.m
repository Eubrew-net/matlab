function [dt,rs,dtavg,rsavg]=read_dt(path,varargin)
 
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'read_dt';

% input obligatorio
arg.addRequired('path');

% input param - value
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
arg.addParamValue('dtplot', 1, @isfloat);      % por defecto, dt plot
arg.addParamValue('rsplot', 1, @isfloat);      % por defecto, rs plot

% validamos los argumentos definidos:
try
  arg.parse(path, varargin{:}); mmv2struct(arg.Results);
catch exception    
  fprintf('%s\n',exception.message);
end

 
 if isempty(regexp(path, '\B(\d|\W)'))
    path=cat(2,path,'\B*');
 end
 
p=fileparts(path);        s=dir(path); 
if ~isempty(date_range)
    dir_cell=struct2cell(s); files=dir_cell(1,:);
    myfunc_clean=@(x)regexp(x, '^B\D.\d*','ignorecase')';     clean=@(x)~isempty(x); 
    remove=find(cellfun(clean,cellfun(myfunc_clean,files, 'UniformOutput', false))==1);
    files(remove)=[];  s(remove)=[];
    myfunc=@(x)sscanf(x,'%*c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,files, 'UniformOutput', false)');
%                    Año    Dia
    dates=datejuli(A(:,2),A(:,1));    
    s(dates<date_range(1))=[];    dates(dates<date_range(1))=[];
    if length(date_range)>1
       s(dates>date_range(2))=[]; dates(dates>date_range(2))=[];
    end
end
   

 dtavg=[]; rsavg=[]; dt=[]; rs=[];
 for i=1:length(s)
     try
       [dtavg_,rsavg_]=readb_dt(fullfile(p,s(i).name));
       dtavg=[dtavg;dtavg_];   rsavg=[rsavg;rsavg_];
     catch exception
       fprintf('%s, file: %s\n',exception.message,s(i).name);
     end
 end
 
% plots  
if dtplot
   if ~isempty(dtavg) % dead time on bfile
       figure;
       dt=[dtavg(:,1),dtavg(:,30:33)];
       
       p2=confplot(dt(:,1:3)); hold on; plot(dtavg(:,1),dtavg(:,13:17),'*r');
       set(p2(1),'LineStyle','None','Marker','s','MarkerFaceColor','r','LineWidth',1.5);
       plot(dtavg(:,1),dtavg(:,20:29),'b.'); p1=errorbard(dt(:,[1,4,5]),'ko'); 
       set(p1,'MarkerFaceColor','b','LineWidth',1);

       datetick('x',19,'keepticks','keeplimits');grid
       legend([p1,p2(1)],'dt low','dt high');
       title('Dead Time Test'); ylabel('Time ( \times 10^{-9} ) seconds');       
   end
end

if rsplot
   if ~isempty(rsavg)
       figure;
       rs=[rsavg(:,1),rsavg(:,19:26)];
       %subplot(2,1,2)
       plot(rs(:,1),rsavg(:,[19,21:26]));
       datetick;
       set(gca,'Ylim',[0.990,1.01]);
       hline([0.997,1.003])
       grid
   end        
end