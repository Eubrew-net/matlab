
function read_voltLAB(nbrw,date,path_to_raw)
% ,fin_ql,lamp,offset
% Lectura de los ficheros de voltaje de lámparas medidas en laboratorio.
% Ejecutando primero el script read_hg obtendremos las horas de fin de
% cada ql para cada lámpara. Restando el valor de offset obtengo 
% el momento en que comenzó (7 para doble, 4 para simple).
% Pasamos luego estos tiempos a la función que plotea los datos de voltaje 
% e intensidad. 
% Uso: brewerid y fecha en formato 'yymmdd'
%       read_voltAFC(157,'080926',fin_ql,lamp,offset)
% fin_ql,lamp,offset son variables devueltas por read_hg
% 
% Cuidado con los dias en los que se lleva a cabo una calibracion durante 
% cambio de dia local. Da problemas

% lamps=[];
% for k=1:length(lamp)
%     lamps = [lamps lamp{k}];
% end

brw_dir=path_to_raw;
s=dir([brw_dir,filesep(),'brewer','*.dat']);
[tmp ordenar_ind]=sort(cell2mat({s(:).datenum}')); s=s(ordenar_ind);
% s=s([2 3])

% test=find(fin_ql(end-2:end,1)<fin_ql(1,1));
% if ~isempty(test)
%     new_ind=test(find(test~=0))+(length(fin_ql)-length(fin_ql(end-4:end,:)));
%     fin_ql(new_ind)=fin_ql(new_ind)+24
% end

for i=1:length(s)
format='%f %2d/%3c/%4d %2d:%2d:%2d %f %f %f %f';
file=fullfile(brw_dir,s(i).name);
f=fopen(file);
a=fscanf(f,format,[13,Inf]);
a=a';
aux=(a(:,1)/60/60/24)+365; %paso a fecha matlab
a=[aux a(:,10:end)];

yy_mm_dd=datevec(aux(1));
% lamp=cell2mat(regexp(s(i).name,'p\D?\D?\d*\_','match')); lamp=lamp(2:end-1);
% lamp_ind=strcmp(lamps,lamp);
% 
% if isempty(lamps), return 
% end
% ql_ind=find(lamp_ind==1); 
% 
% if length(ql_ind)>4, ql_ind=ql_ind(1:2);
% else ql_ind=ql_ind;
% end

% lamps_time=cat(2,repmat(yy_mm_dd(1:3),length(ql_ind),1),fin_ql(ql_ind,:));
% lamps_time=datenum(lamps_time);

fclose(f);
if ~isempty(a(a(:,end)==3,:))
    a=a(a(:,end)==3,:); 
else a=a(a(:,end)==2,:);
end
    
    
a(1:20,:)=[]; %calentamiento

figure;
subplot(2,1,1);
ploty(a(:,[1,2]));
ax=[-Inf,Inf,7.9985,8.0025]; axis(ax);
% for l=1:length(lamps_time)
% %    [m i2]=min(abs(a(:,1)-lamps_time(l))); [m i1]=min(abs(a(:,1)-(lamps_time(l)-datenum(0,0,0,0,offset,0))));    
%     table_amp{l}=[mean(a(i1:i2,2)) std(a(i1:i2,2))];
%     v=vline(lamps_time(l)-datenum(0,0,0,0,offset,0),'r-');set(v,'LineWidth',2);   
%     v=vline(lamps_time(l),'r-');set(v,'LineWidth',2);
%     text(min(a(:,1),max(a(:,2)+.001),sprintf('Mean %e +/- %e',...
%                      table_amp{l}),'FontSize',10,'FontWeight','Bold',...
%                      'BackgroundColor','w','Linestyle','-','LineWidth',2,'EdgeColor','k');
%     text(a(i1,1),8.0015,sprintf('Mean %e +/- %e',...
%                      table_amp{l}),'FontSize',10,'FontWeight','Bold',...
%                      'BackgroundColor','w','Linestyle','-','LineWidth',2,'EdgeColor','k');
% end

%%%%% PARA MARTA %%%%%%
% Aqui tienes la variable a con los datos de voltaje
% Mirate en la ayuda de Matlab las funciones: text, legend, ...
%%%%%%%%%%%%%%%%%%%%%%%

t=title(file); ylabel('amperes');
set(t,'Interpreter','none','FontWeight','Bold'); 

datetick; grid; 
% v=mean(a(:,2)); y=std(a(:,2));
% legend(sprintf(' Mean %e +/- %e',v,y));

subplot(2,1,2)
ploty(a(:,[1,3]));
ax=[-Inf,Inf,min(a(:,3))-.2,max(a(:,3))+.2]; axis(ax)
% for l=1:length(lamps_time)
%    [m i2]=min(abs(a(:,1)-lamps_time(l))); [m i1]=min(abs(a(:,1)-(lamps_time(l)-datenum(0,0,0,0,offset,0))));    
%     table_volt{l}=[mean(a(i1:i2,3)) std(a(i1:i2,3))];
%     v=vline(lamps_time(l)-datenum(0,0,0,0,offset,0),'r-');set(v,'LineWidth',2);   
%     v=vline(lamps_time(l),'r-');set(v,'LineWidth',2);
%     text(a(i1,1),max(a(:,3)+.1),sprintf(' Mean %e +/- %e',...
%                      table_volt{l}),'FontSize',10,'FontWeight','Bold',...
%                      'BackgroundColor','w','Linestyle','-','LineWidth',2,'EdgeColor','k');
% end
ylabel('voltios'); xlabel('tiempo');

datetick; grid
% v=mean(a(:,3)); y=std(a(:,3));
% legend(sprintf(' Mean %e +/- %e',v,y));

drawnow; orient landscape;
end
