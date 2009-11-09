% function ax_mes_en  -> label monhs on the x axis
function ax_mes_en

YDays = 1:12;
%[1,32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
YDayn=['Jan';'Feb';'Mar';'Abr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dic'];

set(gca,'XTick',YDays);
set(gca,'XTickLabel',YDayn);
set(gca,'Xlim',[0.5,12.5]);
