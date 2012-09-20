function xi=bring2int(x,xmin,xmax);
%xi=bring2int(x,xmin,xmax) bringt Werte x ins Intervall [xmin,xmax]
%durch addieren und subtrahieren von (xmax-xmin)

ig=x<xmin;
while sum(ig)>0
    x(ig)=x(ig)+(xmax-xmin);
    ig=x<xmin;
end;

ig=x>xmax;
while sum(ig)>0
    x(ig)=x(ig)-(xmax-xmin);
    ig=x>xmax;
end;

xi=x;
