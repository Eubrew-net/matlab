function [ resp,stats ] = filter_langley(lgl,brw )
%UNTITLED6 Summary of this function goes here
%   resp four dim matrix(AM_PM,CFG,Parameter,Results);
%          dim  (2,2,4,7,8);
%   AM_PM dim 2  AM=1/PM=2  
%   CFG dim 2  CFG1,CFG2
%   WV  dim 7  F0,F1,F2,F3,F4,F5,F6
%   Paramenter dim 4   ETC,SLOPE,FILTER1,FILTER2
%   results    dim 8   1 Value, 2 Standard Error,
%                      3-6 coefcorr (i,1:4) 
%                      7 ratio Vaule/Se
%                      p valor of 7
%   stats(AM,PM) output of roboust_fit
if nargin==1
    brw='XXX';
end
fecha=datestr(unique(fix(lgl(:,1))));    
 o3.ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
           'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1º
           'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25  
           'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32Segund configuracion                          
           'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)               
         };
%% remplazamos dark for R6 ->continuos
lgl(:,13)=lgl(:,25);
lgl(:,27)=lgl(:,39);
  
%%cortamos en airmass 6 y eliminamos el filtro 4
  lgl=lgl(lgl(:,5)<6,:);
  %lgl=lgl(lgl(:,10)<=192,:);
  % separamos la mañana de la tarde (tst-> true solar time)
  jpm=(lgl(:,9)/60>12) ; jam=~jpm;
 stats=[];
 resp=NaN*zeros(2,2,4,7,8);
for ampm=1:2  
    if ampm==1 jk=jam; else jk=jpm; end
    t=tabulate(lgl(jk,10));
    for ncfg=1:2
        if ncfg==1 jc=[12:18];  else jc=[26:32];   end    
        %% FIlTER regression
        X=[lgl(jk,5),lgl(jk,10)==192,lgl(jk,10)==256];
       
        BE=[5200,0,4870,4620,4410,4220,4040];

         for idx=1:length(jc)
         try 
          RC=lgl(jk,jc(idx))+lgl(jk,6)*BE(idx)*770/1013;%correccion de Rayleight
          [c1,ci]=robustfit(X,RC);
          resp(ampm,ncfg,:,idx,:)=[c1,ci.se,ci.coeffcorr,ci.t,ci.p];
          stats{ampm,ncfg,idx}=ci;
         catch
           disp('warning');
         end
        end
    end
end


 figure;
  h=mmplotyy_temp(lgl(:,9)/60,lgl(:,12:18),lgl(:,[19,33]),'.');
  legend(o3.ozone_lgl_legend([12:18,19,33]),'orientation','horizontal');
  ylabel('counts second');
  mmplotyy('ozone')
  title([brw,' ',fecha]);
  
  
  
  %%
  figure;
  plot(lgl(:,5),lgl(:,[25]),'g:')
  hold on;
  plot(lgl(jam,5),lgl(jam,25),'.r')
  hold on
  plot(lgl(jpm,5),lgl(jpm,25),'.b')
  legend('all','am','pm')
  xlabel('time')
  ylabel('ms9 ratios');
  [a,b]=rline;
  legend(num2str(b'))
  title([brw,' ',fecha]);
 % Filter   
figure;
  gscatter(lgl(:,5),lgl(:,[25,39]),[lgl(:,10)])
  xlabel('air mass')
  ylabel('ms9 ratios');
  title([brw,' ',fecha]);
figure;
  gscatter(lgl(:,5),lgl(:,[12,18]),[lgl(:,10)])
  xlabel('air mass')
  ylabel('ms9 ratios');
  title([brw,' ',fecha]);

  figure
  plot(lgl(jam,5),lgl(jam,12:18),'.')
  legend(o3.ozone_lgl_legend(12:18));
  ylabel('ratios ');
  [h,r]=rline;
  title([brw,' ',fecha]);
  O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
  try
  r6=(r*O3W');
  title([brw,' ',fecha,' AM ',num2str(r6(2))]);
  catch
      title([brw,' ',fecha,' AM ','NODATA']);
  end
figure
  plot(lgl(jpm,5),lgl(jpm,12:18),'.')
  legend(o3.ozone_lgl_legend(12:18));
  ylabel('ratios ');
  [h,r]=rline;
  title([brw,' ',fecha]);
  O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
  try
  r6=(r*O3W');
  title([brw,' ',fecha,' PM ',num2str(r6(2))]);
  catch
      title('NO_DATA')
  end
end

