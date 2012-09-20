

close all;clear;clc

[MAXIMOSHT_017 Error_017]=analyzeFV('E:\CODE\aro2010\bdata017\FV2*10.017');
[MAXIMOSHT_040 Error_040]=analyzeFV('E:\CODE\aro2010\bdata040\FV2*10.040');
[MAXIMOSHT_064 Error_064]=analyzeFV('E:\CODE\aro2010\bdata064\FV2*10.064');
[MAXIMOSHT_072 Error_072]=analyzeFV('E:\CODE\aro2010\bdata072\FV2*10.072');
[MAXIMOSHT_156 Error_156]=analyzeFV('E:\CODE\aro2010\bdata156\FV2*10.156');
[MAXIMOSHT_163 Error_163]=analyzeFV('E:\CODE\aro2010\bdata163\FV2*10.163');
[MAXIMOSHT_185 Error_185]=analyzeFV('E:\CODE\aro2010\bdata185\FV2*10.185');


%% 
try
    figure;
    subplot (2,1,1)
    P=plot(MAXIMOSHT_017(:,1),MAXIMOSHT_017(:,6),'bo');
    set(P,'Tag','FV_Report');
    hline([-20 20],{'k','k'});
    datetick('x',25,'keeplimits','keepticks') ;
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    %grid;
    ylabel('Azimut steps (maximum I)');
    hold on
    P=plot(MAXIMOSHT_040(:,1),MAXIMOSHT_040(:,6),'g*');
    P=plot(MAXIMOSHT_064(:,1),MAXIMOSHT_064(:,6),'c<');
    P=plot(MAXIMOSHT_072(:,1),MAXIMOSHT_072(:,6),'y+');
    P=plot(MAXIMOSHT_156(:,1),MAXIMOSHT_156(:,6),'kd');
    P=plot(MAXIMOSHT_163(:,1),MAXIMOSHT_163(:,6),'bh');
    P=plot(MAXIMOSHT_185(:,1),MAXIMOSHT_185(:,6),'rs');
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1);
    % ,'Brw#163'
    hold off
    
    
    subplot (2,1,2)
    P=plot(MAXIMOSHT_017(:,1),MAXIMOSHT_017(:,6),'bo');
    set(P,'Tag','FV_Report');
    set(gca,'YLim',[-50 50])
    hline([-20 20],{'k','k'});
    datetick('x',25,'keeplimits','keepticks') ;
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    %grid;
    ylabel('Azimut steps (maximum I)');
    hold on
    P=plot(MAXIMOSHT_040(:,1),MAXIMOSHT_040(:,6),'g*');
    P=plot(MAXIMOSHT_064(:,1),MAXIMOSHT_064(:,6),'c<');
    P=plot(MAXIMOSHT_072(:,1),MAXIMOSHT_072(:,6),'y+');
    P=plot(MAXIMOSHT_156(:,1),MAXIMOSHT_156(:,6),'kd');
    P=plot(MAXIMOSHT_163(:,1),MAXIMOSHT_163(:,6),'bh');
    P=plot(MAXIMOSHT_185(:,1),MAXIMOSHT_185(:,6),'rs');
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1);
    % ,'Brw#163'
    hold off
    
    figure;
    subplot(2,1,1)
    P=plot(MAXIMOSHT_017(:,1),MAXIMOSHT_017(:,6),'bo');
    hold on
    set(P,'Tag','FV_Report');
    hline([-20 20],{'k','k'});
    datetick('x',25,'keeplimits','keepticks') ;
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    %grid;
    ylabel('Zenit steps (maximum I)');
    hold on
    P=plot(MAXIMOSHT_040(:,1),MAXIMOSHT_040(:,9),'g*');
    P=plot(MAXIMOSHT_064(:,1),MAXIMOSHT_064(:,9),'c<');
    P=plot(MAXIMOSHT_072(:,1),MAXIMOSHT_072(:,9),'y+');
    P=plot(MAXIMOSHT_156(:,1),MAXIMOSHT_156(:,9),'kd');
    P=plot(MAXIMOSHT_163(:,1),MAXIMOSHT_163(:,9),'bh');
    P=plot(MAXIMOSHT_185(:,1),MAXIMOSHT_185(:,9),'rs');
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1);
    % ,'Brw#163'
    
    subplot(2,1,2)
    P=plot(MAXIMOSHT_017(:,1),MAXIMOSHT_017(:,6),'bo');
    hold on
    set(P,'Tag','FV_Report');
    hline([-20 20],{'k','k'});
    set(gca,'YLim',[-50 50]);
    datetick('x',25,'keeplimits','keepticks') ;
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    %grid;
    ylabel('Zenit steps (maximum I)');
    hold on
    P=plot(MAXIMOSHT_040(:,1),MAXIMOSHT_040(:,9),'g*');
    P=plot(MAXIMOSHT_064(:,1),MAXIMOSHT_064(:,9),'c<');
    P=plot(MAXIMOSHT_072(:,1),MAXIMOSHT_072(:,9),'y+');
    P=plot(MAXIMOSHT_156(:,1),MAXIMOSHT_156(:,9),'kd');
    P=plot(MAXIMOSHT_163(:,1),MAXIMOSHT_163(:,9),'bh');
    P=plot(MAXIMOSHT_185(:,1),MAXIMOSHT_185(:,9),'rs');
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1);
    % ,'Brw#163'
    hold off
end

%% 
 data2.Column1='FechaHoraMatlab';
 data2.Column1='Hora';
 data2.Column2='Minutos';
 data2.Column3='Dia juliano';
 data2.Column4='I máxima az';
 data2.Column5='Pasos azimutales';
 data2.Column6='Grados azimut';
 data2.Column7='I maxima ze';
 data2.Column8='Pasos zenitales';
 data2.Column9='Grados zenit'