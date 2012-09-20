function [LFHTSMP0 LFHTSMP1  LFHTSMP2 LFHTSMP3 LFHTSMP4 LFHTSMP5 LFHTSMP6 LFHTSMP7 Error]=analyzeNI(path,varargin)
% This function analize NI files and  gives the response of each one.
% We obtain 8 matrix where Wavelengths, Date and Temperature are the firsts three columns and
% the remaining "z" columns are Counts/second for each scan.

% [  ]=analyzeNI('E:\CODE\aro2010\bdata185\NI2*10.185');

%%  MODIFICADO:
%  26/10/2010 Isabel: Modificados titulos y ejes para que salgan en negrita
%                     Se muestran los archivos que dan error
%                     Se comenta el display de los archivos de error y NIFiles=dir(path);


%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'analyzeNI';

% input obligatorio
arg.addRequired('path'); 
% arg.addRequired('nameb'); 

% input param - value,varargin
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas
% arg.addParamValue('depuracion',0, @(x)(x==0 || x==1)); % por defecto no depuracion
% arg.addParamValue('outlier_flag', 0, @(x)(x==0 || x==1)); % por defecto no depuracion

% validamos los argumentos definidos:
try
arg.parse(path, varargin{:});
mmv2struct(arg.Results);
chk=1;
catch
  errval=lasterror;
  chk=0;
end

%% NI FILES

NIFiles=dir(path);
FilesNI=[]; FilesNI_m=[];
for i=1:length(NIFiles)
    FilesNI  = [FilesNI; cellstr(NIFiles(i,1).name)];
    FilesNI_m= [FilesNI_m; brewer_date(str2num(NIFiles(i).name(3:end-4)))];end
if isempty (FilesNI)
    warning ('No NI Files')
end

% control de fechas
if ~isempty(date_range)
   indx=FilesNI_m(:,1)<date_range(1); 
   FilesNI(indx)=[]; FilesNI_m(indx,:)=[];
   if length(date_range)>1
      indx=FilesNI_m(:,1)>date_range(2);
      FilesNI(indx)=[]; FilesNI_m(indx,:)=[];
   end
end


%% DEFINING VARIABLES
LSMP0=[];
LSMP1=[];
LSMP2=[];
LSMP3=[];
LSMP4=[];
LSMP5=[];
LSMP6=[];
LSMP7=[];

FHj=[];
Error=[];
TNumFinal=[];


%% READING NI FILES

for j=1:length(FilesNI)
    try
        [DataNumRFHCS{j} TNumTotal{j}]= ReadNI(fullfile(fileparts(path),FilesNI{j}));
        f=length(DataNumRFHCS{j});
        % DataNumRFHCS{j}{i} second column are wavelengths
        % because of that we use it for the sanjoin.
        

        for i=1:f
            [LSMP0]=scan_join(LSMP0,DataNumRFHCS{j}{i}(:,[2 4]));
            [LSMP1]=scan_join(LSMP1,DataNumRFHCS{j}{i}(:,[2 5]));
            [LSMP2]=scan_join(LSMP2,DataNumRFHCS{j}{i}(:,[2 6]));
            [LSMP3]=scan_join(LSMP3,DataNumRFHCS{j}{i}(:,[2 7]));
            [LSMP4]=scan_join(LSMP4,DataNumRFHCS{j}{i}(:,[2 8]));
            [LSMP5]=scan_join(LSMP5,DataNumRFHCS{j}{i}(:,[2 9]));
            [LSMP6]=scan_join(LSMP6,DataNumRFHCS{j}{i}(:,[2 10]));
            [LSMP7]=scan_join(LSMP7,DataNumRFHCS{j}{i}(:,[2 11]));
            % We join Datas, keeping in the firs column Wavelengths, and in
            % the rest Datas of each repeticion.
        end


        %...DATA/TIME......................................................
        
        
        for   i=1:f
            fhj= DataNumRFHCS{j}{i}(1,1);
            FHj= [FHj fhj];
        end

        % We take "DataNumRFHCS{j}{i}(1,1)" of each file (DataNumRFHCS{j}).
        % Inside each DataNumRFHCS{j} could be several repetitions DataNumRFHCS{j}{i}.
        % We asociate a matlab Data-Time for each Counts/Second, this is
        % ...the firs data of the first column and row of DataNumRFHCS{j}.
        % Data/Time values are joined in a row, so we have a row with the
        % ...values Matlab Data/Time related with each column CS
        


        %...JOINING  TEMPERATURES and FHs................................................
        
        TNumFinal=[TNumFinal TNumTotal{j}];
        TNaN=[NaN TNumFinal];
        FHNaN=[NaN FHj];

        %...OUTPUT........................................................

        LFHTSMP0= [LSMP0;TNaN;FHNaN];
        LFHTSMP1= [LSMP1;TNaN;FHNaN];
        LFHTSMP2= [LSMP2;TNaN;FHNaN];
        LFHTSMP3= [LSMP3;TNaN;FHNaN];
        LFHTSMP4= [LSMP4;TNaN;FHNaN];
        LFHTSMP5= [LSMP5;TNaN;FHNaN];
        LFHTSMP6= [LSMP6;TNaN;FHNaN];
        LFHTSMP7= [LSMP7;TNaN;FHNaN];
        
    catch
        Error=[Error;FilesNI{j}];
        %ex=lasterror;
        %disp(ex);
    end
end
% display(Error)



%% 2D GRAPHS
%...R.us.CS.......................................................
set(0,'DefaultFigureWindowStyle','docked');

figure; ha=tight_subplot(4,2,.05,.1);    
axes(ha(1)); LSMP0_=ones(size(LSMP0,1),size(LSMP0,2));
LSMP0_(:,1)=LSMP0(:,1); LSMP0_(:,2:end)=(LSMP0(:,2:end)-repmat(LSMP0(:,2),1,size(LSMP0,2)-1))*100./repmat(LSMP0(:,2),1,size(LSMP0,2)-1);
P0=ploty(LSMP0_,'r*'); set(gca,'XTickLabel',[]); title(''); grid
 text(3145,max(max(LSMP0_(:,2:end))),'Slit#0','BackgroundColor',[.7 .9 .7]);
interactivelegend(P0,cellstr(datestr(FHj)));
% Cp=size(LSMP0_,2);
% gris_line(3*Cp);

axes(ha(2)); LSMP1_=ones(size(LSMP1,1),size(LSMP1,2));
LSMP1_(:,1)=LSMP1(:,1); LSMP1_(:,2:end)=(LSMP1(:,2:end)-repmat(LSMP1(:,2),1,size(LSMP1,2)-1))*100./repmat(LSMP1(:,2),1,size(LSMP1,2)-1);
P1=ploty(LSMP1_,'r*'); set(gca,'XTickLabel',[]); title(''); grid
 text(3145,max(max(LSMP1_(:,2:end))),'Slit#1','BackgroundColor',[.7 .9 .7]);
interactivelegend(P1,cellstr(datestr(FHj)));

axes(ha(3)); LSMP2_=ones(size(LSMP2,1),size(LSMP2,2));
LSMP2_(:,1)=LSMP2(:,1); LSMP2_(:,2:end)=(LSMP2(:,2:end)-repmat(LSMP2(:,2),1,size(LSMP2,2)-1))*100./repmat(LSMP2(:,2),1,size(LSMP2,2)-1);
P2=ploty(LSMP2_,'r*'); set(gca,'XTickLabel',[]); title(''); grid
 text(3145,max(max(LSMP2_(:,2:end))),'Slit#2','BackgroundColor',[.7 .9 .7]);
interactivelegend(P2,cellstr(datestr(FHj)));

axes(ha(4)); LSMP3_=ones(size(LSMP3,1),size(LSMP3,2));
LSMP3_(:,1)=LSMP3(:,1); LSMP3_(:,2:end)=(LSMP3(:,2:end)-repmat(LSMP3(:,2),1,size(LSMP3,2)-1))*100./repmat(LSMP3(:,2),1,size(LSMP3,2)-1);
P3=ploty(LSMP3_,'r*'); set(gca,'XTickLabel',[]); title(''); grid
 text(3145,max(max(LSMP3_(:,2:end))),'Slit#3','BackgroundColor',[.7 .9 .7]);
interactivelegend(P3,cellstr(datestr(FHj)));

axes(ha(5)); LSMP4_=ones(size(LSMP4,1),size(LSMP4,2));
LSMP4_(:,1)=LSMP4(:,1); LSMP4_(:,2:end)=(LSMP4(:,2:end)-repmat(LSMP4(:,2),1,size(LSMP4,2)-1))*100./repmat(LSMP4(:,2),1,size(LSMP4,2)-1);
P4=ploty(LSMP4_,'r*'); set(gca,'XTickLabel',[]); title(''); grid
 text(3145,max(max(LSMP4_(:,2:end))),'Slit#4','BackgroundColor',[.7 .9 .7]);
interactivelegend(P4,cellstr(datestr(FHj)));

axes(ha(6)); LSMP5_=ones(size(LSMP5,1),size(LSMP5,2));
LSMP5_(:,1)=LSMP5(:,1); LSMP5_(:,2:end)=(LSMP5(:,2:end)-repmat(LSMP5(:,2),1,size(LSMP5,2)-1))*100./repmat(LSMP5(:,2),1,size(LSMP5,2)-1);
P5=ploty(LSMP5_,'r*'); set(gca,'XTickLabel',[]); title(''); grid
text(3145,max(max(LSMP5_(:,2:end))),'Slit#5','BackgroundColor',[.7 .9 .7]);
interactivelegend(P5,cellstr(datestr(FHj)));

axes(ha(7)); LSMP6_=ones(size(LSMP6,1),size(LSMP6,2));
LSMP6_(:,1)=LSMP6(:,1); LSMP6_(:,2:end)=(LSMP6(:,2:end)-repmat(LSMP6(:,2),1,size(LSMP6,2)-1))*100./repmat(LSMP6(:,2),1,size(LSMP6,2)-1);
P6=ploty(LSMP6_,'r*'); title(''); grid
text(3145,max(max(LSMP6_(:,2:end))),'Slit#6','BackgroundColor',[.7 .9 .7]);
interactivelegend(P6,cellstr(datestr(FHj)));

axes(ha(8)); LSMP7_=ones(size(LSMP7,1),size(LSMP7,2));
LSMP7_(:,1)=LSMP7(:,1); LSMP7_(:,2:end)=(LSMP7(:,2:end)-repmat(LSMP7(:,2),1,size(LSMP7,2)-1))*100./repmat(LSMP7(:,2),1,size(LSMP7,2)-1);
P7=ploty(LSMP7_,'r*'); title(''); grid
 text(3145,max(max(LSMP7_(:,2:end))),'Slit#7','BackgroundColor',[.7 .9 .7]);
interactivelegend(P7,cellstr(datestr(FHj)));

sup=suptitle(sprintf('%s%s','NI Report, Brewer#',FilesNI{end}(end-2:end)));
set(sup,'FontWeight','bold');

end