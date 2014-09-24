function resp_brw = langley_analys_filter(lgl_data,brw,varargin)

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
arg.FunctionName = 'langley_analys_filter';

% input obligatorio
arg.addRequired('lgl_data',@iscell);
arg.addRequired('brw',@isfloat);

% input param - value
arg.addParamValue('res_filt',  0, @(x)(x==0 || x==1));   % por defecto no res. filter
arg.addParamValue('plot_flag', 0, @(x)(x==0 || x==1));   % por defecto no plots

% validamos los argumentos definidos:
arg.parse(lgl_data,brw,varargin{:});

% It makes no sense to be informed of columns (in auxiliary var. X) not linearly independent.  
warning('off','stats:regress:RankDefDesignMat');

%% Inicializamos Variables
resp_brw=NaN*ones(length(lgl_data{brw}),9,2); resp_brw(:,1,[1 2])=repmat(cellfun(@(x) unique(fix(x(:,1))),lgl_data{brw}),1,2); 
am_pm={'AM','PM'};

%%
for dd=1:length(lgl_data{brw})
    lgl=lgl_data{brw}{dd};
    % fecha=unique(fix(lgl(:,1))); [dd diaj(fecha)]
  
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
            else
               P_brw=lgl(jk,39);
            end
            try
               % Just Brewer method
               % Multiple regresssion: ND#0,#1 & #2 are used as the base state
               X=[m_ozone,lgl(jk,10)==0 | lgl(jk,10)==64 | lgl(jk,10)==128,...
                                          lgl(jk,10)==192, lgl(jk,10)==256];                 
               [c1_brw,ci,r]=regress(P_brw,X); 
%                % Filtering data: no valid if num(ND#3)<5 summaries (25 indv)                       
%                if size(X(logical(X(:,3)),:),1)<25
%                   c1_brw(3)=0; 
%                end
%                % Filtering data: no valid if num(ND#4)<3 summaries (15 indv)                       
%                if size(X(logical(X(:,4)),:),1)<15
%                   c1_brw(4)=0;
%                end               
               % No ND#0,#1 & #2 |  ND#3 |  ND#4 
               c1_brw(c1_brw==0)=NaN;
               if arg.Results.res_filt
                  idx=abs(r)>1.5*nanstd(r);
                  lgl_=lgl(jk,:);
                  if any(idx==1)
                     X=X(~idx,:); P_brw=P_brw(~idx); m_ozone=m_ozone(~idx); lgl_=lgl_(~idx,:);
                  end   
                  [c1_brw,ci,r]=regress(P_brw,X); 
%                   % Filtering data: no valid if num(ND#3)<5 summaries (25 indv)                       
%                   if size(X(logical(X(:,3)),:),1)<25
%                      c1_brw(3)=0;
%                   end
%                   % Filtering data: no valid if num(ND#4)<3 summaries (15 indv)                       
%                   if size(X(logical(X(:,4)),:),1)<15
%                      c1_brw(4)=0; 
%                   end                     
                  c1_brw(c1_brw==0)=NaN;
                  if arg.Results.plot_flag && ncfg==2 %&& ampm==2                       
                     figure; gscatter(m_ozone,P_brw,lgl_(:,10),'','.',{},'on');
                     set(findobj(gcf,'Tag','legend'),'Location','SouthEast');
                     hold on; plot(m_ozone,polyval(c1_brw([1 2]),m_ozone),'-g');
                              plot(m_ozone,polyval(c1_brw([1 3]),m_ozone),'b-');
                     ylabel('MS9'); grid;
                     title(sprintf('%s (%d): %s',datestr(unique(fix(lgl_(:,1)))),...
                                                 diaj(unique(fix(lgl_(:,1)))),...
                                                 am_pm{ampm}));
                  end
               end
               % Index to create output. Just ETC & Slope, no stats !!
               if ampm==1
                  id=1;
               else
                  id=5;
               end
               resp_brw(dd,id+1,ncfg)              = c1_brw(2); % 1st ETC (ND#0,#1 & #2)
               resp_brw(dd,id+2,ncfg)              = c1_brw(3); % 2nd ETC (ND#3)       
               resp_brw(dd,id+3,ncfg)              = c1_brw(4); % 3rd ETC (ND#4)       
               resp_brw(dd,id+4,ncfg)              = c1_brw(1); % Slope (we assume same for all ND)
             catch exception
               fprintf('%s\n',exception.message);
             end
        end
    end
end
