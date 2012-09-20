
function [f,type,IT,dt,CY,dark,time,JD,YR,lat,long,temp,filter]=loaduv(filename);

%function [a,IT,dt,CY,dark,time,JD,YR,lat,long,temp]=loaduvstd(filename);
% changes for ss  and sx scans
% 13 5 97 julian. read xl file with special header items.
% 29 nov 96 julian
% 2 header lines and 1 endline
% 14 may 97 funktioniert mit xl files.
% 14 5 98 julian
% change fgets to fgets4.
% 26 8 98 julian read ul files. and uv files from 009. Only uv files now
% 12 2 98  Resuelto el uv
% nueva version 2003

IT=0.1147;
%IT=[];
f=[];type=[];dt=[];CY=[];dark=[];time=[];JD=[];YR=[];lat=[];long=[];temp=[];
count=0;flag=0;filter=[];
scan_data=[];
b2=fileread(filename);
bt=strrep(b2,[char(13),char(10)],char(13));
bt=strrep(bt,['end',char(13)],['end',char(13),char(10)]);
% convertimos a formato !! antiguo
scan=mmstrtok(bt,char(10)); % tenemos todos los scanes en celdas




for i=1:length(scan)
    if isempty(findstr(scan{i},'Integration'))
        %disp(scan{i}); % no es un scan
    else
        buf=0;
        count=count+1;
        % old vs new

        jscan=findstr(scan{i},'dark');
        jfilter=findstr(scan{i},'filter');
      
        meds=mmstrtok(scan{i}(1:jscan+4),char(13));
        if isempty(meds)
            break;
        end
        if meds{1}(1)=='u' % scan nuevo
            %disp('new');
            type=[type;meds{1}];
            %IT=[IT sscanf(meds{2},'Integration time is %f seconds per sample')];
            dt=[dt sscanf(meds{3},'dt %f')];
            CY=[CY sscanf(meds{4},'cy %f')];
            %dh=5
            days=meds{6};
            months=meds{7};
            YR=[YR str2double(meds{8})];years=meds{8};
            JD=[JD diaj([months '/' days '/' years])];
            lat=[lat str2double(meds{10})];
            long=[long str2double(meds{11})];
            temp=[temp str2double(meds{12})];
            %dark=[dark str2num(meds{15})];
            jk=findstr(scan{i},'end');
            if ~isempty(jk)
                a=sscanf(scan{i}(jscan+4:jk),'%f ');
                dark=[dark a(1)];
                a(1)=[];
                %a=cell2mat(mmcellfun('str2double',{meds{16:end-1}}));
                % a=sscanf(cat(2,meds{16:end-1}),'%f ');
                scan_data{count}=reshape(a,4,length(a)/4)';
            end
        else
            %disp('old');
            type=[type;'uv'];
            %IT=[IT sscanf(meds{2},'Integration time is %f seconds per sample')];
            dt=[dt sscanf(meds{2},'dt %f')];
            CY=[CY sscanf(meds{3},'cy %f')];
            %dh=4
            days=meds{5};
            months=meds{6};
            YR=[YR str2double(meds{7})];years=meds{7};
            JD=[JD diaj([months '/' days '/' years])];
            lat=[lat str2double(meds{9})];
            long=[long str2double(meds{10})];
            temp=[temp str2double(meds{11})];
            %dark=[dark str2num(meds{14})];
            %j=strmatch('dark',meds);
            jk=findstr(scan{i},'end');
            if ~isempty(jk)
               try
                  %old uv 
                  a=sscanf(scan{i}(jscan(1)+4:jscan(2)),'%f ');
                  filter(i,1,1)=0;
               catch
                  % ux 
                  if isempty(jfilter)
                       a=sscanf(scan{i}(jscan+4:jk),'%f ');
                       filter(i,1,1)=0;
                  else
                      auxfilter=[];auxf=[];
                      for fn=1:length(jfilter)
                          filter_str{fn}=strtok(scan{i}(jfilter(fn):jfilter(fn)+30),char(13));
                          filter(i,fn,1)=sscanf(filter_str{fn},'filter %d');
                          df=length(filter_str{fn});
                          if fn==1
                           auxfilter=sscanf(scan{i}(jscan+4:jfilter(1)),'%f ');
                           dark_=auxfilter(1);
                           scan2=reshape(auxfilter(2:end),4,length(auxfilter(2:end))/4)';
                           filter(i,fn,2)=scan2(end,2);                                          
                          else
                            auxfilter=sscanf(scan{i}(jfilter(fn-1)+df:jfilter(fn)),'%f ');
                            scan2=reshape(auxfilter,4,length(auxfilter)/4)';
                            filter(i,fn,2)=scan2(end,2);
                          end
                          auxf=[auxf;auxfilter]; 
                          
                      end    
                          auxfilter=sscanf(scan{i}(jfilter(end)+df:jk),'%f ');
                          auxf=[auxf;auxfilter]; 
                          %disp('doo');
                          a=auxf;
                  end
               end    
                dark=[dark a(1)];
                a(1)=[];
                %a=cell2mat(mmcellfun('str2double',{meds{16:end-1}}));
                % a=sscanf(cat(2,meds{16:end-1}),'%f ');
                scan_data{count}=reshape(a,4,length(a)/4)';



                count=count+1;
                type=[type;'uv'];

                %IT=[IT sscanf(meds{2},'Integration time is %f seconds per sample')];
                dt=[dt sscanf(meds{2},'dt %f')];
                CY=[CY sscanf(meds{3},'cy %f')];
                %dh=4
                days=meds{5};
                months=meds{6};
                YR=[YR str2double(meds{7})];years=meds{7};
                JD=[JD julianday([months '/' days '/' years])];
                lat=[lat str2double(meds{9})];
                long=[long str2double(meds{10})];
                temp=[temp str2double(meds{11})];
                %
                % dark=[dark str2num(meds{j+1})];
                %a=cell2mat(mmcellfun('str2double',{meds{j+2:end-1}}));
                %a=sscanf(cat(2,meds{j+2:end-1}),'%f ');
                try
                   a=sscanf(scan{i}(jscan(2)+4:jk),'%f ');
                   dark=[dark a(1)];
                   a(1)=[];
                   %a=cell2mat(mmcellfun('str2double',{meds{16:end-1}}));
                   % a=sscanf(cat(2,meds{16:end-1}),'%f ');
                   scan_data{count}=sortrows(reshape(a,4,length(a)/4)',2); %ordenamos por lamda
                catch
                    %ux
                    %disp('filter');
                end    
            end
        end
    end
end
try
    for i=1:length(scan_data);
       if isempty(scan_data{i})
          scan_data(i)=[];
       end
    end
    f=cell2mat(scan_data);
    time=f(:,1:4:end);
    f(:,1:4:end)=f(:,2:4:end);
    f(:,2:4:end)=f(:,4:4:end);
    f(:,4:4:end)=[];
catch
    if ~isempty(scan_data)
      [f,time]=unifyscan(scan_data);
    end
end
%disp('fin')
IT=repmat(IT,count,1);
temp=-33.27+temp*18.64;

function [f,time]=unifyscan(scan_data)
    [dim,imax]=max(cellfun('length',scan_data));
    ref=scan_data{imax};
    l_0=ref(:,2);
    f=[];time=[];
    for i=1:length(scan_data)
        a=scan_data{i} ;    
        % gestiona que los scanes tengan la misma longitud rellenando con nan si es preciso
        %n=size(ref,2);
        l=a(:,2);
        [D,d,d_0]=setxor(l,l_0);
        if isempty(d) & isempty(d_0) % son iguales los scanes               
            a(:,5)=a(:,3); 
            time=[time a(:,1)];
            
        elseif ~isempty(d_0)             % esta incluido en los anteriores (ej uv en ux)
            [I,il,il_0]=intersect(l,l_0);
            c=[];
            c(il_0,:)=a(il,:);
            c(d_0,:)=NaN;
            a=c;
            a(:,5)=a(:,3); 
            time=[time a(:,1)];
        else                             % el scan no esta incluido  hay que modificar f
            warning('no  deberia entrar');
            [I,il,il_0]=intersect(l,l_0);
            f(il,:)=f;
            f(d,:)=NaN;
            time(il,:)=time;
            time(d,:)=NaN;
            a(:,5)=a(:,3); 
            time=[time a(:,1)];
        end     
        f=[f a(:,[2 4 5])];
        
    end %count  
   