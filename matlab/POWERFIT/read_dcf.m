function [pwl,dcf]=read_dcf(file)
dcf=textread(file,'%f',18); % only ozone
%5474 CLOSE 8:OPEN DD$+NO$+"\"+DCF$+"."+NO$ FOR INPUT AS 8
%5476 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,DC(I,J):DC(0,J)=DC(6,J):NEXT:NEXT
%5478 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,NDC(I,J):NDC(0,J)=NDC(6,J):NEXT:NEXT

% to matlab polinomials
dcf_=[dcf(end-2:end);dcf(1:end-3)]; % la 0 es la 6
pwl=reshape(dcf_,3,6);
pwl=flipud(pwl);
