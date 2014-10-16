function [resp_brw stats_brw] = langley_analys_AOD_filter(lgl_data,brw,Cal,varargin)

% Function for calculating ND corrections through Langley plots.
% It works with langley_filter_lvl1 output
% 
% INPUT
% - lgl_data: langley FILTERED data as produced by langley_filter_lvl1 function
% - brw     : Brewer id
%
% Input optional:
% - res_filt   : 0 (default) or 1. Residuals filter as defined in 
%                Harrison & Michalsky, Appl. Opt. Vol 33, No 22, 1 August 1994, pp 5126-5132
%                "The standard deviation of the residuals of the remaining data points around the regression
%                 line are computed. A sweep is then made through the data points eliminating all points
%                 more than 1.5 standard deviations from the regression line".
% 
%  - plot_flag : 0 (default) or 1. Plotting MS9  vs airmass grouped by ND plus regression line
%                Two plots each day (AM & PM)
% 
% OUTPUT:
% 
% - resp_brw   : 3-D matrix
%                - 1D = results corresponding to each analyzed day
%                - 2D = data: 'Date','ETC(ND#0,#1,#2), AM','ETC(ND#3), AM','ETC(ND#4), AM','Slope, AM',...
%                                    'ETC(ND#0,#1,#2), PM','ETC(ND#3), PM','ETC(ND#4), PM','Slope, PM',...
%                - 3D = 1st & 2nd configurations
% 
% EXAMPLE:  
%
%        lgl_filt{Cal.n_inst}=langley_filter_lvl1(ozone_lgl{Cal.n_inst},'plots',0,...
%                                                 'airmass',airm_rang,'O3_hday',2,'N_hday',12,...
%                                                 'AOD','140101_141231_Izana.lev15');
%        brw_indv_{Cal.n_inst} = langley_analys_filter(lgl_filt,Cal.n_inst,Cal,...
%                                                      'res_filt',1,'plot_flag',0);
% 
%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_analys_AOD_filter';

% input obligatorio
arg.addRequired('lgl_data',@iscell);
arg.addRequired('brw',@isfloat);
arg.addRequired('Cal',@isstruct);

% input param - value
arg.addParamValue('res_filt',  0, @(x)(x==0 || x==1));   % por defecto no filter
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1));   % por defecto no plots

% validamos los argumentos definidos:
arg.parse(lgl_data,brw,Cal,varargin{:});

% It makes no sense to be informed of columns (in auxiliary var. X) not linearly independent.  
warning('off','stats:regress:RankDefDesignMat');

%% Inicializamos Variables
resp_brw=NaN*ones(length(lgl_data{brw}),9,5,2); resp_brw(:,1,:,:)=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),[1 1 5 2]);
stats_brw=struct('r',[],'ci',[]);
stats_brw.ci=NaN*ones(length(lgl_data{brw}),5,2); stats_brw.ci(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_brw.r=cellfun(@(x) NaN*ones(x,13,2),cellfun(@(x) size(x,1),lgl_data{brw},'UniformOutput', 0),'UniformOutput', 0);
stats_brw.rs=NaN*ones(length(lgl_data{brw}),11,2); stats_brw.rs(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 

%%
for dd=1:length(lgl_data{brw})
    lgl=lgl_data{brw}{dd};  
    stats_brw.r{dd}(:,1,[1 2])=repmat(lgl(:,1),1,2);  
    stats_brw.r{dd}(:,2,[1 2])=repmat(lgl(:,5),1,2); 
    stats_brw.r{dd}(:,3,[1 2])=repmat(lgl(:,10),1,2); 

    jpm=(lgl(:,9)/60>12); jam=~jpm;
    jk=cell(1,2); jk_idx=cell(1,2); P_brw=cell(1,2);
    for ampm=1:2 
        if ampm==1
           jk{ampm}=jam; ci_idx=[2 3];
        else
           jk{ampm}=jpm; ci_idx=[4 5];
        end
       
        if ~any(jk{ampm})
           continue
        end

        P_brw{ampm,1}=lgl(jk{ampm},[5 10 14:18]); P_brw{ampm,2}=lgl(jk{ampm},[5 10 28:32]); 
        for ncfg=1:2 
            try
%             Brewer method
              for slit=1:5
                  jk_idx{ampm}=jk{ampm}; 
                  X=[P_brw{ampm,2}(:,1),P_brw{ampm,2}(:,2)==0 | P_brw{ampm,2}(:,2)==64 | P_brw{ampm,2}(:,2)==128,...
                             P_brw{ampm,2}(:,2)==192,P_brw{ampm,2}(:,2)==256];                 
                  
                  [c1_brw,ci,r,ri,st]=regress(P_brw{ampm,ncfg}(:,slit+2),X);
                  % No ND#0,#1 & #2 |  ND#3 |  ND#4 
                  c1_brw(c1_brw==0)=NaN;                  
                  if arg.Results.res_filt
                     idx=abs(r)>1.5*nanstd(r);
                     if any(idx==1)
                        X=X(~idx,:); 
                        if ampm==1
                           jk_idx{ampm}(find(idx))=0;
                        else
                           jk_idx{ampm}(find(idx)+length(find(jam)))=0;                          
                        end
                     end
                     [c1_brw,ci,r,ri,st]=regress(P_brw{ampm,ncfg}(~idx,slit+2),X);
                     c1_brw(c1_brw==0)=NaN;                  
                  end
                  % Index to create output. Just ETC & Slope, no stats !!
                  if ampm==1
                     id=1;
                  else
                     id=5;
                  end
                  resp_brw(dd,id+1,slit,ncfg) = c1_brw(2); % 1st ETC (ND#0,#1 & #2)
                  resp_brw(dd,id+2,slit,ncfg) = c1_brw(3); % 2nd ETC (ND#3)       
                  resp_brw(dd,id+3,slit,ncfg) = c1_brw(4); % 3rd ETC (ND#4)       
                  resp_brw(dd,id+4,slit,ncfg) = c1_brw(1); % Slope (we assume same for all ND)
              end                
              
            catch exception
                resp_brw(dd,ampm+1,slit,ncfg)=NaN; 
            end            
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
%             resp(ampm,ncfg,1:length(c1),idx,:)=[c1,ci];
%             stats(ampm,ncfg,idx,:)=st; %npoints...
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
        end
    end
    if arg.Results.plot_flag
%        rat_res=cat(1,stats_brw.r{dd}(jk_idx{1},4:8,1),stats_brw.r{dd}(jk_idx{2},9:13,1))./cat(1,stats_brw.r{dd}(jk_idx{1},4:8,2),stats_brw.r{dd}(jk_idx{2},9:13,2)); 
       m_oz=stats_brw.r{dd}(:,2,1); filt=stats_brw.r{dd}(:,3,1);
       
       figure; 
       a(1)=subaxis(3,2,1);  gscatter(stats_brw.r{dd}(jk_idx{1},2,1),stats_brw.r{dd}(jk_idx{1},1+3,1),stats_brw.r{dd}(jk_idx{1},3,1),'','o',{},'off'); hold all
                             gscatter(stats_brw.r{dd}(jk_idx{1},2,2),stats_brw.r{dd}(jk_idx{1},1+3,2),stats_brw.r{dd}(jk_idx{1},3,2),'','.',{},'off'); 
                             text(3,-500,'Slit#2','Background','w'); xlabel(gca,'');
       a(2)=subaxis(3,2,2);  gscatter(stats_brw.r{dd}(jk_idx{1},2,1),stats_brw.r{dd}(jk_idx{1},2+3,1),stats_brw.r{dd}(jk_idx{1},3,1),'','o',{},'off'); hold all
                             gscatter(stats_brw.r{dd}(jk_idx{1},2,2),stats_brw.r{dd}(jk_idx{1},2+3,2),stats_brw.r{dd}(jk_idx{1},3,2),'','.',{},'off'); 
                             text(3,-500,'Slit#3','Background','w'); xlabel(gca,'');
       a(3)=subaxis(3,2,3);  gscatter(stats_brw.r{dd}(jk_idx{1},2,1),stats_brw.r{dd}(jk_idx{1},3+3,1),stats_brw.r{dd}(jk_idx{1},3,1),'','o',{},'off'); hold all
                             gscatter(stats_brw.r{dd}(jk_idx{1},2,2),stats_brw.r{dd}(jk_idx{1},3+3,2),stats_brw.r{dd}(jk_idx{1},3,2),'','.',{},'off'); 
                             text(3,-500,'Slit#4','Background','w'); xlabel(gca,'');
       a(4)=subaxis(3,2,4);  gscatter(stats_brw.r{dd}(jk_idx{1},2,1),stats_brw.r{dd}(jk_idx{1},4+3,1),stats_brw.r{dd}(jk_idx{1},3,1),'','o',{},'off'); hold all
                             gscatter(stats_brw.r{dd}(jk_idx{1},2,2),stats_brw.r{dd}(jk_idx{1},4+3,2),stats_brw.r{dd}(jk_idx{1},3,2),'','.',{},'off'); 
                             text(3,-500,'Slit#5','Background','w'); xlabel(gca,'');
       a(5)=subaxis(3,2,5);  gscatter(stats_brw.r{dd}(jk_idx{1},2,1),stats_brw.r{dd}(jk_idx{1},5+3,1),stats_brw.r{dd}(jk_idx{1},3,1),'','o',{},'off'); hold all
                             gscatter(stats_brw.r{dd}(jk_idx{1},2,2),stats_brw.r{dd}(jk_idx{1},5+3,2),stats_brw.r{dd}(jk_idx{1},3,2),'','.',{},'off'); 
                             text(3,-500,'Slit#6','Background','w'); xlabel(gca,'');
       set(a,'Xgrid','On','Ygrid','On','Box','On','Ylim',[-200 200]);  set(a(1:4),'XTickLabel','');      
       pos=get(a(5),'Position'); set(a(5),'Position',[0.31 pos(2:4)]);
       suptitle(sprintf('%s (%d, AM)',datestr(lgl(1,1),1),diaj(lgl(1,1))));

       figure; 
       if ~isempty(P_brw{1,1});
           a=[];
           a(1)=subaxis(2,1,1); hold all;
           g1=gscatter(P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),1),P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),1+2),...
                       P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),2),'','.',{},'off'); set(g1,'MarkerSize',6);        
              plot(m_oz(jk_idx{1}),polyval(resp_brw(dd,[1+11 1+1],1),m_oz(jk_idx{1})),'m-'); 
           g2=gscatter(P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),1),P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),2+2),...
                       P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),2),'','*',{},'off');
              plot(m_oz(jk_idx{1}),polyval(resp_brw(dd,[2+11 2+1],2),m_oz(jk_idx{1})),'m-'); set(g2,'MarkerSize',4);  
           g3=gscatter(P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),1),P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),3+2),...
                       P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),2),'','s',{},'off');
              plot(m_oz(jk_idx{1}),polyval(resp_brw(dd,[3+11 3+1],2),m_oz(jk_idx{1})),'m-'); set(g3,'MarkerSize',4);  
           g4=gscatter(P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),1),P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),4+2),...
                       P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),2),'','d',{},'off');
              plot(m_oz(jk_idx{1}),polyval(resp_brw(dd,[4+11 4+1],2),m_oz(jk_idx{1})),'m-'); set(g4,'MarkerSize',4);  
           g5=gscatter(P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),1),P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),5+2),...
                       P_brw{1,2}(jk_idx{1}(jk_idx{1}==1),2),'','p',{},'off');        
              plot(m_oz(jk_idx{1}),polyval(resp_brw(dd,[5+11 5+1],2),m_oz(jk_idx{1})),'m-');  set(g5,'MarkerSize',4);  

           set(gca,'Xgrid','On','Ygrid','On');               
%            legend([g1(1) g2(1) g3(1) g4(1) g5(1)],'Slit#1','Slit#2','Slit#3','Slit#4','Slit#5','Location','SouthWest');                           
           
           a(2)=subaxis(2,1,2); hold all
           plot(1:5,stats_brw.rs(dd,2:6,1), 'sb');    plot(1:5,stats_brw.rs(dd,7:11,1),'sr'); 
           plot(1:5,stats_brw.rs(dd,2:6,2), '*b');    plot(1:5,stats_brw.rs(dd,7:11,2),'*r'); 
           set(gca,'Xgrid','On','Ygrid','On','Box','On','XLim',[0.5 5.5],...
                   'XTick',1:5,'XTickLabel',{'#1','#2','#3','#4','#5'});   ylabel('Rsquared'); 
           legend({'Cfg1: AM','Cfg1: PM','Cfg2: AM','Cfg2: PM'},'Location','NorthEast');                
       end
       suptitle(sprintf('%s (%d, AM)',datestr(lgl(1,1),1),diaj(lgl(1,1)))); 
       drawnow
    end
end

function RC=rayleigth_cor(F,P,M3,BE)

% function RC=rayleigth_cor(F,P,M3,BE)
% Rayleight correction
% Si se proporcionan coeficientes se calculan si no se usa el standard
%
% FROM INIT.RTN 
% 12060 FOR I=2 TO 6:READ BE(I):NEXT:REM  read Rayleigh coeffs
% 12070 DATA 4870,4620,4410,4220,4040
%
% F(I)=F(I)+BE(I)*M3*PZ%/1013:REM rayleigh
% 
% TODO: Vectorizado
% w=[0.00  0.00   0.00   -1.00    0.50    2.20   -1.70];
% 
% RC=matmul(m3ds,R)*pr/1013*w'
% R coef raleight
% w weithgth

  if nargin==3 % si no usa la estandard
     BE=[0,0,4870,4620,4410,4220,4040];
  end
  % BE=[5327    0 5096    4835    4610    4408    4217];
 
  for j=1:7
      F(:,j)=F(:,j)+BE(j)*M3*P/1013;         
  end    
  RC=F;
    