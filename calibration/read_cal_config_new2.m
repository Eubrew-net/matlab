function  [A,ETC,SL_B,SL_R,cfg]=read_cal_config_new(config,file_setup,sl_s)
% function  [A,ETC,SL_B,SL_R,cfg]=read_cal_config_new(config,file_setup,sl_s)
% configuration for FINAL days
% load(file_save)
% TODO SL_REFERENCE
%
if isstruct(file_setup)
    mmv2struct(file_setup);
    mmv2struct(Date);
    
    %brw=file_setup.brw;
    %CALC_DAYS=file_setup.Date.CALC_DAYS;
    %day0=file_setup.Date.day0;
    %CALC_YEAR=file_setup.Date.cal_year;
elseif exist(file_setup,'file')
    eval(file_setup);
    mmv2struct(Cal);
else
    disp('incorrect input');
    return;
end
n_=length(brw);
d_=length(CALC_DAYS);
A=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)},'b',{NaN*ones(d_,n_)});
ETC=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)},'b',{NaN*ones(d_,n_)});
SL_R=struct('new',{NaN*ones(d_,n_)},'old',{NaN*ones(d_,n_)},'b',{NaN*ones(d_,n_)});
% A=struct('new',cell(n_,1),'old',cell(n_,1));
% ETC=struct('new',cell(n_,1),'old',cell(n_,1));
fecha_days=CALC_DAYS+datenum(cal_year,1,0);
SL_B=NaN*zeros(d_,n_);

cfg={};

for i=1:length(brw)
    try
        a=cell2mat(config{i}');
        n_rows=3; % por definicion 
        fecha=a(end,2:3:end)';
        
        [idx,loc]=ismember(fecha_days,fecha);
    catch
        disp(brw(i));
        disp('No configuration !!');
        a=[];
    end
    if isempty(a)
        A.new(i)=NaN;
        ETC.new(i)=NaN;
        A.old(i)=NaN;
        ETC.old(i)=NaN;
        SL_R(i)=NaN;
        disp(brw(i));
        disp('No configuration !!');
    
    else
        
        %configuracon inicial o de prueba dimesion 1
        % end-1 en la ultima posicion esta la fecha
        cfg.old{i}=unique(a(1:end-2,1:3:end)','rows');
        A.old(:,i)= cfg.old{i}(8);
        ETC.old(:,i)=cfg.old{i}(11);
        SL_R.old(:,i)=SL_OLD_REF(i);
        
        % Segunda configuracion
          [xx,bb,ext]=fileparts(brw_config_files_new{i});
          [cfg.new{i},ki,kj]=unique(a(1:end-2,2:3:end)','rows');
           y=group_time(fecha,cfg.new{i}(:,1)); 
           if all(y==0) %solo hay uno y esta fuera del rango de fechas.
               y=1;
           end
           A.new(idx,i)= cfg.new{i}(y,8);
           ETC.new(idx,i)= cfg.new{i}(y,11);
          if strcmp(ext,'.cfg') % R6 esta defindio
                 SL_R.new(idx,i)=cfg.new{i}(y,27);
          else
                 SL_R.new(idx,i)=SL_NEW_REF(i);
          end
        % tercera configuracion  %fichero b
           [cfg.b{i},ki,kj]=unique(a(2:end-2,3:3:end)','rows'); 
           cfg.b{i}=sortrows([a([end,2:end-2],3)';[a(end,ki)',cfg.b{i}];a([end,2:end-2],end)']);
           %unique devuelve la fecha desordenada-> comprobar
           %cfg.b{i}=[cfg.b{i};a([end,2:end-2],end)'];
           % como es el fichero b el periodo comienza con el primer dia y
           % finaliza por el ultimo dia,
           %fecha=a(end,3:3:end)';
           %[idx,loc]=ismember(fecha_days,fecha);
           y=group_time(fecha,cfg.b{i}(:,1)); 
           A.b(idx,i)= cfg.b{i}(y,8);
           ETC.b(idx,i)= cfg.b{i}(y,11);
           SL_R.b(idx,i)= SL_NEW_REF(i);% humm
           %icf_b{i}=cfg.b{i};
           
           
           [sidx,loc]=ismember(fecha_days,fix(sl_s{i}(:,1)));
           SL_B(sidx,i)=sl_s{i}(:,2);
        disp(i)
    end
end

