%%Read Shift files (GS), quitando errores


path_root=fullfile(cell2mat(regexpi(pwd,'^[A-Z]:', 'match')),'CODE','iberonesia'); %define path independientemente del ordenador
brw_str={'157','183','185'}; %defino variable que incluye los tres Brewer

file=dir((fullfile(path_root,'tmp',strcat('*GS','.','iz1'))));
p=[];t=[];z={};
for i=3:length(file)
fid=fopen(file(i).name);

data = [];
while ~feof(fid)
    tline = fgetl(fid);
    if any(strfind(tline,'wave_fit:')) && ~any(strfind(tline,'Error Ratio')) && ~any(strfind(tline,'NOT_SIGNIFICANT'));%& significa que se han de verificar las tres condiciones en este caso
        data=[data;sscanf(tline,'%7f')'];
    elseif ~any(strfind(tline,'wave_fit:')) && ~any(strfind(tline,'Error Ratio')) && ~any(strfind(tline,'NOT_SIGNIFICANT'));
        data=[data;NaN NaN NaN NaN NaN NaN];
    elseif any(strfind(tline,'Error Ratio'));
        data=[data;NaN NaN NaN NaN NaN NaN];
    elseif any(strfind(tline,'NOT_SIGNIFICANT'));
         data=[data;NaN NaN NaN NaN NaN NaN];
end
    
%    matches = strfind(tline, literal);
%    num = length(matches);
%    if num > 0
%       y = y + num;
%       fprintf(1,'%d:%s\n',num,tline);
%    end
%    tline = fgetl(fid);
end


date=sscanf(file(i).name,'%3d%2d%2d%*s.%*s'); date_=datenum([2012,1,date(1),date(2),date(3),0]);
% format='%s %s %s %s %s %s %*s';
% shift_=textscan(data,format);
if isempty(data)
    disp('empty')
elseif ~isempty(data)
l=NaN*ones(size(data(1),1)+1,size(data,2));
%l(2:end,:)=cell2mat(data);
l(1,:)=repmat(date_,1,size(l,2)); 
t=[l(1,:);data];

z{i}=t;
     fclose(fid);
end
end

%%Lo comentado es para plotear un periodo usando únicamente una longitud de
%%onda
% dates=datestr(cellfun(@(x) x(1,end),z)'); %me coge la 1ªfila de la 7ª columna
% chk_wl=cell2mat(cellfun(@(x) x([1 14],[6]),z,'UniformOutput',0));%para una
% %longitud de onda
%chk_shift=cell2mat(cellfun(@(x) x([1 14],[3]),z,'UniformOutput',0));%para una longitud de onda
%chk_shiftstd=cell2mat(cellfun(@(x) x([1 14],[4]),z,'UniformOutput',0));%para una longitud de onda
chk_shift_=cell2mat(cellfun(@(x) x([1:end],[4]),z,'UniformOutput',0));%para todas las longitudes de onda
chk_lamda=cell2mat(cellfun(@(x) x([1:end],[6]),z,'UniformOutput',0));
k=chk_shift_(1,:);
n=fix(dia_juliano(k));%paso a día juliano y cojo únicamente la parte entera
s=(datevec(k));
hour=s(:,4);
minute=s(:,5);
matriz=[n;chk_shift_];


comunes=unique(n); %me dice los días que tengo sin repetir día
h_m=[n;hour';minute'];
t2=[]; %inicializo celdas
  p2=[];
  h2=[];
 for i=1:length(comunes) %me busca los indices de diajuliano para cada día (pues hay varios datos para un mismo día)
  t2{i}=find(matriz(1,:)==comunes(i));
 p2{i}=matriz(:,t2{i});
 h2{i}=h_m(:,t2{i});
 end
 
%%shift 
  
shift_day=[];
hour_=[];
minute_=[];

for i=1:length(p2)
   shift_day{i}=(p2{i}(3:end,:));%me da todos las columnas de la3ª al final
   day{i}=(p2{i}(1,:));
   hour_{i}=(h2{i}(2,:));
   minute_{i}=(h2{i}(3,:));
end
 %Represento duv para cada día
for i=1:length(p2)
day1=day{i};
day_=unique(day1);
hour__=hour_{i};
minute__=minute_{i};
%h_s=num2str(hour__);
%m_s=num2str(minute__);

figure;
plot(chk_lamda(2:end,2),shift_day{i});
set(gca,'YLim',[-0.05 0.05])

title(day_);
kj=[];
for j=1:length(hour__)
    h_m_def=strcat(num2str(hour__(j)),':',num2str(minute__(j)));
    kj{j}=h_m_def;
    legend(kj);
end
ylabel('Shift');   %asignamos nombre a variables y título.Unidades de irradiancia espectral W/m2,
%unidades de irradiancia integrada en tiempo J/m2,se van los seg
xlabel('Wavelength (nm)')
end

%%Para plotear una longitud de onda únicamente

% plot(chk_wl(1,:),chk_shift(2,:),'*')
% datetick('x','keeplimits','keepticks')
% grid
% set(gca,'YLim',[-0.02 0.02])
% hline(0.007)
% hline(-0.007)

 %vline_v([datenum(2012,09,27)
 %datenum(2012,10,22)],'-b',{datestr(datenum(2012,09,27)),datestr(datenum(2012,10,22))});para
 %poner líneas con fecha
 
 %options_doc_nocode.format='html'
%options_doc_nocode.showCode=false
%publish('Shift_sinerror',options_doc_nocode)