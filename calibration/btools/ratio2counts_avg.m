function F=ratio2counts(sls)
    % Del programa de analisis de SL.
    % entramos con los sumarios
    % SLSUMARY-> 
    MS=sls(:,17:24); %el uno es el MS4-> restar 3
    %  ratios=[ms4,ms5,ms6,ms7,ms8,ms9,sl(:,9),sl(:,13)];
    %           1   2   3   4   5   6   F(3)     F(7)
    % F 1->7
    %   S0 DARK S1 S2   S3  S4  S5  
    % F   1  2   3  4    5   6   7  8  9
    % f   0  1   2  3    4   5   6 
    
    F(:,3)=log(MS(:,7))*1E4/log(10); % deshacemos la escala
    % MS7 son la cuentas de la slit 1->f(2)
    F(:,6)=MS(:,1)+F(:,3); % f5= ms4 - f2
    F(:,4)=F(:,6)-MS(:,2); % f3=f5-MS5
    F(:,5)=F(:,6)-MS(:,3); % f4=f5-ms6
    F(:,7)=F(:,6)+MS(:,4); % f6=f5+ms7
    F(:,8)=MS(:,5);      % ms(8)   
    F(:,9)=MS(:,6);      % ms(9)
    
    F(:,1)=diaj2(sls(:,1));
    F(:,2)=sls(:,13);
    % F(7) tiene que ser igual a MS8 !!
%     
%       F8c=log(MS(:,8))*1E4/log(10);
%      figure;plot(100*(F(:,7)-F8c)./F(:,7));
%      ylabel('ratio %')