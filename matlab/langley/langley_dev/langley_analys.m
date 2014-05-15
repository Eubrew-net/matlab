function [resp_brw resp_dbs stats_brw stats_dbs] = langley_analys(lgl_data,brw,Cal,varargin)

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
arg.addParamValue('res_filt',  0, @(x)(x==0 || x==1));   % por defecto no filter
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1));   % por defecto no plots

% validamos los argumentos definidos:
arg.parse(lgl_data,brw,Cal,varargin{:});

%% Inicializamos Variables
resp_brw=NaN*ones(length(lgl_data{brw}),3,2); resp_brw(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_brw=struct('r',[],'ci',[]);
stats_brw.ci=NaN*ones(length(lgl_data{brw}),5,2); stats_brw.ci(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_brw.r=cellfun(@(x) NaN*ones(x,5,2),cellfun(@(x) size(x,1),lgl_data{brw},'UniformOutput', 0),'UniformOutput', 0);
stats_brw.rs=NaN*ones(length(lgl_data{brw}),3,2); stats_brw.rs(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 

resp_dbs=NaN*ones(length(lgl_data{brw}),3,2); resp_dbs(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_dbs=struct('r',[],'ci',[],'rs',[]);
stats_dbs.ci=NaN*ones(length(lgl_data{brw}),5,2); stats_dbs.ci(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
stats_dbs.r=cellfun(@(x) NaN*ones(x,5,2),cellfun(@(x) size(x,1),lgl_data{brw},'UniformOutput', 0),'UniformOutput', 0);
stats_dbs.rs=NaN*ones(length(lgl_data{brw}),3,2); stats_dbs.rs(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 

%%
for dd=1:length(lgl_data{brw})
    lgl=lgl_data{brw}{dd};
    fecha=unique(fix(lgl(:,1)));
    config_1=read_icf(Cal.brw_config_files{brw,1},fecha); 
    config_2=read_icf(Cal.brw_config_files{brw,2},fecha); 

    stats_brw.r{dd}(:,1,[1 2])=repmat(lgl(:,1),1,2);  stats_brw.r{dd}(:,2,[1 2])=repmat(lgl(:,5),1,2); stats_brw.r{dd}(:,3,[1 2])=repmat(lgl(:,10),1,2); 
    stats_dbs.r{dd}(:,1,[1 2])=repmat(lgl(:,1),1,2);  stats_dbs.r{dd}(:,2,[1 2])=repmat(lgl(:,5),1,2); stats_dbs.r{dd}(:,3,[1 2])=repmat(lgl(:,10),1,2); 

    jpm=(lgl(:,9)/60>12); jam=~jpm;
    for ampm=1:2        
        if ampm==1
           jk=jam; ci_idx=[2 3];
        else
           jk=jpm; ci_idx=[4 5];
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
                jk_idx=jk; 
                X=[ones(size(m_ozone)),m_ozone];% matriz de diseño         
                [c1_brw,ci,r,ri,st]=regress(P_brw,X);
                if arg.Results.res_filt
                   idx=abs(r)>1.5*nanstd(r);
                   if any(idx==1)
                      X=X(~idx,:); 
                      if ampm==1
                          jk_idx(find(idx))=0;
                      else
                          jk_idx(find(idx)+length(find(jam)))=0;                          
                      end
                   end
                   if arg.Results.plot_flag %&& ncfg==2
                      figure; 
                      gscatter(m_ozone,r,lgl(jk,10),'','.',{},'off'); ax(1)=gca;
                      ylabel('Residuos'); xlabel('airmass'); 
                      set(ax(1),'Ylim',[-65 65]); grid; box on; 
                      hold on; plot(ax(1),m_ozone(idx),r(idx),'sk','MarkerFaceCOlor','k');                              
                      ax(2) = axes('Units',get(ax(1),'Units'),'Position',get(ax(1),'Position'),...
                                   'Parent',get(ax(1),'Parent'));
                      set(ax(2),'YAxisLocation','right','Color','none', ...
                                'XGrid','off','YGrid','off','Box','off', ...
                                'XLim',get(ax(1),'Xlim'),'Ticklength',[0 0],'XTicklabel',[]); 
                      hold on; plot(m_ozone,polyval(flipud(c1_brw),m_ozone),'*-',m_ozone,P_brw,'r.-');
                      ylabel('MS9'); title(sprintf('%s (%d)',datestr(lgl(jk(1),1),1),diaj(lgl(jk(1),1))));
                   end
                   [c1_brw,ci,r,ri,st]=regress(P_brw(~idx),X);
                end
                resp_brw(dd,ampm+1,ncfg)            = c1_brw(1);    
                stats_brw.ci(dd,ci_idx,ncfg)        = ci(1,:);
                stats_brw.r{dd}(jk_idx,ampm+3,ncfg) = r; 
                stats_brw.rs(dd,ampm+1,ncfg)        = st(1);

%               Dobson method
                jk_idx=jk; 
                X=[ones(size(m_ozone)),1./m_ozone];% matriz de diseño                         
                [c1_dbs,ci_dbs,r_dbs,ri,st_dbs]=regress(P_dbs,X);
                if arg.Results.res_filt
                   idx=abs(r_dbs)>1.5*nanstd(r_dbs); 
                   if any(idx==1)
                      X=X(~idx,:); 
                      if ampm==1
                         jk_idx(find(idx))=0;
                      else
                         jk_idx(find(idx)+length(find(jam)))=0;                          
                      end
                   end
                   if arg.Results.plot_flag %&& ncfg==2
                      figure; 
                      plot(1./m_ozone,polyval(flipud(c1_dbs),1./m_ozone),'*-',1./m_ozone,P_dbs,'r.:'); ax(1)=gca;                                                  
                      ylabel('(MS9-ETC)/airmass');title(sprintf('%s (%d)',datestr(lgl(jk(1),1),1),diaj(lgl(jk(1),1))));
                      ax(2) = axes('Units',get(ax(1),'Units'),'Position',get(ax(1),'Position'),...
                                   'Parent',get(ax(1),'Parent'));
                      set(ax(2),'YAxisLocation','right','Color','none', ...
                                'XGrid','off','YGrid','off','Box','off', ...
                                'XLim',get(ax(1),'Xlim'),'Ticklength',[0 0],'XTicklabel',[]); 
                      hold on; gscatter(1./m_ozone,r_dbs,lgl(jk,10),'','.',{},'off'); 
                      ylabel('Residuos'); xlabel('1/airmass'); 
                      set(ax(2),'Ylim',[-40 40]); grid; box on; 
                      hold on; plot(1./m_ozone(idx),r_dbs(idx),'sk','MarkerFaceCOlor','k');
                   end
                   [c1_dbs,ci_dbs,r_dbs,ri,st_dbs]=regress(P_dbs(~idx),X);
                end
                resp_dbs(dd,ampm+1,ncfg)            = c1_dbs(2);
                stats_dbs.ci(dd,ci_idx,ncfg)        = ci_dbs(1,:);
                stats_dbs.r{dd}(jk_idx,ampm+3,ncfg) = r_dbs; 
                stats_dbs.rs(dd,ampm+1,ncfg)        = st_dbs(1);                
            catch exception
                resp_brw(dd,ampm+1,ncfg)=NaN; resp_dbs(dd,ampm+1,ncfg)=NaN;
            end
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
%             resp(ampm,ncfg,1:length(c1),idx,:)=[c1,ci];
%             stats(ampm,ncfg,idx,:)=st; %npoints...
%             data{ampm,ncfg,idx}=[lgl(jk,5),X(:,1:2)*c1(1:2),RC,r,ri];
        end
    end
end
