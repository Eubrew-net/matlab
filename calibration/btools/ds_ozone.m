function [ozone,so2,ratios]=ds_ozone(ds_raw,config,M2,M3,RC)
% Raw counts-> ds raw measuremente
%  Columns 1 through 7
%    'dat'    'flg'    'nds'    'tmp'    'fl1'    'fl2'    'tim' 
%  Columns 8 through 14
%    'm2 '    'm3 '    'cy '    'F0 '    'F1 '    'F2 '    'F3 '   
%  Columns 15 through 21
%   'F4 '    'F5 '    'F6 '    'r1 '    'r2 '    'r3 '    'r4 '

% OJO m3 normalizada con la presion
% 8700 REM -8799 calculate ratios
% 8705 IF MDD$="n2" THEN 8730
% FOR I=4 TO 6:MS(I)=F(5)-F(I-2):NEXT:
% 						MS(7)=F(6)-F(5):REM single ratios
% 8715   MS(8)=MS(4)-3.2*MS(7):REM SO2 ratio
% 8720   MS(9)=MS(5)-.5*MS(6)-1.7*MS(7):REM O3 ratio

%     ms4=DS(:,6)-DS(:,3);
%     ms5=DS(:,6)-DS(:,4);
%     ms6=DS(:,6)-DS(:,5);
%     ms7=DS(:,7)-DS(:,6);
%     ms9=ms5-0.5*ms6-1.7*ms7;     % o3 double ratio ==MS(9)
%     ms8=ms4-3.2*ms7;             %:REM SO2 ratio MS(8)


% default values
 m2ds=ds_raw(:,8); 
 m3ds=ds_raw(:,9); % ojo normalizada con la presion
% FROM INIT.RTN 
%12060 FOR I=2 TO 6:READ BE(I):NEXT:REM  read Rayleigh coeffs
%12070 DATA 4870,4620,4410,4220,4040
 R=[ 0 0   4870  4620    4410    4220    4040 ]; 
 if nargin>2 && ~isempty(M2)
     m2ds=M2;
 end
 if nargin>3 && ~isempty(M3)
     m3ds=M3;
 end
        
% Rayleight
if nargin>4 && ~isempty(RC)
    R=RC;
end



% Weight definition for the seven slits
% slit 0 used for hg calibration slit 1-> dark
O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
SO2W=[  0.00    0  -1.00    0.00    0.00    4.20   -3.20];
% MS8 SO2 ms9 o3 en el soft del brewer.
% single ratios used in brewer software
rms4=[0 0 -1  0  0  1  0];
rms5=[0 0  0 -1  0  1  0];
rms6=[0 0  0  0 -1  1  0];
rms7=[0 0  0  0  0 -1  1];

Ratios=[rms4;rms5;rms6;rms7;O3W;SO2W];




% constants from config file
    
B1=config(11);
B2=config(12);
A1=config(8);
A2=config(9);
A3=config(10);  

% airmass

% Raleight correction
 RC=matmul(m3ds,R);
% R coef raleight
% w weithgth
F=ds_raw(:,11:17);
% rayleight corrected counts
F=round(F+RC);

%airmc
ratios=F*Ratios';

% ozone=(ms9-B1)./(10*A1*m2ds);
ozone=(ratios(:,5)-B1)./(10*A1*m2ds);
%so2=(ms8-B2)./(A2*A3*m2ds)-ozone/A2;
so2=(ratios(:,6)-B2)./(A2*A3*m2ds-ozone/A2);


    
    