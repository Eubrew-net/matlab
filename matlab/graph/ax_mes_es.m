function ax_mes_es

YDays = 1:12;
%[1,32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
YDayn=['Ene';'Feb';'Mar';'Abr';'May';'Jun';'Jul';'Ago';'Sep';'Oct';'Nov';'Dic'];

set(gca,'XTick',YDays);
set(gca,'XTickLabel',YDayn);
set(gca,'Xlim',[0.5,12.5]);
