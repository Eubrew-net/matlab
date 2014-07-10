function I=falt_eqi(ex_wl,ex_I,wl,P);

% I=falt_eqi(ex_wl,ex_I,wl,P)
%
% faltet das Spektrum (ex_wl,ex_I) mit der durch den Spline P beschriebenen
% Spaltfunktion auf die Wellenlängen wl
%
% P muß mit csapi berechnet werden !
%
% ex_wl und wl müssen äquidistant sein und die Schrittweite von wl ein 
% Vielfaches der Schrittweite von ex_wl sein

[breaks,coeff,l,k,d]=ppbrk(P);
spmin=min(breaks);spmax=max(breaks);
clear breaks coeff l k d;

d1=diff(ex_wl);d2=diff(wl);md1=min(d1);md2=min(d2);
if (max(d1)-md1>1e-6)|(max(d2)-md2>1e-6),
  error('Wellenlängenvektoren nicht äquidistant');
end

per=md2/md1;
if abs(per-round(per))>1e-6,
  error('Schrittweite von wl muß ein Vielfaches der von ex_wl sein');
end
per=round(per);
[wl(1) ex_wl(1)];
h=(wl(1)-ex_wl(1))/md1;
delta=(h-floor(h))*md1;
anf_index=1+floor(h);
anf_spalt=floor((spmin+delta)/md1)-1;end_spalt=ceil((spmax+delta)/md1)+1;
spalt_wl=(end_spalt:-1:anf_spalt)'*md1-delta;
%spalt=(ppual(P,spalt_wl))'.*(spalt_wl>=spmin).*(spalt_wl<=spmax);
spalt=(ppual(P,spalt_wl)).*(spalt_wl>=spmin).*(spalt_wl<=spmax);
spalt=spalt/sum(spalt);

anf_index=anf_index+end_spalt;
h=conv(ex_I,spalt);
ind=(0:length(wl)-1)'*per+anf_index;
I=h(ind);
