function [ lgl ] = plot_langley(lgl,plot )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%% depuracion de observaciones
[m,s,n,g]=grpstats(lgl(:,[2,19,33]),fix(lgl(:,3)/10));
j=find(s(:,2)<1.0 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
idx=cellfun(@str2num,g(j));
t=ismember(fix(lgl(:,3)/10),idx);
lgl=lgl(t,:);

if plot
    
 o3.ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
           'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1º
           'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25  
           'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32Segund configuracion                          
           'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)               
         };
   
 figure;
  mmplotyy_temp(lgl(:,9)/60,lgl(:,12:18),lgl(:,[19,33]),'.')
  legend(o3.ozone_lgl_legend(12:18));
  ylabel('counts second');
  mmplotyy('ozone')

 figure
  plot(o3.ozone_lgl(:,5),o3.ozone_lgl(:,19:25))
  legend(o3.ozone_lgl_legend(19:25));
  ylabel('ratios ');
  
  %%cortamos en airmass 6
  lgl=lgl(lgl(:,5)<5,:);
  plot(lgl(:,5),lgl(:,[25,39]),'g:')
  % separamos la mañana de la tarde (tst-> true solar time)
  jpm=(lgl(:,9)/60>12) ; jam=~jpm;
  plot(lgl(jam,5),lgl(jam,25),'.r')
  hold on
  plot(lgl(jpm,5),lgl(jpm,25),'.b')
  legend('am','pm')
  xlabel('time')
  ylabel('ms9 ratios');
 % Filter   
figure;
  gscatter(lgl(:,5),lgl(:,25),[jam,lgl(:,10)])
  xlabel('air mass')
  ylabel('ms9 ratios');

end

