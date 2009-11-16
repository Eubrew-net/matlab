function [sl_sum,slm,SL_T]=sl_2000(bfile,config)
dsum=[];ds=[];dss=[];timeds=[];timedss=[];ds_l=[];ds_aod=[];
%leemos el fichero en memoria
f=fopen(bfile);
s=fread(f);
fclose(f);
s=char(s)';
[path,file]=fileparts(bfile);
fileinfo=sscanf(file,'%c%03d%02d.%03d');
datefich=datejul(fileinfo(3),fileinfo(2));

datestr(datefich(1))

l=mmstrtok(s,char(10));

% [line,rest]=strtok(s,char(10));
% i=1;
% l{i}=line;
% l
% while length(rest)
%     [line,rest]=strtok(rest,char(10));
%     l{i}=line; %    {strrep(line,char(13),' ');}
%     i=i+1;
% end
% disp(i)

jsl=strmatch('sl',l);
jsum=strmatch('summary',l);
%jco=strmatch('co',l);
%jum=strmatch('um',l);


fmtds=[' ds %c %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
fmtsl=[' sl %c %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
fmt=['ds %*s %d %f %d %d %d %d %d %d %d %d %d %d rat %d %d %d %d']; % format of ds Bfile
fmtsum=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format
fmtsum_output=['summary\r%d:%d:%d\r%c%c%c\r%d/\r%d\r%.5f\r%.3f\r%d\r%c%c\r%d\r%d\r%d\r%d\r%d\r%d\r%d\r%.1f\r%.1f\r%d\r%d\r%d\r%d\r%d\r%d\r%.1f\r%.1f']; % output summary format

%fmtinst=['inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%d'];
fmtinst=['inst %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f mk%*3c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'];
TCfmt=['inst %f %f %f %f %f '];
absfmt=['inst %*f %*f %*f %*f %*f %*f %f %f %f '];
extratfmt=['inst %*f %*f %*f %*f %*f %*f %*f %*f %*f %f %f'];
dtfmt=['inst %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f'];

fmtum=['um %d %d %d %*s %f %f %f pr %f %d %f %d %d %d %d %d %d %d %d %d rat %d %d %d %d'];
fmtum_output=['summary\r%d:%d:%d\r%c%c%c\r%f/\r%f\r%f\r%f\r%f\r%c%c\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f\r%f']; % output um format
%measures=cell('ds','zs','uq','co');


ds=[];sl=[];
dss=[];sls=[];
ndss=0;
timedsum=[];
timeds=[];
% um=[];
%
% for i=1:length(jum)
%     um_=sscanf(l{jum(i)},fmtum);
%     type='um';
%     fecha=datenum(um_(3)+2000,um_(2),um_(1));
%     hora=um_(9)/60/24;
%     timeline=[timeline;[fecha+hora,jum(i),type(1)+type(2)/1000]];
%     um=[um;[fecha+hora,um_']];
% end

%read header
filter=[0,64,128,192,256];
buf=l{1}; % get first line, should be version...
if any(strmatch('version',buf))==1, %then OK
    ind=find(buf==char(13));
    lat=str2num(buf(ind(6):ind(7)));
    long=str2num(buf(ind(7):ind(8)));
    pr=str2num(buf(ind(end-1):end));
end

buf=l{2};
if any(strmatch('inst',buf))==1, %then OK
    ind=find(buf==char(13));
    TC=sscanf(buf,TCfmt)';
    DT=sscanf(buf,dtfmt);
    extrat=sscanf(buf,extratfmt);
    absx=sscanf(buf,absfmt);
end
inst=sscanf(l{2},fmtinst);
AT=inst(16:21); % atenuation filters


if nargin>1 & isstr(config)==0
    cal_idx=max(fkind(config(1,:)<=datefich(1))); % calibracion mas proxima
    datestr(config(1,cal_idx) )
    if ~isnan(config(2:6,cal_idx))
        TC=config(2:6,cal_idx); end
    if ~isnan(config(13,cal_idx))
        DT=config(13,cal_idx);  end
    if ~isnan(config(11:12,cal_idx))
        extrat=config(11:12,cal_idx); end %    B1=extrat(1);B2=extrat(2);
    if ~isnan(config(8:10,cal_idx))
        absx=config(8:10,cal_idx);    end % A1=absx(1);A2=absx(2);A3=absx(3);
    if ~isnan(config(17:22,cal_idx))
        AT=config(17:22,cal_idx);     end % atenuacion
else
    if nargin>1
        [config,TC,DT,extrat,absx,AT]=read_icf(config);
    end
end

% if nargin>1
%     cal_idx=max(find(config(1,:)<=datefich(1))); % calibracion mas proxima
%     datestr(config(1,cal_idx) )
%     if ~isnan(config(2:6,cal_idx))
%         TC=config(2:6,cal_idx); end
%     if ~isnan(config(13,cal_idx))
%         DT=config(13,cal_idx);  end
%     if ~isnan(config(11:12,cal_idx))
%         extrat=config(11:12,cal_idx); end %    B1=extrat(1);B2=extrat(2);
%     if ~isnan(config(8:10,cal_idx))
%         absx=config(8:10,cal_idx);    end % A1=absx(1);A2=absx(2);A3=absx(3);
%     if ~isnan(config(17:22,cal_idx))
%         AT=config(17:22,cal_idx);     end % atenuacion
% end
%

ndss=0;
for i=1:length(jsum)
    dsum=sscanf(l{jsum(i)},fmtsum);
    type=char(dsum(12:13)');
    month=char(dsum(4:7)');
    fecha=datenum(sprintf(' %02d/%s/%02d',dsum(7),month,dsum(8)));
    hora=dsum(1)/24+dsum(2)/24/60+dsum(3)/24/60/60;
    if strmatch('sl',type)

        ndss=ndss+1;
        jdssum(ndss)=jsum(i);
        sl_idx=find(jsl-jsum(i)<0 & jsl-jsum(i)>=-7);
        jsl(sl_idx);
        if length(sl_idx)==7

            timedsum=[timedsum;[fecha+hora,jsum(i)]];
            sls=[sls,dsum];
            for ii=1:7
                sl_=sscanf(l{jsl(sl_idx(ii))},fmtsl);
                if size(sl_,1)==17
                    sl=[sl,sl_];
                    hora=sl_(3)/60/24;
                    timeds=[timeds;[fecha+hora,jsl(sl_idx(ii)),size(sls,2)]];
                end
            end
        end
        %disp(jsum(i));
    end
end

if ~isempty(sls)
    hora=sls(1,:)*60+sls(2,:)+sls(3,:)/60;



    timeds=[timeds,sls(11,timeds(:,3))']; % temperatura;dss(11);

    sl=sl';
    sls=sls';
    slm=[timeds,sl];
    sl_sum=[timedsum,sls(:,9:11),sls(:,[14,22,30,21,29]),sls(:,[15,23,16,24,17,25,18,26,19,27,20,28])];
    F=sl(:,8:13);
    SL_T=ds_escale(F,sl(:,2),timeds(:,end),sl(:,6),DT,TC,AT);
   %SL_T=[timeds,SL_T];


%     %     %RC=rayleigth_cor(F,P,M3)
   %  DS=rayleigth_cor(DS_,770,m3ds);
     DS=SL_T;
     ms4=DS(:,5)-DS(:,2);
     ms5=DS(:,5)-DS(:,3);
     ms6=DS(:,5)-DS(:,4);
     ms7=DS(:,6)-DS(:,5);
     ms9=ms5-0.5*ms6-1.7*ms7;     % o3 double ratio ==MS(9)
     ms8=ms4-3.2*ms7;            %:REM SO2 ratio MS(8)
% 
     SL_T=[timeds,SL_T,ms8,ms9];

    %
    %
    %     MS9=ds(:,15)-0.5*ds(:,16)-1.7*ds(:,17); % o3 double ratio ==MS(9)
    %     MS8=ds(:,14)-3.2*ds(:,17); %:REM SO2 ratio MS(8)
    %
    %
    %     B1=extrat(1);B2=extrat(2);
    %     A1=absx(1);A2=absx(2);A3=absx(3);
    %
    %     OZONE=(MS9-B1)./(10*A1*m2ds);
    %     SO2=(MS8-B2)./(A2*A3*m2ds)-OZONE/A2;
    %
    %     ozone=(ms9-B1)./(10*A1*m2ds);
    %     so2=(ms8-B2)./(A2*A3*m2ds)-ozone/A2;
    %
    %
    %     ds_l=[timeds(:,1),tst_ds/60,szads,m3ds,m2ds,timeds(:,end),ds(:,6),ozone,OZONE,so2,SO2...
    %             ms4,ds(:,14),ms5,ds(:,15),ms6,ds(:,16),ms7,ds(:,17),ms8,MS8,ms9,MS9];
    %     ds_aod=[timeds(:,1),tst_ds/60,szads,m3ds,m2ds,timeds(:,end),ds(:,2),ozone,OZONE,so2,SO2,...
    %             DS_,DS];

else
warning ('Fichero vacio');
dsum=[];ds=[];dss=[];timeds=[];timedss=[];ds_l=[];
end







function DS=ds_escale(F,Filtro,temp,CY,DT,TC,AF)
%correccion por dark

F_dark=F(:,1);
IT=0.1147;
for j=2:6
    F(:,j) = 2*[F(:,j)-F_dark]./CY/IT;
end
% dead time correction
F0=F;
for j=1:9
    for i=2:6
        F(:,i)=(F0(:,i).*exp(F(:,i)*DT));
    end
end
j=find(F<=0);
F(j)=2;
F=log10(F)*10^4;  %aritmetica entera

% Filtro=(Filtro/64)+1;
% for j=2:6
%     F(:,j)=F(:,j)+TC(j-1)*temp+AF(Filtro);
% end
% 
 DS=F;



function DS=ds_counts(F,Filtro,temp,CY,DT,TC,AF)
%correccion por dark

F_dark=F(:,1);
IT=0.1147;
for j=2:6
    F(:,j) = 2*[F(:,j)-F_dark]./CY/IT;
end
% dead time correction
F0=F;
for j=1:9
    for i=2:6
        F(:,i)=(F0(:,i).*exp(F(:,i)*DT));
    end
end
j=find(F<=0);
F(j)=2;
F=log10(F)*10^4;  %aritmetica entera

Filtro=(Filtro/64)+1;
%filtos y temperatura
for j=2:6
    F(:,j)=F(:,j)+(TC(j)*temp)+AF(Filtro);
end
DS=F;

function RC=rayleigth_cor(F,P,M3)

BE=[0,4870,4620,4410,4220,4040];

for j=2:6

    F(:,j)=F(:,j)+BE(j)*M3*P/1013;
end
RC=F;



%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ds
% if strmatch('ds',type)
%         ndss=ndss+1;
%         jdssum(ndss)=jsum(i);
%         ds_idx=find(jds-jsum(i)<0 & jds-jsum(i)>=-5);
%         %jds(ds_idx);
%         if length(ds_idx)==5
%           dss=[dss,dsum];
%           for ii=1:5
%            ds_=sscanf(l{jds(ds_idx(ii))},fmtds);
%            ds=[ds,ds_];
%            hora=ds_(3)/60/24;
%            %timeline=[timeline;[fecha+hora,jds(ds_idx(ii)),type(1)+type(2)/1000]];
%           end
%         end
%         %disp(jsum(i));
%     end