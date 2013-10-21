function [fig_indv,fig_day,ratio,uv,time,lamda,szar]=comp_scan_jj(uv1,uv2,fplot)

% eleccion de candidatos
ratio=[];uv=[];time=[];l=[];fig_indv=[];fig_day=[]; 
szar=[]; duv=[];

if nargin==2
   fplot=0; % solo plotea el resumen
end
%c1=find(uv1.type(2,:)=='a'); % scanes tipo ua sincronizados
%c2=find(uv2.type(2,:)=='a'); % scanes tipo ua sincronizados

% comprobamos la simultaniedad

%time1=uv1.time(1,c1)/60;
%Time2=uv2.time(1,c2)/60;

%fecha=uv1.date(:,1);fecha=sprintf('%03d%02d',fecha(2),fecha(1));

if ~isempty(uv1.time) && ~ isempty(uv2.time)

%     time1=uv1.time(1,:)/60;
%     time2=uv2.time(1,:)/60;

    %Longitud de onda de sincronismo  --->revisar presupone que son iguales
%     [l_1,j1]=find(uv1.l==2900);
%     [l_2,j2]=find(uv2.l==2900);
    %leyendas y titutlos
    disp([uv1.file,' ',uv2.file]);
    inst1=uv1.inst;
    if ~ischar(inst1)
        inst1=num2str(inst1);
    end
    inst2=uv2.inst;
    if ~ischar(inst2)
        inst2=num2str(inst2);
    end

    leg1=strtok(inst1,' ');
    leg2=strtok(inst2,' ');


    % buscamos los scanes comunes. Se trata de ver que la diferencia de tiempo
    % entre el comienzo del scan para los dos instrumentos es inferior a
    % una cierta cantidad de tiempo (en este caso 2 segundos)

      i1=[]; i2=[];
      for kk1=1:length(uv1.time(1,:))
          for kk2=1:length(uv2.time(1,:))
              test=abs(uv1.time(1,kk1)-uv2.time(1,kk2));
              if test*60<2 %dos segundos
                  i1=[i1,kk1];
                  i2=[i2,kk2];
              else
                  continue
              end           
          end
      end
        
    % buscamos las longitudes de onda comunes
    count=length(i1);
    for i=1:count
        [cl,l1,l2]=intersect(uv1.l(:,i1(i)),uv2.l(:,i2(i)));
        x=[uv1.l(l1,i1(i)),uv2.l(l2,i2(i))];
        y=[uv1.uv(l1,i1(i)),uv2.uv(l2,i2(i))];
        y2=100*((y(:,1)-y(:,2))./y(:,2));
        x2=x(:,1);
        ratio=[ratio,y2];
        uv=[ uv,[x2,y]];
        try
         duv=[duv;uv1.duv(4,i1(i)),uv2.duv(4,i2(i))];   
        catch % old version trasposed matrix
         duv=[duv;uv1.duv(i1(i),4),uv2.duv(i2(i),4)];
        end
        l=[l,x2];
        lamda=l;
        time=[time;[ uv1.time(1,i1(i)),uv2.time(1,i2(i))]];

        if fplot==1
            figure;
           [h,a,b]=plotyy(x,y,x2,y2,'semilogy','plot');
            set(a(2),'Marker','o','MarkerSize',4);
            set(a(1),'Marker','+','MarkerSize',5); 
            set(b,'Marker','s','MarkerSize',4);
            axes(h(1));
            ylabel(' Spectral Irradiance W/m^2/nm ');
            axes(h(2));
            ylabel(' Ratio (%) ');       
            xlabel(' Wavelength (A) ');         
            set(a(1),'linewidth',1);
            l1=legend(a,sprintf('%8s  %03s',datestr(uv1.time(1,i1(i))/60/24,15),leg1),...
                        sprintf('%8s  %03s', datestr(uv2.time(1,i2(i))/60/24,15),leg2),2);
            set(l1,'FontWeight','demi','Location','NorthEast');
            l2=legend(b,sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2),4);
            set(l2,'FontWeight','demi');
 
            ht=title(sprintf(' Intercomparison plot %03s vs %03s %02d/%02d',...
                            leg1,leg2,uv1.date(1,i),uv1.date(2,i)));
            set(ht,'Fontweight','bold');
            axes(h(2));
            ax=axis;
            ax(3)=-Inf;  ax(4)=Inf;
            axis(ax);
            set(h(2),'Ylim',[-20,20],'YTick',[20,10,5,2.5,0,-2.5,-5,-10,-20]*-1,...
                     'XLim',[3000 Inf],'XTick',[]);
%             set(h(1),'Ylim',[1E-6,10],'YtickMode','Auto','YtickLabelMode','Auto',...
%                      'XLim',[3000 Inf]);         
            grid;
        end
    end
            
    if(count>0)
        % intercomparacion
        fig_day=figure;
        orient landscape
        
        subplot(3,3,[1 2 4 5])
        %h=plot(l(:,(2:2:end)),ratio(:,(2:2:end)));
        %evitamos los picos
        ratio(find(abs(ratio)>100))=NaN;
        h=plot(l,ratio);
        h=legend(datestr(time(:,1)/60/24,15),'Location','West');        
%         h=legend(cat(2,datestr(time(:,1)/60/24,15),repmat(' (',size(time,1),1),...
%                        num2str(abs(time(:,1)-time(:,2))*60),repmat(')',size(time,1),1)),...
%                        'Location','West');
        set(h,'FontWeight','Bold','FontSize',8);
        grid
        hold on
        if(size(ratio,2)>1)
            %h2=errorbar(x2,nanmean(ratio'),nanstd(ratio'),'k');
            h2=plot(x2,nanmean(ratio'),'-k');
            set(h2,'linewidth',2);
        end
        axis([2900,3650,-20,20]);
        set(gca,'YTick',[20,10,5,2.5,0,-2.5,-5,-10,-20]*-1);
        ht=title(sprintf(' Intercomparison ratio %03s vs %03s %02d/%02d',...
            leg1,leg2,uv1.date(1,i),uv1.date(2,i)));
        set(ht,'Fontweight','bold');
%         xlabel(' wavelength (A) ','FontWeight','Bold')
        ylabel(sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg1),'FontWeight','Bold');
        hold off;

        subplot(3,3,[7 8 9])
        conv=datejul(uv1.date(1,1),uv1.date(2,1));
        [sza,az,szac,ampm]=zeit2sza(conv(1)+time(:,1)/60/24,28.3,-16.5,3);
        sza(ampm<1)=-1*sza(ampm<1);
        lamda_=lamda(:,1);
        g=lamda_;
        lamda_grp=[3000,3100,3200,3300,3400,3495,3500,3600];
        for ii=1:length(lamda_grp)-1,
                     g(:,ii)=lamda_>=lamda_grp(ii) & lamda_<lamda_grp(ii+1);
        end
        [m,s]=grpstats(ratio,g);
        plot(sza,m','*-.');
        set(gca,'XLim',[sza(1)-5 sza(end)+5],'XTick',sza,'XTickLabel',fix(sza*10)/10,...
            'FontWeight','Bold','FontSize',10);
        h=legend(num2str(lamda_grp'),'Orientation','Horizontal',...
                                               'Location','SouthOutside');
        set(h,'FontWeight','Bold','FontSize',9,'Box', 'off');
        h=rotateticklabel(gca,25); set(h,'FontWeight','Bold');
%         xlabel('SZA','FontWeight','Bold');
        szar=[szar;[sza,m']];
        grid
        
        subplot(3,3,[3 6])
        mmplotyy(nanmean(time,2)/60,duv,'*-.',(duv(:,1)-duv(:,2))*100./duv(:,1),'go--',...
            [min((duv(:,1)-duv(:,2))*100./duv(:,1))-2 max((duv(:,1)-duv(:,2))*100./duv(:,1))+2]);
        t=mmplotyy(sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg1));
        set(t,'FontWeight','Bold');
        h=legend(leg1,leg2,'Location','NorthEast'); set(h,'FontWeight','Bold','FontSize',8);
        grid;
        
%         subplot(3,3,9)
%         plot(time/60,(duv(:,1)-duv(:,2))*100./duv(:,1),'go--'); grid
        
%         figure
%         %gplotmatrix(saz,m',diaj(time(:,1)))
        
%         figure
%         orient landscape
% 
% %         lineas de nivel
%         v=150:100:200;
%         v2=150:50:200;
% %         evitamos los picos
%         ratio(find(abs(ratio)>20))=NaN;
%         
%         [cc,hh]=contour(x(:,1),time(:,1)/60,ratio','k');
%         [cc,hh]=contour(x(:,1),time(:,1)/60,ratio',v2,'k');
%         clabel(cc,hh);
%         hold on;
%         contourf(x(:,1),time(:,1)/60,ratio',v);
%         contourf(x(:,1),time(:,1)/60,ratio');
% 
%         colorbar;
%         
%         ht=title({sprintf(' Intercomparison ratio %03s vs %03s %02d/%02d',...
%             leg1,leg2,uv1.date(1,1),uv1.date(2,1)),...
%             sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2)});
%         set(ht,'Fontweight','bold');
%         xlabel(' wavelength (A) ')
%         ylabel(' hour ')
% %         print('-dpsc',['Hcompr_',fecha,'_',leg1,'_',leg2]) ;
%         orient portrait;
% %         print('-djpeg',['Hcompr_',fecha,'_',leg1,'_',leg2]) ;
% %         saveas(gcf,['Hcompr_',fecha,'_',leg1,'_',leg2],'fig')  

% % %    para izaña
     end
end




