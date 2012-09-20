function  [A,ETC,SL_B,cfg,icf_brw]=read_cal_config(config,file_setup,sl_s)
% READ Configuration
% configuration for FINAL days
% load(file_save)
if isstruct(file_setup)
brw=file_setup.brw;
CALC_DAYS=file_setup.Date.CALC_DAYS;
day0=file_setup.Date.day0;
else  
  eval(file_setup)
  mmv2struct(Cal);
end
n_=length(brw);
A=struct('new',{NaN*ones(1,n_)},'old',{NaN*ones(1,n_)});
ETC=struct('new',{NaN*ones(1,n_)},'old',{NaN*ones(1,n_)});

SL_B=[];
cfg={};

for i=1:length(brw)
    if length(sl_s)<i
        continue
    end
    try
        a=cell2mat(config{i}');
        n_rows=size(a,2);
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
       % SL_B(i)=NaN;
    else
        
        %configuracon inicial (1)
        % end-1 en la ultima posicion esta la fecha
        cfg.old{i}=unique(a(1:end-2,1:n_rows:end)','rows');
        % configuracion 2�
        cfg.new{i}=unique(a(1:end-2,2:n_rows:end)','rows');
        %config_1=a(:,a(2:1:end)','rows');
        if size(cfg.new{i},1)==1
            A.new(i)= cfg.new{i}(8);
            ETC.new(i)= cfg.new{i}(11);
            A.old(i)= cfg.old{i}(8);
            ETC.old(i)=cfg.old{i}(11);
            for ii=CALC_DAYS
                if ~isempty(sl_s{i})
                    xday=find(diaj(sl_s{i}(:,1))==ii);
                    if ~isempty(xday)
                        aux=sl_s{i}(xday,2);
                    else
                        aux=0;
                    end
                else
                    aux=0;
                end
                try
                SL_B(i,ii-day0+1)=aux; 
                catch
                    %disp('warning')
                end
            end
        else
            try
                A.new(i)=unique(cfg.new{6}(:,8));
                ETC.new(i)=unique(cfg.new{6}(:,11));
                A.old(i)=unique(cfg.old{6}(:,8));
                ETC.old(i)=unique(cfg.old{6}(:,11));
                for ii=CALC_DAYS
                    if ~isempty(sl_s{i})
                        xday=find(diaj(sl_s{i}(:,1))==ii);
                        if ~isempty(xday)
                            aux=sl_s{i}(xday,2);
                        else
                            aux=0;
                        end
                    else
                        aux=0;
                    end
                    SL_B(i,ii-day0+1)=aux;
                end
            catch
                A.new(i)=NaN;
                ETC.new(i)=NaN;
                A.old(i)=NaN;
                ETC.old(i)=NaN;
                %SL_B(i)=NaN;
            end
            
        end
        if ~isempty(a)
            icf_brw{i}=[a(end,1:n_rows:end);a(8,1:n_rows:end);a(11,1:n_rows:end)];
        else
            disp(brw(i));
            disp('No configuration !!');
        end
    end
end
