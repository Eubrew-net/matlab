% Programa para realizar el analisis de las lámparas de calibración.
clc; clear; close all;  
path(genpath(fullfile(pwd,'.','matlab_uv')),path);

% VARIABLES A MODIFICAR EN EL PROGRAMA:
date_initial=[datenum(2006,08,01) datenum(2011,5,30)];% 2006
nlamp={'646','650','026','034','039', '957','958','1081', '856','1080','1083'};%
%'646','650','856','958','1005','1201','1202','1083'
% numero de las lamparas a analizar
% Año 2005: '646','650','957','1080','1081','1083'
% Año 2006: '646','650','957','958','1080','1081'
% Año 2007: '646','650','856','957','1080'
% Año 2008: '646','650','856','957','958','1004','1080','1083'
% Año 2009: '026','034','039','646','650','856','958','1083'  % Hay que
% comprobar que pasa con la 1005. La calibracion de AFC de Octubre
% descartada para todos los brewer. En todos da un 2% por debajo de lo que
% deberia!!
% Año 2010: '856','1080','1005'; 

% Año 2008 y 2009 new standar: '103','857','856','1083'
% Todo: '646','650','856','957','958','1004','1080','1081','1083'

lamp_info=[   % falla con nombres con letra
%     646,50;
%     647,50;
%     648,50;
%     650,50;
    103,1000;
    857,1000;
    856,1000;
%     858,1000;
%     957,1000;
%     958,1000;
%     1004,1000;
%     1005,1000;
%     1080,1000;
%     1081,1000;
    1083,1000;
%     1201,1000;
%     1202,1000;
% 959,1000;
     ];

nbr='183';      %numero del Brewer en estudio
dirin='.\QL183';  %directorio en el que se encuentran los ficheros QL de las lamparas a analizar
dirout='.\QL183\procesado'; %directorio al que se llevan las figuras creadas
dirirr='.\certificados'; %directorio en el que se encuentran los ficheros de irradiancia absoluta de las lámparas
s_ref='.\QL183\UVRES\uvr21307.183';

%Se determinan los ficheros asociados a los datos introducidos
listin=cell(1,length(nlamp)); fichin=cell(1,length(nlamp));
for i=1:length(nlamp)
    listin{i}=dir(fullfile(dirin,strcat('QL*',nlamp{i},'.',nbr))); 
    fichin{i}=listin{i}.name;
end
disp(fichin);

%% ANÁLISIS INDIVIDUAL DE LAS LÁMPARAS: 
close all
% Se llama al programa que carga los ficheros QL (load_ql_PLC)
% Si se tienen los ficheros de irradiancia absoluta de las lámparas en el
% path de Matlab, calcula también las respuestas y saca tres gráficas por
% cada lámpara.
cuenta0=1;
for i=1:length(nlamp);
    file_ql=fullfile(dirin,fichin{i});
    [ql_avg{i},ql_dat{i}]=load_ql_PLC(file_ql,dirirr,[],date_initial);
    
    % Se crea la matriz que contiene los valores de los ql para cada fecha
    % Notar que en realidad ql_avg.qlc es la respuesta calculada
    ql_d{i}=[ql_avg{i}.date,ql_avg{i}.qlc'];
    ql_info{i}=[ql_avg{i}.date,repmat(str2num(nlamp{i}),length(ql_avg{i}.date),1),ql_avg{i}.temp];

% Se guardan las gráficas en formato PostScript:
%     nomcom1=['Br',nbr,'L',nlamp{i}];
%     for j=cuenta0:cuenta0+2
%         print(j,'-dpsc',fullfile(dirout,nomcom1),'-append');
%     end
end

%%  ANALISIS DE LOS DIAS DE CALIBRACION %%%%%%%%%%%%%%%%%%%%%%%%%
close all
ifno=cell2mat(ql_info');
dias=unique(fix(ifno(:,1)));% dias con calibracion de cualquier lampara
if length(date_initial)==1
dias=dias(dias(:,1)>date_initial(1));
else dias=dias(dias(:,1)>date_initial(1) & dias(:,1)<date_initial(2));
end

respons=cell2mat(ql_d'); % ¡Todas las lamparas declaradas!

lamda=ql_dat{1}.l(1,:);
last=[];
s_last='';
ref=load(s_ref);
[a,b,c]=intersect(lamda,ref(:,1));
ref_r=ref(c,:);
[p,s,m]=polyfit(ref_r(end-3:end,1),ref_r(end-3:end,2),3);
yaux=polyval(p,3495,[],m);
ref2=[ref_r(1:end-4,:);[3495,yaux];ref_r(end-3:end,:)];
% Lo anterior se hace porque el fichero uvr que genera el LampPro no presenta la doble 3495

for i=1:length(dias)
   jx=find(abs(respons(:,1)-dias(i))<=1);% buscamos entre todos los dias de lamparas
   % los que esten en un rango de 3 dias (hacia atras o hacia adelante)
   % respecto de  aquellos dias comunes para las lamparas estudiadas 
   disp(datestr(dias(i)));   disp(ifno(jx,2));
 
  
    h=figure;
     subplot(1,2,1)
     plot(lamda,respons(jx,2:end),':','LineWidth',2.5);
     legend(cellstr(num2str([diajul(ifno(jx,1)),ifno(jx,2:3)])),'Location','SouthEast')
     hold on;
     title(datestr(dias(i)),'FontWeight','Bold');
     set(h,'Tag',datestr(dias(i)));
     resumen{i}=[dias(i),mean(respons(jx,2:end),1),std(respons(jx,2:end),0,1)];
 %  resumen de cada dia de calibracion
     plot(lamda,mean(respons(jx,2:end)),'lineWidth',3);

     if ~isempty(last)
         plot(lamda,last,'r--','lineWidth',2.5);
     end
     if ~isempty(ref2)
         plot(lamda,ref2(:,2),'m-','lineWidth',3);
     end
     grid;
    %axis([-Inf,Inf,6500,9000])
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
    warning('off', 'MATLAB:tex'); legend(strvcat(num2str([diajul(ifno(jx,1)),ifno(jx,2:3)]),s_last,s_ref));
    axis([-Inf,Inf,0.95,1.05]); grid
%     set(gca,'YLim',[.96 1.04],'FontSize',19,'FontWeight','Demi');
    last=mean(respons(jx,2:end),1);
    s_last=sprintf('Last %s',datestr(respons(jx(1),1))) ;         
end
% nomcom1='AnalisisDiasCalibracion';
% for j=cuenta0:length(dias)
%     print(j,'-dpsc',fullfile(dirout,nomcom1),'-append');
% end

figure;
lamda=ql_dat{1}.l(1,:);
rex=cell2mat(resumen');
% resumen{i}=[dias(i),mean(respons(jx,2:end),1),std(respons(jx,2:end),0,1)];
% osea, que ploteamos para todos los dia que hubo calibracion con cualquier
% lámpara, la respuesta promedio
l=size(rex,1);
errorbar(repmat(lamda,l,1)',rex(:,2:25)',rex(:,26:end)');
legend(datestr(rex(:,1)));
title('Mean Responses')
%print('-dpsc',fullfile(dirout,'MeanResponses'));
%close all

%% RESUMEN FINAL 
% lamparas de 50
% lamp_50={'646','650'};

% lamparas de 1000
% lamp_1000={'1080','1081','1083','856','957','958','104'}; 

ifno=cell2mat(ql_info');
dias=unique(fix(ifno(:,1))); % dias de calibracion (con cualquier lámpara,
lamda=ql_dat{1}.l(1,:);      % incluso una sola)                   
respons=cell2mat(ql_d'); % ql_d eran respuestas
temp=[]; 
for inx=1:size(ql_avg,2)
temp=[temp; ql_avg{inx}.temp];% ql_d{i}=[ql_avg{i}.date,ql_avg{i}.qlc'];
end

figure
% lamparas de 50W
n_50W=1;
r_50w=[]; temp_r50=[];
for id=1:length(dias)
   jx=find(abs(respons(:,1)-dias(id))<1 & ifno(:,2)<700 );
   if ~isempty(jx) && length(jx)>1
       datestr(dias(id));
       ifno(jx,2);
       % falta n lamparas
       r_50w(n_50W,:)=[dias(id),mean(respons(jx,2:end))];
       temp_r50(n_50W,:)=[dias(id),mean(temp(jx))];
       n_50W=n_50W+1;
   end
end

ref_5=r_50w(1,2:end);
H=mmplotyy(r_50w(:,1),median(matdiv(r_50w(:,2:end),ref_5)')*1.08,'*',temp_r50(:,2),':^',[10 40]);
mmplotyy('Temperatura'); 
set(H(1),'LineWidth',2);
set(H(2),'Color',[102/256 102/256 102/256],'LineWidth',1,'MarkerSize',5,'MarkerFaceColor',[102/256 102/256 102/256]);
hold on; 
plot(gca,r_50w(:,1),smooth(r_50w(:,1),median(matdiv(r_50w(:,2:end),ref_5)'),7)*1.08,'-g^','Linewidth',2.5)

% lamparas de 1000W
n_1KW=1;
r_kw=[];
check=[datevec(ifno(:,1))]; ifno(:,4:6)=check(:,1:3);

for id=1:length(dias)
   jx=find(abs(respons(:,1)-dias(id))<1 & ifno(:,2)>700 );
   if ~isempty(jx)
       datestr(dias(id));
       ifno(jx,2)
       % Falta escribir un fichero con
       % resultados (lo que se hace)
       if  length(jx)>=2
            r_kw(n_1KW,:)=[dias(id),mean(respons(jx,2:end))];
            temp_rkw(n_1KW,:)=[dias(id),mean(temp(jx))];
       else
            r_kw(n_1KW,:)=[dias(id),respons(jx,2:end)];
            temp_rkw(n_1KW,:)=[dias(id),mean(temp(jx))];
       end
       n_1KW=n_1KW+1;
   end
end
ref_=r_kw(8,2:end);% Cambia la respuesta espectral

% Interpolo entre las respuestas, un polinomio para cada longitud de onda
poly_coeff=[]; mu_all=[];
for l=1:24 
[poly,stats,mu]=polyfit(r_kw(:,1)',r_kw(:,l+1)',1);
poly_coeff(l,:)=poly; mu_all{l}=mu;
end

intpol=[]; residuos=[];
for l=1:24 
intpol(:,l+1)=polyval(poly_coeff(l,:),r_kw(:,1)',[],mu_all{l});
end
intpol(:,1)=r_kw(:,1);
residuos_todos={};
residuos_todos={r_kw(:,1),r_kw(:,2:end),intpol(:,2:end),...
                (r_kw(:,2:end)-intpol(:,2:end))./r_kw(:,2:end)*100};% matdiv(r_kw(:,2:end)-intpol(:,2:end),r_kw(1,2:end))*100

H=mmplotyy(r_kw(:,1),median(matdiv(r_kw(:,2:end),ref_)'),'--sk',temp_rkw(:,2),'ko',[10 40]);
mmplotyy('Temperatura'); 
set(H(1),'LineWidth',2);
set(H(2),'MarkerSize',6,'MarkerFaceColor','k'); 
hold on; 
plot(gca,r_kw(:,1),median(matdiv(intpol(:,2:end),ref_)')','-ro','LineWidth',2.5)
title(['Brewer#',nbr,' UV mean response ratio to initial calibration']);
h=legend('50W check (mediana en lamdas)','Temperatura 50W','50W smooth',...
       '1000W calibration (mediana)','Temperatura 1000W',...
        sprintf('%s%d%s','1000W Ajuste Orden#',size(poly_coeff,2)-1,' (mediana)'),...
       'Location','SouthWest'); set(h,'FontSize',9);
datetick('x',12,'keeplimits','keepticks'); grid

% Ploteo de la respuesta espectral + la mediana de interpolación, y de los
% residuos
figure;
subplot(3,1,1:2)
H2=mmplotyy(r_kw(:,1),matdiv(r_kw(:,2:end),ref_)','*--',temp_rkw(:,2),'ko',[10 40]);
mmplotyy('Temperatura'); set(gca,'YMinorGrid','on')
set(H2(end),'MarkerSize',6,'MarkerFaceColor','k'); 
hold on; H3=plot(r_kw(:,1),median(matdiv(r_kw(:,2:end),ref_)'),'-sk','Linewidth',2.5);
         H4=plot(r_kw(:,1),median(matdiv(intpol(:,2:end),ref_)'),'--*m','Linewidth',2.5)
h=legend([H2(12) H2(end) H3 H4],'1000W calibration (Espectral)',...
                              'Temperatura 1000W','1000W Calibration (mediana)',...
                              sprintf('%s%d%s','1000W Ajuste Orden#',size(poly_coeff,2)-1,' (mediana)'),...
                              'Location','SouthWest'); set(h,'FontSize',9);
title(['Brewer#',nbr,' UV mean response ratio to initial calibration (1000W)'],'FontWeight','Bold');
datetick('x',12,'keeplimits','keepticks'); grid
subplot(3,1,3)
plot(r_kw(:,1),cell2mat(residuos_todos(end)),'o--');
hold on; plot(r_kw(:,1),median(residuos_todos{end}'),'-sk','Linewidth',1.5)
set(gca,'YLim',[-2.5 2.5],'Ytick',[-1.5 0 1.5],'YtickLabel',[-1.5 0 1.5])
h(1)=hline(-1.5,'r-'); h(2)=hline(1.5,'r-'); 
h(3)=hline(-1,'b--');    h(4)=hline(1,'b--');
set(h,'Linewidth',2); 
title('Residuos (%)','FontWeight','Bold');
datetick('x',12,'keeplimits','keepticks'); grid

%% Ploteo con ajuste manual
periodos={
%           periodo1: 11/Octubre/2006 a 1/Septiembre/2007 (between IOS's)
            [datenum(2006,10,11) datenum(2007,09,1)]
%           periodo2: 2/Septiembre/2007 a 5/Septiembre/2009 (between IOS's)            
            [datenum(2007,09,2) datenum(2009,09,5)]
%           periodo3: 6/Septiembre/2009 a 25/Septiembre/2010 (between IOS's)
            [datenum(2009,09,6) datenum(2010,09,25)]
%           periodo4: (from IOS10 to now, last update: 20/April/2011)
            [datenum(2010,09,26) now]             
         };
events_line=cell2mat(periodos)';  events_label={'IOS06','IOS07','IOS09','IOS10'};  
     
intpol={};  extpol={};
for p=1:length(periodos)
    poly_coeff=[]; mu=[]; stat=[]; extpol_per=[];
    indx = find(r_kw(:,1)>=periodos{p}(1) & r_kw(:,1)<periodos{p}(2));
    extpol_per=(periodos{p}(1):30:periodos{p}(2))'; extpol_per(end)=periodos{p}(2);
    if p==1 % cogemos la media
       intpol{p}=[r_kw(indx,1),repmat(mean(r_kw(indx,2:end)),length(indx),1)];        % Sólo lamps    
       extpol{p}=[extpol_per,repmat(mean(r_kw(indx,2:end)),length(extpol_per),1)];    % Periodos        
    elseif p==3 % cogemos la media
       intpol{p}=[r_kw(indx,1),repmat(mean(r_kw(indx,2:end)),length(indx),1)];        % Sólo lamps    
       extpol{p}=[extpol_per,repmat(mean(r_kw(indx,2:end)),length(extpol_per),1)];    % Periodos        
    else % Interpolaciòn lineal (ver grafico, si sale ;))
       for l=1:24
           [poly_coeff(l,:),stat,mu(l,:)]=polyfit(r_kw(indx,1)',r_kw(indx,l+1)',1);
           intpol{p}(:,l+1)=polyval(poly_coeff(l,:),r_kw(indx,1)',[],mu(l,:));        % Sólo lamps
           extpol{p}(:,l+1)=polyval(poly_coeff(l,:),extpol_per,[],mu(l,:));           % Periodos
       end
       intpol{p}(:,1)=r_kw(indx,1);     extpol{p}(:,1)=extpol_per';
    end        
end

figure
H=plot(r_50w(:,1),median(matdiv(r_50w(:,2:end),ref_5)')*1.08,'o'); 
set(H,'LineWidth',2);
hold on; 
plot(gca,r_50w(:,1),smooth(r_50w(:,1),median(matdiv(r_50w(:,2:end),ref_5)'),7)*1.08,'-g^','Linewidth',2.5);
H=plot(r_kw(:,1),median(matdiv(r_kw(:,2:end),ref_)'),'--sk');
set(H,'LineWidth',2);
vl=vline(events_line(1,:),'-k',events_label); set(vl,'Linewidth',1.5); 
% ploteo de extpol's
for p=1:length(periodos)
    plot(gca,extpol{p}(:,1),median(matdiv(extpol{p}(:,2:end),ref_)')','-r*','LineWidth',2.5);
end

title(['Brewer#',nbr,' UV mean response ratio to initial calibration'],'FontSize',12,'FontWeight','Bold');
legend('UV check (mediana en lamdas)','UV check smooth','1000W calibration (mediana)',...
       '1000W Ajuste Final (mediana)','Location','SouthWest');
datetick('x',12,'keeplimits','keepticks'); grid

% Ploteo de la respuesta espectral + la mediana de interpolación, y de los residuos
residuos={}; intpol_res=cell2mat(intpol');
residuos={r_kw(:,1),r_kw(:,2:end),intpol_res(:,2:end),...
                (r_kw(:,2:end)-intpol_res(:,2:end))./r_kw(:,2:end)*100};% matdiv(r_kw(:,2:end)-intpol(:,2:end),r_kw(1,2:end))*100

figure;
subplot(3,1,1:2)
H2=mmplotyy(r_kw(:,1),matdiv(r_kw(:,2:end),ref_)','*--',temp_rkw(:,2),'ko',[10 40]);
mmplotyy('Temperatura'); set(gca,'YMinorGrid','on');
set(H2(end),'MarkerSize',6,'MarkerFaceColor','k'); 
hold on; H3=plot(r_kw(:,1),median(matdiv(r_kw(:,2:end),ref_)'),'-sk','Linewidth',2.5);
         for p=1:length(periodos)
             H4=plot(gca,intpol{p}(:,1),median(matdiv(intpol{p}(:,2:end),ref_)')','-r*','LineWidth',2.5);
         end
vl=vline(events_line(1,:),'-r',events_label); set(vl,'Linewidth',1.5); 
set(gca,'xTickLabel',[]); grid;
title(['Brewer#',nbr,' UV mean response ratio to initial calibration (1000W)'],'FontWeight','Bold');
legend([H2(12) H2(end) H3 H4],'1000W calibration (Espectral)',...
                              'Temperatura 1000W','1000W Calibration (mediana)',...
                              '1000W Ajuste Final (mediana)',...
                              'Location','SouthWest');
subplot(3,1,3)
plot(r_kw(:,1),residuos{end},'o--');
hold on; plot(r_kw(:,1),median(residuos{end}'),'-sk','Linewidth',2)
set(gca,'YLim',[-2.5 2.5],'Ytick',[-1.5 0 1.5],'YtickLabel',[-1.5 0 1.5])
h(1:2)=hline([-1.5 1.5],'r-'); h(3:4)=hline([-1 1],'b--'); set(h,'Linewidth',2); 
title('Residuos (%)','FontWeight','Bold');
vl=vline(events_line(1,:),'-r'); set(vl,'Linewidth',1.5); 
datetick('x',12,'keeplimits','keepticks'); grid

%% Creamos los ficheros uvr
% 
% Tengo dos respuestas: r_kw (:x25), las calculadas a partir de las lámparas, 
% y intpol (:x25), la interpolada. Estas son las que a mi me interesan,
% pero están con resolucion
% 
% 2865 2900 2935 2970 3005 3040 3075 3110 3145 3180 3215 3250 3285 3320 3355 3390 3425 3460 3495 3495 3495 3530 3565 3600 3635
% 
% Las quiero cada 5 nanometros, y sin la 3495 repetida.
% Lo que hago será interpolar con función pchip, para mantener la forma, tomando como
% modelo las respuestas generadas por el LampPro, a saber: 
% 1) interpolo desde 2865 a 3500, usando los valores de intpol desde 2865 a la primera 3495
% 2) interpolo desde 3505 a 3635, usando los valores de intpol desde la segunda 3495 a 3635
% 

rall_intpol1=[]; rall_intpol2=[];
intpol_res=cell2mat(intpol');
indx=find(lamda==3495);
for l=1:size(intpol_res,1) 
    rall_intpol1(l,:)=pchip(2865:35:3495,intpol_res(l,2:indx(1)+1),2865:5:3500); 
    rall_intpol2(l,:)=pchip(3495:35:3635,intpol_res(l,indx(2)+1:end),3505:5:3635);
end
rall_intpol=cat(2,r_kw(:,1),rall_intpol1,rall_intpol2);

lambda=2865:5:3635;
mkdir(fullfile(dirin,'UVRES','resp_intp'));
for dd=1:size(intpol_res,1)    
    fech=datevec(r_kw(dd,1)); yy=num2str(fech(1));
    uvr=fullfile(dirin,'UVRES','resp_intp',...
                 sprintf('%s%03d%s.%s','uvr',diaj(intpol_res(dd,1)),yy(end-1:end),nbr))
    fid=fopen(uvr,'w');
    for indx=1:length(lambda)
        fprintf(fid,' %4d  %8.3f\r\n',[lambda(indx) rall_intpol(dd,indx+1)]);
    end
    fclose(fid);
end


