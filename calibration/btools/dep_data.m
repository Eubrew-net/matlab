function data=dep_data(incidences,data)

 if size(incidences,2)>3 % Solo si se han definido periodos para depurar

    % Creamos las variables necesarias:
    % idx = ficheros que vamos a depurar
    % chk = periodos a descartar
    idx=cellfun(@(x) ~isempty(x),incidences(:,4),'UniformOutput',1);
    chk=cellfun(@(x) str2num(x),incidences(idx,4:5),'UniformOutput',0);

    % De todos los días cargados, escogemos los que vamos a depurar
    [days a b]=intersect(cellfun(@(x) unique(fix(x(:,1))),data.ozone_ds,'UniformOutput',1),...
                         fix(datenum(cell2mat(chk(:,1)))));

    % y ahora depuramos. Usamos un bucle
    % En principio solo hara falta para ozone_ds, raw y raw0
    for dd=1:length(a)
        fprintf('Removing outliers. Day %d (from %s to %s)\n',...
                 diaj(days(dd)),datestr(chk{dd,1},16),datestr(chk{dd,2},16));

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
