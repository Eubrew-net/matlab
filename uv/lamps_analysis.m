
dirin=path_to_raw;  %directorio en el que se encuentran los ficheros QL de las lamparas a analizar
dirirr=fullfile(path_root,'Lamps\certificados'); %directorio en el que se encuentran los ficheros de irradiancia absoluta de las lámparas

s_ref=fullfile(path_root,'Lamps',strcat('QL',num2str(nbrw)),'UVRES\UV2016HIST.txt');
fid=fopen(s_ref,'r');
ref=textscan(fid,'%s'); ref=ref{1};
s_ref=fullfile(path_root,'Lamps',strcat('QL',num2str(nbrw)),'UVRES',ref{end}); % respuesta usada como referencia

listin={}; fichin={};
nlamp=dir(fullfile(dirin,strcat('QL*','.',num2str(nbrw))));

%% Check scans:
close all; cuenta0=1;
date=datejuli(dat(2),dat(end));
for i=1:length(nlamp);
       file_ql=fullfile(dirin,nlamp(i).name);
       [ql_avg{i},ql_dat{i}]=load_ql_check(file_ql,dirirr,[],date);

    [a b c]=fileparts(file_ql);
    if(~isnan(ql_avg{i}.date))
      ql_d{i}=[ql_avg{i}.date,ql_avg{i}.qlc'];
      ql_info{i}=[ql_avg{i}.date,...
                  repmat(str2num(b(end-2:end)),length(ql_avg{i}.date),1),ql_avg{i}.temp];
    else
      ql_d{i}=[ql_avg{i}.date,ones(1,24)];
      ql_info{i}=[i,repmat(str2num(b(end-2:end)),length(ql_avg{i}.date),1),ql_avg{i}.temp];
      disp(file_ql);
    end
end

%% Check voltaje & intensity & Hg´s:
close all
volts=dir(fullfile(dirin,strcat('KS*','.','dat')));
volts_1000=dir(fullfile(dirin,strcat('brewer*','.','dat')));

for i=1:length(volts);
    figure;
    file_volt=load(fullfile(dirin,volts(i).name));
    H=mmplotyy(file_volt(:,1),file_volt(:,3),'k+',file_volt(:,4).*10,'r*');
    title(volts(i).name); legend('Voltage','Intensity'); 
    fprintf('%s\r\nMean Int. = %f,  Mean Volt. = %f\r\nMax. = %f,  Max. Volt. = %f\r\nMin. = %f,  Min. Volt. = %f\r\nStd. Int. = %f,   Std. Volt. = %f\r\n\n',...
            volts(i).name,nanmean(file_volt(:,4).*10),nanmean(file_volt(:,3)),nanmax(file_volt(:,4).*10),nanmax(file_volt(:,3)), nanmin(file_volt(:,4).*10), nanmin(file_volt(:,3)), nanstd(file_volt(:,4).*10),nanstd(file_volt(:,3)));
end

if ~isempty(volts_1000)
    read_voltLAB(nbrw,date,path_to_raw);
end

bfile=sprintf('B%03d%02d.%03d',dat(end),dat(2)-2000,nbrw);
read_hg(fullfile(path_to_raw,bfile));

%%  Check Calibration
close all
ifno=cell2mat(ql_info');
dias=unique(fix(ifno(:,1)));

respons=cell2mat(ql_d');

lamda=ql_dat{1}.l(1,:);
last=[];
s_last='';
ref=load(s_ref);
[a,b,c]=intersect(lamda,ref(:,1));
ref_r=ref(c,:);
[p,s,m]=polyfit(ref_r(end-3:end,1),ref_r(end-3:end,2),3);
yaux=polyval(p,3495,[],m);
ref2=[ref_r(1:end-4,:);[3495,yaux];ref_r(end-3:end,:)];

for i=1:length(dias)
   jx=find(abs(respons(:,1)-dias(i))<1);
   disp(datestr(dias(i)));   disp(ifno(jx,2));

    h=figure;
    subplot(1,2,1)
    plot(lamda,respons(jx,2:end),':','LineWidth',2.5);
    title(datestr(dias(i)),'FontWeight','Bold');
    resumen{i}=[dias(i),mean(respons(jx,2:end),1),std(respons(jx,2:end),0,1)];
    if ~isempty(last)
        hold on;plot(lamda,last,'r--','lineWidth',2.5);
    end
    if ~isempty(ref2)
        hold on;plot(lamda,ref2(:,2),'m-','lineWidth',3);
    end
    warning('off', 'MATLAB:tex');
    l=legend(strvcat(num2str([diajul(ifno(jx,1)),ifno(jx,2:3)]),s_last,s_ref),'Location','SouthEast');
    set(l,'FontSize',9); grid;
    hold on; plot(lamda,mean(respons(jx,2:end)),'lineWidth',3);

     subplot(1,2,2)
    plot(lamda,matdiv(respons(jx,2:end),mean(respons(jx,2:end),1)),':','LineWidth',2.5);
    title([datestr(dias(i)),' Ratios'],'FontWeight','Bold');
    hold on;
    if ~isempty(last)
      plot(lamda,matdiv(last,mean(respons(jx,2:end),1)),'r--','LineWidth',2.5);
    end
    if ~isempty(ref2)
      plot(lamda,matdiv(ref2(:,2)',mean(respons(jx,2:end),1)),'m-','LineWidth',3);
    end
    axis([-Inf,Inf,0.95,1.05]); grid
    last=mean(respons(jx,2:end),1);
    s_last=sprintf('Last %s',datestr(respons(jx(1),1))) ;
end

% %% Creamos los ficheros uvr
% % 
% % Tengo dos respuestas: r_kw (:x25), las calculadas a partir de las lámparas, 
% % y intpol (:x25), la interpolada. Estas son las que a mi me interesan, en
% % particular trabajo con extpol, pues ahí ya tengo los periodos definidos
% % Pero están con resolucion
% % 
% % 2865 2900 2935 2970 3005 3040 3075 3110 3145 3180 3215 3250 3285 3320 3355 3390 3425 3460 3495 3495 3495 3530 3565 3600 3635
% % 
% % Las quiero cada 5 nanometros, y sin la 3495 repetida.
% % Lo que hago será interpolar con función pchip, para mantener la forma, tomando como
% % modelo las respuestas generadas por el LampPro, a saber: 
% % 1) interpolo desde 2865 a 3500, usando los valores de intpol desde 2865 a la primera 3495
% % 2) interpolo desde 3505 a 3635, usando los valores de intpol desde la segunda 3495 a 3635
% % 

respons=cell2mat(ql_d'); lamda=ql_dat{1}.l(1,:);

uvr_ = mean(respons(:,2:end),1);
intpol1=[]; intpol2=[];
indx=find(lamda==3495);

intpol1=pchip(2865:35:3495,uvr_(1:indx(1)),2865:5:3500); 
intpol2=pchip(3495:35:3635,uvr_(indx(2):end),3505:5:3635);
intpol=cat(2,intpol1,intpol2);

lambda=2865:5:3635; yy=num2str(dat(2));
uvr=sprintf('%s%03d%c%s','uvr',dat(end),yy(end-1:end),'.',nbrw), uvr_path=fullfile(dirin,uvr);
fid=fopen(uvr_path,'w');

for indx=1:length(lambda)
    fprintf(fid,' %6.1f  %8.3f\r\n',[lambda(indx) intpol(indx)]);
end
fclose(fid);
copyfile(uvr_path,fullfile(path_root,'Lamps',strcat('QL',num2str(nbrw)),'uvr',uvr));

ref_uvr=fullfile(path_root,'Lamps',strcat('QL',num2str(nbrw)),'uvr',strcat('UV',yy,'HIST.txt'));
uvrs=textscan(fopen(ref_uvr,'r'),'%s %s');
chk=[];
for i=1:length(uvrs{2})
    chk=[chk,findstr(uvr,cell2mat(uvrs{2}(i,:)))];%chequea si la respuesta nueva ya está en el historial
end

if isempty(chk)%si no está la escribe
   fiq=fopen(ref_uvr,'a');
   fprintf(fiq,'\n%02d.%02d.%4d %s',dat(4),dat(3),dat(2),uvr);
end    
fclose all;

%%  Check Calibration
close all
ifno=cell2mat(ql_info');
dias=unique(fix(ifno(:,1)));

last=[]; s_last='';
ref=load(s_ref);
[a,b,c]=intersect(lamda,ref(:,1));
ref_r=ref(c,:);
[p,s,m]=polyfit(ref_r(end-3:end,1),ref_r(end-3:end,2),3);
yaux=polyval(p,3495,[],m);
ref2=[ref_r(1:end-4,:);[3495,yaux];ref_r(end-3:end,:)];

uvrs=textscan(fopen(ref_uvr,'r'),'%s %s');
for i=1:length(uvrs{2})
    if strcmp(uvrs{2}{i},uvr)
       indx=i;
    end
end
if indx~=1
last=load(fullfile(path_root,'Lamps',strcat('QL',num2str(nbrw)),'uvr',cell2mat(uvrs{2}(indx-1,:))));
   lastleg=cell2mat(uvrs{2}(indx-1));
else
    last=[]; lastleg='';
end

for i=1:length(dias)
   jx=find(abs(respons(:,1)-dias(i))<1);
   disp(datestr(dias(i)));   disp(ifno(jx,2));

    h=figure;
    subplot(1,2,1)
   try
    plot(lamda,respons(jx,2:end),':','LineWidth',2.5);
   catch
       disp('error lamda respons');
   end
    title(datestr(dias(i)),'FontWeight','Bold');
    resumen{i}=[dias(i),mean(respons(jx,2:end),1),std(respons(jx,2:end),0,1)];
    hold on;
    if ~isempty(last)
       plot(last(:,1),last(:,2),'r--','LineWidth',2.5);
    end
    if ~isempty(ref2)
       plot(lamda,ref2(:,2),'m-','lineWidth',3);
    end
    warning('off', 'MATLAB:tex');
    l=legend(strvcat(num2str([diajul(ifno(jx,1)),ifno(jx,2:3)]),lastleg,s_ref),'Location','SouthEast');
    set(l,'FontSize',9); grid;
    hold on; plot(lamda,mean(respons(jx,2:end)),'lineWidth',3);

    subplot(1,2,2)
    try
    plot(lamda,matdiv(respons(jx,2:end),mean(respons(jx,2:end),1)),':','LineWidth',2.5);
    
    catch
     disp('error lampda respons');
    end
    title([datestr(dias(i)),' Ratios'],'FontWeight','Bold');
    hold on;
    if ~isempty(last)
      plot(last(:,1),last(:,2)./intpol','r--','LineWidth',2.5);
    end
    if ~isempty(ref2)
      plot(lamda,matdiv(ref2(:,2)',mean(respons(jx,2:end),1)),'m-','LineWidth',3);
    end
    axis([-Inf,Inf,0.92,1.05]); grid   
end

% %%Promedio en longitud de onda de cada ratio de cada lámpara
f=matdiv(respons(jx,2:end),mean(respons(jx,2:end),1));%divide cada respuesta del equipo calculada con cada lámpara entre la media de las respuestas generadas por el equipo con todas las lámparas
%me la mide para cada longitud de onda, por eso he de promediarla
Promedio_long_onda=mean(f,2);%el 2 me indica que la media se hará por filas
Desvi=std(f,0,2);
lamp=ifno(:,2);
z=[datenum(datestr(respons(:,1))),repmat(nbrw(i),size(jx,1),1),lamp,Promedio_long_onda,Desvi];%Matriz donde se incluye
% Tabla:fecha para cada lámpara,número de brewer,promedio en longitud de onda para
%cada lámpara y desviación estándar.
t={'Fecha','Brewer','Numero_lampara','Promedio_ratio','Desviacion_estandar'};

displaytable(z,t);

%%
makeHtmlTable(z,[],cellstr(datestr(z(:,1))),t);%me permite generar una tabla en el html

%% 
% %% Promedio de la última respuesta entre el promedio de las respuestas de
% %%todas las lámparas
m=(last(:,2)./intpol');%divide la última respuesta del equipo entre la media de las respuestas generadas por el equipo con todas las lámparas
%me la mide para cada longitud de onda, por eso he de promediarla
p=NaN
Promedio_long_onda_=mean(m);%el 2 me indica que la media se hará por filas
Desvi_=std(m);
displaytable([p,Promedio_long_onda_,Desvi_],{'Última_respuesta','Promedio_ratio','Desviacion_estandar'});
%%
makeHtmlTable([p,Promedio_long_onda_,Desvi_],{'Última_respuesta','Promedio_ratio','Desviacion_estandar'});%me permite generar una tabla en el html


%% Promedio de la respuesta de referencia entre el promedio de las respuestas de
%%todas las lámparas

y=matdiv(ref2(:,2)',mean(respons(jx,2:end),1));
Promedio_long_onda__=mean(y);%el 2 me indica que la media se hará por filas
Desvi__=std(y);
k=NaN;
displaytable([k,Promedio_long_onda__,Desvi__],{'Respuesta_referencia','Promedio_ratio','Desviacion_estandar'})
%%
makeHtmlTable([k,Promedio_long_onda__,Desvi__],{'Respuesta_referencia','Promedio_ratio','Desviacion_estandar'});%me permite generar una tabla en el html

