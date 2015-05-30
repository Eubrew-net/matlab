
% read the configuration from the bfile
function [config,TC,DT,extrat,absx,AT]=readb_config(bfile)

   %[PATHSTR,NAME,EXT,VERSN] = fileparts(bfile);  
   %info=file_brewer([NAME,EXT]);
    
  
fmt_icf=[
'inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%3c',...
' %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s'];


s=fileread(bfile);
l=mmstrtok(s,char(10));


% READ CONFIGURATION
% colunna 1 % Configuracion en el fichero

buf=l{1}; % get first line, should be version...
if any(strmatch('version',buf))==1, %then OK
    if size(buf)<20
        buf=[l{1}(1:end-1),l{2}]; 
    end
    ind=find(buf==char(13));
    lat=str2num(buf(ind(6):ind(7)));
    long=str2num(buf(ind(7):ind(8)));
    pr=str2num(buf(ind(end-1):end));
end

%buf=l{2};
buf=l{strmatch('inst',l)};
if any(strmatch('inst',buf))==1, %then OK
    cfg=sscanf(buf,fmt_icf);
    TC=cfg(1:5);
    DT=cfg(12);
    extrat=cfg(10:11);
    absx=cfg(7:9);
    AT=cfg(16:21); % atenuation filters
    %model
    type=char(cfg(23:25)');
    fecha=char(cfg(54:end)');
    if strcmp(type,'iii')
        cfg(23)=3;
    elseif strmatch('ii',type)
        cfg(23)=2;
    elseif strcmp(type,'v')
        cfg(23)=5;
    elseif strcmp(type,'iv')
        cfg(23)=4;
    end
    cfg(24:25)=[]; %instrumento
    TC=[TC(:)',cfg(25)]; % temperature coef for lamda1
    cfg(51)=NaN; % UV zenith no in header
    cfg(52:end)=[]; % no suport for extended config
    config=[NaN;cfg]; % a?adimos la fecha

else
    % chapuza para el b171-------------------REVISAR
    buf=l{1};
    lat=str2num(buf(ind(6):ind(7)));
    long=str2num(buf(ind(7):ind(8)));
    bufr=mmstrtok(buf,char(13));
    ind=strmatch('pr',bufr);
    pr=str2num(bufr{11});
    ind=strmatch('inst',bufr);

    if nargin>1  & isstr(config_file)    % resolver de forma mas elgante.
        %config_file=config;
        config=[];
    end
    cfg=sscanf(char(bufr(ind:end))',fmt_icf);
    TC=cfg(1:5);
    DT=cfg(12);
    extrat=cfg(10:11);
    absx=cfg(7:9);
    AT=cfg(16:21); % atenuation filters
    %model
    type=char(cfg(23:25)');
    fecha=char(cfg(54:end)');
    if strcmp(type,'iii')
        cfg(23)=3;
    elseif strmatch('ii',type)
        cfg(23)=2;
    elseif strcmp(type,'v')
        cfg(23)=5;
    elseif strcmp(type,'iv')
        cfg(23)=4;
    end
    cfg(24:25)=[]; %com port
    TC=[TC(:)',cfg(25)]; % temperature coef for lamda1
    cfg(51)=NaN; % UV zenith no in header
    config=[NaN;cfg]; % a?adimos la fecha
end


%       TC=[NaN,NaN,TC];
%       TC(1)=TC(3)-TC(6)-3.2*(TC(6)-TC(7));
%       TC(2)=TC(5)-TC(6)-.5*(TC(5)-TC(6))-1.7*(TC(6)-TC(7));


  