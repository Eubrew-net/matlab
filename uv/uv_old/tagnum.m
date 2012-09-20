function tn=tagnum(yy,mm,dd);
%tn=tagnum(yy,mm,dd) berechnet die Tagnummer
%mit 1=1.Jan, auch für Vektoren

%Schaltjahrkontrolle
s=(yy/4-floor(yy/4))==0;

%Monatserste
merste=[1,32,60,91,121,152,182,213,244,274,305,335];
schalt=[0,0,1,1,1,1,1,1,1,1,1,1];

tn=yy*0;
for ii=1:length(s)
   me=merste+s(ii)*schalt;
   tn(ii)=me(mm(ii))+dd(ii)-1;
end;