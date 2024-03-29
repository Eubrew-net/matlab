function data=dep_data(incidences,data)

 if size(incidences,2)>3 % Solo si se han definido periodos para depurar

    % Creamos las variables necesarias:
    % idx = ficheros que vamos a depurar
    % chk = periodos a descartar
    idx=cellfun(@(x) ~isempty(x),incidences(:,4),'UniformOutput',1);
    chk=cellfun(@(x) str2num(x),incidences(idx,4:5),'UniformOutput',0);

    % De todos los d�as cargados, escogemos los que vamos a depurar
    % Primero eliminamos dias vacios
    idx_noempty=cellfun(@(x) ~isempty(x(:,1)),data.ozone_ds,'UniformOutput',1);
    try 
        [days a b]=intersect(cellfun(@(x) unique(fix(x(:,1))),data.ozone_ds(idx_noempty),'UniformOutput',1),...
                             fix(datenum(cell2mat(chk(:,1)))));
    catch exception
        fprintf('Error en dep_data:\n%s\n(Different days at the same b file. Removing)\n',exception.message);
        % Quitamos el fichero malo
        idx_aux=cellfun(@(x) unique(fix(x(:,1))),data.ozone_ds(idx_noempty),'UniformOutput',0);
        idx_aux_=cellfun(@(x) length(x)==1,idx_aux,'UniformOutput',1);
        [days a b]=intersect(cellfun(@(x) unique(fix(x(:,1))),data.ozone_ds(idx_aux_),'UniformOutput',1),...
                             fix(datenum(cell2mat(chk(:,1)))));        
    end

    % y ahora depuramos. Usamos un bucle
    % En principio solo hara falta para ozone_ds, raw y raw0
    for dd=1:length(a)
        fprintf('Removing outliers. Day %d (from %s to %s)\n',...
                 diaj(days(dd)),datestr(chk{b(dd),1},16),datestr(chk{b(dd),2},16));

        rmv=find(data.ozone_ds{a(dd)}(:,1)>=datenum(chk{b(dd),1}) & ...
                  data.ozone_ds{a(dd)}(:,1)<=datenum(chk{b(dd),2}));                      
        data.ozone_ds{a(dd)}(rmv,:)=[];         

        rmv=find(data.raw{a(dd)}(:,1)>=datenum(chk{b(dd),1}) & ...
                  data.raw{a(dd)}(:,1)<=datenum(chk{b(dd),2}));                      
        data.raw{a(dd)}(rmv,:)=[];         

        rmv=find(data.raw0{a(dd)}(:,1)>=datenum(chk{b(dd),1}) & ...
                  data.raw0{a(dd)}(:,1)<=datenum(chk{b(dd),2}));                      
        data.raw0{a(dd)}(rmv,:)=[];                 
    end    
 end
