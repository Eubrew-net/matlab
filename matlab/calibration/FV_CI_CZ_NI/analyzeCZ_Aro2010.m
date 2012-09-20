
%% Unión Brewers

clear;close all;clc

[RL1_017 RL2 RL3 AB_017 E017]=analyzeCZ('E:\CODE\aro2010\bdata017\CZ2*.017');
[RL1_040 RL2 RL3 AB_040 E040]=analyzeCZ('E:\CODE\aro2010\bdata040\CZ2*.040');
[RL1_064 RL2 RL3 AB_064 E064]=analyzeCZ('E:\CODE\aro2010\bdata064\CZ2*.064');
[RL1_072 RL2 RL3 AB_072 E072]=analyzeCZ('E:\CODE\aro2010\bdata072\CZ2*.072');
[RL1_156 RL2 RL3 AB_156 E156]=analyzeCZ('E:\CODE\aro2010\bdata156\CZ2*.156');
[RL1_163 RL2 RL3 AB_163 E163]=analyzeCZ('E:\CODE\aro2010\bdata163\CZ2*.163');
[RL1_185 RL2 RL3 AB_185 E185]=analyzeCZ('E:\CODE\aro2010\bdata185\CZ2*.185');


%%

try
    figure;
    subplot(2,1,1)
    P=plot(RL1_017(:,1),RL1_017(:,4),'ro',RL1_017(:,1),RL1_017(:,6),'go');
    set(P,'Tag','CZ_Report');
    set(gca,'YLim',[-0.6 0.7]);
    datetick('x',25,'keeplimits','keepticks') ;
    hline([-0.13 0.13],{'k','k'});
    %     rotateticklabel(gca,20);
    % grid;
    ylabel('Diff (A)');
    %     legend ('MP-R2967','CM-R2967',2)
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    
    hold on
    P=plot(RL1_040(:,1),RL1_040(:,4),'r*',RL1_040(:,1),RL1_040(:,6),'g*');
    P=plot(RL1_064(:,1),RL1_064(:,4),'r<',RL1_064(:,1),RL1_064(:,6),'g<');
    P=plot(RL1_072(:,1),RL1_072(:,4),'r+',RL1_072(:,1),RL1_072(:,6),'g+');
    P=plot(RL1_156(:,1),RL1_156(:,4),'rd',RL1_156(:,1),RL1_156(:,6),'gd');
    P=plot(RL1_163(:,1),RL1_163(:,4),'rh',RL1_163(:,1),RL1_163(:,6),'gh');
    P=plot(RL1_185(:,1),RL1_185(:,4),'rs',RL1_185(:,1),RL1_185(:,6),'gs');
    %     legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',2);
    legend ('Brw#017','','Brw#040','','Brw#064','','Brw#072','','Brw#156','','Brw#163','','Brw#185','',-1)
%     ,'Brw#163',''
%     legend ('Brw#017_MP','Brw#017_CM','Brw#040_MP','Brw#040_CM','Brw#064_MP','Brw#064_CM','Brw#072_MP','Brw#072_CM','Brw#156_MP','Brw#156_CM','Brw#185_MP','Brw#185_CM');
%     ,'Brw#163_MP','Brw#163_CM'
    hold off
    
    
    subplot(2,1,2)
    P=plot(AB_017(:,2),AB_017(:,1),'mo');
    set(P,'Tag','CZ_Report');
    %set(gca,'YLim',[6 5]);
    datetick('x',25,'keeplimits','keepticks') ;
    % grid;
    ylabel('Ancho banda(A)');
    hold on
    P=plot(AB_040(:,2),AB_040(:,1),'g*');
    P=plot(AB_064(:,2),AB_064(:,1),'y<');
    P=plot(AB_072(:,2),AB_072(:,1),'c+');
    P=plot(AB_156(:,2),AB_156(:,1),'bd');
    P=plot(AB_163(:,2),AB_163(:,1),'kh');
    P=plot(AB_185(:,2),AB_185(:,1),'rs');            
    %     legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',2);
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1)
%     ,'Brw#163',''
%     legend ('Brw#017_MP','Brw#017_CM','Brw#040_MP','Brw#040_CM','Brw#064_MP','Brw#064_CM','Brw#072_MP','Brw#072_CM','Brw#156_MP','Brw#156_CM','Brw#185_MP','Brw#185_CM');
%     ,'Brw#163_MP','Brw#163_CM'
    hold off
end



%% Dos métodos separados
try
    figure;
    
    subplot(2,1,1)
    P=plot(RL1_017(:,1),RL1_017(:,4),'ro');
    set(P,'Tag','CZ_Report');
    set(gca,'YLim',[-0.6 0.7]);
    datetick('x',25,'keeplimits','keepticks') ;
    hline([-0.13 0.13],{'k','k'});
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    grid;
    ylabel('Diff MP  (A)');
    hold on
    P=plot(RL1_040(:,1),RL1_040(:,4),'r*');
    P=plot(RL1_064(:,1),RL1_064(:,4),'r<');
    P=plot(RL1_072(:,1),RL1_072(:,4),'r+');
    P=plot(RL1_156(:,1),RL1_156(:,4),'rd');
    P=plot(RL1_163(:,1),RL1_163(:,4),'rh');
    P=plot(RL1_185(:,1),RL1_185(:,4),'rs');
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1);
    % ,'Brw#163'
    
    subplot(2,1,2)
    P=plot(RL1_017(:,1),RL1_017(:,6),'go');
    set(P,'Tag','CZ_Report');
    hline([-0.13 0.13],{'k','k'});
    set(gca,'YLim',[-0.6 0.7]);
    datetick('x',25,'keeplimits','keepticks') ;
    sup=suptitle('BREWERS AROSA 2010');
    pos=get(sup,'Position');
    grid;
    ylabel('Diff CM  (A)');
    hold on
    P=plot(RL1_040(:,1),RL1_040(:,6),'g*');
    P=plot(RL1_064(:,1),RL1_064(:,6),'g<');
    P=plot(RL1_072(:,1),RL1_072(:,6),'g+');
    P=plot(RL1_156(:,1),RL1_156(:,6),'gd');
    P=plot(RL1_163(:,1),RL1_163(:,6),'gh');
    P=plot(RL1_185(:,1),RL1_185(:,6),'gs');
    legend ('Brw#017','Brw#040','Brw#064','Brw#072','Brw#156','Brw#163','Brw#185',-1)
    hold off
end
