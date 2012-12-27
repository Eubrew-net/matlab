function utstu=sza2zeit(nn,sza,pm,la,lo,meth);    
%utstu=sza2zeit(nn,sza,pm,la,lo,meth) is the inversion of zeit2sza
%nn=datenum(yy,mm,dd) in UT, muss ein Skalar sein!
%uses interpolation
%pm=1: local afternoon, pm=0: local morning, pm hat selbe dimension wie sza
%meth=1: from Michalski, 1988, valid until 2050 with accuray 0.01deg
%meth=2: old method (von Innsbruck)
%meth=3: Brewer method (von xmain.asc 7700-7885)
%negativ values of meth use the refraction corrected (apparent) sza, positive values the geometrical sza

if nargin<6
    meth=1;
end;
if nargin<5
    [lo,la]=koordinaten;
end;

%margin for local noon
delta=0.1;%[deg]

%sza for all hours
[yy,mm,dd]=datevec(nn);
utstust=[0:25*60]/60';
nnst=datenum(yy,mm,dd,utstust,0,0);
if meth>0
   szast=zeit2sza(nnst,la,lo,meth);%ohne refraction
else
   [h,h,szast]=zeit2sza(nnst,la,lo,abs(meth));%mit refraction
end;

%teile in 3 Tagesklassen
sequ=zeros(3,2);%3 sequences
%col1: 1=vorm,2=nachm
%col2: ending index
dszast=diff(szast);
ind=dszast>0;
hg=find(ind);
hk=find(~ind);
if dszast(1)<0
   sequ(1,1)=1;
   sequ(1,2)=min(hg)-1;
   sequ(2,1)=2;
   ig=hk>=sequ(1,2)+1;
   sequ(2,2)=min(hk(ig))-1;
   sequ(3,1)=1;
   ig=hg>=sequ(2,2)+1;
   if sum(ig)==0
      sequ(3,2)=length(utstust);
   else
      sequ(3,2)=min(hg(ig))-1;
   end;
else
   sequ(1,1)=2;
   sequ(1,2)=min(hk)-1;
   sequ(2,1)=1;
   ig=hg>=sequ(1,2)+1;
   sequ(2,2)=min(hg(ig))-1;
   sequ(3,1)=2;
   ig=hk>=sequ(2,2)+1;
   if sum(ig)==0
      sequ(3,2)=length(utstust);
   else
      sequ(3,2)=min(hk(ig))-1;
   end;
end;
%eventually cut 4th sequence off
utstust=utstust(1:sequ(3,2));
szast=szast(1:sequ(3,2));

%eliminate duplicated sza in sequences 1 and 3
if sequ(1,1)==1
   ind=szast<=szast(1);
else
   ind=szast>=szast(1);
end;
hh=find(ind);
ig=hh>=sequ(2,2)+1;
if sum(ig)>0
   iend=min(hh(ig))-1;
   utstust=utstust(1:iend);
   szast=szast(1:iend);
end;
sequ(3,2)=length(szast);

%ordne von Midnight to Midnight
szanoon=min(szast);
szamidn=max(szast);
ig=find(szast==szamidn);
utmidn=utstust(ig(1));
utstusts=utstust;
ig=utstust<utmidn;
utstusts(ig)=utstusts(ig)+24;
[utstusts,is]=sort(utstusts);
szasts=szast(is);

%vormittag-nachmittag
ig=find(szasts==szanoon);
utnoon=utstusts(ig(1));
iv=utstusts<=utnoon;
in=utstusts>=utnoon;

%5 Faelle
utstu=sza*0;
%1) sza not reached
ig=(sza<szanoon-delta)|(sza>szamidn+delta);
%utstu(ig)=-9999;
utstu(ig)=utnoon;
%2) im Margin unten (=around noon)
ig=(sza<szanoon)&(sza>szanoon-delta);
utstu(ig)=utnoon;
%3) im Margin oben (=around midnight)
ig=(sza>szamidn)&(sza<szamidn+delta);
utstu(ig)=utmidn;
%4) vormittag
ig=(sza<=szamidn)&(sza>=szanoon)&(pm==0);
utstu(ig)=interp1(szasts(iv),utstusts(iv),sza(ig));
%5) nachmittag
ig=(sza<=szamidn)&(sza>=szanoon)&(pm==1);
utstu(ig)=interp1(szasts(in),utstusts(in),sza(ig));

ig=utstu>=24;
utstu(ig)=utstu(ig)-24;












%--------------------------------------------------------
%Test
nein=1;
if nein==0
    
clear
utstu=[0:23]';
nn=datenum(2005,6,21,utstu,0,0);
lo=90;
la=90;
sza=zeros(length(utstu),3);
az=zeros(length(utstu),3);
pm=zeros(length(utstu),3);
for i=1:3
    [sza(:,i),az(:,i),h,pm(:,i)]=zeit2sza(nn,la,lo,i);
end;
plot(utstu,sza)
legend('new','old','Brew',0)

plot(utstu,az)
legend('new','old','Brew',0)

pm

nn1=floor(nn(1));
utstur=zeros(length(utstu),3);
for i=1:3
    utstur(:,i)=sza2zeit(nn1,sza(:,i),pm(:,i),la,lo,i);    
end;
plot(utstu,utstur)
utstur

end;


