function read_voltAFC(nbrw,date,fin_ql,lamp,offset)
% Lectura de los ficheros de voltaje de lámparas medidas en laboratorio.
% Ejecutando primero el script read_hg obtendremos las horas de fin de
% cada ql para cada lámpara. Restando el valor de offset obtengo 
% el momento en que comenzó (8 para doble, 4 para simple).
% Pasamos luego estos tiempos a la función que plotea los datos de voltaje 
% e intensidad. 
% Uso: brewerid y fecha en formato 'yymmdd'
%       read_voltAFC(157,'080926',fin_ql,lamp,offset)
% fin_ql,lamp,offset son variables devueltas por read_hg
% 
% Cuidado con los dias en los que se lleva a cabo una calibracion durante 
% cambio de dia local. Da problemas
% Tambien habra que tener cuidado: en algunos ficheros la posicion decimal
% es una coma, y en otros es un punto (líneas 42 y 43 para cada caso)

lamps=[]; lamps_ind=[];
for k=1:length(lamp)
    lamps = [lamps lamp{k}];
    lamps_ind = [lamps_ind str2num(cell2mat(lamp{k}))];
end
[x w p]=unique(lamps_ind);
lamps_ind_s=x(p(1:2:end));

brw_dir=fullfile('.',num2str(nbrw),'2005');
s=dir([brw_dir,filesep(),'Monitoring_*','20',date,'_',num2str(nbrw),'.log']);

ordenar=[];
for ind=1:length(s)
   ordenar=[ordenar
            repmat(sscanf(cell2mat(regexp(s(ind).name,'ing_\d?\d\d\d_','match')),'ing_%d_'),2,1)];
end
[x w p]=unique(ordenar);
ordenar=x(p(1:2:end));
indx=[];
for o=1:length(lamps_ind_s)
    indx=[indx find(lamps_ind_s(o)==ordenar)];
end
s=s(indx);
    
for i=1:length(s)
format='%2d %2d %4d %2d:%2d:%2d %d,%d %d,%d %d,%d %d,%d %d,%d';
% format='%2d %2d %4d %2d:%2d:%2d %d.%d %d.%d %d.%d %d.%d %d.%d';
file=fullfile(brw_dir,s(i).name);
f=fopen(file); fich=[];
while ~feof(f)
      [A,count]=sscanf(fgets(f),format);
      if count<16, continue
      else
        shunt_voltage=str2double(sprintf('%d.%d',A(9),A(10)));
        lamp_voltage=str2double(sprintf('%d.%d',A(11),A(12))) ;         
        fich=[fich;A(1:6)' shunt_voltage lamp_voltage];
      end
end
lamp=cell2mat(regexp(s(i).name,'\_\d*\_','match')); lamp=lamp(2:end-1);
lamp_ind=strcmp(lamps,lamp);

if isempty(lamps), return 
end
ql_ind=find(lamp_ind==1); 

if length(ql_ind)>1, ql_ind=ql_ind(1:2);
else ql_ind=ql_ind;
end

lamps_time=cat(2,repmat([fich(1,3),fich(1,2),fich(1,1)],length(ql_ind),1),fin_ql(ql_ind,:));
lamps_time=datenum(lamps_time);

fecha_matlab=datenum(fich(:,3),fich(:,2),fich(:,1),fich(:,4),fich(:,5),fich(:,6));
fich(:,2:6) = []; fich(:,1) = fecha_matlab; 

fclose(f);

fich(1:150,:)=[]; %calentamiento

figure;
subplot(2,1,1);
plot(fich(:,1),fich(:,3),'.-');
ax=[-Inf,Inf,min(fich(:,3))-.02,max(fich(:,3))+.02]; axis(ax);
for l=1:length(lamps_time)
   [m i2]=min(abs(fich(:,1)-lamps_time(l))); [m i1]=min(abs(fich(:,1)-(lamps_time(l)-datenum(0,0,0,0,offset,0))));    
    table_volt{l}=[mean(fich(i1:i2,3)) std(fich(i1:i2,3))];
    v=vline(lamps_time(l)-datenum(0,0,0,0,8,0),'b-');set(v,'LineWidth',2);   
    v=vline(lamps_time(l),'b-');set(v,'LineWidth',2);
    text(fich(i1,1),max(fich(:,3)+.01),sprintf('Mean %e +/- %e',...
                     table_volt{l}),'FontSize',10,'FontWeight','Bold',...
                     'BackgroundColor','w','Linestyle','-','LineWidth',2,'EdgeColor','k');
end
t=title(s(i).name); ylabel('voltios'); 
set(t,'Interpreter','none','FontWeight','Bold');  
datetick('x',15); grid

% v=mean(fich(:,3)); y=std(fich(:,3));
% legend(sprintf(' Mean %e +/- %e',v,y),'Location','SouthOutside'); legend('boxoff')

subplot(2,1,2);
plot(fich(:,1),fich(:,2),'.-'); 
ax=[-Inf,Inf,0.7999,0.8002]; axis(ax);
for l=1:length(lamps_time)
    [m i2]=min(abs(fich(:,1)-lamps_time(l))); [m i1]=min(abs(fich(:,1)-(lamps_time(l)-datenum(0,0,0,0,offset,0))));    
    table_amp{l}=[mean(fich(i1:i2,2)) std(fich(i1:i2,2))];
    v=vline(lamps_time(l)-datenum(0,0,0,0,8,0),'b-');set(v,'LineWidth',2);   
    v=vline(lamps_time(l),'b-');set(v,'LineWidth',2);
    text(fich(i1,1),0.80017,sprintf('Mean %e +/- %e',...
                     table_amp{l}),'FontSize',10,'FontWeight','Bold',...
                     'BackgroundColor','w','Linestyle','-','LineWidth',2,'EdgeColor','k');
end
xlabel('tiempo'); ylabel('shunt voltage'); 
datetick('x',15); grid; 

% v=mean(fich(:,2)); y=std(fich(:,2));
% legend(sprintf(' Mean %e +/- %e',v,y),'Location','SouthOutside'); legend('boxoff')

for l=1:length(lamps_time)
    hold on; v=vline(lamps_time(l),'b-');set(v,'LineWidth',2);
end

drawnow; orient tall;
  print('-djpeg',[file,'.jpg']); 
end
