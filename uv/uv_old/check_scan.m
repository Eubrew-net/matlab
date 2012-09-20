function check_scan(nbrw,date,lamp)


date_initial=brewer_date(date);
nlamp=lamp; nbrw=num2str(nbrw);
dirirr='.\certificados'; %directorio en el que se encuentran los ficheros de irradiancia absoluta de las lámparas
s_ref='.\QL157\UVRES\uvr36309.157';

%Se determinan los ficheros asociados a los datos introducidos
for i=1:length(nlamp)
    listin{i}=dir(fullfile('.',['QL',nbrw],['QL*',nlamp{i},'.',nbrw])); 
    fichin{i}=listin{i}.name;
end
disp(fichin)

% Se llama al programa que carga los ficheros QL (load_ql_PLC)
% Si se tienen los ficheros de irradiancia absoluta de las lámparas en el
% path de Matlab, calcula también las respuestas y saca tres gráficas por
% cada lámpara.
for i=1:length(nlamp)
    file_ql=fullfile('.',['QL',nbrw],fichin{i});
    [ql_avg{i},ql_dat{i}]=load_ql_PLC(file_ql,dirirr,[],date_initial(1));
    
    % Se crea la matriz que contiene los valores de los ql para cada fecha
    % Notar que en realidad ql_avg.qlc es la respuesta calculada
    ql_data{i}=[ql_dat{i}.date(:,1),repmat([str2num(nlamp{i}),ql_avg{i}.temp],size(ql_dat{i}.ql,1),1),...
              ql_dat{i}.ql];
    
    figure;
    subplot(3,1,1:2);
%   referencia: promedio de los scans
    ploty([ql_dat{i}.l(1,:)',matdiv((ql_data{i}(:,4:end)-repmat(nanmean(ql_data{i}(:,4:end)),size(ql_dat{i}.ql,1),1))'.*100,...
                                     nanmean(ql_data{i}(:,4:end))')]);
    set(gca,'XTickLabel',[],'Ylim',[-1.5 1.5]);% set(findobj(gca,'Type','Line'),'Linewidth',2);
    title(sprintf('%s%s %s',file_ql,'    SCAN´S','   (dif. rel. al promedio, %)'))
    leg=strcat(datestr(ql_data{i}(:,1),30),' T=',num2str(ql_data{i}(:,2)));
    legend(leg,'Location','SouthEast');  set(gca,'FontWeight','Bold');  grid;
    subplot(3,1,3);    
    plot(ql_dat{i}.l(1,:)',nanstd(ql_data{i}(:,4:end))'); 
    set(gca,'FontWeight','Bold'); grid;
end


