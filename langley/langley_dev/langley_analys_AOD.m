function [resp_brw stats_brw] = langley_analys_AOD(lgl_data,brw,Cal,varargin)

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
%    1   -> airmass  x
%    2   -> y hat (sin filtros)  yhat= b+ax
%    3   -> y F counts/second
%    4   -> residuals y-
%    5-6 -> residuals ci

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'langley_analys_AOD';

% input obligatorio
arg.addRequired('lgl_data',@iscell);
arg.addRequired('brw',@isfloat);
arg.addRequired('Cal',@isstruct);

% input param - value
arg.addParamValue('res_filt',  0, @(x)(x==0 || x==1));   % por defecto no filter
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1));   % por defecto no plots

% validamos los argumentos definidos:
arg.parse(lgl_data,brw,Cal,varargin{:});

%% Inicializamos Variables
resp_brw=NaN*ones(length(lgl_data{brw}),21,2); resp_brw(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_brw=struct('r',[],'ci',[]);
stats_brw.ci=NaN*ones(length(lgl_data{brw}),5,2); stats_brw.ci(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_brw.r=cellfun(@(x) NaN*ones(x,13,2),cellfun(@(x) size(x,1),lgl_data{brw},'UniformOutput', 0),'UniformOutput', 0);
stats_brw.rs=NaN*ones(length(lgl_data{brw}),11,2); stats_brw.rs(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 

ampm_label={'AM','PM'}; 

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
           if arg.Results.plot_flag
              figure; subplot(2,1,1);
                      title(sprintf('Residuals: %s (%d, %s)',datestr(lgl(1,1),1),diaj(lgl(1,1)),ampm_label{ampm}));
                      subplot(2,1,2); 
                      title(sprintf('Langley Plots: %s (%d, %s)',datestr(lgl(1,1),1),diaj(lgl(1,1)),ampm_label{ampm}));
           end            
           continue
        end

        P_brw{ampm,1}=lgl(jk{ampm},[5 10 14:18]); P_brw{ampm,2}=lgl(jk{ampm},[5 10 28:32]); 
        for ncfg=1:2 
            try
%             Brewer method
              for slit=1:5
                  r_orig{slit}=[NaN NaN]; 
                  jk_idx{ampm}=jk{ampm}; 
                  X=[ones(size(P_brw{ampm,2},1),1),P_brw{ampm,2}(:,1)];% matriz de diseño
                  [c1_brw,ci,r,ri,st]=regress(P_brw{ampm,ncfg}(:,slit+2),X);
                  if arg.Results.res_filt
%                    we keep original 
                     r_orig{slit}=[X(:,2) r]; 
                     idx=abs(r_orig{slit}(:,2))>1.5*nanstd(r_orig{slit}(:,2));
                     if any(idx==1)                        
                        if ampm==1
                           jk_idx{ampm}(find(idx))=0;
                        else
                           jk_idx{ampm}(find(idx)+length(find(jam)))=0;                          
                        end
                     end
                     [c1_brw,ci,r,ri,st]=regress(P_brw{ampm,ncfg}(~idx,slit+2),X(~idx,:));
                  end
                  if ampm==1
                     idx_=ampm+2;
                     resp_brw(dd,ampm+slit,ncfg)                    = c1_brw(1);    
                     resp_brw(dd,ampm+slit+10,ncfg)                 = c1_brw(2);    
%                    stats_brw.ci(dd,ci_idx,ncfg)                   = ci(1,:);
                     stats_brw.r{dd}(jk_idx{ampm},idx_+slit,ncfg)   = r; 
                     stats_brw.rs(dd,ampm+slit,ncfg)                = st(1);
                  else
                     idx_=ampm+6;
                     resp_brw(dd,slit+ampm+4,ncfg)                  = c1_brw(1);    
                     resp_brw(dd,ampm+slit+14,ncfg)                 = c1_brw(2);    
%                    stats_brw.ci(dd,ci_idx,ncfg)                   = ci(1,:);
                     stats_brw.r{dd}(jk_idx{ampm},idx_+slit,ncfg)   = r; 
                     stats_brw.rs(dd,slit+ampm+4,ncfg)              = st(1);                       
                  end
              end                
              
            catch exception
                resp_brw(dd,ampm+1,ncfg)=NaN; 
            end            
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
%             resp(ampm,ncfg,1:length(c1),idx,:)=[c1,ci];
%             stats(ampm,ncfg,idx,:)=st; %npoints...
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
        end
        if arg.Results.plot_flag
%          rat_res=cat(1,stats_brw.r{dd}(jk_idx{1},4:8,1),stats_brw.r{dd}(jk_idx{2},9:13,1))./cat(1,stats_brw.r{dd}(jk_idx{1},4:8,2),stats_brw.r{dd}(jk_idx{2},9:13,2)); 
           m_oz=stats_brw.r{dd}(:,2,1); 
       
           figure; suptitle(sprintf('Langley Plot Residuals: %s (%d, %s)',datestr(lgl(1,1),1),diaj(lgl(1,1)),ampm_label{ampm}));
           a(1)=subaxis(3,2,1);  p=plot(r_orig{1}(:,1),r_orig{1}(:,2),'.'); hold all
                                 gs_1=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,1),stats_brw.r{dd}(jk_idx{ampm},1+idx_,1),stats_brw.r{dd}(jk_idx{ampm},3,1),'','o',{},'off'); 
                                 gs_2=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,2),stats_brw.r{dd}(jk_idx{ampm},1+idx_,2),stats_brw.r{dd}(jk_idx{ampm},3,2),'','.',{},'off'); 
                                 l=legend(p,'Slit#2','Location','se'); set(l,'Box','Off'); xlabel(gca,''); set(gs_1,'MarkerSize',5); set(gs_2,'MarkerSize',6);
           a(2)=subaxis(3,2,2);  p=plot(r_orig{2}(:,1),r_orig{2}(:,2),'.'); hold all
                                 gs_1=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,1),stats_brw.r{dd}(jk_idx{ampm},2+idx_,1),stats_brw.r{dd}(jk_idx{ampm},3,1),'','o',{},'off');
                                 gs_2=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,2),stats_brw.r{dd}(jk_idx{ampm},2+idx_,2),stats_brw.r{dd}(jk_idx{ampm},3,2),'','.',{},'off'); 
                                 l=legend(p,'Slit#3','Location','se'); set(l,'Box','Off'); xlabel(gca,''); set(gs_1,'MarkerSize',5); set(gs_2,'MarkerSize',6);
           a(3)=subaxis(3,2,3);  p=plot(r_orig{3}(:,1),r_orig{3}(:,2),'.'); hold all
                                 gs_1=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,1),stats_brw.r{dd}(jk_idx{ampm},3+idx_,1),stats_brw.r{dd}(jk_idx{ampm},3,1),'','o',{},'off');
                                 gs_2=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,2),stats_brw.r{dd}(jk_idx{ampm},3+idx_,2),stats_brw.r{dd}(jk_idx{ampm},3,2),'','.',{},'off'); 
                                 l=legend(p,'Slit#4','Location','se'); set(l,'Box','Off'); xlabel(gca,''); set(gs_1,'MarkerSize',5); set(gs_2,'MarkerSize',6);
           a(4)=subaxis(3,2,4);  p=plot(r_orig{4}(:,1),r_orig{4}(:,2),'.'); hold all
                                 gs_1=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,1),stats_brw.r{dd}(jk_idx{ampm},4+idx_,1),stats_brw.r{dd}(jk_idx{ampm},3,1),'','o',{},'off');
                                 gs_2=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,2),stats_brw.r{dd}(jk_idx{ampm},4+idx_,2),stats_brw.r{dd}(jk_idx{ampm},3,2),'','.',{},'off'); 
                                 l=legend(p,'Slit#5','Location','se'); set(l,'Box','Off'); xlabel(gca,''); set(gs_1,'MarkerSize',5); set(gs_2,'MarkerSize',6);
           a(5)=subaxis(3,2,5);  p=plot(r_orig{5}(:,1),r_orig{5}(:,2),'.'); hold all
                                 gs_1=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,1),stats_brw.r{dd}(jk_idx{ampm},5+idx_,1),stats_brw.r{dd}(jk_idx{ampm},3,1),'','o',{},'off');
                                 gs_2=gscatter(stats_brw.r{dd}(jk_idx{ampm},2,2),stats_brw.r{dd}(jk_idx{ampm},5+idx_,2),stats_brw.r{dd}(jk_idx{ampm},3,2),'','.',{},'off'); 
                                 xlabel(gca,'airmass'); set(gs_1,'MarkerSize',5); set(gs_2,'MarkerSize',6);
           set(a,'Xgrid','On','Ygrid','On');  set(a(1:4),'XTickLabel',''); % ,'Ylim',[-200 200]
           pos=get(a(5),'Position'); set(a(5),'Position',[0.31 pos(2:4)]);
                                 l=legend(p,'Slit#6','Location','se'); set(l,'Box','Off'); 
   
           figure; suptitle(sprintf('Langley Plots: %s (%d, %s)',datestr(lgl(1,1),1),diaj(lgl(1,1)),ampm_label{ampm}));
           if ~isempty(P_brw{ampm,1});
              if ampm==1
                 indx=1; 
              else
                 indx=6; 
              end
              a=[];
              a(1)=subaxis(2,1,1); hold all;
              g1=gscatter(P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),1),P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),1+2),...
                          P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),2),'','.',{},'off'); set(g1,'MarkerSize',6);        
                 plot(m_oz(jk_idx{ampm}),polyval(resp_brw(dd,[indx+10+1 indx+1],1),m_oz(jk_idx{ampm})),'m-'); 
              g2=gscatter(P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),1),P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),2+2),...
                          P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),2),'','*',{},'off');
                 plot(m_oz(jk_idx{ampm}),polyval(resp_brw(dd,[indx+10+2 indx+2],2),m_oz(jk_idx{ampm})),'m-'); set(g2,'MarkerSize',4);  
              g3=gscatter(P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),1),P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),3+2),...
                          P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),2),'','s',{},'off');
                 plot(m_oz(jk_idx{ampm}),polyval(resp_brw(dd,[indx+10+3 indx+3],2),m_oz(jk_idx{ampm})),'m-'); set(g3,'MarkerSize',4);  
              g4=gscatter(P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),1),P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),4+2),...
                          P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),2),'','d',{},'off');
                 plot(m_oz(jk_idx{ampm}),polyval(resp_brw(dd,[indx+10+4 indx+4],2),m_oz(jk_idx{ampm})),'m-'); set(g4,'MarkerSize',4);  
              g5=gscatter(P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),1),P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),5+2),...
                          P_brw{ampm,1}(jk_idx{ampm}(jk_idx{ampm}==1),2),'','p',{},'off');        
                 plot(m_oz(jk_idx{ampm}),polyval(resp_brw(dd,[indx+10+5 indx+5],2),m_oz(jk_idx{ampm})),'m-');  set(g5,'MarkerSize',4);  

              set(gca,'Xgrid','On','Ygrid','On');               
   %            legend([g1(1) g2(1) g3(1) g4(1) g5(1)],'Slit#1','Slit#2','Slit#3','Slit#4','Slit#5','Location','SouthWest');                           
           
              a(2)=subaxis(2,1,2); hold all
              plot(1:5,stats_brw.rs(dd,indx+1:indx+5,1), 'sb');    %plot(1:5,stats_brw.rs(dd,7:11,1),'sr'); 
              plot(1:5,stats_brw.rs(dd,indx+1:indx+5,2), '*r');     %  plot(1:5,stats_brw.rs(dd,7:11,2),'*r'); 
              set(gca,'Xgrid','On','Ygrid','On','Box','On','XLim',[0.5 5.5],...
                      'XTick',1:5,'XTickLabel',{'#1','#2','#3','#4','#5'});   ylabel('Rsquared'); 
              l=legend({sprintf('Cfg1: %s',ampm_label{ampm}),sprintf('Cfg2: %s',ampm_label{ampm})},'Location','NorthEast');                
              set(l,'HandleVisibility','Off');
          end
          drawnow
       end        
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
    