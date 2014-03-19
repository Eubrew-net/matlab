function [x,r,ab,rp,data,osc_out,osc_smooth,outliers]=ratio_min_ozone(a,b,n_min,name_a,name_b,varargin)
% function [x,r,ab,rp,data,osc_out,osc_smooth,outliers]=ratio_min_ozone(a,b,n_min,name_a,name_b,varargin)
% Calcula el ratio entre series temporales (el ratio es respecto a b)
% b puede y a pueden tener varias columnas
% 
% x= elementos comunes
% r= ratio
% ab= diferecia absoluta
% rp= ration porcentual
%
% Special Version for ozone measurements
% input argument:  date, ozone,airm, sza,ms9,sms9, temperature, filter
% 
% 
%   INPUTS:
% 
% -------- Necesarios (como siempre) --------
% - a, instrumento
% - b, referencia
% - n_min, tsync
% - name_a, string con el nombre del instrumento
% - name_b, string con el nombre de la referencia
% 
% -------- Opcionales ---------
% - OSC_lim. Por defecto [300 1600]
% - plot_flag. Por defecto 1 (ploteo de individuales)
% 
%  MODIFICADO: 
% 
% Juanjo 12/04/2011: Se añade control de inputs opcionales a la funcion. Uso de inputparser
% 
% Juanjo 17/04/2012: En el caso de que name_a=name_b (o nargin=3), no ploteos
% 
% Ejemplo:
%     [x,r,rp,ra,dat,ox,osc_smooth_old]=ratio_min_ozone(inst1_b(:,[1,6,3,2,8,9,4,5]),ref2_b(:,[1,6,3,2,8,9,4,5]),...
%                                                                              5,brw_str{n_inst},brw_str{n_ref});   

%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='ratio_min_ozone';

arg.addRequired('a', @isfloat);
arg.addRequired('b', @isfloat);
arg.addRequired('n_min', @isfloat);
arg.addRequired('name_a', @ischar);
arg.addRequired('name_b', @ischar);

arg.StructExpand = false;
arg.addParamValue('OSC_lim', [250 1700], @isfloat); % Por defecto [300 1600]
arg.addParamValue('plot_flag', 1, @(x)(x==1 || x==0)); % Por defecto 1 (ploteo de individuales)

   try
     arg.parse(a, b, n_min, name_a, name_b, varargin{:});
     mmv2struct(arg.Results); Args=arg.Results;
     chk=1;
   catch
     errval=lasterror;
     chk=0;
   end

% calcula el ratio entre respuestas o lamparas
MIN=60*24;

%a(find(a(:,2)<190 | a(:,2)>500),:)=NaN;
%b(find(b(:,2)<190 | b(:,2)>500),:)=NaN;


%n_min=10;
[aa,bb]=findm_min(a(:,1),b(:,1),n_min/MIN);

if isempty(aa)
   fprintf('No common data between #%s and #%s for tsync=%d min.\r\n',name_a,name_b,n_min);
   x=NaN*ones(1,23); r=NaN*ones(1,10); rp=NaN*ones(1,8); ab=NaN*ones(1,8);
   data=NaN*ones(1,16); osc_out=NaN*ones(1,6); osc_smooth=NaN*ones(1,7);

   return
end

c=a(aa,1);
% PORQUE NO RULA no busca todos !!!
% 3 minutos 1/( 3  *7E-4)
%aux_a(:,1)=fix(round(a(:,1)*MIN)/n_min);
%aux_b(:,1)=fix(round(b(:,1)*MIN)/n_min);
%[c,aa,bb]=intersect(aux_a(:,1),aux_b(:,1));
data=[a(aa,1),a(aa,1)-b(bb,1),a(aa,2:end),b(bb,2:end)];
data_l=size(a,2);





r=[c,(a(aa,2:end)./b(bb,2:end)),b(bb,2).*b(bb,3),b(bb,4)];
ab=[c,(a(aa,2:end)-b(bb,2:end))];
rp=[c,100*(a(aa,2:end)-b(bb,2:end))./b(bb,2:end)];


x=[data,rp(:,2:end)];

% dos posibilidades 1 sin temperatura y filtro
if size(b,2)==6;
 osc=data(:,8).*data(:,9);
 sza=data(:,10);
else
 osc=data(:,10).*data(:,11);  
 sza=data(:,12);
end



% ratio ozone slant path
  
try 
   osc_ranges=[300,550,850,1250,1500];
    %osc_int=[200,400,700,1000,1500];
   osc_grp=[osc<400, osc>=400 & osc<700, osc>=700 & osc<=1000,osc>1000 & osc<1500,osc>1500 | isnan(osc)];
   [osc_x,aux]=find(osc_grp');
    osc_x=osc_ranges(osc_x);
    [m,s,n,er,name]=grpstats(rp(:,2),osc_x,{'mean','std','numel','sem','gname'});
    aux_x=str2num(char(name));
     osc_ratio=[aux_x/1000,m,s,n,er];
     % relleno con NaN
     osc_out=NaN*ones(length(osc_ranges)+2,6);
     for ii=1:length(osc_ranges)
         jj=find(osc_x==osc_ranges(ii),1);
         if ~isempty(jj) & ii<size(osc_ratio,1)
          osc_out(ii+1,2:end)=osc_ratio(ii,:);
         end
     end
    [m1,s1,n1,er1,name1]=grpstats(rp(:,2),[],{'mean','std','numel','sem','gname'});
     osc_=[NaN,m1,s1,n1,er1];
     osc_out(end,2:end)=osc_;
   catch
       warning('osc')
   end
% ratio ozone slant path % Matthias Method
  

    y=mean_smooth(osc,rp(:,2),0.125);
    [m_,s_,outliers.r,outliers.idx]=outliers_bp(y(:,5)-rp(:,2));
    osc_smooth=sortrows([osc,y(:,1:end)],1);
    
     
if  nargin~=3 && ~strcmp(name_a,name_b)
    f=figure;
    set(f,'Tag','RATIOo_1');
    subplot(2,2,1);
    ploty(data(:,[1,3,3+data_l-1]),'o');grid;title('medidas');
    hold on;
    plot(a(:,1),a(:,2),'-',b(:,1),b(:,2),':');
    datetick;
    if nargin==2
        name_a=inputname(1);
        name_b=inputname(2);
    end
    legend(name_a,name_b);
    %r=[c,100*(a(aa,2)- b(bb,2))./b(bb,2)];
    %r=[c,log(a(aa,2)./b(bb,2))];
    if isempty(c)
        warning('no comon elemets to ratio')
    end
    if size(b,2)~=size(a,2) & size(b,2)==2
        b=[b(:,1),repmat(b(:,2),1,size(a,2)-1)];
    end
    subplot(2,2,2);
    plot(data(:,3),data(:,3+data_l-1),'x');
    rline;
    grid;title([name_a,' vs ',name_b]);

% rp(find(rp(:,2)<-1.4),:)=NaN;
    subplot(2,3,4);
    ploty(rp(:,1:2));grid;title(['ratio %',name_a,' vs ',name_b]);
    datetick;
    subplot(2,3,5);
    ploty(ab(:,1:2));grid;title(['dif ',name_a,' - ',name_b]);
    datetick;
    subplot(2,3,6);
    plot(data(:,2)*60*24,data(:,3)-data(:,3+data_l-1),'o');grid;
    title('difference vs time difference (min) ');
    xlabel('min');
    
    f=figure;    set(f,'Tag','RATIO_day');
    try        
     P=gscatter(osc,rp(:,2),diaj(data(:,1)));
     set(findobj(gca,'Type','Line'),'MarkerSize',5);
     set(findobj(gcf,'Tag','legend'),'Location','EastOutside')
    opts.selected.Marker='x';     opts.selected.Color='k';
    interactivelegend(P,cellstr(num2str(unique(diaj(data(:,1))))),opts);
     set(gca,'Xlim',OSC_lim,'Ylim',[-3,3]);
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title(sprintf('(%s - %s) / %s.  Grouped by day',name_a,name_b,name_b))
     box on;
    catch % falla cuando hay un solo dia revisar
     plot(osc,rp(:,2),'o');
     set(gca,'Xlim',OSC_lim);
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title( [name_a,' - ',name_b,'/ ',name_b])
     box on;
    end
%     hold on;
%     errorbar(aux_x,m,2*s,'s-');
    grid;
   
    %%
    
    f=figure; 
    set(f,'Tag','RATIO_SZA'); 
    j=data(:,1)-fix(data(:,1))>=0.5;
    %hold on;
    %plot(sza(j),rp(j,2),'o');
    %j=find(data(:,1)-fix(data(:,1))<0.5);
    %plot(sza(j),rp(j,2),'+');
    gscatter(sza,rp(:,2),{diaj(data(:,1)),j},[],'o+'); set(findobj(gcf,'Tag','legend'),'Location','NorthEast');
    xlabel('solar zenith angle'); ylabel('Ozone Relative Difference (%)');
    title(sprintf('(%s - %s) / %s.  AM=+ PM=o',name_a,name_b,name_b))
    box on;  grid;
    
     f=figure;      set(f,'Tag','RATIO_SMOOTH'); 
     aux2=(matadd(osc_smooth(:,[6,7]),-osc_smooth(:,2)));
     jk=find(~isnan(osc_smooth(:,1)));
     errorfill(osc_smooth(jk,1)',osc_smooth(jk,2)',osc_smooth(jk,3)','b.')
     hold on
     errorfill(osc_smooth(jk,1)',osc_smooth(jk,2)',abs([aux2(jk,1),aux2(jk,2)])','r.-')
     box on;
     grid;
     set(gca,'Xlim',OSC_lim,'YLim',[-3,3]);
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title(sprintf('(%s - %s) / %s',name_a,name_b,name_b))
     grid on;
     
     figure
     set(f,'Tag','RATIO_ERRORBAR');
     
       errorbar(aux_x,m,2*s,'s-');
       set(gca,'Xlim',OSC_lim,'YLim',[-3,3]);
       xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
       title(sprintf('(%s - %s) / %s',name_a,name_b,name_b))
       grid; box on;
   
    %figure by filter 
    filter_name={'NoFilt','Filt#1','Filt#2','Filt#3','Filt#4','Filt#5'};
    f=figure;    set(f,'Tag','RATIO_FILTER_INST');
    if size(b,2)==8;   
    try
     gscatter(osc,rp(:,2),data(:,9),'','o',5); 
     l=legend(gca,filter_name{unique(data(:,9))/64+1},'Orientation','Horizontal','Location','NorthEast');
     set(l,'FontSize',12);
     set(gca,'Xlim',OSC_lim,'YLim',[-3 3]); hline(0,'-k');
     grid;   box on;
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title(sprintf('(%s-%s) / %s : #%s Filters',name_a,name_b,name_b,name_a));
    catch % falla cuando hay un solo dia revisar
     plot(osc,rp(:,2),'.');
     set(gca,'Xlim',OSC_lim,'YLim',[-3 3]); hline(0,'-k');
     grid;   box on;
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title(sprintf('(%s-%s) / %s : #%s Filters',name_a,name_b,name_b,name_a));
    end
    
    fbox=figure;    set(fbox,'Tag','RATIO_FILTER_BOX');
    [mf,sf,nf,erf,namef]=grpstats(rp(:,2),data(:,9),{'mean','std','numel','sem','gname'});
    x_=str2num(char(namef));
    errorbar(x_,mf,2*sf,'s-'); 
    [mf,sf,nf,erf,namef]=grpstats(rp(:,2),data(:,end),{'mean','std','numel','sem','gname'});
    x_=str2num(char(namef));     
    hold on;    errorbar(x_,mf,2*sf,'ro-');
    
    legend({['Ratio ',name_a,' filter: Mean +/- 2SD'],['Ratio',name_b,' filter: Mean +/- 2SD']}); box off
    set(gca,'XTick',unique(data(:,9))','XTickLabel',x_); 

    %figure by temp 
    f=figure;    set(f,'Tag','RATIO_TEMP_INST');    
       P=gscatter(osc,rp(:,2),data(:,8),'','o',5);  %,data(:,end-data_l+1)],'','+o');
       set(gca,'Ylim',[-3 3]); grid
       set(findobj(gca,'Type','Line'),'MarkerSize',5);
       set(findobj(gcf,'Tag','legend'),'Location','EastOutside')
    opts.selected.Marker='x';     opts.selected.Color='k';
    interactivelegend(P,cellstr(num2str(unique(diaj(data(:,1))))),opts);
       xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
       title(sprintf('(%s - %s) / %s . Temperature',name_a,name_b,name_b))
        
    f=figure;   set(f,'Tag','RATIO_FILTER_REF');    
    try
     gscatter(osc,rp(:,2),data(:,end),'','o',5); 
     l=legend(gca,filter_name{unique(data(:,9))/64+1},'Orientation','Horizontal','Location','NorthEast');
     set(l,'FontSize',12);
     set(gca,'Xlim',OSC_lim,'YLim',[-3 3]); hline(0,'-k');
     grid;   box on;
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title(sprintf('(%s-%s) / %s : #%s Filters',name_a,name_b,name_b,name_b));
    catch % falla cuando hay un solo dia revisar
     plot(osc,rp(:,2),'.');
     set(gca,'Xlim',OSC_lim);
     xlabel('Ozone slant path (DU)'); ylabel('Ozone Relative Difference (%)');
     title(sprintf('(%s-%s) / %s : #%s Filters',name_a,name_b,name_b,name_b));
     box on;
    end
    
    end
    
    %figure by day
  if plot_flag     
    f=figure;
    set(f,'Tag','RATIO_DAY');
    
    dias=unique(diaj(data(:,1)));
%     nplots=ceil(length(dias)/2);
        nplots=ceil(length(dias)/2);
    ndias=length(dias);
    b=[]; idx=1
    for f=f:f+nplots
        figure(f)
          for s=1:2  
            if s+(idx-1)*2>length(dias), continue 
            else
             subplot(2,1,s);  
             j=find(diaj(data(:,1))==dias(s+(idx-1)*2));
             h=mmplotyy(diajul(data(j,1)),[data(j,3),data(j,3+data_l-1)],'k.-',[min(data(j,3))-10 max(data(j,3))+10],...
                        rp(j,2),'g.',[-3,3]);  
             set(h(1),'Marker','x','Color','r');    grid; 
            end
          end
        suptitle([name_a,' - ',name_b,'/ ',name_b]);
        idx=idx+1;
    end  
   % [aux,ll(1)]=suplabel('day');
   % [aux,ll(2)]=suplabel(' Ozone DU','y');
   % [aux,ll(3)]=suplabel([name_a,'(x) , ',name_b,'(.)'],'t');
   % set(ll,'FontSize',18);
 end
end

if chk
    % Se muestran los argumentos que toman los valores por defecto
  disp('--------- Validation OK --------------') 
  disp('List of arguments given default values:') 
  if ~numel(arg.UsingDefaults)==0
     for k=1:numel(arg.UsingDefaults)
        field = char(arg.UsingDefaults(k));
        value = arg.Results.(field);
        if isempty(value),   value = '[]';   
        elseif isfloat(value), value = num2str(value); end
        disp(sprintf('   ''%s''    defaults to %s', field, value))
     end
  else
     disp('               None                   ')
  end
  disp('--------------------------------------') 
else
     disp('NO INPUT VALIDATION!!')
     disp(sprintf('%s',errval.message))
end
