function o3f=filters_data(fi_data,Cal,varargin)

%%
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'filter_data';

% input obligatorio
arg.addRequired('fi_data'); 
arg.addRequired('Cal'); 

% input param - value
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas

% validamos los argumentos definidos:
arg.parse(fi_data, Cal, varargin{:});
mmv2struct(arg.Results);

fi=fi_data{Cal.n_inst}.fi;  fi_avg=fi_data{Cal.n_inst}.fi_avg; 
% control de fechas
if ~isempty(date_range)
    fi(fi_avg(:,1)<date_range(1),:,:)=[]; fi_avg(fi_avg(:,1)<date_range(1),:)=[];   
   if length(date_range)>1
    fi(fi_avg(:,1)>date_range(2),:,:)=[]; fi_avg(fi_avg(:,1)>date_range(2),:)=[];
   end
end
fech=fi_avg(:,1); temp=repmat(fi_avg(:,4),1,6); 

%%
O3W=[0.0  0.0  -1.0  0.5  2.2  -1.7];
label_filter={'Int.','F{\it#1}','F{\it#2}','F{\it#3}','F{\it#4}','F{\it#5}'};

% correccion de filtros
o3w=cell(size(fi,1),1);
for ii=1:size(fi,1)
    o3w{ii}=O3W*squeeze(fi(ii,4:2:end,2:end)); 
end
o3f=cell2mat(o3w);

%% Atts. vs Time: every nd for 2 sample wls (slit#3 & slit#5)
att={}; att_std={}; att_n={};
for ii=1:6 
    [a b c]=grpstats([fech,temp(:,1),fi(:,4:2:end,ii)],{year(fech),month(fech)},{'mean','sem','numel'});
    att{ii}=a; att_std{ii}=b; att_n{ii}=c;
end

figure; set(gcf,'tag','FI_TIME_atts'); 
ha=tight_subplot(2,1,.07,[.1 0.1],[.1 .1]);    
% slit#3
axes(ha(1)); sampl1=cell2mat(cellfun(@(x) x(:,5),att,'UniformOutput',0));
ploty([att{1}(:,1),100*matdiv(matadd(sampl1(:,2:end),-nanmean(sampl1(:,2:end))),nanmean(sampl1(:,2:end)))],'*-'); 
set(gca,'XTicklabel',[],'YTickLabelMode','auto','box','on'); grid;
title(sprintf('%s\r\nND attenuations vs. time (sample slits #3, top, and #5, bottom)',Cal.brw_name{Cal.n_inst}));
%legendflex(label_filter(2:end),'ref', ha(1),'anchor', {'sw','sw'},'buffer',[6 0],...
%                         'nrow',1,'fontsize',8,'box','off','xscale',.5);                   
% slit#5
axes(ha(2)); sampl1=cell2mat(cellfun(@(x) x(:,7),att,'UniformOutput',0));
ploty([att{1}(:,1),100*matdiv(matadd(sampl1(:,2:end),-nanmean(sampl1(:,2:end))),nanmean(sampl1(:,2:end)))],'*-'); 
set(gca,'YTickLabelMode','auto','box','on'); grid;
datetick('x','mmmyy','keeplimits','keepticks');

yl=ylabel('ND att. relative diff. (%) with respect to mean');
set(yl,'Units','Normalized','Position',[-.05,1,0])

%% F corr. vs Time
[a b c]=grpstats([fech,temp(:,1),o3f],{year(fech),month(fech)},{'mean','sem','numel'});

fh=figure; set(fh,'tag','FI_TIME_ETC2');
errorbar(a(:,1),a(:,3),b(:,3),'Color','k','Marker','s'); 
hold on
errorbar(a(:,1),a(:,4),b(:,4),'Color','b','Marker','s'); 
errorbar(a(:,1),a(:,5),b(:,5),'Color','r','Marker','s'); 
errorbar(a(:,1),a(:,6),b(:,6),'Color','g','Marker','s'); 
% errorbar(a(:,1),a(:,7),b(:,7),'Color','m','Marker','s'); 
title(sprintf('%s\r\nETC correction vs time. Monthly means',Cal.brw_name{Cal.n_inst}));
ylabel('ETC correction');
legend(label_filter(2:end),'Location','North','orientation','horizontal');
datetick('x','mmmyy','keeplimits','keepticks'); grid;

%% Tabla
% fprintf('\r\nETC corr Monthly means: %s\r\n', Cal.brw_name{Cal.n_inst});
% tabla_data=cat(2,cellfun(@(x,y) strcat(num2str(x),' +/- ',num2str(y)),...
%                  num2cell(round(a(:,3:end))),num2cell(round(b(:,3:end))),'UniformOutput',0),...
%                  cellstr(num2str(c(:,1))));
% displaytable(tabla_data,{'ETC corr(FW#21)','ETC corr(FW#22)','ETC corr(FW#23)','ETC corr(FW#24)','ETC corr(FW#25)','N'},...
%              15,'.0f',cellstr(datestr(a(:,1),1)));
%% Output
o3f=[fech,temp(:,1),o3f];
