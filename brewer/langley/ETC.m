function [ETC_AM,ETC_PM,AM,PM,rAM,rPM]=ETC(dss,M,method)

ETC_AM=NaN*ones(1,10);
ETC_PM=ETC_AM;
AM=[];
PM=[];

rAM=[];
rPM=[];

col_ms9=22;   col_ms8=20;     col_ozo=8;

AM=dss(find( dss(:,2)<12.0 & dss(:,3)<90 & dss(:,5)<M(1) & dss(:,5)>M(2) ),:);
PM=dss(find( dss(:,2)>12.0 & dss(:,3)<90 & dss(:,5)<M(1) & dss(:,5)>M(2) ),:);  


if(length(AM)>20) 
    [b,bint,rAM,rint,stats]=linregress(AM(:,col_ms9),AM(:,5),0.01); 
    p1ds=b;
    p1int=bint;
    p1r=stats(1)^2*10^4;
    ea0=mean(abs(bint(2,:)-b(2)));
    ea2=mean(abs(bint(1,:)-b(1)));
    ozoAM=[nanmean(AM(:,8)),trimmean(AM(:,8),5),nanstd(AM(:,8)),1.3*mad(AM(:,8))];       
    ETC_AM=[p1ds(2),p1ds(1),p1r,ea0,ozoAM,length(AM(:,8)),range(AM(:,5))];
end  

if(length(PM)>20)
    [bpm,bint_pm,rPM,rint,stats_pm]=linregress(PM(:,col_ms9),PM(:,5),0.01); 


    p2int=bint_pm;
    p2r=stats_pm(1)^2*10^4;
    ep0=mean(abs(bint_pm(2,:)-bpm(2)));
    ep2=mean(abs(bint_pm(1,:)-bpm(1)));
    ozoPM=[nanmean(PM(:,8)),trimmean(PM(:,8),5),nanstd(PM(:,8)),1.3*mad(PM(:,8))]; 
    ETC_PM=[bpm(2),bpm(1),p2r,ep0,ozoPM,length(PM(:,8)),range(PM(:,5))];
end 

