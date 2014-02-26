function output= read_custom(path_to_files, filetype, expr, varargin)



%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'read_custom';

% input obligatorio
arg.addRequired('path_to_files');
arg.addRequired('filetype');
arg.addRequired('expr');

% input param - value
arg.addParamValue('printfile',0, @(x)(x==0 || x==1)); % por defecto, noprint
arg.addParamValue('date_range', [], @isfloat); % por defecto: no control de fechas

% validamos los argumentos definidos:
arg.parse(path_to_files,filetype,expr, varargin{:});
mmv2struct(arg.Results);

%%
s=dir(fullfile(path_to_files,filetype)); 
if ~isempty(date_range)
    dir_cell=struct2cell(s); files=dir_cell(1,:);
    myfunc=@(x)sscanf(x,'%*c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,files, 'UniformOutput', false)');
%                    Año    Dia
    dates=datejuli(A(:,2),A(:,1));    
    s(dates<date_range(1))=[];    dates(dates<date_range(1))=[];
    if length(date_range)>1
       s(dates>date_range(2))=[]; dates(dates>date_range(2))=[];
    end
end

%%
files=s; output=[];
for d=1:length(files)   
    f=fopen(fullfile(path_to_files,files(d).name));
    if f < 0
       disp(files(d).name)
       continue
    end
    
    s=fread(f);    fclose(f);    s=char(s)';
    d_fil=mmstrtok(s,char(10));
    jco=find(cellfun(@(x) ~isempty(x),regexpi(d_fil,expr)));
    switch expr 
           case 'hg'
             jco=jco(cellfun(@(x) ~isempty(x),regexpi(d_fil(jco),'hg.\d+')));
           case 'sr'
             jco=jco(cellfun(@(x) ~isempty(x),regexpi(d_fil(jco),'sr: Azimuth.\w+')));
           case 'ze'
             jco=jco(cellfun(@(x) ~isempty(x),regexpi(d_fil(jco),'Zenith.\w+')));
           case 'si'
             jco=jco(cellfun(@(x) ~isempty(x),regexpi(d_fil(jco),'New SI')));
    end
    
    for l=1:length(jco)
           time_med=sscanf( d_fil{jco(l)}, '%*s%02d:%02d:%02d*s');
           fileinfo=sscanf(files(d).name,'%*c%03d%02d.%*03d');
           datefich=datejuli(fileinfo(2),fileinfo(1));
           datefich=datefich+time_med(1)/24+time_med(2)/60/24+time_med(3)/60/60/24;
           if strcmp(expr,'sr')
              output=cat(1,output,[datefich, sscanf(d_fil{jco(l)},'%*s%*d%*c%*d%*c%*d%*s%*c%*s%*s%*s%*s%*s%*s%*c%d')]);
           elseif strcmp(expr,'ze')
              output=cat(1,output,[datefich, sscanf(d_fil{jco(l)},'%*s%*s%*s%*s%*s%*s%d')]);
           elseif strcmp(expr,'si')
              si=regexpi(d_fil{jco(l)}, '=','split'); old=sscanf(si{4},'%05d%*s%05d');
              output=cat(1,output,[datefich,sscanf(si{2},'%05d%*s'),sscanf(si{3},'%05d%*s'),old(1),old(2)]);
           else
              output=[output; datefich];
           end
    end

    if printfile==1 % particular para los resets
       g=fopen(fullfile(path_to_files,'resets.txt'),'a');
       if ~isempty(jco)
          for l=1:length(jco)
              time_reset=sscanf( d_fil{jco(l)},'Brewer reset at %02d:%02d:%02d');
              tim=sprintf('%02d:%02d:%02d',time_reset);
              if jco~=1
                 fprintf(g,'File %s:  %s\n',files(d).name,d_fil{jco(l)-1});
              else
                 fprintf(g,'File %s:  %s\n',files(d).name,d_fil{jco(l)});
              end                 
              fprintf(g,'\t\t\t Brewer reset at %s\r\n',tim);
          end       
       end
    end    
end   
fclose all;