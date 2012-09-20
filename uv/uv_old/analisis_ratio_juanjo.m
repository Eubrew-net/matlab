% %   PARA PLOTEAR LAS RATIOS EN UN DIA DE CALIBRACIÓN
% indx_date=find(RESUMEN_RATIO(:,4)==datenum('2007-07-30','yyyy-mm-dd'));
% figure; plot(lamda,RESUMEN_RATIO(indx_date,7:end));
% names=[num2str(RESUMEN_RATIO(indx_date,1)),repmat('-',length(indx_date),1),num2str(RESUMEN_RATIO(indx_date,2))];
% legend(mat2cell(names,repmat(1,1,size(names,1)),size(names,2)));
% title(datestr(RESUMEN_RATIO(indx_date(1),4)))
% 
% figure; plot(lamda,RESUMEN_RATIO(:,4:end));
% % names=[num2str(RESUMEN_RATIO(:,1)),repmat('-',length(indx_date),1),num2str(RESUMEN_RATIO(:,2))];
% legend(mat2cell(names,repmat(1,1,size(names,1)),size(names,2)));
% title(datestr(RESUMEN_RATIO(:,4)))

%  PARA PLOTEAR LAS RATIOS ENTRE DOS LÁMPARAS TODOS LOS DÍAS DISPONIBLES
lbda={'2865','2900','2970','3005','3040','3075','3110','3145','3180','3215',...
      '3250','3285','3320','3355','3390','3390','3425','3460','3495','3495','3530','3565','3600','3635'}
indx_lamp=find(RESUMEN_RATIO(:,1)==857 & RESUMEN_RATIO(:,3)==1083);
RES_plot=RESUMEN_RATIO; %RES_plot(:,2:10)=NaN; 
figure; plot(RES_plot(indx_lamp,2),RES_plot(indx_lamp,4:end),'*-');
legend(lbda{5:end}); datetick('x',20,'keepticks','keeplimits'); grid
title('103/857 ratio')
% lbda={'2865','2900','2970','3005','3040','3075','3110','3145','3180','3215',...
%       '3250','3285','3320','3355','3390','3390','3425','3460','3495','3495','3530','3565','3600','3635'}
% indx_lamp=find(RESUMEN_RATIO(:,1)==103 & RESUMEN_RATIO(:,4)==1083);
% RES_plot=RESUMEN_RATIO; RES_plot(:,7:10)=NaN; 
% figure; plot(RES_plot(indx_lamp,4),RES_plot(indx_lamp,7:end),'*-');
% legend(lbda{5:end}); datetick('x',20,'keepticks','keeplimits'); grid
% title('103/857 ratio')

idx=2; % if idx=1, 50W, elseif idx=2, 1000W
lamp_info=[   % falla con nombres con letra,'958','1004','1084','858','959','1005'
%     646,50;
%     647,50;
%     648,50;
%     650,50;
    103,1000;
    857,1000;
    856,1000;
%     858,1000;
%     957,1000;
%     958,1000;
%     1004,1000;
%     1005,1000;
%     1080,1000;
%     1081,1000;
    1083,1000;
%     1201,1000;
%     1202,1000;
% 959,1000;
     ];

% lbda={'2865','2900','2970','3005','3040','3075','3110','3145','3180','321
% 5','3250','3285','3320','3355','3390','3390','3425','3460','3495','3495','3530','3565','3600','3635'}

% ANÁLISIS DEL RATIO DE LAS LAMPARAS
%numero de longitudes de onda que hay
lamda=ql_avg{1}.lamda;
nlamb=length(lamda);

lamp_inf=[];
for i=1:size(ql_avg,2)
name_lamp=str2num(cell2mat(regexp(ql_avg{1,i}.lamp,'\d*','match')));
% lamp_inf=[lamp_inf,str2num(cell2mat(regexp(ql_avg{1,i}.lamp,'\d*','match')))];
lamp_inf=[lamp_inf;name_lamp,lamp_info(find(lamp_info(:,1)==name_lamp),2)];
end

lamp_50=lamp_inf(lamp_inf(:,2)==50,1);
lamp_1000=lamp_inf(lamp_inf(:,2)==1000,1);

% separado el analisys 1000 y 50
% % lamp_inf=[ 646,50; 650,50; 1080,1000;1081,1000;1082,1000;957,1000;
%  958,1000]


% % lamda_grp=[2800,3000,3150,3300,3495,3700];
% % % 1-  2865-3100
% % % 2- 3100-3250
% % % 3- 3250-3500
% % % 4- 3500-3630
% % %agrupacion de lamda
% % 
% % g=lamda';
% % k=find((lamda==3495),1,'first');
% % for ii=1:length(lamda_grp)-1,
% %      
% %       g(:,ii)=(lamda>=lamda_grp(ii) & lamda<lamda_grp(ii+1));
% %  end
% % g(k,end)=1;
% % g(k,end-1)=0;
% % fliplr(g);
% % 
% % 
% % data_d={};
% % data_l={};
% % r_d={};
% % r_l={};
% % ql1={};
% % ql2={};
% %    

if idx==1
   nlamps=lamp_50; % analisis de 50
elseif idx==2
   nlamps=lamp_1000; % analisis de 1000
else
   nlamps=lamp_inf; % cruzado
end
   
RESUMEN=[]; ResumeN=[]; Resumen=[];    
RESUMEN_RATIO=[];
ratio_d=[]; data_d=[]; rel_diff=[]; abs_rel=[];
    
% Lectura de datos
% for i=1:length(nlamps)-1
%     indx = find(nlamps~=nlamps(i));  indx = indx(find(indx>i)); 
%     for j=1:length(indx)
%         j=indx(j);
%         l0=find(lamp_inf==nlamps(i)); l1=find(lamp_inf==nlamps(j));          
%         ql1{l0,l1}=[]; ql2{l0,l1}=[];

%        Se calculan los dias comunes a dos lamparas (ql_d era: fecha y respuesta)


%        [common,aa,bb]=intersect(ql_d{l0}(:,1),ql_d{l1}(:,1));
%         if isempty(common) 
%            disp('no comon elemets to ratio');
%            data_d=[]; ratio_d=[];
%            abs_diff=[]; rel_diff=[];  continue
%         end
%      %regexp(ql_avg{1,4}.lamp,'\d*','match')    
%         data_d=[common,ql_d{l0}(aa,2:end);common,ql_d{l1}(bb,2:end)];
%         ratio_d=[common,(ql_d{l0}(aa,2:end)./ql_d{l1}(bb,2:end))];
%         abs_diff=[common,(ql_d{l0}(aa,2:end)-ql_d{l1}(bb,2:end))];
%         rel_diff=[common,100*(ql_d{l0}(aa,2:end)-ql_d{l1}(bb,2:end))./ql_d{l1}(bb,2:end)];
% 
%         temperatura=[ql_avg{l0}.temp(aa),ql_avg{l1}.temp(bb)];
%         n=size(temperatura,1);
%         brw=repmat(str2num(nbr),n,1);
%         lamp_=repmat([lamp_inf(l0,1),lamp_inf(l1,1)],n,1);                
%                             
%         if (~isempty(data_d)  && size(data_d,1)>1)
%             fecha=data_d(:,1);
%             ratio=ratio_d(:,2:end);
%             data=data_d(:,2:end);
% 
% % % %           respuesta de la lampara 1
% % %             ql1{l0,l1}=[ql_avg{1}.lamda',data(:,1:nlamb)'];
% % %             
% % % %           respuesta de la lampara 2
% % %             ql2{l0,l1}=[ql_avg{1}.lamda',data(:,nlamb+2:end)'];
% 
% 
% % Si renombramos los ficheros esto falla. ver como no tocarlos
%             RESUMEN=[RESUMEN;...
%                     [lamp_(:,1),brw,ql_d{l0}(aa),temperatura(:,1);...
%                      lamp_(:,2),brw,ql_d{l1}(bb),temperatura(:,2)],data(:,1:nlamb)];
%                 
%             RESUMEN_RATIO=[RESUMEN_RATIO;lamp_,brw,unique(fecha),temperatura,ratio];  
%             
% u=0;

for g=1:length(lamp_info)-1,g
    ind=find(ifno(:,2)==lamp_info(g,1));
    respons1=respons; ifno1=ifno;
    respons1(ind)=NaN; ifno1(ind)=NaN;
    for k=1:length(ind),k
        respons2=respons1(ind(k)+1:end,:); 
        ifno2=ifno1(ind(k)+1:end,:); 

        ind2=find(abs((respons2(:,1)-respons(ind(k),1)))<=5);
        if isempty(ind2)
            continue 
        else
            Resumen=[Resumen;repmat(lamp_info(g),length(ind2),1),ifno2(ind2,[1 2]),...
                matdiv(respons2(ind2,2:end)',repmat(respons(ind(k),2:end),length(ind2),1)')'];
        end
%     u=u+length(find(ifno(:,2)~=lamp_info(g,1)))
    end
%         ResumeN=[ResumeN;Resumen(k+1:end,:)];

end
    RESUMEN_RATIO=Resumen;

%     end
% end

% save(['R_.',nbr],'RESUMEN','-ascii');
 C_todo=unique(RESUMEN,'rows');
% [m,s]=grpstats(ratio',g,{'median','std'});
 dlmwrite(['R_',nbr,'.csv'],C_todo,'precision','%.0f')
% 
% save(['R_RATIO.',nbr],'RESUMEN_RATIO','-ascii');
C_met=unique(RESUMEN_RATIO,'rows'); 
% %[m,s]=grpstats(ratio',g,{'median','std'});
dlmwrite(['R_RATIO',nbr,'.csv'],C_met,'precision','%.3f')

% legend(strcat(num2str(r(19:22,1)),'/',num2str(r(19:22,2)),' -
% ',datestr(r(19:22,4),29)))
% % for i=1:length(nlamps)
% %     l0=find(lamp_inf==nlamps(i))
% %     for j=i+1:length(nlamps)-1
% %         l1=find(lamp_inf==nlamps(j))
% %         fecha=data_d{l0,l1}(:,1)
% %         if ~isempty(fecha) && length(fecha)>1
% %             ratio=r_d{l0,l1}(:,2:end);
% %             lamda=ql1{l0,l1}(:,1);
% %         %agrupacion de lamda
% %             g=lamda;
% %             k=find((lamda==3495),1,'first');
% %         for ii=1:length(lamda_grp)-1,
% %             g(:,ii)=lamda>=lamda_grp(ii) & lamda<lamda_grp(ii+1);
% %         end
% %         g(k,end)=1;
% %         g(k,end-1)=0;
% %         fliplr(g);
% %         %% figure ratio vs lamda
% %         figure;
% %         gris_line(length(fecha));
% %         h1=confplot(mean_lamp([lamda,ratio']));
% %         set(h1,'LineWidth',3)
% %         hold on;
% %         aux=plot(lamda,ratio');
% %         legend(aux,datestr(fecha),-1);
% %         for ii=1:length(aux), set(aux(ii),'Tag',datestr(fecha(ii))); end
% %         grid
% %         ylabel('Ratio');
% %         xlabel('Wavelength (A)');
% %         title(['Brewer ',nbr,' Lamps ',nlamp{i},' & ',nlamp{j},' : Ratio vs Lambda']);
% %         interactivelegend(aux);
% % 
% % 
% %         %% ratio temporal
% % 
% %         figure;
% %         %gris_line(size(lamda,1))
% %         hp=plot(fecha,ratio,'.');
% %         %legend(num2str(lamda),0);
% %         grid
% %         xdate=unique(fecha);
% %         set(gca,'xtick',xdate);
% %         set(gca,'xticklabel',datestr(xdate));
% %         try
% %             rotateticklabel(gca,90);
% %         catch
% %             datetick('x',12,'keeplimits','keeplimits')
% %         end
% %         hold on;
% %         [m,s]=grpstats(ratio',g,{'median','std'});
% %         h=plot(fecha,m);
% %         legend(h,num2str(lamda_grp(1:end-1)'))
% %         %plot(r_d{i,cuenta1}(:,1),median(r_d{i,cuenta1}(:,2:end)'),'r*')
% %         h=plot(fecha,smooth(fecha,median(m),5),'-+');
% %         set(h,'linewidth',3);
% % 
% %         ylabel('Ratio');
% %         title(['Brewer ',nbr,' Lamps ',nlamp{l0},' & ',nlamp{l1},' : Ratio vs Date']);
% %         end
% %         
% %     end
% % end
              

% for i=7:8
%     hold on; plot(lamda,(RESUMEN(i,7:end)-1)*100)
% end