function change=write_excel_config(config,Cal,n_inst)

% config: (from process_config.m)
% colunna 1 % 1º configuracion (cuando 2 configs.) o la del fichero B
% columna 2 % 2º configuracion (o única configuración)
% columna 3 % configuracion del fichero B

aux=cell2mat(config{n_inst}'); bconfig=aux(:,3:3:end);
[config_orig,TCorig,DTorig,ETCorig,A1orig,ATorig,icf_legend]=read_icf(Cal.brw_config_files{n_inst,1}); 
[a b c]=fileparts(Cal.brw_config_files{n_inst,2});
if ~isempty(c) & ~strcmp(c,'.cfg')
    config_def=read_icf(Cal.brw_config_files{n_inst,2}); 
else
    config_def=bconfig(1:end-1,1); 
end

icf_legend=[cellstr(icf_legend);{'date'}];

% changes ? 
% Si por ejemplo se cambia el CSN de 283 a 285, encontrará los
% dos, pero si luego se vuelve a poner a 283, ese día ya no lo verá.
% Solucionado
[row,days]=unique(diff([bconfig(2:end-2,1),bconfig(2:end-2,:)]'),'rows','first');
% "pegamos" una columna, la del primer día, para que los indices sean correctos (diff siempre retorna n-1)
days=sort(days);  % porque unique devuelve el resultado ordenado de menor a mayor, y por el diff habrán -
days=days(2:end); % el primer día siempre aparecerá (todos 0) por el apaño de linea 106
aux1=bconfig(2:end-2,days)';

% ver el dia en el que ha cambiado
ch=datestr(bconfig(end,days));

% que dia cambio ? no va sia hay muchos
if  ~isempty(days)
   for ii=1:length(days)
       a=find(matadd(aux1(ii,:)',-bconfig(2:end-2,days(ii)-1)),1,'first'); 
       change{ii,1}=sprintf('Day %d (%s, %s): %s',diaj(bconfig(end,days(ii))),ch(ii,:),...
                                                  Cal.brw_name{n_inst},cell2str(icf_legend(a+1)));
       disp(cell2str(change));      
   end
else
    change=' ';
end

try       
 bconfig(1,:)=diaj(bconfig(end,:));   
 [s,m]=xlswrite('brewer_config.xlsx',[icf_legend,num2cell(bconfig)],Cal.brw_str{n_inst});
 if s==false
     disp(m);
 end
 [s,m]=xlswrite('brewer_config.xlsx',[icf_legend,num2cell([[config_orig;config_orig(1)],matadd(bconfig,-[config_orig;config_orig(1)])])],[Cal.brw_str{n_inst},'_orig']);
 [s,m]=xlswrite('brewer_config.xlsx',[icf_legend,num2cell([[config_def;config_def(1)],matadd(bconfig,-[config_def;config_def(1)])])],[Cal.brw_str{n_inst},'_def']);
catch
 s=lasterror;   
 disp(s.message);
end
