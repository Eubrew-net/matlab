function [uv,duv]=loaduvl(path,response,varargin)
% function [uv,duv]=loaduvl(path,response,uv) calcula duv y uv
% input  path: ficheros uv admite comodines,path,
% response:  path completo del fichero de respuesta
% opcionales
% uv_data  -> uv struct, overwrite and update the struct uv
% output uv (estructura uv) duv estructura duv
%  
%
% example :
% uv183=loaduvl('./bdata183/UV*.183','./bfiles/183/uvr36309.183','uv_data',uv183)
%
% verificado con rd_ux diferencia max 1E-7 w/m2 
% 
%   See also loaduvstd, plotuv,plotduv .

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='loaduvl';

arg.addRequired('path', @ischar);
arg.addRequired('response',@ischar);

arg.StructExpand = false;
arg.addParamValue('uv_data', [], @isstruct); % por defecto: no actualiza la variable
arg.addParamValue('date_range', [], @isfloat); % por defecto: no control de fechas
try
  arg.parse(path, response, varargin{:});
  mmv2struct(arg.Results); 
  Args=arg.Results;
  chk=1;
catch
  errval=lasterror;
  disp(errval.message);
  chk=0;
end

s=dir(path); 
if ~isempty(date_range)
    dir_cell=struct2cell(s); files=dir_cell(1,:);
    myfunc_clean=@(x)regexp(x, '^uv\D.\d*','ignorecase')';     clean=@(x)~isempty(x); 
    remove=find(cellfun(clean,cellfun(myfunc_clean,files, 'UniformOutput', false))==1);
    files(remove)=[];  s(remove)=[];
    myfunc=@(x)sscanf(x,'%*2c%3d%2d.%*d')';    
    A=cell2mat(cellfun(myfunc,files, 'UniformOutput', false)');
%                    Año    Dia
    dates=datejuli(A(:,2),A(:,1));    
    s(dates<date_range(1))=[];    dates(dates<date_range(1))=[];
    if length(date_range)>1
       s(dates>date_range(2))=[]; dates(dates>date_range(2))=[];
    end
end
   
if isempty(uv_data)
    uv=[];duv=[];
    % ahora el indice es el dia juliano
    for i=1:366
        uv(i).l=[];         uv(i).raw=[];         uv(i).uv=[];
        uv(i).time=[];      uv(i).slc=[];         uv(i).type=[];
        uv(i).dark=[];      uv(i).date=[];        uv(i).temp=[];
        uv(i).file=[];      uv(i).resp=[];        uv(i).inst=[];
        duv(i).duv=[];
    end   
else
    uv=uv_data;
end
    
for i=1:length(s)
    if isdir(response) % se supone que si no es dir, le estamos pasando el path + nombre del fichero respuesta
        path_r=response;
        resp=[];
    else
        resp_file=response;
    end

    file=s(i).name
    file_path=fileparts(path);
    file_info=sscanf(upper(file),'UV%03d%02d.%03d');        
    
    if isempty(strfind(upper(file),'UVR')) && isempty(strfind(upper(file),'UVOAVG') ) % trabajamos con los ficheros UV
%    if ~strcmpi(upper(file),upper(resp))        
        [f,ty,IT,dt,CY,dark,time,JD,YR,lat,long,temp,filter]=loaduv(fullfile(file_path,file));        
        
        if upper(file(1))=='S' & isempty(f)
            [f,ty,IT,dt,CY,dark,time,JD,YR,lat,long,temp,filter]=loaduv_ss(fullfile(file_path,file));
        end
        %i_med=strmatch('ua',ty);        
       if ~isempty(strfind(upper(resp_file),'HIST'))
           fecha=unique(datenum(YR+2000,1,0)+JD);
           if length(fecha)==1
            [uvr_hist,resp_file]=read_uvr_hist(response,fecha);
            disp([response,'->',resp_file]);
           else
             disp('error severall days on UV File');
             resp_file=[];
           end
       end 
        if isempty(filter)
            if exist('resp','var') && isempty(resp)
                resp_file=fullfile(path_r,[file(1:2),'r',file(3:end)]);
            end
           [counts,duv_,slc]=cal_uv(f,IT,CY,dt,dark,resp_file); % convierte a cuentas por segundo        
        else    
            [counts,duv,slc]=cal_direct(f,IT,CY,dt,dark,'',filter);                        
        end
        r=sscanf(file,'%*2s%3d%2d.%d');
        if isempty(r)
            disp(file)
            break;            
        else
            dia=r(1); inst=r(3);
        end   
        if ~all(structfun(@isempty,uv(dia)))
            disp('overwriting the day')
        end
        uv(dia).l=counts(:,1:3:end);
        uv(dia).raw=counts(:,2:3:end);
        uv(dia).uv=counts(:,3:3:end);
        uv(dia).time=time;
        uv(dia).slc=slc;
        uv(dia).type=ty';
        dat=[YR;JD];
        uv(dia).date=dat;
        uv(dia).temp=temp;
        uv(dia).dark=dark;
        uv(dia).file=file;
        uv(dia).resp=resp_file;
        uv(dia).inst=inst;
        uv(dia).filter=filter;
        uv(dia).duv=[dat',nanmean(time)',duv_];
        if inst==33 uv(dia).spikes=[];  % no hay correccion para el #033
        else   
            [uvc,inds,cols]=spikes(uv(dia).l(:,1),uv(dia).uv,2900); % quitamos los picos;
            if ~isempty(inds) 
                for j=1:length(inds) 
                    spik(j,:)=[uv(dia).time(inds(j),cols(j)),uv(dia).l(inds(j),cols(j)),uv(dia).uv(inds(j),cols(j))];
                end   
                uv(dia).spikes=[inds,cols,spik];
                %plot(uv(i).l(:,cols),[uv(i).uv(:,cols),uvc(:,cols)],'.:');
                spik=[];
                uv(dia).uv=uvc;
            else
                uv(dia).spikes=[];
            end  
        end
        try
         % write_interchange(uv(i))
         % disp('OK');
        catch
         disp(file);
        end
    end
end



if chk
%     % Se muestran los argumentos que toman los valores por defecto
%   disp('--------- Validation OK --------------') 
%   disp('List of arguments given default values:') 
%   if ~numel(arg.UsingDefaults)==0
%      for k=1:numel(arg.UsingDefaults)
%         field = char(arg.UsingDefaults(k));
%         value = arg.Results.(field);
%         if isempty(value),   value = '[]';   
%         elseif isfloat(value), value = num2str(value); end
%         disp(sprintf('   ''%s''    defaults to %s', field, value))
%      end
%   else
%      disp('               None                   ')
%   end
%   disp('--------------------------------------') 
else
     disp('NO INPUT VALIDATION!!')
     disp(sprintf('%s',errval.message))
end

function [uvb,duv,slc]=cal_uv(f,IT,CY,dt,dark,resp_file)
uvb=[]; duv=[];duv_=[];


for i=1:length(dt)
    r=f(:,2+(3*(i-1)));
    l=f(:,1+(3*(i-1)));
    counts=(r-dark(i))*2/CY(i)/IT(i);
    jj=find(counts<2); counts(jj)=2;
    jj=find(counts>1E7); counts(jj)=1E7;
    auxf=counts;
    for j=1: 9  
        counts=auxf.*exp(counts*dt(i));
    end
    % IF I < 2922 THEN s1 = s1 + 1: s2 = s2 + c1(I)
    
    counts=[l,counts];
    slc_=mean(counts(find(counts(:,1)<2922),2));
    slc(i)=slc_;
    if exist(resp_file)==2
        resp=load(resp_file);        
        [uv,l]=irad([counts(:,1),counts(:,2)-slc_],resp);
        uv=uv(:)';
        l=l(:)';
        duv_old=cal_duvbrw([l',uv']);   
        [duv_,duv_mkii,duv_o]=cost_duv([l',uv']);        
    else
        disp(['warnig: ', resp_file, 'not found']);
        uv=NaN*zeros(size(l));          
    end
    
    jn=find(uv<0);
    if ~isempty(jn)
        uv(jn)=1E-6;
        warning('underflow');
    end

    jh=find(uv>2);
    if ~isempty(jn)
        uv(jn)=2.0;
        warning('outlier');
    end

    uvb=[uvb,[counts,uv(:)]];
    duv=[duv;duv_];
    %uvb=NaN;
    %duv=NaN;        
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uvb,duv,slc]=cal_direct(f,IT,CY,dt,dark,resp,filter)
uvb=[]; duv=[];duv_=[];

for i=1:size(f,2)/3
   %try 
    r=f(:,2+(3*(i-1)));
    l=f(:,1+(3*(i-1)));
    counts=(r-dark(i))*2/CY(i)/IT(i);
    jj=find(counts<2); counts(jj)=2;
    jj=find(counts>1E7); counts(jj)=1E7;
    auxf=counts;
    for j=1: 9  
        counts=auxf.*exp(counts*dt(i));
    end
    % IF I < 2922 THEN s1 = s1 + 1: s2 = s2 + c1(I)
    
    counts=[l,counts];
    slc_=mean(counts(find(counts(:,1)<2922),2));
    slc(i)=slc_;    
    if exist(resp)==2        
        resp=load(resp);    
        [uv,l]=irad([counts(:,1),counts(:,2)-slc_],resp);
        % 1 aprox uv=uv*17.87;
        uv=uv.*(0.034*l/10+   6.48630549450554);                            
    else
        disp(['warnig: ', resp, 'not found']);
        uv=NaN*zeros(size(l));          
    end
    
    jn=find(uv<0);
    if ~isempty(jn)
        uv(jn)=1E-6;
        warning('underflow');
    end
    
    jh=find(uv>2);
    if ~isempty(jn)
        uv(jn)=2.0;
        warning('outlier');
    end
    
    uvb=[uvb,[,uv']];
    duv=[duv;duv_];
    %catch
    %    warning('cal error');
    %end   
   end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_interchange(uvstruct)

for ss=1:length(uvstruct.type)
     hora=fix(uvstruct.time(1,ss)/60);
     min=fix((uvstruct.time(1,ss)/60-hora)*60);
     horaf=fix(uvstruct.time(end,ss)/60);
     minf=fix((uvstruct.time(end,ss)/60-hora)*60);
  
     fname=sprintf('%03d%02d%02d.iz2', uvstruct.date(2,ss),hora,min);
     f=fopen(fname,'w');
     try
     fprintf(f,'Izaña \r\n'); % linea 1
     if isnumeric(uvstruct.inst)
              fprintf(f,'Brewer # %03d \r\n',uvstruct.inst);              % linea 2
     else         
         fprintf(f,'Brewer # %s \r\n',uvstruct.inst);              % linea 2
     end
     fprintf(f,'%s_%s\r\n',uvstruct.file,uvstruct.resp); % linea 3
     fprintf(f,'sl:%f ',uvstruct.slc(ss));  %linea 4
     fprintf(f,'PMT:%f \r\n',uvstruct.temp(ss)); %
     fprintf(f,'fecha: %d/%d \r\n',uvstruct.date(1,ss),uvstruct.date(2,ss));  
     fprintf(f,'hora_inicio:%d:%d \r\n',hora,min); 
     fprintf(f,'hora_fin: %d:%d \r\n"' ,horaf,minf); 
     %fprintf(f,'!5\r\n#6\r\n#7\r\n#8\r\n');
     fprintf(f,'!9\r\n#10\r\n#11\r\n#12\r\n#13\r\n');
     fprintf(f,'lamda(nm) irradiancia (W/m2) correccion \r\n');
     jnan=find(isnan(uvstruct.uv(:,ss)));
     if ~isempty(jnan)
        uvstruct.uv(jnan,ss)=1E-9;
     end   
     scan_=[uvstruct.l(:,ss)/10,uvstruct.uv(:,ss),ones(size(uvstruct.l(:,ss)))];
     fprintf(f,'%5.1f %2.8E %2.8E \r\n',scan_');
     fclose(f);
     catch
         fclose(f);
     end
  end
  

 






 function [irad,l]=irad(counts,resp)
 
    
 if(length(resp)==length(counts))
      irad=counts(:,2)./resp(:,2)/1000;
      l=counts(:,1);
   else
      [jj,jjc,jjr]=intersect(counts(:,1),resp(:,1));
      irad=NaN*(counts(:,1));
      irad(jjc)=counts(jjc,2)./resp(jjr,2)/1000;
      irad=irad';
      l=irad*NaN;
      l(jjc)=counts(jjc,1);
   end   
      jj= irad<1E-6; irad(jj)=1E-6;
   
function duv=cal_duvbrw(uv) %tradicional
   
     lamda=uv(:,1);   
     DV=ones(size(lamda))*NaN;
     j=find(lamda<=2980);     DV(j)=1;
     j=find(lamda>2980);     DV(j)=10.^(9.399999E-02*(2980-lamda(j))/10);  %CIE
     j=find(lamda==3240) ;   DV(j)=0.148;  %UVA corr
     j=find(lamda>3290 ) ;   DV(j)=10.^(1.5E-2*(1390-lamda(j))/10);  %UVA
     j=find(lamda==3565 ) ;   DV(j)=0.027; %CIE desde 3565 A hasta 4000A
     
     
     duv=0.5*nansum(DV.*uv(:,2))*1000; %en mW
      
     
function [duvc,duvc2,duv] =cost_duv(uv)

% calcula el duv siguiendo el método del cost
%duvc-> m´etodo del cost
%duvc2->simula un brewer mk-II (280-325)
%duv-> tal cual
% Expanden el scan considerando la media de las ultimas 5 longitudes de onda hasta 400nm
% sustituida la suma por ingtegral
   
   uv(find(isnan(uv(:,2))),:)=[]; % NaN da errores en trapz
   lamda=uv(:,1);
   diffey=DV(lamda); 
   duv=trapz(lamda,diffey.*uv(:,2))*100; %en mW y nm

   % rellenamos hasta 400nm paso 0.5nm
   j=find(~isnan(uv(:,2)));
   [ultima_lamda,ultimo]=max(uv(j,1));
   ultimo=j(ultimo);
   duvc=NaN;
   duvc2=NaN;
      
   if ~isempty(ultima_lamda)
       
       lamda_f=ultima_lamda+5;
       lamda_c=lamda_f:5:4000;
       lamda=[uv(1:ultimo,1);lamda_c'];
       % rellenamos uv
       
       uv_5=nanmean(uv(ultimo-5:ultimo,2));
       uv_c=uv_5*ones(size(lamda_c))';
       uv_=[uv(1:ultimo,2);uv_c];
       
       diffey=DV(lamda); 
       duvc=trapz(lamda,(diffey.*uv_))*100; %en mW
       
       %simulamos un brewer MKII 
       j=find(lamda==3250);
       if ~isempty(j)
           uv_5=nanmean(uv_(j-5:j));
           lamda_c=3255:5:4000;
           lamda_2=[lamda(1:j);lamda_c'];
           uv_2c=uv_5*ones(size(lamda_c))';
           uv_2=[uv_(1:j);uv_2c];
           diffey=DV(lamda_2);
           duvc2=trapz(lamda_2,diffey.*uv_2)*100; %en mW y nm (1000/10)
       end
   end
 
 function DV=DV(lamda)
  DV=zeros(size(lamda));
  %Brewer software
  j=find(lamda<=2980);     DV(j)=1;
  j=find(lamda>2980);     DV(j)=10.^(9.399999E-02*(2980-lamda(j))/10);  %CIE
  j=find(lamda>3280 ) ;   DV(j)=10.^(1.5E-2*(1390-lamda(j))/10);  %UVA
 
     
 function uv=at_filter(uv,at)

%aplica la calibracion de filtros
% af matriz de la rutina af o at
%
% at=[
%    0.43000000000000  -0.00001761000000
%    0.14600000000000  -0.00000888000000
%    0.08480000000000  -0.00001320000000
%    0.03450000000000  -0.00000767000000
% ]
% filtros del brewer157
if nargin==1
    at=[
0.441   -2.24E-5  
0.152   -1.12E-5
0.0441  -1.26E-6
0.00187 1.549E-6
0.00127 5.87E-7       ];
end

uv.ss=uv.raw;


for i=1:size(uv.filter,1)
     
    fw=uv.filter(i,:,1);
    lc=uv.filter(i,:,2);
    l=uv.l(:,i);
    c=uv.uv(:,i);
    nf=nnz(fw);
    
    if any(fw)
       for j=1:nf
              
         if j==nf | nf==1
              nl=find(l>lc(j));
         else
              nl=find(l>lc(j) & l<=lc(j+1));
         end     
         if isempty(nl)
             warning('nn');
         else
             coef=at(fw(j)/64,1)+at(fw(j)/64,2)*l(nl);
             uv.ss(nl,i)=uv.uv(nl,i)./coef;
%              if fw(j)/64 ==4
%                  disp('ll');
%              end
         end
       end
    end
end
     
   