function [aod,aod_m,aeronet]=read_aeronet(filename,varargin)
%filename='090101_111231_Izana.lev2'
    if isempty(varargin)
       aod_idx=8;
    else
       aod_idx=varargin{:};
    end
    aeronet=[];
    aeronet_f=fopen(filename,'rt');
    aeronet=textscan(aeronet_f,'%f:%f:%f,%f:%f:%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d/%d/%d,%f\t',...
        'headerlines',5,'treatAsEmpty','N/A'); %Formato all points corresponent al format del Level 1.5 i 2.0 de la Versió 2 d'AERONET.
    %aeronet=textscan(aeronet_f,'%f','headerlines',5,'treatAsEmpty','N/A','Delimiter',',:'); %Formato all points corresponent al format del Level 1.5 i 2.0 de la Versió 2 d'AERONET.
    fclose(aeronet_f);


    dia_aeronet=aeronet{1,1};
    mes_aeronet=aeronet{1,2};
    any_aeronet=aeronet{1,3};
    hora_aeronet=aeronet{1,4};
    minut_aeronet=aeronet{1,5};
    segon_aeronet=aeronet{1,6};
    date=datenum(any_aeronet,mes_aeronet,dia_aeronet,hora_aeronet,minut_aeronet,segon_aeronet);

    AOD340=aeronet{1,23};
    AOD380=aeronet{1,22};
    AOD412=aeronet{1,21};
    AOD440=aeronet{1,20};
    AOD443=aeronet{1,19};
    AOD490=aeronet{1,18};
    AOD500=aeronet{1,17};
    AOD531=aeronet{1,16};
    AOD532=aeronet{1,15};
    AOD551=aeronet{1,14};
    AOD555=aeronet{1,13};
    AOD667=aeronet{1,12};
    AOD675=aeronet{1,11};
    AOD870=aeronet{1,10};
    AOD1020=aeronet{1,9};
    AOD1640=aeronet{1,8};
    
    alfa340_440=aeronet{1,46};
    alfa440_870=aeronet{1,42};
    water_cm=aeronet{1,24};
    aodL2_340=[date,AOD340];

    aod = [ date,...
    dia_aeronet,mes_aeronet,any_aeronet,hora_aeronet,minut_aeronet,segon_aeronet,...
    AOD340,...
    AOD380,...
    AOD412,...
    AOD440,...
    AOD443,...
    AOD490,...
    AOD500,...
    AOD531,...
    AOD532,...
    AOD551,...
    AOD555,...
    AOD667,...
    AOD675,...
    AOD870,...
    AOD1020,...
    AOD1640,...
    alfa340_440,...
    alfa440_870,...
    water_cm];


   [m,s,n]=grpstats(aod,[year(date),diaj(date)],{'mean','std','numel'});

   aod_m=[m(:,1),m(:,aod_idx),s(:,aod_idx),n(:,aod_idx)];

   %save aod_340_L2_m aod_340_m
   %save aodL2_340 aodL2_340


