function [ resp,stats,data ] = simple_langley_summ(lgl,brw,FC,fplot )
%function [ resp,stats ] = simple_langley(lgl,brw,FC,fplot )
%   resp four dim matrix(AM_PM,CFG,Parameter,Results);
%          dim  (2,2,5,7,3);
%   AM_PM dim 2  AM=1/PM=2
%   CFG dim 2  CFG1,CFG2
%
%   Paramenter dim 5   ETC,SLOPE,FILTER1,FILTER2,FILTER3
%   WV  dim 7  F0,R6,F2,F3,F4,F5,F6
%   results    dim 3   1 Value,
%                      2-3 ci,
%
%   stats(AM_PM,CFG,WV) stat output of regress
%   DATA regression data used for plots
%   data(AM_PM,CFG,WV,6)    y=b+ax+ f1(F)+f2(F)+f3(F)  (b,a,f1,f2,f3) 5 incognitas
%    1-> airmass  x
%    2-> y hat (sin filtros)  yhat= b+ax
%    3-> y F counts/second
%    4-> residuals  y-
%    5-6 -> residuals ci
% TODO
% revisar el problema con el numero peque�o de datos

% TODO
% revisar el problema con el numero peque�o de datos
if nargin==1
    brw='XXX';
    fplot=0;
end
if nargin==2
    FC=[];
    fplot=0;
end
if nargin==3
    fplot=0;
end

fecha=datestr(unique(fix(lgl(:,1))));
o3.ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11
    'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1� conf
    'o3 cfg1'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25
    'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32 Second configuracion
    'O3 cfg2'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)
    };
%% remplazamos dark for R6 ->continuos
lgl(:,13)=lgl(:,25);
lgl(:,27)=lgl(:,39);

%%cortamos en airmass 6 y eliminamos el filtro 4  <-- en la entrada
%  lgl=lgl(lgl(:,5)<5,:);
%  lgl=lgl(lgl(:,10)<=192,:);                    %
% separamos la ma�ana de la tarde (tst-> true solar time)
jpm=(lgl(:,9)/60>12) ; jam=~jpm;

stats=NaN*zeros(2,2,7,4);     %parametros de la regression
resp= NaN*zeros(2,2,5,7,3);    %
data=cell(2,2,7);%test        % 

for ampm=1:2
    if ampm==1 jk=jam; else jk=jpm; end
    %t=tabulate(lgl(jk,10));
    
        
    
    if sum(jk)>=10   %numero minimo de datos
        for ncfg=1:2
            
            if ncfg==1
                jc=[19:25];  %columnas de regression
            else
                jc=[33:39];  
            end
            %% FIlTER regression
            XF=[];
            for ff=1:length(FC)
                XF=[XF,lgl(jk,10)==FC(ff)];
                if(sum(lgl(jk,10)==FC(ff))<3)   %numero de datos para el filtro
                 lgl(lgl(jk,10)==FC(ff),6)=NaN;  % si es menor se elimina
                end
                
            end;
            X=[ones(size(lgl(jk,5))),lgl(jk,5),XF];  %matriz de dise�o
            
            %BE=[5200,0,4870,4620,4410,4220,4040];    %raleyght 
            % no Rayleigh for ratios
            for idx=1:length(jc)
                try
                    RC=lgl(jk,jc(idx))%+lgl(jk,6)*BE(idx)*770/1013;
                    %correccion de Rayleight las cuentas brutas no estan corregidas
                    % ojo R6 si pero BE=0 en el dark
                    [c1,ci,r,ri,st]=regress(RC,X);
                    resp(ampm,ncfg,1:length(c1),idx,:)=[c1,ci];
                    stats(ampm,ncfg,idx,:)=st; %npoints...
                    data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
                catch
                    %disp('reg error');
                end
            end
        end
    else
        % revisar el problema con el numero peque�o de datos
        data(ampm,:,:)=num2cell(NaN*zeros(2,6,7),2);
    end    
end

if fplot
 figure;
  h=mmplotyy_temp(lgl(:,9)/60,lgl(:,12:18),lgl(:,[19,33]),'.');
  legend(o3.ozone_lgl_legend([12:18,19,33]),'Location','South','orientation','horizontal');
  ylabel('counts second');
  mmplotyy('ozone')
  try
  title([brw,' ',fecha]);
  catch
  title([brw,' ']);
  end
figure;
  h=mmplotyy_temp(lgl(:,9)/60,lgl(:,26:32)-lgl(:,12:18),lgl(:,19)-lgl(:,33),'.');
  legend(o3.ozone_lgl_legend([26:32,19,33]),'Location','South','orientation','horizontal');
  ylabel('counts second');
  mmplotyy('ozone')
  try
  title([brw,' cfg  diff ',fecha]);
  catch
  title([brw,' cfg diff']);
  end
  
  %   %%
  
    for am=1:2
        if am==1 jk=jam; else jk=jpm;end
        for nc=1:2
        figure;   
        aux=cell2mat(data(am,nc,:));
        cx=squeeze(aux(:,1,2:end));
        cy=squeeze(aux(:,2,2:end)); %filter corrected
        cr=squeeze(aux(:,3,2:end)); % uncorrected
        resid=squeeze(aux(:,4,2:end));
        try
        gplotmatrix(cx(:,1),resid,lgl(jk,10),[],[],10,[],[],'airmass',o3.ozone_lgl_legend([19,14:18]))
        catch
            disp('No data');
        end
        title(sprintf(' am %d  cfg %d  etc %d sl %d f1= %d f2= %d f3= %d ',am,nc,...
        fix(resp(am,nc,1:5,2,1))));
        try
        suptitle([brw,' ',fecha]);
        catch
         suptitle([brw,' ']);
        end
       end
    end
    
  
    %% 
  
  %%
%   figure;
%   aux=cell2mat(data(2,:,:));
%   cx=squeeze(aux(:,7,:));
%   cy=squeeze(aux(:,8,:)); %filter corrected
%   cr=squeeze(aux(:,9,:)); % uncorrected
%   resid=squeeze(aux(:,10,:));
%   gplotmatrix(cx(:,1),resid(:,2:end),lgl(jpm,10),[],[],10,[],[],'airmass',o3.ozone_lgl_legend([19,14:18]))
%   title([brw,' PM cfg 2 ',fecha]);
%   title([brw,' PM cfg 2 ',fecha]);
% 
  
%   %%
    figure;
    n=0;
    for am=1:2
        for nc=1:2
        n=n+1;
        subplot(4,1,n);    
        aux=cell2mat(data(am,nc,:));
        cx=squeeze(aux(:,1,3:end)); %airmass
        cy=squeeze(aux(:,2,3:end)); %filter corrected
        cr=squeeze(aux(:,3,3:end)); % uncorrected
        resid=squeeze(aux(:,4,3:end));
        if ~isempty(cx)
          h=mmplotyy_temp(cx(:,1),resid,cy,'.');
          ylabel('residuals');
          mmplotyy('Filter corrected');
          %legend(o3.ozone_lgl_legend([12,19,14:18]),'Location','North','orientation','horizontal');
          legend(sprintf(' am %d  cfg %d ',am,nc));
        end
        end
    end
      samexaxis('abc','xmt','on','ytac','join','yld',1);
      try
        suptitle([brw,' ',fecha]);
        catch
         suptitle([brw,' ']);
        end
%%
    figure;
    n=0;
    for am=1:2
        for nc=1:2
        n=n+1;
        subplot(4,1,n);    
        aux=cell2mat(data(am,nc,:));
        cx=squeeze(aux(:,1,end)); %airmass
        cy=squeeze(aux(:,2,end)); %filter corrected
        cr=squeeze(aux(:,3,end)); % uncorrected
        resid=squeeze(aux(:,4,end));
       if ~isempty(cx) 
          h=mmplotyy_temp(cx(:,1),resid,[cr,cy],'.');
          ylabel('residuals');
          mmplotyy('Filter corrected');
          %legend(o3.ozone_lgl_legend([12,19,14:18]),'Location','North','orientation','horizontal');
          legend({sprintf(' am %d  cfg %d ',am,nc),'uncor','cor'});
       end
     end
    end
      samexaxis('abc','xmt','on','ytac','join','yld',1);
      %suptitle(['F5 ',brw,' ',fecha]);      
      try
        suptitle([brw,' F5 ',fecha]);
        catch
         suptitle([brw,' F5  ']);
        end
%  % Filter   
% figure;
%   gscatter(lgl(:,5),lgl(:,[25,39]),[lgl(:,10)])
%   xlabel('air mass')
%   ylabel('ms9 ratios');
% 
% hold on
%   gscatter(lgl(:,5),lgl(:,[12,18]),[lgl(:,10)])
%   xlabel('air mass')
%   ylabel('ms9 ratios');
%   title([brw,' ',fecha]);

  
end