
function [uv,duv]=loaduvl(path,response,filter,uv)
% function [uv,duv]=loaduvl(path,response,uv) calcula duv y uv
% input  path: ficheros uv admite comodines, response: fichero de respuesta
% output uv (estructura uv) duv estructura duv
% % TODO introduce los filtros para atenuar
% verificado con rd_ux diferencia max 1E-7 w/m2 
% 
%   See also loaduvstd, plotuv,plotduv .


s=dir(path);
if nargin~=3   
    uv=[];duv=[];
    % ahor el indice es el dia juliano
    for i=1:366
        uv(i).l=[];         uv(i).raw=[];         uv(i).uv=[];
        uv(i).time=[];      uv(i).slc=[];         uv(i).type=[];
        uv(i).dark=[];      uv(i).date=[];        uv(i).temp=[];
        uv(i).file=[];      uv(i).resp=[];        uv(i).inst=[];
        duv(i).duv=[];
    end   
end

for i=1: length(s)
    file=s(i).name

    r=sscanf(file,'%*2s%3d%2d.%d');
    if isempty(r) break;
    else    dia=r(1); inst=r(3);   
    end   

    
    
    if isempty(strfind(upper(file),'UVR'))
%    if ~strcmpi(upper(file),upper(response))
        
        [f,ty,IT,dt,CY,dark,time,JD,YR,lat,long,temp,filter]=loaduv(file);
        
        if upper(file(1))=='S' & isempty(f)
            [f,ty,IT,dt,CY,dark,time,JD,YR,lat,long,temp,filter]=loaduv_ss(file);
        end
        %i_med=strmatch('ua',ty);
        
        if isempty(filter)
        [counts,duv_,slc]=cal_uv(f,IT,CY,dt,dark,response); % convierte a cuentas por segundo
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
        uv(dia).resp=response;
        uv(dia).inst=inst;
        uv(dia).filter=filter;
        %duv_=[dat',nanmean(time)',duv_];
        duv(dia).duv=[];
        
        else    
            [counts,slc]=cal_counts(f,IT,CY,dt,dark,'',filter);
            uv(dia).l=counts(:,1:2:end);
            uv(dia).raw=counts(:,2:2:end);
            uv(dia).uv=counts(:,2:2:end);
            uv(dia).filter=filter;
            
            uvaux=at_filter(uv(dia));
            
            
            uv(dia).ss=uvaux.ss;
            uv(dia).time=time;uv(dia).slc=slc;   
            uv(dia).dark=dark;
            uv(dia).type=ty';
            dat=[YR;JD]; 
            uv(dia).date=dat;
            uv(dia).temp=temp; 
            uv(dia).file=file;  uv(dia).resp=response; uv(dia).inst=inst;       
            
            uvaux=cal_direct(uv(dia),response,filter);
            uv(dia)=uvaux;
        end
        
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
       % write_interchange(uv(i))
    end
end


function [uvb,duv,slc]=cal_uv(f,IT,CY,dt,dark,response)
uvb=[]; duv=[];duv_=[];

for i=1:length(dt)
    try
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
    
    if exist(response)==2
        resp=load(response);
        
        [uv,l]=irad([counts(:,1),counts(:,2)-slc_],resp);
       
        duv_old=cal_duvbrw([l',uv']);
        try
          [duv_,duv_mkii,duv_o]=cost_duv([l',uv']);
        catch
         disp(['warnig: DUV error ']);
        end                   
    else
        disp(['warnig: ', response, 'not found']);
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
   
     
    % deal with different scan lengths
    uv=uv(:)';
    uvb=[uvb,[counts,uv']];
    duv=[duv;duv_];
    catch
     aux=lasterror;
     disp(aux.message);
     disp(i);
end
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [counts,slc]=cal_counts(f,IT,CY,dt,dark,response,filter)
        counts=[]; 

        for i=1:size(f,2)/3
            %try
            r=f(:,2+(3*(i-1)));
            l=f(:,1+(3*(i-1)));
            cnt=(r-dark(i))*2/CY(i)/IT(i);
            jj=find(cnt<2); cnt(jj)=2;
            jj=find(cnt>1E7); cnt(jj)=1E7;
            auxf=cnt;
            for j=1: 9
                cnt=auxf.*exp(cnt*dt(i));
            end
            % IF I < 2922 THEN s1 = s1 + 1: s2 = s2 + c1(I)

            cnt=[l,cnt];
            slc_=mean(cnt(find(cnt(:,1)<2922),2));
            slc(i)=slc_;

            cnt_=([cnt(:,1),cnt(:,2)-slc_]);
            counts=[counts,cnt_];
  
        end
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [uv]=cal_direct(uv,response,filter)

 if exist(response)==2   
        resp=load(response);    
 else
        resp=NaN*zeros(size(counts,1))';  
     
 end
  for i=1:size(uv.l,2)
      
    r0=uv.ss(:,i);
    l0=uv.l(:,i);
    irad=NaN*zeros(size(l0))';  
        
    if(length(resp(:,1))==length(l0))
        irad=r(:,2)./resp(:,2)/1000;
        l=l0;
   else
      [jj,jjc,jjr]=intersect(l0,resp(:,1));
           irad=NaN*(l0);
           irad(jjc)=r0(jjc)./resp(jjr,2)/1000;
           irad=irad';
           l=irad*NaN;
           l(jjc)=l0(jjc);
        end   
         jj=find(irad<1E-6); irad(jj)=1E-6;
        
        % CL calibration 
        irad=irad./(0.034*l/10+   6.48630549450554);
        % 1 aprox uv=uv*17.87;
        %uv=uv./(0.034*l/10+   6.48630549450554);
                
    
    jn=find(irad<0);
    if ~isempty(jn)
        irad(jn)=1E-6;
        warning('underflow');
    end
    jh=find(irad>2);
    if ~isempty(jn)
        irad(jn)=2.0;
        warning('outlier');
    end
   
 
     uv.uv(:,i)=irad;   
         
    
   
   end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function write_interchange(uvstruct)

for ss=1:length(uvstruct.type)
     hora=fix(uvstruct.time(1,ss)/60)
     min=fix((uvstruct.time(1,ss)/60-hora)*60)
     horaf=fix(uvstruct.time(end,ss)/60)
     minf=fix((uvstruct.time(end,ss)/60-hora)*60)
  
     fname=sprintf('%03d%02d%02d.iz1', uvstruct.date(2,ss),hora,min)
     f=fopen(fname,'w');
     
     fprintf(f,'Intercomparacion Izaña julio/agosto 2000\r\n'); % linea 1
     fprintf(f,'Brewer # %s \r\n',uvstruct.inst);              % linea 2
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
      jj=find(irad<1E-6); irad(jj)=1E-6;
   
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
             uv.ss(nl,i)=uv.raw(nl,i)./coef;
%              if fw(j)/64 ==4
%                  disp('ll');
%              end
         end
       end
    end
end
     
  