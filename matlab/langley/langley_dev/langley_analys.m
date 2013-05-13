function [resp_brw resp_dbs] = langley_analys(lgl_data,brw,Cal,varargin)

%function [ resp,stats ] = simple_langley(lgl,brw,FC,fplot )
% 
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
% revisar el problema con el numero pequeño de datos

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_analys';

% input obligatorio
arg.addRequired('lgl_data',@iscell);
arg.addRequired('brw',@isfloat);
arg.addRequired('Cal',@isstruct);

% input param - value
arg.addParamValue('res_filt', 0, @(x)(x==0 || x==1));   % por defecto no filter

% arg.addParamValue('airmass', [1.15 3.5], @isfloat); % default [1.15 3.5] range
% arg.addParamValue('N_flt', 5, @isfloat);            % default 5 meas. / filter
% arg.addParamValue('N_hday', 25, @isfloat);          % default 25 o3 summaries / hday
% arg.addParamValue('O3_hday', NaN, @isfloat);        % default 2 O3 std / hday

% validamos los argumentos definidos:
arg.parse(lgl_data,brw,Cal,varargin{:});

%%
resp_brw=NaN*ones(length(lgl_data{brw}),3,2); resp_dbs=NaN*ones(length(lgl_data{brw}),3,2);
resp_brw(:,1,1)=cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}); resp_brw(:,1,2)=cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw});

resp_dbs=NaN*ones(length(lgl_data{brw}),3,2); resp_dbs=NaN*ones(length(lgl_data{brw}),3,2);
resp_dbs(:,1,1)=cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}); resp_dbs(:,1,2)=cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw});

for dd=1:length(lgl_data{brw})
    lgl=lgl_data{brw}{dd};
    fecha=unique(fix(lgl(:,1)));
    config_1=read_icf(Cal.brw_config_files{brw,1},fecha); 
    config_2=read_icf(Cal.brw_config_files{brw,2},fecha); 
    
    jpm=(lgl(:,9)/60>12); jam=~jpm;
    for ampm=1:2
        if ampm==1
           jk=jam; 
        else
           jk=jpm; 
        end
        
        if ~any(jk)
           continue
        end
        
        for ncfg=1:2   
            m_ozone=lgl(jk,5);
            if ncfg==1
               P_brw=lgl(jk,25);
               P_dbs=matdiv(matadd(lgl(jk,25),-config_1(11)),m_ozone);
            else
               P_brw=lgl(jk,39);
               P_dbs=matdiv(matadd(lgl(jk,39),-config_2(11)),m_ozone);
            end
            try
%               Brewer method
                X=[ones(size(m_ozone)),m_ozone];% matriz de diseño         
                [c1_brw,ci,r,ri,st]=regress(P_brw,X);
                if arg.Results.res_filt
                   idx=abs(r)>1.5*nanstd(r);
%                    if ncfg==2
%                       figure; 
%                       mmplotyy(m_ozone,polyval(flipud(c1_brw),m_ozone),'.-k',r,'b*:');
%                       hold on; plot(m_ozone,P_brw,'.r'); 
%                       ylabel('MS9'); mmplotyy('Residuos'); grid                                          
%                    end
                   if any(idx==1)
                      [c1_brw,ci,r,ri,st]=regress(P_brw(idx),X(idx,:));
                   end
                end
                resp_brw(dd,ampm+1,ncfg)=c1_brw(1);                
                
%               Dobson method
                X=[ones(size(m_ozone)),1./m_ozone];% matriz de diseño                         
                [c1_dbs,ci,r,ri,st]=regress(P_dbs,X);
                if arg.Results.res_filt
                   idx=abs(r)>1.5*nanstd(r);
%                    if ncfg==2
%                       figure; 
%                       mmplotyy(m_ozone,polyval(flipud(c1_dbs),m_ozone),'.-k',r,'b*:');
%                       hold on; plot(m_ozone,P_dbs,'.r'); 
%                       ylabel('MS9'); mmplotyy('Residuos'); grid                                          
%                    end
                   if any(idx==1)
                      [c1_dbs,ci,r,ri,st]=regress(P_dbs(idx),X(idx,:));
                   end
                end
                resp_dbs(dd,ampm+1,ncfg)=c1_dbs(2);
%                 figure; plot(1./lgl(jk,5),P_dbs,'.r'); hold on; 
%                 plot(1./lgl(jk,5),polyval(flipud(c1_dbs),1./lgl(jk,5)),'.-k');
%                 [c1_dbs_]=robustfit(P_dbs,1./lgl(jk,5))
%                 plot(1./lgl(jk,5),polyval(flipud(c1_dbs_),1./lgl(jk,5)),'.-m');
            catch
                resp_brw(dd,ampm+1,ncfg)=NaN; resp_dbs(dd,ampm+1,ncfg)=NaN;
            end
            
%             stats(ampm,ncfg,idx,:)=st; %npoints...
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
%             resp(ampm,ncfg,1:length(c1),idx,:)=[c1,ci];
%             stats(ampm,ncfg,idx,:)=st; %npoints...
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
        end
    end
end
