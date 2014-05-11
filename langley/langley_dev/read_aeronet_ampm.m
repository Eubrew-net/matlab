function [aod_ampm,aod]=read_aeronet_ampm(filename,varargin)

    aod_idx=9;

    aeronet_f=fopen(filename,'rt');
    aeronet=textscan(aeronet_f,'%f:%f:%f,%f:%f:%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d/%d/%d,%f\t',...
        'headerlines',5,'treatAsEmpty','N/A'); %Formato all points corresponent al format del Level 1.5 i 2.0 de la Versió 2 d'AERONET.
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

    alfa440_870=aeronet{1,42};
    water_cm=aeronet{1,24};
    aodL2_340=[date,AOD340];

    days=unique(fix(date)); lat=28.3081; long=-16.4992; 
    aux=NaN*ones(size(date,1),1);
    for dd=1:length(days)
       [szax,sazx,tstx,snoon]=sun_pos(days(dd),lat,long);

       aux(date>days(dd) & date<days(dd)+snoon/60/24)=1;
       aux(date>=days(dd)+snoon/60/24 & date<days(dd)+1)=2;
    end
        
    aod = [ date,aux,...
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
    alfa440_870,...
    water_cm];

    aod_am=aod(aod(:,2)==1,:);     aod_pm=aod(aod(:,2)==2,:);
    [m_am,s_am,n_am]=grpstats([fix(aod_am(:,1)),aod_am(:,2:end)],fix(aod_am(:,1)),{'mean','std','numel'});
    [m_pm,s_pm,n_pm]=grpstats([fix(aod_pm(:,1)), aod_pm(:,2:end)],fix(aod_pm(:,1)),{'mean','std','numel'});

    m=scan_join(unique(fix(aod(:,1))),m_am);    m_=scan_join(m,m_pm);
    n=scan_join(unique(fix(aod(:,1))),[m_am(:,1) n_am(:,2:end)]);    n_=scan_join(n,[m_pm(:,1) n_pm(:,2:end)]);
    s=scan_join(unique(fix(aod(:,1))),[m_am(:,1) s_am(:,2:end)]);    s_=scan_join(s,[m_pm(:,1) s_pm(:,2:end)]);
    
    aod_ampm=[m_(:,1),m_(:,2),m_(:,aod_idx),s_(:,aod_idx),n_(:,aod_idx),...
                      m_(:,27),m_(:,aod_idx+25),s_(:,aod_idx+25),n_(:,aod_idx+25)];
