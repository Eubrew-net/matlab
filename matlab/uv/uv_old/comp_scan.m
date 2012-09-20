function [fig_indv,fig_day,ratio,uv,time,lamda,szar]=comp_scan(uv1,uv2,fplot)

% eleccion de candidatos
ratio=[];uv=[];time=[];l=[];
fig_indv=[];fig_day=[]; 
szar=[];
if nargin==2
    fplot=0;
    % solo plotea el resumen
end
%c1=find(uv1.type(2,:)=='a'); % scanes tipo ua sincronizados
%c2=find(uv2.type(2,:)=='a'); % scanes tipo ua sincronizados

% comprobamos la simultaniedad

%time1=uv1.time(1,c1)/60;
%Time2=uv2.time(1,c2)/60;

fecha1=uv1.date(:,1); fecha1=sprintf('%03d%02d',fecha1(2),fecha1(1));

if ~isempty(uv1.time) && ~ isempty(uv2.time)

    time1=uv1.time(1,:)/60;
    time2=uv2.time(1,:)/60;

    %Longitud de onda de sincronismo  --->revisar presupone que son iguales
    [l_1,j1]=find(uv1.l==2900);
    [l_2,j2]=find(uv2.l==2900);
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


    % buscamos las comunes

    %introducimos los dias
    date1=datenum(uv1.date(2,:)',1,0)+uv1.date(1,:)'+uv1.time(1,:)'/60/24;
    date2=datenum(uv2.date(2,:)',1,0)+uv2.date(1,:)'+uv2.time(1,:)'/60/24;

    %[c,i1,i2]=intersect(round(uv1.time(1,:)),round(uv2.time(2,:))) % tiempos comunes (al minuto)
    [c,i1,i2]=intersect(fix(date1*60*24/2)*2,fix(date2*60*24/1)*1); % tiempos comunes (al 2 minuto)
    dates={datestr(date2(i2)),datestr(date1(i1))}
    uv2.time(1,:)=uv2.time(2,:); %chapuza
    % buscamos las longitudes de onda comunes
    count=length(c)


    for i=1:count

        [cl,l1,l2]=intersect(uv1.l(:,i1(i)),uv2.l(:,i2(i)));
        x=[uv1.l(l1,i1(i)),uv2.l(l2,i2(i))];
        y=[uv1.uv(l1,i1(i)),uv2.uv(l2,i2(i))];
        y2=100*((y(:,1)-y(:,2))./y(:,2));
        x2=x(:,1);
        ratio=[ratio,y2];
        uv=[ uv,[x2,y]];
        l=[l,x2];
        lamda=l;
        %time=[time;[ uv1.time(1,i1(i)),uv2.time(1,i2(i))]];
        time=[time;[ date1(i1(i)),date2(i2(i))]];

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
            xlabel(' wavelength (A) ');
            set(a(1),'linewidth',1);
            l1=legend(a,sprintf('%8s  %03s',datestr(uv1.time(1,i1(i))/60/24,15),leg1),...
                sprintf('%8s  %03s', datestr(uv2.time(1,i2(i))/60/24,15),leg2),2);
            set(l1,'FontWeight','demi');
            l2=legend(b,sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2),4);
            set(l2,'FontWeight','demi');

            ht=title(sprintf(' Intercomparison plot %03s vs %03s %02d/%02d',...
                leg1,leg2,uv1.date(1,i),uv1.date(2,i)));
            set(ht,'Fontweight','bold');
            axes(h(2));
            set(h,'Xlim',[2900,3560]);
            ax=axis;
            
            ax(3)=-Inf;
            ax(4)=Inf;
            
            axis(ax);
            set(h(2),'YTick',[20,10,5,2.5,0,-2.5,-5,-10,-20]*-1);
            set(h(2),'Ylim',[-15,15],'YtickMode','Auto','YtickLabelMode','Auto');

            grid

            set(h(1),'Ylim',[1E-6,10],'YtickMode','Auto','YtickLabelMode','Auto');

            set(h(1),'Xtick',[])

            print('-dpsc','-append',['comp_',fecha,'_',leg1,'_',leg2]) ;
            %if i==13
            %        saveas(gcf,['comp_',fecha,'_',leg1,'_',leg2,'_',num2str(i)],'fig')
            %else
            %     close;
            %end
            disp('1');
        end
%        close all;
    end


    if(count>0)

        % intercomparacion
        fig_day=figure
        orient landscape

        %h=plot(l(:,(2:2:end)),ratio(:,(2:2:end)));
        %evitamos los picos
        ratio(find(abs(ratio)>20))=NaN;
        h=plot(l,ratio);
        legend(h,datestr(time(:,1),15),-1);
        grid
        hold on
        if(size(ratio,2)>1)

            %h2=errorbar(x2,nanmean(ratio'),nanstd(ratio'),'k');
            h2=plot(x2,nanmean(ratio'),'-k');

            set(h2,'linewidth',2);
        end
        axis([3000,3650,-20,20]);
        set(gca,'YTick',[20,10,5,2.5,0,-2.5,-5,-10,-20]*-1);        
        ht=title(sprintf(' Intercomparison ratio %03s vs %03s %02d/%02d',...
            leg1,leg2,uv1.date(1,i),uv1.date(2,i)));
        set(ht,'Fontweight','bold');


        xlabel(' wavelength (A) ')
        ylabel(sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2))
        hold off;
        orient portrait;
        %print('-djpeg',['Xcompr_',fecha,'_',leg1,'_',leg2]) ;
        %saveas(gcf,['Xcompr_',fecha,'_',leg1,'_',leg2],'fig')
        
        
                 
                 figure;
                 lamda_grp=[2900,3000,3100,3200,3300,3400,3495,3500,3600];
                 jl=findm(lamda(:,1),lamda_grp,1);
                 
                 plot(time(:,1),ratio(jl,:));
                 legend(cellstr(num2str((lamda(jl,1)))))
                 datetick;
                   
                 ht=title({sprintf(' Intercomparison ratio %03s vs %03s %02d/%02d',...
                     leg1,leg2,uv1.date(1,i),uv1.date(2,i)),...
                     sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2)});
                 set(ht,'Fontweight','bold');
                 ylabel(' ratio ')
                 xlabel(' hour ')
        
        


        %         figure
        %         orient landscape
        %
        %         %lineas de nivel
        %         v=150:100:200;
        %         v2=150:50:200;
        %         %evitamos los picos
        %         %ratio(find(abs(ratio)>20))=NaN;
        %         %
        %         [cc,hh]=contour(x(:,1),time(:,1)/60,ratio','k');
        %         %[cc,hh]=contour(x(:,1),time(:,1)/60,ratio',v2,'k');
        %         clabel(cc,hh);
        %         hold on;
        %         %contourf(x(:,1),time(:,1)/60,ratio',v);
        %         % contourf(x(:,1),time(:,1)/60,ratio');
        %
        %         colorbar;
        %         %
        %         ht=title({sprintf(' Intercomparison ratio %03s vs %03s %02d/%02d',...
        %             leg1,leg2,uv1.date(1,i),uv1.date(2,i)),...
        %             sprintf('ratio (%%) [%03s-%03s/%03s]  ',leg1,leg2,leg2)});
        %         set(ht,'Fontweight','bold');
        %         xlabel(' wavelength (A) ')
        %         ylabel(' hour ')
        % %        print('-dpsc',['Hcompr_',fecha,'_',leg1,'_',leg2]) ;
        % %        orient portrait;
        % %        print('-djpeg',['Hcompr_',fecha,'_',leg1,'_',leg2]) ;
        % %        saveas(gcf,['Hcompr_',fecha,'_',leg1,'_',leg2],'fig')

        
    %    para izaña
    
    
        figure
       [saz,az,sazc,ampm]=zeit2sza(time(:,1),28.3,-16.5,3);
         lamda_=lamda(:,1);
        g=lamda_;
        lamda_grp=[2800,3000,3100,3200,3300,3400,3495,3500,3600]
        for ii=1:length(lamda_grp)-1,
                     g(:,ii)=lamda_>=lamda_grp(ii) & lamda_<lamda_grp(ii+1);
        end
        [m,s]=grpstats(ratio,g);
        plot(saz,m','*-.');
        legend(num2str(lamda_grp(end:-1:2)'))
        szar=[szar;[saz,m']];
%         figure;
%         gplotmatrix(saz,m',diaj(time(:,1)))
    end
end




