function D=sun_earth_factor(fecha_matlab)
% formula de spencer
% Spencer, J. W., 
%"Fourier Series Representation of the Position of the Sun," 
% Search, Vol. 2, 1971, p. 172. 
angulo_diario=2*pi*(diaj(fecha_matlab)-1)/365;

D=1.001100 + ...
  0.034221 * cos(angulo_diario)+ ...
  0.001280 * sin(angulo_diario)+ ...
  0.000719 * cos(2*angulo_diario)+ ...
  0.000077 * sin(2*angulo_diario);




  