function zeit=mza2zeit(m_za,fecha,lat,long,f_plot)
if nargin==4
    f_plot=0;
end
day=fix(fecha);
t=day:1/24/60:day+1;

for i=1:length(t), 
  [maz(i),mza(i)]=lunar_sza(t(i),rad2deg(lat),rad2deg(long),2.4);
  [s_za(i),m2(i)]=sza(t(i),rad2deg(lat),rad2deg(long));
end

%zeit=interp1(mza,t,m_za);
[x,zeit]=meetpoint(mza,t,[m_za,m_za],[min(t),max(t)]);
sza_m=sza(zeit,lat,-long); %brewer
if f_plot
figure
mmploty2([t;mza;maz]',{[-90,90],[0,360]});
hold on
 plot(t,90-s_za,'b')
 l=legend('moon elev','moon az','sun sza')
datetick('x','keeplimits','keepticks');
vline(zeit,'r',cellstr(datestr(zeit')));
hline(x);
ylabel('moon elevation & sun solar zenith angle')
mmplotyy('monn azimut');
suptitle({'',sprintf('Moon %s lat=%.2f  long=%.2f',datestr(day),rad2deg(lat),rad2deg(long))...
 ,sprintf(' time %.2fh sza = %.2f \n',[24*(zeit-fix(zeit))',sza_m]') }); 
 l=legend('moon elev','moon az','sun sza')

end