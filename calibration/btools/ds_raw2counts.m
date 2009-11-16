function DS=ds_raw2counts(ds_raw,config)
% OJO falta vectorizar
% Raw counts-> ds raw measuremente
%  Columns 1 through 7
%    'dat'    'flg'    'nds'    'tmp'    'fl1'    'fl2'    'tim' 
%  Columns 8 through 14
%    'm2 '    'm3 '    'cy '    'F0 '    'F1 '    'F2 '    'F3 '   
%  Columns 15 through 21
%   'F4 '    'F5 '    'F6 '    'r1 '    'r2 '    'r3 '    'r4 '
%function DS=ds_counts(Raw_counts,Filter,temp,CY,DT,TC,AF)
% REM calc corr F's
% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
% 8350 REM correct VA for dark/dead time
% 8355 VA=(VA-F(1))*2/CY/IT:IF VA>1E+07 THEN VA=1E+07
% 8360 IF VA<2 THEN VA=2
% 8365 F1=VA:FOR J=0 TO 8:VA=F1*EXP(VA*T1):NEXT
% 8370 RETURN
%correccion por dark  
  F=ds_raw(:,11:17);
  Filtro=ds_raw(:,6);
  temp=ds_raw(:,4);
  CY=ds_raw(:,10);
  AT=config(17:22);
  AT=AT(:);
  
  TC=config(2:6);
  TC=[TC;config(26)]; %slit 0
  TC=[NaN,NaN,TC'];
  TC(1)=TC(3)-TC(6)-3.2*(TC(6)-TC(7));
  TC(2)=TC(5)-TC(6)-.5*(TC(5)-TC(6))-1.7*(TC(6)-TC(7));
  
  
  F_dark=F(:,2);
  F(:,2)=NaN*F_dark;
  % otra constante
  IT=0.1147;
  for j=1:7
    F(:,j) = 2*(F(:,j)-F_dark)./CY/IT;
  end
  % scale correction
  F(F<=0)=2;
  F(F>1E07)=1E07;

  % dead time correction
  DT=config(13);
  F0=F;
  for j=1:9
     for i=1:7  
        F(:,i)=(F0(:,i).*exp(F(:,i)*DT)); 
     end
  end
  F=round(log10(F)*10^4);  %aritmetica entera
  
% REM calc corr F's
% 8305 FOR I=WL TO WU:IF I=1 THEN 8335
% 8310   VA=F(I):GOSUB 8350
% 8315   F(I)=LOG(VA)/CO*P4%:J=I:IF J=0 THEN J=7
% 8320   IF MDD$="o3" THEN X=TC(J) ELSE X=NTC(J)
% 8325   F(I)=F(I)+X*TE%+AF(AF%)
% 8335 NEXT:RETURN

  
  Filtro=(Filtro/64)+1;
  for j=1:7
      if j~=1  
          ii=j;
      else
          ii=8;
      end
      % slit 0 no tiene correccion (no se usa para ozono) 
       F(:,j)=F(:,j)+(TC(ii)*temp)+AT(Filtro);
  end
  F(:,2)=F_dark;
  ds_raw(:,11:17)=F;
  DS=ds_raw;
  