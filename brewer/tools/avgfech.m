% los ficheros avg tienen la fecha en formato DDDAA
% esta funcion las pasa a fecha de matlab
% function avg=avgfech(mavg)
% input la matriz con la primera columna en formato DDDAA
 
function avg=avgfech(mavg)

diaj=fix(mavg(:,1)/100);
ano= mavg(:,1)-diaj*100;
avg=[datejul(ano,diaj),mavg(:,2:end)];
