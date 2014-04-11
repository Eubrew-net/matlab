function  [A,ETC,SL_B,SL_R,F_corr,cfg]=read_cal_config_new(config,file_setup,sl_s)
% 

% Updated:
%   - 27/11/2012 (Juanjo): Now it gives filter correction as output
% 
% INPUT:
%   - config: columna 1 % 1º configuracion (cuando 2 configs.) o la del fichero B
%             columna 2 % 2º configuracion (o única configuración)
%             columna 3 % configuracion del fichero B
%   - file_setup
%   - sl_s  : daily values: 'time','R6','R5','T','F1','F5' (median,std)
%             Puede ser una celda de dos elementos, para 1 & 2 configs. respectivamente
%             (en el caso de cambios instrumentales puede ser importante)
%             En el caso de dar una sóla sl_s, se asume que será con la 2 config
% 
% OUTPUT:
%   - A    : three fields struct: new (2nd config), old (1st config) & b (B config).
%           (Cal.Date.CALC_DAYS x length(Cal.brw)+1) matrix. 1st column=date. NaN when no data
%   - ETC  : three fields struct: new (2nd config), old (1st config) & b (B config).
%           (Cal.Date.CALC_DAYS x Cal.n_brw+1) matrix. 1st column=date. NaN when no data
%   - SL_B : Daily means (Cal.Date.CALC_DAYS x Cal.n_brw+1) matrix. 
%           Two fields struct: new (2nd config) & old (1st config). If not, old=new.
%           1st column=date. Used for SL correcting ozone 
%           If cfg=matrix->taken from there, if not, taken from setup (Cal.ETC_C)
%   - cfg  :  
% 
if isstruct(file_setup)
   Cal=file_setup;
elseif exist(file_setup,'file')
   eval(file_setup);    Cal=file_setup;
else
   disp('incorrect input');    return;
end

n_=Cal.n_brw+1; d_=length(Cal.Date.CALC_DAYS);

A=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)},'b',{NaN*ones(d_,n_)});
ETC=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)},'b',{NaN*ones(d_,n_)});
SL_R=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)});
SL_B=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)});
for i=1:Cal.n_brw
    F_corr{i}=struct('new',{NaN*ones(d_,7)},'old',{NaN*ones(d_,7)});
end
cfg={};

if any(Cal.Date.CALC_DAYS>366)                                  % fecha matlab
   fecha_days=fix(Cal.Date.CALC_DAYS);                          % todos los días considerados
   
else                                                            % dia juliano
   fecha_days=Cal.Date.CALC_DAYS+datenum(Cal.Date.cal_year,1,0);% todos los días considerados
end

% exist()
for i=1:Cal.n_brw
    [xx,bb,ext]=fileparts(Cal.brw_config_files_new{i});% to check config style
    try
        a=cell2mat(config{i}');
        fecha=a(end,2:3:end)';% ficheros cargados con éxito
        
        idx=ismember(fecha_days,fecha);% 1 where the elements of A are in the set S, 0 elsewhere
    catch exception
        a=[];
        fprintf('%s File: %s, line: %d, brewer: %s\n',...
                 exception.message,exception.stack.name,exception.stack.line,Cal.brw_name{i});
    end
    
    if ~isempty(a)               
       %configuracion inicial o de prueba dimesion 1
       if isempty(ext)% si trabajamos con una única config. -> first = bfile
          fprintf('Brewer %s:  1ª config -> Bfiles\t\t\t',Cal.brw_name{i}); 
          a_old=a(:,3:3:end)';
          if any(isnan(a_old(:)))
            a_old(isnan(a_old))=0;
            fprintf('(warning NaN replaced by 0)');
          end
          [cfg.old{i},ki]=unique(a_old(:,2:end-2),'rows','first'); 
          % asignamos las fechas de los primeros ficheros con cambio
          cfg.old{i}=sortrows([a_old(ki,end),cfg.old{i}]);
          y=group_time(fecha,cfg.old{i}(:,1)); 
          A.old(idx,i+1)= cfg.old{i}(y,8);
          ETC.old(idx,i+1)= cfg.old{i}(y,11);
          SL_R.old(idx,i+1)= Cal.SL_OLD_REF(i);
          for f=1:6
              F_corr{i}.old(idx,f+1)=Cal.ETC_C{i}(f);                              
          end
       else% dos configuraciones
           
          % Primera configuracion
          [xx,bb,ext]=fileparts(Cal.brw_config_files{i,1});% to check config style                   
          fprintf('Brewer %s:  1ª config -> %s\t\t\t',Cal.brw_name{i},[bb,ext]);
          a_old=a(1:end-2,1:3:end)';
          if any(isnan(a_old(:)))
            a_old(isnan(a_old))=0;
            fprintf('(warning NaN replaced by 0 in 1 config)');
          end
            cfg.old{i}=unique(a_old,'rows');
            
          if strcmp(ext,'.cfg')
             y=group_time(fecha(idx),cfg.old{i}(:,1)); % asociamos un indice a cada fecha de cal
             if all(y==0) %solo hay uno y esta fuera del rango de fechas.
                y=1;
             end
             A.old(idx,i+1)= cfg.old{i}(y,8);
             ETC.old(idx,i+1)= cfg.old{i}(y,11);             
             SL_R.old(idx,i+1)=cfg.old{i}(y,27);
             F_corr{i}.old(idx,2:end)=cat(2,repmat(0,length(y),2),cfg.old{i}(y,29:32));
          else
             A.old(idx,i+1)= cfg.old{i}(8);% si falta algun fichero -> NaN
             ETC.old(idx,i+1)=cfg.old{i}(11);
             SL_R.old(idx,i+1)=Cal.SL_OLD_REF(i);
             try
                 for f=1:6
                     F_corr{i}.old(idx,f+1)=Cal.ETC_C{i}(f);                                                                            
                 end
             catch exception
                 fprintf('(Warning: %s) \n',exception.message);
             end
          end
       end
         
          % Segunda configuracion
          [xx,bb,ext]=fileparts(Cal.brw_config_files{i,2});% to check config style
          if ~isempty(ext)             
             fprintf('2ª config -> %s\n',[bb,ext]);
             a_new=a(1:end-2,2:3:end)';
          else
             [xx,bb,ext]=fileparts(Cal.brw_config_files{i,1});% to check config style              
             fprintf('2ª config -> %s\n',[bb,ext]);
             a_new=a(1:end-2,1:3:end)';              
          end
          if any(isnan(a_new(:)))
            a_new(isnan(a_new))=0;
            fprintf('(warning NaN replaced by 0 in 2 config)');
          end
          cfg.new{i}=unique(a_new,'rows');
          
          if strcmp(ext,'.cfg')
             y=group_time(fecha(idx),cfg.new{i}(:,1)); % asociamos un indice a cada fecha de cal
             if all(y==0) %solo hay uno y esta fuera del rango de fechas.
                y=1;
             end 
             try 
                 A.new(idx,i+1)= cfg.new{i}(y,8);
                 ETC.new(idx,i+1)= cfg.new{i}(y,11);             
                 SL_R.new(idx,i+1)=cfg.new{i}(y,27);
                 F_corr{i}.new(idx,2:end)=cat(2,repmat(0,length(y),2),cfg.new{i}(y,29:32));                 
             catch exception
                 fprintf('Try reloading Brewer %s!! %s File: %s, line: %d\n',...
                       Cal.brw_name{i},exception.message,exception.stack.name,exception.stack.line);
             end
          else
             A.new(idx,i+1)= cfg.new{i}(8);% si falta algun fichero -> NaN
             ETC.new(idx,i+1)=cfg.new{i}(11);               
             SL_R.new(idx,i+1)=Cal.SL_NEW_REF(i);
             try
                for f=1:6
                    F_corr{i}.new(idx,f+1)=Cal.ETC_C{i}(f);                              
                end
             catch exception
                fprintf('(Warning: %s)  ',exception.message);
             end
          end
                    
          % Tercera configuracion  %fichero b
          a_b=a(1:end-2,3:3:end)'; a_b(:,1)=a(end,3:3:end)';
          if any(isnan(a_b(:)))
            a_b(isnan(a_b))=0;
            fprintf('(warning NaN replaced by 0 in B config)');
          end
          cfg.b{i}=unique(a_b,'rows','first'); 
          y=ismember(cfg.b{i}(:,1),fecha_days);
          A.b(idx,i)= cfg.b{i}(y,8);
          ETC.b(idx,i)= cfg.b{i}(y,11);
          
          % Creamos variable SL_B (mediana diaria, ver sl_report_jday: sl_median -> (median,std) daily values: 'time','R6','R5','T','F1','F5' )
          if size(sl_s,2)==2 && iscell(sl_s{1})
          % tenemos dos celdas: 1 y 2 configs. Pero ... 
           try
             switch i<=length(sl_s{1})
                 case 1 
                     if isempty(sl_s{1}{i}) && ~isempty(sl_s{2}{i})
                        fprintf('%s: estás corrigiendo SIEMPRE con las R6 -> 2º config\n',Cal.brw_name{i});                         
                        sl_s_o=sl_s{2}{i}; sl_s_n=sl_s{2}{i}; 
                     elseif isempty(sl_s{2}{i}) && ~isempty(sl_s{1}{i})
                        fprintf('%s: estás corrigiendo SIEMPRE con las R6 -> 1ª config\n',Cal.brw_name{i});                         
                        sl_s_o=sl_s{1}{i}; sl_s_n=sl_s{1}{i}; 
                     elseif isempty(sl_s{1}{i}) && isempty(sl_s{2}{i})
                        continue;
                     else
                        sl_s_o=sl_s{1}{i}; sl_s_n=sl_s{2}{i}; 
                     end                     
                 case 0 
                     sl_s_o=sl_s{2}{i}; sl_s_n=sl_s{2}{i};                                           
             end
           catch exception
               fprintf('%s, brewer: %s\n',exception.message,Cal.brw_str{i});
               continue
           end
          else
             fprintf('%s: estás corrigiendo SIEMPRE con las R6 -> 2º config\n',Cal.brw_name{i});                         
             sl_s_o=sl_s{i}; sl_s_n=sl_s{i};               
          end          
          sidx=group_time(fix(sl_s_n(:,1)),fecha_days); % se supone que tienen iguales días sl_s_n y sl_s_o 
          sl_s_n(sidx==0,:)=[]; sl_s_o(sidx==0,:)=[];
          SL_B.new(sidx(sidx~=0),i+1)=sl_s_n(:,2); 
          try
              SL_B.old(sidx(sidx~=0),i+1)=sl_s_o(:,2);
          catch exception
              fprintf('%s: sl_median_OLD y sl_median_NEW no tienen igual longitud?\n\t\t Check sl_report_jday inputs !!\nFile: %s, line: %d\n',...
                          Cal.brw_name{i},exception.stack.name,exception.stack.line);              
          end
    else 
          disp('No data. Continue');    continue
    end
    F_corr{i}.old(:,1)=fecha_days; F_corr{i}.new(:,1)=fecha_days;
end
    A.old(:,1)   = fecha_days; A.new(:,1)   = fecha_days;
    ETC.old(:,1) = fecha_days; ETC.new(:,1) = fecha_days;
    SL_R.old(:,1)= fecha_days; SL_R.new(:,1)= fecha_days;
    SL_B.old(:,1)= fecha_days; SL_B.new(:,1)= fecha_days;
