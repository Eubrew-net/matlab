function P=linint(x,y);

% P=LININT(x,y)  berechnet ein piecewise polynomial P, das die
%                lineare Interpol. zwischen den Datenpunkten (x,y) beschreibt.
%
%                x ist eine Zeile und y eine Matrix, wobei die
%                Zeilen von y die einzelnen Datens„tze darstellen;
%
%                Die Auswertung des piecewise polynomial an den x-Werten
%                x1 (Zeile!) erfolgt mit y1=ppual(P,x1);
% 6 2 99 julian von martin geschrieben

sx=size(x);sy=size(y);
if sx(1)~=1,
 error('x muá eine Zeile sein');
elseif sx(2)~=sy(2),
 error('x und y muessen gleich viele Spalten haben');
elseif sx(2)==1,
 error('x muss mind. zwei Datenpunkte haben');
else
    l=sx(2)-1;d=sy(1);
dx=ones(d,1)*diff(x);
    dy=(diff(y'))';
    koeff(:,1:2:(2*l-1))=dy./dx;
    koeff(:,2:2:(2*l))=y(:,1:l);
    P=ppmak(x,koeff);
end

