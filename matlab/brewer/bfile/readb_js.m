function [jp,F,F_0]=readb_js(bfile,config)
%  Input : fichero B, configuracion (ICF en formato ASCII)
%  Output:
%
%
% Alberto Redondas 2014

dt=[]; rs=[]; jp=[];
fmtdt='dto3  %c%c%c %f/ %f %d:%d:%d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f  ';
fmtrs='rso3  %c%c%c %f/ %f %d:%d:%d ';
fmt_js=['js %*s %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
fmt_jp=['jb %c %d %f %d %d %d %d %d rat %f %f %f %f']
fmt_ds=['ds %*s %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
fmtsum=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format

%leemos el fichero en memoria
f=fopen(bfile);
if f < 0
    disp(['Error',bfile]);
    return
end
    s=fread(f);
    fclose(f);
    s=char(s)';
    [PATHSTR,NAME,EXT] = fileparts(bfile);
    fileinfo=sscanf([NAME,EXT],'%c%03d%02d.%03d');
    datefich=datejul(fileinfo(3),fileinfo(2));
%     datestr(datefich(1));

    l=mmstrtok(s,char(10));
    jjp=strmatch('jb',l);
    
%     jds=strfind(l,'ds');
%     j_ds=find(~cellfun(@isempty,jds));
%     jdss=strfind(l(j_ds),'summary');
%     j_dss=find(~cellfun(@isempty,jdss));
%     j_dss=j_ds(j_dss);
%% js is preceded by a ds measurement 
%  Temperature and airmass calculation can be take from previous ds
%  we need the DSP to have the wavelength
%  then we have 20 measurements taken at slit 1 wavelength 
%  
    
    jp=[];
    if ~isempty(jjp)
        jp_str=l(jjp);
        for i=1:length(jjp)
           dt_=sscanf(l{jjp(i)},fmt_jp);
           %month=char(dt_(1:3)');
           %fecha=datenum(sprintf(' %02d/%s/%02d',dt_(4),month,dt_(5)));
           %hora=dt_(6)/24+dt_(7)/24/60+dt_(8)/24/60/60;  
           %dt=[dt;[fecha+hora,dt_']];  
           jp=[jp,dt_];
        end         
    else
        jp=[];
    end
    
%     if ~isempty(jrs)
%         rs_str=l(jrs);
%         for i=1:length(jrs)
%            [rs_,caux]=sscanf(l{jrs(i)},fmtrs);
%            month=char(rs_(1:3)');
%            fecha=datenum(sprintf(' %02d/%s/%02d',rs_(4),month,rs_(5)));
%            hora=rs_(6)/24+rs_(7)/24/60+rs_(8)/24/60/60;  
%            rs_=str2num(l{jrs(i)}(26:end));
%            try
%            rs=[rs;[fecha+hora,rs_']];
%            catch
%             disp(rs_)
%            end
%         end         
%     else
%         rs=[];
%     end

%% only for 185
x=jp(:,end-9:end);

 IT=0.1147;
 F_dark=x(7,:);
 CY=x(6,:);
 F=x(8,:);
 F_0=F;
 %F_dark=x(7,1);
 F= 2*matdiv(matadd(F,-F_dark),CY)/IT;
  F(F<=0)=2;
  F(F>1E07)=1E07;
  DT=2.9E-8
  % dead time correction
  F0=F;
  for j=1:9
    F=F0.*exp(F*DT);   
  end

disp('fin');  
%%  