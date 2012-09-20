% opciones_month.outputDir=fullfile('QL157','html',sprintf('month%02d',month(now))); opciones_month.showCode=false;
% publish('ProcLampsCal_157_juanjo',opciones_month)

%% Programa para realizar el analisis de las lámparas de calibración.
clc; clear; close all;
path(genpath(fullfile(pwd,'.','matlab_uv')),path);

% VARIABLES A MODIFICAR EN EL PROGRAMA:
date_initial=[datenum(2011,1,1)];
nlamp={'026','034','039','856','1080','1083'}; 

nbr='157';      %numero del Brewer en estudio
dirin='.\QL157';  %directorio en el que se encuentran los ficheros QL de las lamparas a analizar
dirout='.\QL157\procesado'; %directorio al que se llevan las figuras creadas
dirirr='.\certificados'; %directorio en el que se encuentran los ficheros de irradiancia absoluta de las lámparas
s_ref='.\QL157\UVRES\uvr36309.157'; % respuesta usada como referencia

lamp_info=[% falla con nombres con letra
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
    if(~isnan(ql_avg{i}.date))
      ql_d{i}=[ql_avg{i}.date,ql_avg{i}.qlc'];
      ql_info{i}=[ql_avg{i}.date,repmat(str2num(nlamp{i}),length(ql_avg{i}.date),1),ql_avg{i}.temp];
    else
      ql_d{i}=[ql_avg{i}.date,ones(1,24)];
      ql_info{i}=[i,repmat(str2num(nlamp{i}),length(ql_avg{i}.date),1),ql_avg{i}.temp];
      disp(file_ql);
    end
end

%%  ANALISIS DE LOS DIAS DE CALIBRACION
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
    title(datestr(dias(i)),'FontWeight','Bold');
%     set(h,'Tag',datestr(dias(i)));
    resumen{i}=[dias(i),mean(respons(jx,2:end),1),std(respons(jx,2:end),0,1)];
% resumen de cada dia de calibracion
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

% %% ANÁLISIS DE LOS DÍAS COMUNES ENTRE LÁMPARAS:
% close all
% nlamb=length(ql_avg{1}.lamda);    %numero de longitudes de onda que hay
% for i=1:length(nlamp)-1
%     cuenta1=1;
%     for j=i+1:length(nlamp)
%         nomcom3=[];
%         %Se llama al programa que calcula los dias comunes a dos lamparas
%         %y saca una figura con diferentes gráficas de la relación entre dos
%         %lámparas:
%         [data_d{i,cuenta1},r_d{i,cuenta1},ab_d{i,cuenta1},rp_d{i,cuenta1}]=ratiod(ql_d{i},ql_d{j});
%         if isempty(data_d{i,cuenta1}) continue
%         end
%         %Se crea la matriz que contiene los valores de los ql para cada longitud de
%         %onda en los dias comunes a dos lamparas
%         ql1_l{i,cuenta1}=[ql_avg{1}.lamda',data_d{i,cuenta1}(:,2:nlamb+1)'];
%         ql2_l{i,cuenta1}=[ql_avg{1}.lamda',data_d{i,cuenta1}(:,nlamb+2:end)']; %da error si el numero de longitudes de onda de las dos lamparas no coincide
%         %Se llama al programa que calcula los dias comunes a dos lamparas
%         %y saca una figura con diferentes gráficas de la relación entre estas dos
%         %lámparas:
%         [data_l{i,cuenta1},r_l{i,cuenta1},ab_l{i,cuenta1},rp_l{i,cuenta1}]=ratiod(ql1_l{i,cuenta1},ql2_l{i,cuenta1});
%         % SE CREAN LAS FIGURAS NECESARIAS:
%         %Se crea la gráfica que muestra el ratio por longitud de onda para cada
%         %fecha
%         figure;
%       %  gris_line(size(data_l{1},2))
%         cambio=ploty(r_l{i,cuenta1});
% 
%         legend(datestr(data_d{i,cuenta1}(:,1)),-1);
%         grid
%         ylabel('Ratio');
%         xlabel('Wavelength (A)');
%         title(['Brewer ',nbr,' Lamps ',nlamp{i},' & ',nlamp{j},' : Ratio vs Lambda']);
%         figure;
%         ploty(rp_d{i,cuenta1});
%         legend(num2str(data_l{i,cuenta1}(:,1)),-1);
%         grid
%         fechcom{i,cuenta1}=unique(fix(data_d{i,cuenta1}(:,1)));
%         set(gca,'xtick',fechcom{i,cuenta1});
%         xdate{i,cuenta1}=datestr(fechcom{i,cuenta1},2);
%         datetick('x',1,'keepticks','keeplimits');
%         rotateticklabel(gca,25.0);
%                 ylabel('Ratio Porcentual');
%                 title(['Brewer ',nbr,' Lamps ',nlamp{i},' & ',nlamp{j},' : Ratio Porcentual vs Date']);
%         %Se lleva una matriz de dos dimensiones los valores de los ql para las
%         %fechas comunes a las dos lamparas
%         rl{i,cuenta1}(:,:,1)=ql1_l{i,cuenta1};
%         rl{i,cuenta1}(:,:,2)=ql2_l{i,cuenta1};
% 
%         %Se calcula la media de los ql de las dos lamparas en la misma fecha
%         qlm{i,cuenta1}=mean(rl{i,cuenta1},3);
%         % Se representa la media de los ql de dos lámparas en la misma
%         % fecha
%         figure;
%         ploty(qlm{i,cuenta1});
%         title(['Brewer ',nbr,': Lamps ',nlamp{i},' & ',nlamp{j},' Mean']);
%         ylabel('QL Mean');
%         xlabel('Wavelength (A)');
%         legend(datestr(data_d{i,cuenta1}(:,1)),-1);
%         grid
%         %Se determina el primer dia de medida como referencia para calcular un
%         %ratio para las medias de las dos lamparas y se representa dicho ratio
%         ref=qlm{i,cuenta1}(:,2);
%         ratio=matdiv(qlm{i,cuenta1}(:,2:end),ref);
%         h2=figure;
%         plot(data_d{i,cuenta1}(:,1),ratio');
%         set(gca,'xtick',fechcom{i,cuenta1});
%         datetick('x',1,'keepticks','keeplimits');
%         %set(gca,'xticklabel',xdate{i,cuenta1});
%         rotateticklabel(gca,25.0);
%         title(['Brewer ',nbr,' Lamps ',nlamp{i},' & ',nlamp{j},' Mean: Reference Day Ratio']);
%         ylabel('Ratio');
%         legend(num2str(data_l{i,cuenta1}(:,1)),-1);
%         grid;
%         cuenta1=cuenta1+1;
%         nomcom3ini = repmat(['Br',nbr,'L',nlamp{i},'_L',nlamp{j}],4,1);
%         nomcom3=[nomcom3;nomcom3ini]; 
%     end
% end
% % Se guardan las gráficas en formato PostScript:
% %nomcom3 = [repmat(nomcom3(1,:),4,1);repmat(nomcom3(2,:),4,1);repmat(nomcom3(3,:),4,1)]
% % parejas = (factorial(length(nlamp))/factorial(length(nlamp)-2))/2;
% % for k=cuenta0:parejas*4
% %     print(k,'-dpsc',fullfile(dirout,nomcom3(k,:)),'-append');
% % end
% %close all



%% RESUMEN FINAL
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
       datestr(dias(id)); ifno(jx,2);
       % falta n lamparas
       r_50w(n_50W,:)=[dias(id),mean(respons(jx,2:end))];
       temp_r50(n_50W,:)=[dias(id),mean(temp(jx))];
       n_50W=n_50W+1;
   elseif ~isempty(jx) && length(jx)==1
       datestr(dias(id)); ifno(jx,2);
       % falta n lamparas
       r_50w(n_50W,:)=[dias(id),respons(jx,2:end)];
       temp_r50(n_50W,:)=[dias(id),temp(jx)];
       n_50W=n_50W+1;
   end
end

ref_ind=find(diaj(r_50w(:,1))==124); ref_5=r_50w(ref_ind,2:end);
H=mmplotyy(r_50w(:,1),median(matdiv(r_50w(:,2:end),ref_5)')*1,'o',temp_r50(:,2),':^',[10 40]);
mmplotyy('Temperatura'); 
set(H(1),'LineWidth',2);
set(H(2),'Color',[102/256 102/256 102/256],'LineWidth',1,'MarkerSize',5,'MarkerFaceColor',[102/256 102/256 102/256]);
hold on; 
plot(gca,r_50w(:,1),smooth(r_50w(:,1),median(matdiv(r_50w(:,2:end),ref_5)')*1,7),'-g^','Linewidth',2.5)

% lamparas de 1000W
n_1KW=1;
r_kw=[];
check=[datevec(ifno(:,1))]; ifno(:,4:6)=check(:,1:3);

for id=1:length(dias)
   jx=find(abs(respons(:,1)-dias(id))<=1 & ifno(:,2)>700 );
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
ref_=r_kw(1,2:end);
% 
% % % % multiple regressiom (por estudiar)
% % % regress_coeff=[];
% % % for l=1:24 
% % % regress_coeff(l,:)=regress(r_kw(:,l+1),[r_kw(:,1),temp_rkw(:,2)]);
% % % end
% % % 
% % % intpol_regress=[]; residuos=[];
% % % for l=1:24 
% % % egress=regress_coeff(l,1)+regress_coeff(l,2)*r_kw(:,1);
% % % intpol_regress(:,l+1)=egress(:,1);
% % % end
% % % intpol_regress(:,1)=r_kw(:,1);
% % % residuos_todos={};
% % % residuos_todos={r_kw(:,1),r_kw(:,2:end),intpol(:,2:end),...
% % %                 (r_kw(:,2:end)-intpol(:,2:end))./r_kw(:,2:end)*100};% matdiv(r_kw(:,2:end)-intpol(:,2:end),r_kw(1,2:end))*100
% % 
% Interpolo entre las respuestas, un polinomio para cada longitud de onda
poly_coeff=[]; mu_all=[];
for l=1:24 
[poly,stats,mu]=polyfit(r_kw(:,1)',r_kw(:,l+1)',2);
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
legend('50W check (mediana en lamdas)','Temperatura 50W','50W smooth',...
       '1000W calibration (mediana)','Temperatura 1000W',...
        sprintf('%s%d%s','1000W Ajuste Orden#',size(poly_coeff,2)-1,' (mediana)'),...
       'Location','SouthWest');
datetick('x',12,'keeplimits','keepticks'); grid; set(gca,'YLim',[.95 1.03])

% % Ploteo de la respuesta espectral + la mediana de interpolación, y de los
% % residuos
% figure;
% subplot(3,1,1:2)
% H2=mmplotyy(r_kw(:,1),matdiv(r_kw(:,2:end),ref_)','*--',temp_rkw(:,2),'ko',[10 40]);
% mmplotyy('Temperatura'); set(gca,'YMinorGrid','on')
% set(H2(end),'MarkerSize',6,'MarkerFaceColor','k'); 
% hold on; H3=plot(r_kw(:,1),median(matdiv(r_kw(:,2:end),ref_)'),'-sk','Linewidth',2.5);
%          H4=plot(r_kw(:,1),median(matdiv(intpol(:,2:end),ref_)'),'--*m','Linewidth',2.5)
% legend([H2(12) H2(end) H3 H4],'1000W calibration (Espectral)',...
%                               'Temperatura 1000W','1000W Calibration (mediana)',...
%                               sprintf('%s%d%s','1000W Ajuste Orden#',size(poly_coeff,2)-1,' (mediana)'),...
%                               'Location','SouthWest');
% title(['Brewer#',nbr,' UV mean response ratio to initial calibration (1000W)'],'FontWeight','Bold');
% datetick('x',12,'keeplimits','keepticks'); grid
% subplot(3,1,3)
% plot(r_kw(:,1),cell2mat(residuos_todos(end)),'o--');
% hold on; plot(r_kw(:,1),median(residuos_todos{end}'),'-sk','Linewidth',1.5)
% set(gca,'YLim',[-2.5 2.5],'Ytick',[-1.5 0 1.5],'YtickLabel',[-1.5 0 1.5])
% h(1)=hline(-1.5,'r-'); h(2)=hline(1.5,'r-'); 
% h(3)=hline(-1,'b--');    h(4)=hline(1,'b--');
% set(h,'Linewidth',2); 
% title('Residuos (%)','FontWeight','Bold');
% datetick('x',12,'keeplimits','keepticks'); grid

% %Ploteo 3D
% figure; plot3(r_kw(:,1),matdiv(r_kw(:,2:end),ref_)',temp_rkw(:,2),'*-');
% hold on; plot3(r_kw(:,1),matdiv(r_kw(:,2:end),ref_)',zeros(size(r_kw(:,2:end))),'*-')
% h = reflinexyz(r_kw(:,1),median(matdiv(r_kw(:,2:end),ref_)')',temp_rkw(:,2),'color','k','linestyle','-');
% delete(h([1 2])); %[1 2]
% set(gca,'YLim',[0.8 1.05]);
% zlabel('Temperature','Fontsize',11)
% datetick('x',12,'keeplimits'); grid
%  
%  