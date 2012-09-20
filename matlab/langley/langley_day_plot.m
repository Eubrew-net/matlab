function langley_day_plot(day,nbrw,lgl_s,cfg_s,F,fplot)
fecha=cellfun(@(x) unique(fix(x(:,1))),lgl_s(1,:))';
nd=find(day==fecha);
langley_day(lgl_s{nbrw,nd},nbrw,cfg_s{nbrw,nd},F,fplot);