  function [ozone,so2,ratios]=ozone_cal_raw(DS,m2,P,M3,config)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % function ozone_cal_raw=(DS,m2,P,M3,BE)
  % ozone calculation from counts/seconds
  % input data
  %  DS counts/second
  %  
  % 1� Rayleight correction
  %  Si se proporcionan coeficientes se calculan si no se usa el standard
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    DS=rayleigth_cor(DS,P,M3);  
      
    ms4=DS(:,6)-DS(:,3);
    ms5=DS(:,6)-DS(:,4);
    ms6=DS(:,6)-DS(:,5);
    ms7=DS(:,7)-DS(:,6);
    ms9=ms5-0.5*ms6-1.7*ms7;     % o3 double ratio ==MS(9)
    ms8=ms4-3.2*ms7;             %:REM SO2 ratio MS(8)
    
        
    B1=config(11);B2=config(12);
    A1=config(8);A2=config(9);A3=config(10);  
    ozone=(ms9-B1)./(10*A1*m2);
    so2=(ms8-B2)./(A2*A3*m2)-ozone/A2;
    ratios=[DS,ms4,ms5,ms6,ms7,ms8,ms9];
    
end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %function RC=rayleigth_cor(F,P,M3,BE)
  %Rayleight correction
  % Si se proporcionan coeficientes se calculan si no se usa el standard
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function RC=rayleigth_cor(F,P,M3,BE)
   % F(I)=F(I)+BE(I)*M3*PZ%/1013:REM rayleigh

      
      if nargin==3 % si no usa la estandard
        % FROM INIT.RTN 
        %12060 FOR I=2 TO 6:READ BE(I):NEXT:REM  read Rayleigh coeffs
        %12070 DATA 4870,4620,4410,4220,4040

      BE=[0,0,4870,4620,4410,4220,4040];
      end
    % BE=[5327    0 5096    4835    4610    4408    4217];
    for j=1:7
        F(:,j)=F(:,j)+BE(j)*M3*P/1013;         
    end    
  RC=F;
  end